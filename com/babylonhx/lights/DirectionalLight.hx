package com.babylonhx.lights;

import com.babylonhx.materials.Effect;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.DirectionalLight') class DirectionalLight extends Light implements IShadowLight {
	
	public var position:Vector3;
	public var direction:Vector3;

	private var _transformedDirection:Vector3;
	public var transformedPosition:Vector3;
	private var _worldMatrix:Matrix;
	

	public function new(name:String, direction:Vector3, scene:Scene) {
		super(name, scene);
		
		this.direction = direction;
		this.position = direction.scale(-1);
	}
	
	override public function getAbsolutePosition():Vector3 {
		return this.transformedPosition != null ? this.transformedPosition : this.position;
	}

	public function setDirectionToTarget(target:Vector3):Vector3 {
		this.direction = Vector3.Normalize(target.subtract(this.position));
		return this.direction;
	}

	public function computeTransformedPosition():Bool {
		if (this.parent != null && this.parent.getWorldMatrix != null) {
			if (this.transformedPosition == null) {
				this.transformedPosition = Vector3.Zero();
			}
			
			Vector3.TransformCoordinatesToRef(this.position, this.parent.getWorldMatrix(), this.transformedPosition);
			return true;
		}
		
		return false;
	}

	override public function transferToEffect(effect:Effect, ?directionUniformName:String, ?extra_UNUSED_PARAM:String):Void {
		if (this.parent != null && this.parent.getWorldMatrix != null) {
			if (this._transformedDirection == null) {
				this._transformedDirection = Vector3.Zero();
			}
			
			Vector3.TransformNormalToRef(this.direction, this.parent.getWorldMatrix(), this._transformedDirection);
			effect.setFloat4(directionUniformName, this._transformedDirection.x, this._transformedDirection.y, this._transformedDirection.z, 1);
			
			return;
		}
		
		effect.setFloat4(directionUniformName, this.direction.x, this.direction.y, this.direction.z, 1);
	}

	override public function _getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		
		Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);
		
		return this._worldMatrix;
	}
	
}
