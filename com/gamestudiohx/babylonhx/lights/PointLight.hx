package com.gamestudiohx.babylonhx.lights;

import com.gamestudiohx.babylonhx.lights.shadows.ShadowGenerator;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Color3;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class PointLight extends Light {
		
	public var _worldMatrix:Matrix;
	public var _transformedPosition:Vector3;
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, scene);
		        
        this.position = position;
        this.diffuse = new Color3(1.0, 1.0, 1.0);
        this.specular = new Color3(1.0, 1.0, 1.0);
	}
	
	override inline public function transferToEffect(effect:Effect, positionUniformName:String = "", directionUniformName:String = "") {
        if (this.parent != null && this.parent.getWorldMatrix() != null) {
            if (this._transformedPosition == null) {
                this._transformedPosition = Vector3.Zero();
            }

            Vector3.TransformCoordinatesToRef(this.position, this.parent.getWorldMatrix(), this._transformedPosition);			
            effect.setFloat4(positionUniformName, this._transformedPosition.x, this._transformedPosition.y, this._transformedPosition.z, 0);
        } else {
		    effect.setFloat4(positionUniformName, this.position.x, this.position.y, this.position.z, 0);
		}
    }
	
	override public function getShadowGenerator():ShadowGenerator {
        return null;
    }
	
	override inline public function _getWorldMatrix():Matrix {
        if (this._worldMatrix == null) {
            this._worldMatrix = Matrix.Identity();
        }

        Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);

        return this._worldMatrix;
    }
	
}