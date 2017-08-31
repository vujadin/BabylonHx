package com.babylonhx.materials;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.EffectFallbacks') class EffectFallbacks {
	
	private var _defines:Array<Array<String>> = [];
	
	private var _currentRank:Int = 32;
	private var _maxRank:Int = -1;
	
	private var _mesh:AbstractMesh;
    private var _meshRank:Int;
	
	
	public function new() {	}
	
	public function unBindMesh() {
        this._mesh = null;
    }

	public function addFallback(rank:Int, define:String):Void {
		if (this._defines[rank] == null) {
			if (rank < this._currentRank) {
				this._currentRank = rank;
			}
			
			if (rank > this._maxRank) {
				this._maxRank = rank;
			}
			
			this._defines[rank] = new Array<String>();
		}
		
		this._defines[rank].push(define);
	}
	
	public function addCPUSkinningFallback(rank:Int, mesh:AbstractMesh) {
		this._meshRank = rank;
		this._mesh = mesh;
		
		if (rank < this._currentRank) {
			this._currentRank = rank;
		}
		if (rank > this._maxRank) {
			this._maxRank = rank;
		}
	}
	
	public var isMoreFallbacks(get, never):Bool;
	private function get_isMoreFallbacks():Bool {
		return this._currentRank <= this._maxRank;
	}

	public function reduce(currentDefines:String):String {		
		// First we try to switch to CPU skinning
		if (this._mesh != null && this._mesh.computeBonesUsingShaders && this._mesh.numBoneInfluencers > 0) {
			this._mesh.computeBonesUsingShaders = false;
			currentDefines = StringTools.replace(currentDefines, "#define NUM_BONE_INFLUENCERS " + this._mesh.numBoneInfluencers, "#define NUM_BONE_INFLUENCERS 0");
			Tools.Log("Falling back to CPU skinning for " + this._mesh.name);
			
			var scene = this._mesh.getScene();
			for (index in 0...scene.meshes.length) {
				var otherMesh = scene.meshes[index];
				
				if (otherMesh.material == this._mesh.material && otherMesh.computeBonesUsingShaders && otherMesh.numBoneInfluencers > 0) {
					otherMesh.computeBonesUsingShaders = false;
				}
			}
		}
		else {
			var currentFallbacks = this._defines[this._currentRank];
			if (currentFallbacks != null) {
				for (index in 0...currentFallbacks.length) {
					currentDefines = StringTools.replace(currentDefines, "#define " + currentFallbacks[index], "");
				}
			}
			
			this._currentRank++;
		}
		
		return currentDefines;
	}
	
}
