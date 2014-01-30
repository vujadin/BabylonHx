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

class SpotLight extends Light {
	
	public var _transformedPosition:Vector3;
	public var direction:Vector3;
	public var _transformedDirection:Vector3;
	public var angle:Float;
	public var exponent:Float;
	public var _worldMatrix:Matrix;

	public function new(name:String, position:Vector3, direction:Vector3, angle:Float, exponent:Float, scene:Scene) {
		super(name, scene);
		
		this.position = position;
        this.direction = direction;
        this.angle = angle;
        this.exponent = exponent;
        this.diffuse = new Color3(1.0, 1.0, 1.0);
        this.specular = new Color3(1.0, 1.0, 1.0);
	}
	
	override inline public function transferToEffect(effect:Effect, positionUniformName:String = "", directionUniformName:String = "") {
        var normalizeDirection:Vector3 = Vector3.Zero();
        
        if (this.parent != null && this.parent.getWorldMatrix() != null) {
            if (this._transformedDirection == null) {
                this._transformedDirection = Vector3.Zero();
            }
            if (this._transformedPosition == null) {
                this._transformedPosition = Vector3.Zero();
            }
            
            var parentWorldMatrix:Matrix = this.parent.getWorldMatrix();

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
	
	override inline public function _getWorldMatrix():Matrix {
        if (this._worldMatrix == null) {
            this._worldMatrix = Matrix.Identity();
        }

        Matrix.TranslationToRef(this.position.x, this.position.y, this.position.z, this._worldMatrix);

        return this._worldMatrix;
    }
	
}
