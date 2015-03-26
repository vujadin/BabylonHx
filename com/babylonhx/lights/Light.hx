package com.babylonhx.lights;

import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Light') class Light extends Node {
	
	public var diffuse:Color3 = new Color3(1.0, 1.0, 1.0);
	public var specular:Color3 = new Color3(1.0, 1.0, 1.0);
	public var intensity:Float = 1.0;
	public var range:Float = Math.POSITIVE_INFINITY;
	public var includeOnlyWithLayerMask:Int = 0;
	public var includedOnlyMeshes:Array<AbstractMesh> = [];
	public var excludedMeshes:Array<AbstractMesh> = [];

	public var _shadowGenerator:ShadowGenerator;
	private var _parentedWorldMatrix:Matrix;
	public var _excludedMeshesIds:Array<String> = [];
	public var _includedOnlyMeshesIds:Array<String> = [];
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		scene.addLight(this);
	}

	public function getShadowGenerator():ShadowGenerator {
		return this._shadowGenerator;
	}
	
	public function getAbsolutePosition():Vector3 {
		return Vector3.Zero();
	}

	public function transferToEffect(effect:Effect, ?uniformName0:String, ?uniformName1:String):Void {
		// to be overriden
	}

	public function _getWorldMatrix():Matrix {
		return Matrix.Identity();
	}

	public function canAffectMesh(mesh:AbstractMesh):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this.includedOnlyMeshes.length > 0 && this.includedOnlyMeshes.indexOf(mesh) == -1) {
			return false;
		}
		
		if (this.excludedMeshes.length > 0 && this.excludedMeshes.indexOf(mesh) != -1) {
			return false;
		}
		
		if (this.includeOnlyWithLayerMask != 0 && this.includeOnlyWithLayerMask != mesh.layerMask){
            return false;
        }
		
		return true;
	}

	override public function getWorldMatrix():Matrix {
		this._currentRenderId = this.getScene().getRenderId();
		
		var worldMatrix = this._getWorldMatrix();
		
		if (this.parent != null && this.parent.getWorldMatrix() != null) {
			if (this._parentedWorldMatrix == null) {
				this._parentedWorldMatrix = Matrix.Identity();
			}
			
			worldMatrix.multiplyToRef(this.parent.getWorldMatrix(), this._parentedWorldMatrix);
			
			return this._parentedWorldMatrix;
		}
		
		return worldMatrix;
	}

	public function dispose():Void {
		if (this._shadowGenerator != null) {
			this._shadowGenerator.dispose();
			this._shadowGenerator = null;
		}
		
		// Remove from scene
		this.getScene().removeLight(this);
	}
	
}
