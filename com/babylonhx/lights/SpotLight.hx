package com.babylonhx.lights;

import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('SpotLight') class SpotLight extends ShadowLight {
	
	private var _angle:Float;

	@serialize()
	public var angle(get, set):Float;
	private function get_angle():Float {
		return this._angle;
	}
	private function set_angle(value:Float):Float {
		this._angle = value;
		this.forceProjectionMatrixCompute();
		return value;
	}
	
	private var _shadowAngleScale:Float = 1;
	@serialize()
	public var shadowAngleScale(get, set):Float;
	/**
	 * Allows scaling the angle of the light for shadow generation only.
	 */
	inline private function get_shadowAngleScale():Float {
		return this._shadowAngleScale;
	}
	/**
	 * Allows scaling the angle of the light for shadow generation only.
	 */
	private function set_shadowAngleScale(value:Float):Float {
		this._shadowAngleScale = value;
		this.forceProjectionMatrixCompute();
		return value;
	}

	@serialize()
	public var exponent:Float;
	
	
	/**
	 * Creates a SpotLight object in the scene with the passed parameters :   
	 * - `position` (Vector3) is the initial SpotLight position,  
	 * - `direction` (Vector3) is the initial SpotLight direction,  
	 * - `angle` (float, in radians) is the spot light cone angle,
	 * - `exponent` (float) is the light decay speed with the distance from the emission spot.  
	 * A spot light is a simply light oriented cone.   
	 * It can cast shadows.  
	 * Documentation : http://doc.babylonjs.com/tutorials/lights  
	 */
	public function new(name:String, position:Vector3, direction:Vector3, angle:Float, exponent:Float, scene:Scene) {
		super(name, scene);
		
		this.position = position;
		this.direction = direction;
		this.angle = angle;
		this.exponent = exponent;
	}

	/**
	 * Returns the string "SpotLight".
	 */
	override public function getClassName():String {
		return "SpotLight";
	}

	/**
	 * Returns the integer 2.
	 */
	override public function getTypeID():Int {
		return Light.LIGHTTYPEID_SPOTLIGHT;
	}

	/**
	 * Sets the passed matrix "matrix" as perspective projection matrix for the shadows and the passed view matrix with the fov equal to the SpotLight angle and and aspect ratio of 1.0.  
	 * Returns the SpotLight.  
	 */
	override public function _setDefaultShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) {
		var activeCamera = this.getScene().activeCamera;
		
		//this._shadowAngleScale = this._shadowAngleScale || 1;
		var angle = this._shadowAngleScale * this._angle;
		
		Matrix.PerspectiveFovLHToRef(angle, 1.0, this.getDepthMinZ(activeCamera), this.getDepthMaxZ(activeCamera), matrix);
	}

	override public function _buildUniformLayout() {
		this._uniformBuffer.addUniform("vLightData", 4);
		this._uniformBuffer.addUniform("vLightDiffuse", 4);
		this._uniformBuffer.addUniform("vLightSpecular", 3);
		this._uniformBuffer.addUniform("vLightDirection", 3);
		this._uniformBuffer.addUniform("shadowsInfo", 3);
		this._uniformBuffer.addUniform("depthValues", 2);
		this._uniformBuffer.create();
	}

	/**
	 * Sets the passed Effect object with the SpotLight transfomed position (or position if not parented) and normalized direction.  
	 * Return the SpotLight.   
	 */
	override public function transferToEffect(effect:Effect, lightIndex:String):Light {
		var normalizeDirection:Vector3 = null;
		
		if (this.computeTransformedInformation()) {
			this._uniformBuffer.updateFloat4("vLightData",
				this.transformedPosition.x,
				this.transformedPosition.y,
				this.transformedPosition.z,
				this.exponent,
				lightIndex);
				
			normalizeDirection = Vector3.Normalize(this.transformedDirection);
		} 
		else {
			this._uniformBuffer.updateFloat4("vLightData",
				this.position.x,
				this.position.y,
				this.position.z,
				this.exponent,
				lightIndex);
				
			normalizeDirection = Vector3.Normalize(this.direction);
		}
		
		this._uniformBuffer.updateFloat4("vLightDirection",
			normalizeDirection.x,
			normalizeDirection.y,
			normalizeDirection.z,
			Math.cos(this.angle * 0.5),
			lightIndex);
		return this;
	}
	
}
