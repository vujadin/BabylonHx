package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.Effect;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PointLight') class PointLight extends ShadowLight {
	
	private var _shadowAngle:Float = Math.PI / 2;
	/**
	 * Getter: In case of direction provided, the shadow will not use a cube texture but simulate a spot shadow as a fallback
	 * This specifies what angle the shadow will use to be created.
	 * 
	 * It default to 90 degrees to work nicely with the cube texture generation for point lights shadow maps.
	 */
	@serialize()
	public var shadowAngle(get, set):Float;
	private function get_shadowAngle():Float {
		return this._shadowAngle;
	}
	/**
	 * Setter: In case of direction provided, the shadow will not use a cube texture but simulate a spot shadow as a fallback
	 * This specifies what angle the shadow will use to be created.
	 * 
	 * It default to 90 degrees to work nicely with the cube texture generation for point lights shadow maps.
	 */
	private function set_shadowAngle(value:Float):Float {
		this._shadowAngle = value;
		this.forceProjectionMatrixCompute();
		return value;
	}

	//public var direction(get, set):Vector3;
	//private function get_direction():Vector3 {
		//return this._direction;
	//}
	/**
	 * In case of direction provided, the shadow will not use a cube texture but simulate a spot shadow as a fallback
	 */
	override private function set_direction(value:Vector3):Vector3 {
		var previousNeedCube = this.needCube();
		this._direction = value;
		if (this.needCube() != previousNeedCube && this._shadowGenerator != null) {
			this._shadowGenerator.recreateShadowMap();
		}
		return value;
	}

	/**
	 * Creates a PointLight object from the passed name and position (Vector3) and adds it in the scene.  
	 * A PointLight emits the light in every direction.  
	 * It can cast shadows.  
	 * If the scene camera is already defined and you want to set your PointLight at the camera position, just set it :
	 * 
	 * var pointLight = new PointLight("pl", camera.position, scene);
	 * 
	 * Documentation : http://doc.babylonjs.com/tutorials/lights  
	 */
	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, scene);
		this.position = position;
	}

	/**
	 * Returns the string "PointLight"
	 */
	override public function getClassName():String {
		return "PointLight";
	}
	
	/**
	 * Returns the integer 0.  
	 */
	override public function getTypeID():Int {
		return Light.LIGHTTYPEID_POINTLIGHT;
	}

	/**
	 * Specifies wether or not the shadowmap should be a cube texture.
	 */
	override public function needCube():Bool {
		return this.direction == null;
	}

	/**
	 * Returns a new Vector3 aligned with the PointLight cube system according to the passed cube face index (integer).  
	 */
	override public function getShadowDirection(?faceIndex:Int):Vector3 {
		if (this.direction != null) {
			return super.getShadowDirection(faceIndex);
		}
		else {
			switch (faceIndex) {
				case 0:
					return new Vector3(1.0, 0.0, 0.0);
				case 1:
					return new Vector3(-1.0, 0.0, 0.0);
				case 2:
					return new Vector3(0.0, -1.0, 0.0);
				case 3:
					return new Vector3(0.0, 1.0, 0.0);
				case 4:
					return new Vector3(0.0, 0.0, 1.0);
				case 5:
					return new Vector3(0.0, 0.0, -1.0);
			}
		}
		
		return Vector3.Zero();
	}
	
	/**
	 * Sets the passed matrix "matrix" as a left-handed perspective projection matrix with the following settings : 
	 * - fov = PI / 2
	 * - aspect ratio : 1.0
	 * - z-near and far equal to the active camera minZ and maxZ.  
	 * Returns the PointLight.  
	 */
	override public function _setDefaultShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) {
		var activeCamera = this.getScene().activeCamera;
		Matrix.PerspectiveFovLHToRef(this.shadowAngle, 1.0, this.getDepthMinZ(activeCamera), this.getDepthMaxZ(activeCamera), matrix);
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
	 * Sets the passed Effect "effect" with the PointLight transformed position (or position, if none) and passed name (string).  
	 * Returns the PointLight.  
	 */
	override public function transferToEffect(effect:Effect, lightIndex:String):Light {
		if (this.computeTransformedInformation()) {
			this._uniformBuffer.updateFloat4("vLightData",
				this.transformedPosition.x,
				this.transformedPosition.y,
				this.transformedPosition.z,
				0.0,
				lightIndex); 
			return this;
		}
		
		this._uniformBuffer.updateFloat4("vLightData", this.position.x, this.position.y, this.position.z, 0, lightIndex);
		return this;
	}
	
}
