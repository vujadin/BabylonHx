package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Base implementation of @see IShadowLight
 * It groups all the common behaviour in order to reduce dupplication and better follow the DRY pattern.
 */
class ShadowLight extends Light implements IShadowLight {

	public function _setDefaultShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) { }

	private var _position:Vector3;
	public function _setPosition(value:Vector3) {
		this._position = value;
	}
	
	public var position(get, set):Vector3;
	/**
	 * Sets the position the shadow will be casted from. Also use as the light position for both 
	 * point and spot lights.
	 */
	@serializeAsVector3()
	inline function get_position():Vector3 {
		return this._position;
	}
	/**
	 * Sets the position the shadow will be casted from. Also use as the light position for both 
	 * point and spot lights.
	 */
	inline function set_position(value:Vector3):Vector3 {
		this._setPosition(value);
		return value;
	}

	private var _direction:Vector3;
	public function _setDirection(value:Vector3) {
		this._direction = value;
	}
	
	public var direction(get, set):Vector3;
	/**
	 * In 2d mode (needCube being false), gets the direction used to cast the shadow.
	 * Also use as the light direction on spot and directional lights.
	 */
	@serializeAsVector3()
	inline function get_direction():Vector3 {
		return this._direction;
	}
	/**
	 * In 2d mode (needCube being false), sets the direction used to cast the shadow.
	 * Also use as the light direction on spot and directional lights.
	 */
	function set_direction(value:Vector3):Vector3 {
		this._setDirection(value);
		return value;
	}

	private var _shadowMinZ:Float;
	
	public var shadowMinZ(get, set):Float;
	/**
	 * Gets the shadow projection clipping minimum z value.
	 */
	@serialize()
	inline function get_shadowMinZ():Float {
		return this._shadowMinZ;
	}
	/**
	 * Sets the shadow projection clipping minimum z value.
	 */
	inline function set_shadowMinZ(value:Float):Float {
		this._shadowMinZ = value;
		this.forceProjectionMatrixCompute();
		return value;
	}

	private var _shadowMaxZ:Float;
	
	public var shadowMaxZ(get, set):Float;
	/**
	 * Sets the shadow projection clipping maximum z value.
	 */
	@serialize()
	inline function get_shadowMaxZ():Float {
		return this._shadowMaxZ;
	}
	/**
	 * Gets the shadow projection clipping maximum z value.
	 */
	inline function set_shadowMaxZ(value:Float):Float {
		this._shadowMaxZ = value;
		this.forceProjectionMatrixCompute();
		return value;
	}

	/**
	 * Callback defining a custom Projection Matrix Builder.
	 * This can be used to override the default projection matrix computation.
	 */
	public var customProjectionMatrixBuilder:Matrix->Array<AbstractMesh>->Matrix->Void = null;

	/**
	 * The transformed position. Position of the light in world space taking parenting in account.
	 */
	public var transformedPosition:Vector3;

	/**
	 * The transformed direction. Direction of the light in world space taking parenting in account.
	 */
	public var transformedDirection:Vector3;

	private var _worldMatrix:Matrix;
	private var _needProjectionMatrixCompute:Bool = true;

	/**
	 * Computes the transformed information (transformedPosition and transformedDirection in World space) of the current light
	 * @returns true if the information has been computed, false if it does not need to (no parenting)
	 */
	public function computeTransformedInformation():Bool {
		if (this.parent != null && this.parent.getWorldMatrix() != null) {
			if (this.transformedPosition == null) {
				this.transformedPosition = Vector3.Zero();
			}
			Vector3.TransformCoordinatesToRef(this.position, this.parent.getWorldMatrix(), this.transformedPosition);
			
			// In case the direction is present.
			if (this.direction != null) {
				if (this.transformedDirection == null) {
					this.transformedDirection = Vector3.Zero();
				}
				Vector3.TransformNormalToRef(this.direction, this.parent.getWorldMatrix(), this.transformedDirection);
			}
			return true;
		}
		return false;
	}

	/**
	 * Return the depth scale used for the shadow map.
	 */
	public function getDepthScale():Float {
		return 50.0;
	}

	/**
	 * Returns the light direction (Vector3) for any passed face index.
	 */
	public function getShadowDirection(?faceIndex:Int):Vector3 {
		return this.transformedDirection != null ? this.transformedDirection : this.direction;
	}

	/**
	 * Returns the ShadowLight absolute position in the World.
	 */
	override public function getAbsolutePosition():Vector3 {
		return this.transformedPosition != null ? this.transformedPosition : this.position;
	}

	/**
	 * Sets the ShadowLight direction toward the passed target (Vector3).
	 * Returns the updated ShadowLight direction (Vector3).
	 */
	public function setDirectionToTarget(target:Vector3):Vector3 {
		this.direction = Vector3.Normalize(target.subtract(this.position));
		return this.direction;
	}

	/**
	 * Returns the light rotation (Vector3).
	 */
	public function getRotation():Vector3 {
		this.direction.normalize();
		var xaxis = Vector3.Cross(this.direction, Axis.Y);
		var yaxis = Vector3.Cross(xaxis, this.direction);
		return Vector3.RotationFromAxis(xaxis, yaxis, this.direction);
	}

	/**
	 * Boolean : false by default.
	 */
	public function needCube():Bool {
		return false;
	}

	/**
	 * Specifies wether or not the projection matrix should be recomputed this frame.
	 */
	public function needProjectionMatrixCompute():Bool {
		return this._needProjectionMatrixCompute;
	}

	/**
	 * Forces the shadow generator to recompute the projection matrix even if position and direction did not changed.
	 */
	public function forceProjectionMatrixCompute() {
		this._needProjectionMatrixCompute = true;
	}

	/**
	 * Get the world matrix of the sahdow lights.
	 */
	override public function _getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		
		Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);
		
		return this._worldMatrix;
	}
	
	/**
	 * Gets the minZ used for shadow according to both the scene and the light.
	 * @param activeCamera 
	 */
	public function getDepthMinZ(activeCamera:Camera):Float {
		return this.shadowMinZ != Math.NEGATIVE_INFINITY ? this.shadowMinZ : activeCamera.minZ;
	}

	/**
	 * Gets the maxZ used for shadow according to both the scene and the light.
	 * @param activeCamera 
	 */
	public function getDepthMaxZ(activeCamera:Camera):Float {
		return this.shadowMaxZ != Math.POSITIVE_INFINITY ? this.shadowMaxZ : activeCamera.maxZ;
	}

	/**
	 * Sets the projection matrix according to the type of light and custom projection matrix definition.
	 * Returns the light.
	 */
	public function setShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>):IShadowLight {
		if (this.customProjectionMatrixBuilder != null) {
			this.customProjectionMatrixBuilder(viewMatrix, renderList, matrix);
		}
		else {
			this._setDefaultShadowProjectionMatrix(matrix, viewMatrix, renderList);
		}
		return this;
	}
	
}
