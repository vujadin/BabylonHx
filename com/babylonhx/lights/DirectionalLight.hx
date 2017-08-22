package com.babylonhx.lights;

import com.babylonhx.materials.Effect;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.DirectionalLight') class DirectionalLight extends ShadowLight {

	private var _shadowFrustumSize:Float = 0;
	/**
	 * Fix frustum size for the shadow generation. This is disabled if the value is 0.
	 */
	@serialize()
	public var shadowFrustumSize(get, set):Float;
	inline private function get_shadowFrustumSize():Float {
		return this._shadowFrustumSize;
	}
	/**
	 * Specifies a fix frustum size for the shadow generation.
	 */
	private function set_shadowFrustumSize(value:Float):Float {
		this._shadowFrustumSize = value;
		this.forceProjectionMatrixCompute();
		return value;
	}

	@serialize()
	private var _shadowOrthoScale:Float = 0.5;
	public var shadowOrthoScale(get, set):Float;
	inline private function get_shadowOrthoScale():Float {
		return this._shadowOrthoScale;
	}
	inline private function set_shadowOrthoScale(value:Float):Float {
		this._shadowOrthoScale = value;
		this.forceProjectionMatrixCompute();
		return value;
	}

	@serialize()
	public var autoUpdateExtends:Bool = true;

	// Cache
	private var _orthoLeft = Math.POSITIVE_INFINITY;
	private var _orthoRight = Math.NEGATIVE_INFINITY;
	private var _orthoTop = Math.NEGATIVE_INFINITY;
	private var _orthoBottom = Math.POSITIVE_INFINITY;
	

	/**
	 * Creates a DirectionalLight object in the scene, oriented towards the passed direction (Vector3).  
	 * The directional light is emitted from everywhere in the given direction.  
	 * It can cast shawdows.  
	 * Documentation : http://doc.babylonjs.com/tutorials/lights  
	 */
	public function new(name:String, direction:Vector3, scene:Scene) {
		super(name, scene);
		this.position = direction.scale(-1.0);
		this.direction = direction;
	}

	/**
	 * Returns the string "DirectionalLight".  
	 */
	override public function getClassName():String {
		return "DirectionalLight";
	}

	/**
	 * Returns the integer 1.
	 */
	override public function getTypeID():Int {
		return Light.LIGHTTYPEID_DIRECTIONALLIGHT;
	}

	/**
	 * Sets the passed matrix "matrix" as projection matrix for the shadows cast by the light according to the passed view matrix.  
	 * Returns the DirectionalLight Shadow projection matrix.
	 */
	override public function _setDefaultShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) {
		if (this.shadowFrustumSize > 0) {
			this._setDefaultFixedFrustumShadowProjectionMatrix(matrix, viewMatrix);
		}
		else {
			this._setDefaultAutoExtendShadowProjectionMatrix(matrix, viewMatrix, renderList);
		}
	}

	/**
	 * Sets the passed matrix "matrix" as fixed frustum projection matrix for the shadows cast by the light according to the passed view matrix.
	 * Returns the DirectionalLight Shadow projection matrix.
	 */
	public function _setDefaultFixedFrustumShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix) {
		var activeCamera = this.getScene().activeCamera;
		
		Matrix.OrthoLHToRef(this.shadowFrustumSize, this.shadowFrustumSize,
			this.shadowMinZ != Math.NEGATIVE_INFINITY ? this.shadowMinZ : activeCamera.minZ, this.shadowMaxZ != Math.POSITIVE_INFINITY ? this.shadowMaxZ : activeCamera.maxZ, matrix);
	}

	/**
	 * Sets the passed matrix "matrix" as auto extend projection matrix for the shadows cast by the light according to the passed view matrix.  
	 * Returns the DirectionalLight Shadow projection matrix.
	 */
	public function _setDefaultAutoExtendShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) {
		var activeCamera = this.getScene().activeCamera;
		
		// Check extends
		if (this.autoUpdateExtends || this._orthoLeft == Math.POSITIVE_INFINITY) {
			var tempVector3 = Vector3.Zero();
			
			this._orthoLeft = Math.POSITIVE_INFINITY;
			this._orthoRight = Math.NEGATIVE_INFINITY;
			this._orthoTop = Math.NEGATIVE_INFINITY;
			this._orthoBottom = Math.POSITIVE_INFINITY;
			
			for (meshIndex in 0...renderList.length) {
				var mesh = renderList[meshIndex];
				
				if (mesh == null) {
					continue;
				}
				
				var boundingInfo = mesh.getBoundingInfo();
				
				if (boundingInfo == null) {
					continue;
				}
				
				var boundingBox = boundingInfo.boundingBox;
				
				for (index in 0...boundingBox.vectorsWorld.length) {
					Vector3.TransformCoordinatesToRef(boundingBox.vectorsWorld[index], viewMatrix, tempVector3);
					
					if (tempVector3.x < this._orthoLeft) {
						this._orthoLeft = tempVector3.x;
					}
					if (tempVector3.y < this._orthoBottom) {
						this._orthoBottom = tempVector3.y;
					}
					
					if (tempVector3.x > this._orthoRight) {
						this._orthoRight = tempVector3.x;
					}
					if (tempVector3.y > this._orthoTop) {
						this._orthoTop = tempVector3.y;
					}
				}
			}
		}
		
		var xOffset = this._orthoRight - this._orthoLeft;
		var yOffset = this._orthoTop - this._orthoBottom;
		
		Matrix.OrthoOffCenterLHToRef(this._orthoLeft - xOffset * this.shadowOrthoScale, this._orthoRight + xOffset * this.shadowOrthoScale,
			this._orthoBottom - yOffset * this.shadowOrthoScale, this._orthoTop + yOffset * this.shadowOrthoScale,
			this.shadowMinZ != Math.NEGATIVE_INFINITY ? this.shadowMinZ : activeCamera.minZ, this.shadowMaxZ != Math.POSITIVE_INFINITY ? this.shadowMaxZ : activeCamera.maxZ, matrix);
	}

	override public function _buildUniformLayout() {
		this._uniformBuffer.addUniform("vLightData", 4);
		this._uniformBuffer.addUniform("vLightDiffuse", 4);
		this._uniformBuffer.addUniform("vLightSpecular", 3);
		this._uniformBuffer.addUniform("shadowsInfo", 3);
		this._uniformBuffer.addUniform("depthValues", 2);
		this._uniformBuffer.create();
	}

	/**
	 * Sets the passed Effect object with the DirectionalLight transformed position (or position if not parented) and the passed name.  
	 * Returns the DirectionalLight.  
	 */
	override public function transferToEffect(effect:Effect, lightIndex:String):DirectionalLight {
		if (this.computeTransformedInformation()) {
			this._uniformBuffer.updateFloat4("vLightData", this.transformedDirection.x, this.transformedDirection.y, this.transformedDirection.z, 1, lightIndex);
			return this;
		}
		this._uniformBuffer.updateFloat4("vLightData", this.direction.x, this.direction.y, this.direction.z, 1, lightIndex);
		return this;
	}

	/**
	 * Gets the minZ used for shadow according to both the scene and the light.
	 * 
	 * Values are fixed on directional lights as it relies on an ortho projection hence the need to convert being
	 * -1 and 1 to 0 and 1 doing (depth + min) / (min + max) -> (depth + 1) / (1 + 1) -> (depth * 0.5) + 0.5.
	 * @param activeCamera 
	 */
	override public function getDepthMinZ(activeCamera:Camera):Float {
		return 1;
	}

	/**
	 * Gets the maxZ used for shadow according to both the scene and the light.
	 * 
	 * Values are fixed on directional lights as it relies on an ortho projection hence the need to convert being
	 * -1 and 1 to 0 and 1 doing (depth + min) / (min + max) -> (depth + 1) / (1 + 1) -> (depth * 0.5) + 0.5.
	 * @param activeCamera 
	 */
	override public function getDepthMaxZ(activeCamera:Camera):Float {
		return 1;
	}
	
}
