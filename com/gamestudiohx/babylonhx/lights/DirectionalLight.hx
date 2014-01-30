package com.gamestudiohx.babylonhx.lights;

import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Color3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Vector3;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class DirectionalLight extends Light {
	
	public var direction:Vector3;
	
	public var _worldMatrix:Matrix;
	public var _transformedPosition:Vector3;
	public var _transformedDirection:Vector3;
	

	public function new(name:String, direction:Vector3, scene:Scene) {
		super(name, scene);
		
		this.position = direction.scale(-1);
        this.direction = direction;
        this.diffuse = new Color3(1.0, 1.0, 1.0);
        this.specular = new Color3(1.0, 1.0, 1.0);
	}
	
	inline public function _computeTransformedPosition():Bool {
		var ret = false;
        if (this.parent != null && this.parent.getWorldMatrix() != null) {
            if (this._transformedPosition == null) {
                this._transformedPosition = Vector3.Zero();
            }

            Vector3.TransformCoordinatesToRef(this.position, this.parent.getWorldMatrix(), this._transformedPosition);
            ret = true;
        }

        return ret;
    }
	
	override inline public function transferToEffect(effect:Effect, positionUniformName:String = "", directionUniformName:String = "") {
        if (this.parent != null && this.parent.getWorldMatrix() != null) {
            if (this._transformedDirection == null) {
                this._transformedDirection = Vector3.Zero();
            }

            Vector3.TransformNormalToRef(this.direction, this.parent.getWorldMatrix(), this._transformedDirection);			
            effect.setFloat4(directionUniformName, this._transformedDirection.x, this._transformedDirection.y, this._transformedDirection.z, 1);
        } else {
			effect.setFloat4(directionUniformName, this.direction.x, this.direction.y, this.direction.z, 1);
		}
    }
	
	override inline public function _getWorldMatrix():Matrix {
        if (this._worldMatrix == null) {
            this._worldMatrix = Matrix.Identity();
        }

        Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);

        return this._worldMatrix;
    }
	
}
