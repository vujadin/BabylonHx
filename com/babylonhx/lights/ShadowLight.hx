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
class ShadowLight extends Light implements IShadowLight {

	public function _setDefaultShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>) { }

	@serializeAsVector3()
	public var position:Vector3;

	private var _direction:Vector3;
	@serializeAsVector3()
	public var direction(get, set):Vector3;
	private function get_direction():Vector3 {
		return this._direction;
	}
	private function set_direction(value:Vector3):Vector3 {
		return this._direction = value;
	}

	private var _shadowMinZ:Float = Math.NEGATIVE_INFINITY;
	@serialize()
	public var shadowMinZ(get, set):Float;
	private function get_shadowMinZ():Float {
		return this._shadowMinZ;
	}
	private function set_shadowMinZ(value:Float):Float {
		this._shadowMinZ = value;
		this.forceProjectionMatrixCompute();
		return value;
	}

	private var _shadowMaxZ:Float = Math.POSITIVE_INFINITY;
	@serialize()
	public var shadowMaxZ(get, set):Float;
	private function get_shadowMaxZ():Float {
		return this._shadowMaxZ;
	}
	private function set_shadowMaxZ(value:Float):Float {
		this._shadowMaxZ = value;
		this.forceProjectionMatrixCompute();
		return value;
	}

	public var customProjectionMatrixBuilder:Matrix->Array<AbstractMesh>->Matrix->Void = null;

	public var transformedPosition:Vector3;

	public var transformedDirection:Vector3;

	private var _worldMatrix:Matrix;
	private var _needProjectionMatrixCompute:Bool = true;

	/**
	 * Computes the light transformed position/direction in case the light is parented. Returns true if parented, else false.
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
		return 30.0;
	}

	/**
	 * Returns the light direction (Vector3) for any passed face index.
	 */
	public function getShadowDirection(?faceIndex:Int):Vector3 {
		return this.transformedDirection != null ? this.transformedDirection : this.direction;
	}

	/**
	 * Returns the DirectionalLight absolute position in the World.
	 */
	override public function getAbsolutePosition():Vector3 {
		return this.transformedPosition != null ? this.transformedPosition : this.position;
	}

	/**
	 * Sets the DirectionalLight direction toward the passed target (Vector3).
	 * Returns the updated DirectionalLight direction (Vector3).
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
