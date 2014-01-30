package com.gamestudiohx.babylonhx.lights;

import com.gamestudiohx.babylonhx.lights.shadows.ShadowGenerator;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.Node;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Color3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.animations.Animation;
import com.gamestudiohx.babylonhx.mesh.Mesh;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Light extends Node {
			
	public var intensity:Float = 1.0;
	public var diffuse:Color3;
	public var specular:Color3;
	public var animations:Array<Animation>;		
	public var excludedMeshes:Array<Mesh>;		
	
	public var _shadowGenerator:ShadowGenerator;	
	public var _parentedWorldMatrix:Matrix;
	public var _childrendFlag:Bool;
		

	public function new(name:String, scene:Scene) {
		super(scene);
		
		this.name = name;
        this.id = name;
        this._childrenFlag = 1;
		
        this._scene = scene;

        _scene.lights.push(this);
        
        // Animations
        this.animations = [];
        
        // Exclusions
        this.excludedMeshes = [];
	}
	
	public function getScene():Scene {
		return this._scene;
	}
	
	public function getShadowGenerator():ShadowGenerator {
		return this._shadowGenerator;
	}
	
	public function transferToEffect(effect:Effect, positionUniformName:String = "", directionUniformName:String = ""):Void {
		
    }
	
	public function _getWorldMatrix():Matrix {
		return Matrix.Zero();
	}
	
	override public function getWorldMatrix():Matrix {
		var worldMatrix:Matrix = this._getWorldMatrix();

        if (this.parent != null && this.parent.getWorldMatrix() != null) {
            if (this._parentedWorldMatrix == null) {
                this._parentedWorldMatrix = Matrix.Identity();
            }

            worldMatrix.multiplyToRef(this.parent.getWorldMatrix(), this._parentedWorldMatrix);

            return this._parentedWorldMatrix;
        }

        return worldMatrix;
	}
	
	public function dispose() {
        if (this._shadowGenerator != null) {
            this._shadowGenerator.dispose();
            this._shadowGenerator = null;
        }
        
        // Remove from scene
        var index = Lambda.indexOf(this._scene.lights, this);
        this._scene.lights.splice(index, 1);
    }
	
}
