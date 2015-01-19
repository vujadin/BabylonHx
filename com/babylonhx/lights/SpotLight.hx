package com.babylonhx.lights;

import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SpotLight') class SpotLight extends Light {

	private var _transformedDirection:Vector3;
	private var _transformedPosition:Vector3;
	private var _worldMatrix:Matrix;
	
	public var position:Vector3;
	public var direction:Vector3;
	public var angle:Float;
	public var exponent:Float;
	

	public function new(name:String, position:Vector3, direction:Vector3, angle:Float, exponent:Float, scene:Scene) {
		super(name, scene);
		
		this.position = position;
		this.direction = direction;
		this.angle = angle;
		this.exponent = exponent;
	}

	public function setDirectionToTarget(target:Vector3):Vector3 {
		this.direction = Vector3.Normalize(target.subtract(this.position));
		return this.direction;
	}
	
	override public function getAbsolutePosition():Vector3 {
		return this._transformedPosition != null ? this._transformedPosition : this.position;
	}

	override public function transferToEffect(effect:Effect, ?positionUniformName:String, ?directionUniformName:String):Void {
		var normalizeDirection:Vector3 = Vector3.Zero();

		if (this.parent != null && this.parent.getWorldMatrix() != null) {
            if (this._transformedDirection == null) {
                this._transformedDirection = Vector3.Zero();
            }
            if (this._transformedPosition == null) {
                this._transformedPosition = Vector3.Zero();
            }

			var parentWorldMatrix = this.parent.getWorldMatrix();

			Vector3.TransformCoordinatesToRef(this.position, parentWorldMatrix, this._transformedPosition);
			Vector3.TransformNormalToRef(this.direction, parentWorldMatrix, this._transformedDirection);

			effect.setFloat4(positionUniformName, this._transformedPosition.x, this._transformedPosition.y, this._transformedPosition.z, this.exponent);
			normalizeDirection = Vector3.Normalize(this._transformedDirection);
		} else {
			effect.setFloat4(positionUniformName, this.position.x, this.position.y, this.position.z, this.exponent);
			normalizeDirection = Vector3.Normalize(this.direction);
		}

		effect.setFloat4(directionUniformName, normalizeDirection.x, normalizeDirection.y, normalizeDirection.z, Math.cos(this.angle * 0.5));
	}

	override public function _getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}

		Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);

		return this._worldMatrix;
	}
	
}
