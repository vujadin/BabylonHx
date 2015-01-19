package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PointLight') class PointLight extends Light {
	
	private var _worldMatrix:Matrix;
	private var _transformedPosition:Vector3;
	
	public var position:Vector3;
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, scene);
		this.position = position;
	}
	
	override public function getAbsolutePosition():Vector3 {
		return this._transformedPosition != null ? this._transformedPosition : this.position;
	}

	override public function transferToEffect(effect:Effect, ?positionUniformName:String, ?extra_UNUSED_PARAM:String):Void {
		if (this.parent != null && this.parent.getWorldMatrix() != null) {
			if (this._transformedPosition == null) {
				this._transformedPosition = Vector3.Zero();
			}
			
			Vector3.TransformCoordinatesToRef(this.position, this.parent.getWorldMatrix(), this._transformedPosition);
			effect.setFloat4(positionUniformName, this._transformedPosition.x, this._transformedPosition.y, this._transformedPosition.z, 0);
			
			return;
		}
		
		effect.setFloat4(positionUniformName, this.position.x, this.position.y, this.position.z, 0);
	}

	override public function getShadowGenerator():ShadowGenerator {
		return null;
	}

	override public function _getWorldMatrix():Matrix {
		if (this._worldMatrix == null) {
			this._worldMatrix = Matrix.Identity();
		}
		
		Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);
		
		return this._worldMatrix;
	}
	
}
