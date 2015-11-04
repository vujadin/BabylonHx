package com.babylonhx.materials;

import com.babylonhx.mesh.AbstractMesh;

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
	
	public var isMoreFallbacks(get, never):Bool;
	
	
	public function new() {
		// 
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
		
		if (rank > this._maxRank) {
			this._maxRank = rank;
		}
	}

	public function reduce(currentDefines:String):String {		
		var currentFallbacks = this._defines[this._currentRank];
		
		for (index in 0...currentFallbacks.length) {
			currentDefines = StringTools.replace(currentDefines, "#define " + currentFallbacks[index], "");
		}
		
		if (this._mesh != null && this._currentRank == this._meshRank){
			this._mesh.computeBonesUsingShaders = false;
			currentDefines = StringTools.replace(currentDefines, "#define NUM_BONE_INFLUENCERS " + this._mesh.numBoneInfluencers, "#define NUM_BONE_INFLUENCERS 0");
			trace("Falling back to CPU skinning for " + this._mesh.name);
		}
		
		this._currentRank++;
		
		return currentDefines;
	}
	
	private function get_isMoreFallbacks():Bool {
		return this._currentRank <= this._maxRank;
	}
	
}
