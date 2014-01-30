package com.gamestudiohx.babylonhx.lights;

import com.gamestudiohx.babylonhx.lights.shadows.ShadowGenerator;
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

class HemisphericLight extends Light {
	
	public var direction:Vector3;
	public var groundColor:Color3;
	
	public var _worldMatrix:Matrix;
	

	public function new(name:String, direction:Vector3, scene:Scene) {
		super(name, scene);
		
		this.direction = direction;
        this.diffuse = new Color3(1.0, 1.0, 1.0);
        this.specular = new Color3(1.0, 1.0, 1.0);
        this.groundColor = new Color3(0.0, 0.0, 0.0);
	}
	
	override public function getShadowGenerator():ShadowGenerator {
        return null;
    }
	
	override inline public function transferToEffect(effect:Effect, directionUniformName:String = "", groundColorUniformName:String = "") {
        var normalizeDirection:Vector3 = Vector3.Normalize(this.direction);
        effect.setFloat4(directionUniformName, normalizeDirection.x, normalizeDirection.y, normalizeDirection.z, 0);
        effect.setColor3(groundColorUniformName, this.groundColor.scale(this.intensity));
    }
	
	override inline public function _getWorldMatrix():Matrix {
        if (this._worldMatrix == null) {
            this._worldMatrix = Matrix.Identity();
        }

        return this._worldMatrix;
    }
	
}
