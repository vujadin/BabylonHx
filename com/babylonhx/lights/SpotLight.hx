package com.babylonhx.lights;

import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * A spot light is defined by a position, a direction, an angle, and an exponent. 
 * These values define a cone of light starting from the position, emitting toward the direction.
 * The angle, in radians, defines the size (field of illumination) of the spotlight's conical beam, 
 * and the exponent defines the speed of the decay of the light with distance (reach).
 * Documentation: https://doc.babylonjs.com/babylon101/lights
 */
@:expose('SpotLight') class SpotLight extends ShadowLight {
	/*
		upVector , rightVector and direction will form the coordinate system for this spot light. 
		These three vectors will be used as projection matrix when doing texture projection.
		
		Also we have the following rules always holds:
		direction cross up   = right
		right cross direction = up
		up cross right       = forward
		light_near and light_far will control the range of the texture projection. If a plane is 
		out of the range in spot light space, there is no texture projection.
	*/
	private var _angle:Float;

	@serialize()
	public var angle(get, set):Float;
	/**
	 * Gets the cone angle of the spot light in Radians.
	 */
	private function get_angle():Float {
		return this._angle;
	}
	/**
	 * Sets the cone angle of the spot light in Radians.
	 */
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

	/**
	 * The light decay speed with the distance from the emission spot.
	 */
	@serialize()
	public var exponent:Float;
	
	private var _projectionTextureMatrix:Matrix = Matrix.Zero();
	
	public var projectionTextureMatrix(get, never):Matrix;
	/**
	* Allows reading the projecton texture
	*/
	inline function get_projectionTextureMatrix():Matrix {
		return this._projectionTextureMatrix;
	}

	private var _projectionTextureLightNear:Float = 1e-6;
	
	public var projectionTextureLightNear(get, set):Float;
	/**
	 * Gets the near clip of the Spotlight for texture projection.
	 */
	@serialize()
	inline function get_projectionTextureLightNear():Float {
		return this._projectionTextureLightNear;
	}
	/**
	 * Sets the near clip of the Spotlight for texture projection.
	 */
	inline function set_projectionTextureLightNear(value:Float):Float {
		this._projectionTextureLightNear = value;
		this._projectionTextureProjectionLightDirty = true;
		return value;
	}

	private var _projectionTextureLightFar:Float = 1000.0;
	
	public var projectionTextureLightFar(get, set):Float;
	/**
	 * Gets the far clip of the Spotlight for texture projection.
	 */
	@serialize()
	inline function get_projectionTextureLightFar():Float {
		return this._projectionTextureLightFar;
	}
	/**
	 * Sets the far clip of the Spotlight for texture projection.
	 */
	inline function set_projectionTextureLightFar(value:Float):Float {
		this._projectionTextureLightFar = value;
		this._projectionTextureProjectionLightDirty = true;
		return value;
	}

	private var _projectionTextureUpDirection:Vector3 = Vector3.Up();
	
	public var projectionTextureUpDirection(get, set):Vector3;
	/**
	 * Gets the Up vector of the Spotlight for texture projection.
	 */
	@serialize()
	inline function get_projectionTextureUpDirection():Vector3 {
		return this._projectionTextureUpDirection;
	}
	/**
	 * Sets the Up vector of the Spotlight for texture projection.
	 */
	inline function set_projectionTextureUpDirection(value:Vector3):Vector3 {
		this._projectionTextureUpDirection = value;
		this._projectionTextureProjectionLightDirty = true;
		return value;
	}

	@serializeAsTexture("projectedLightTexture")
	private var _projectionTexture:BaseTexture;
	
	public var projectionTexture(get, set):BaseTexture;
	/** 
	 * Gets the projection texture of the light.
	*/
	inline function get_projectionTexture():BaseTexture {
		return this._projectionTexture;
	}
	/**
	* Sets the projection texture of the light.
	*/
	inline function set_projectionTexture(value:BaseTexture):BaseTexture {
		this._projectionTexture = value;
		this._projectionTextureDirty = true;
		return value;
	}

	private var _projectionTextureViewLightDirty:Bool = true;
	private var _projectionTextureProjectionLightDirty:Bool = true;
	private var _projectionTextureDirty:Bool = true;
	private var _projectionTextureViewTargetVector:Vector3 = Vector3.Zero();
	private var _projectionTextureViewLightMatrix:Matrix = Matrix.Zero();
	private var _projectionTextureProjectionLightMatrix:Matrix = Matrix.Zero();
	private var _projectionTextureScalingMatrix:Matrix = Matrix.FromValues(
		0.5, 0.0, 0.0, 0.0,
		0.0, 0.5, 0.0, 0.0,
		0.0, 0.0, 0.5, 0.0,
		0.5, 0.5, 0.5, 1.0
	);
	
	
	/**
	 * Creates a SpotLight object in the scene. A spot light is a simply light oriented cone.
	 * It can cast shadows.
	 * Documentation : http://doc.babylonjs.com/tutorials/lights
	 * @param name The light friendly name
	 * @param position The position of the spot light in the scene
	 * @param direction The direction of the light in the scene
	 * @param angle The cone angle of the light in Radians
	 * @param exponent The light decay speed with the distance from the emission spot
	 * @param scene The scene the lights belongs to
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
	 * Overrides the direction setter to recompute the projection texture view light Matrix.
	 */
	override public function _setDirection(value:Vector3) {
		super._setDirection(value);
		this._projectionTextureViewLightDirty = true;
	}

	/**
	 * Overrides the position setter to recompute the projection texture view light Matrix.
	 */
	override public function _setPosition(value:Vector3) {
		super._setPosition(value);
		this._projectionTextureViewLightDirty = true;
	}

	/**
	 * Sets the passed matrix "matrix" as perspective projection matrix for the shadows and the passed view matrix with the fov equal to the SpotLight angle and and aspect ratio of 1.0.  
	 * Returns the SpotLight.  
	 */
	override public function _setDefaultShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) {
		var activeCamera = this.getScene().activeCamera;
		
		if (activeCamera == null) {
			return;
		}
		
		//this._shadowAngleScale = this._shadowAngleScale || 1;
		var angle = this._shadowAngleScale * this._angle;
		
		Matrix.PerspectiveFovLHToRef(angle, 1.0, this.getDepthMinZ(activeCamera), this.getDepthMaxZ(activeCamera), matrix);
	}
	
	private function _computeProjectionTextureViewLightMatrix() {
		this._projectionTextureViewLightDirty = false;
		this._projectionTextureDirty = true;
		
		this.position.addToRef(this.direction, this._projectionTextureViewTargetVector);
		Matrix.LookAtLHToRef(this.position, 
			this._projectionTextureViewTargetVector, 
			this._projectionTextureUpDirection, 
			this._projectionTextureViewLightMatrix);
	}

	private function _computeProjectionTextureProjectionLightMatrix() {
		this._projectionTextureProjectionLightDirty = false;
		this._projectionTextureDirty = true;
		
		var light_far = this.projectionTextureLightFar;
		var light_near = this.projectionTextureLightNear;
		
		var P = light_far / (light_far - light_near);
		var Q = - P * light_near;
		var S = 1.0 / Math.tan(this._angle / 2.0);
		var A = 1.0;
		
		Matrix.FromValuesToRef(S / A, 0.0, 0.0, 0.0,
			0.0, S, 0.0, 0.0,
			0.0, 0.0, P, 1.0,
			0.0, 0.0, Q, 0.0, this._projectionTextureProjectionLightMatrix);
	}

	/**
	 * Main function for light texture projection matrix computing.
	 */
	private function _computeProjectionTextureMatrix() {
		this._projectionTextureDirty = false;
		
		this._projectionTextureViewLightMatrix.multiplyToRef(this._projectionTextureProjectionLightMatrix, this._projectionTextureMatrix);
		this._projectionTextureMatrix.multiplyToRef(this._projectionTextureScalingMatrix, this._projectionTextureMatrix);
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
	 * @param effect The effect to update
	 * @param lightIndex The index of the light in the effect to update
	 * @returns The spot light
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
			
		if (this.projectionTexture != null && this.projectionTexture.isReady()) {
			if (this._projectionTextureViewLightDirty) {
				this._computeProjectionTextureViewLightMatrix();
			}
			if (this._projectionTextureProjectionLightDirty) {
				this._computeProjectionTextureProjectionLightMatrix();
			}
			if (this._projectionTextureDirty) {
				this._computeProjectionTextureMatrix();
			}
			effect.setMatrix("textureProjectionMatrix" + lightIndex, this._projectionTextureMatrix);
			effect.setTexture("projectionLightSampler" + lightIndex, this.projectionTexture);
		}
		
		return this;
	}
	
	/**
	 * Disposes the light and the associated resources.
	 */
	override public function dispose(_:Bool = false) {
		super.dispose();
		if (this._projectionTexture != null) {
			this._projectionTexture.dispose();
		}
	}
	
}
