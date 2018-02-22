package com.babylonhx.materials;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * EffectFallbacks can be used to add fallbacks (properties to disable) to certain properties when desired to improve performance.
 * (Eg. Start at high quality with reflection and fog, if fps is low, remove reflection, if still low remove fog)
 */
@:expose('BABYLON.EffectFallbacks') class EffectFallbacks {
	
	private var _defines:Array<Array<String>> = [];
	
	private var _currentRank:Int = 32;
	private var _maxRank:Int = -1;
	
	private var _mesh:AbstractMesh;
    private var _meshRank:Int;
	
	
	public function new() {	}
	
	/**
	 * Removes the fallback from the bound mesh.
	 */
	public function unBindMesh() {
        this._mesh = null;
    }

	/**
	 * Adds a fallback on the specified property.
	 * @param rank The rank of the fallback (Lower ranks will be fallbacked to first)
	 * @param define The name of the define in the shader
	 */
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
	
	/**
	 * Sets the mesh to use CPU skinning when needing to fallback.
	 * @param rank The rank of the fallback (Lower ranks will be fallbacked to first)
	 * @param mesh The mesh to use the fallbacks.
	 */
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
	
	/**
	 * Checks to see if more fallbacks are still availible.
	 */
	public var isMoreFallbacks(get, never):Bool;
	private function get_isMoreFallbacks():Bool {
		return this._currentRank <= this._maxRank;
	}

	/**
	 * Removes the defines that shoould be removed when falling back.
	 * @param currentDefines defines the current define statements for the shader.
	 * @param effect defines the current effect we try to compile
	 * @returns The resulting defines with defines of the current rank removed.
	 */
	public function reduce(currentDefines:String, effect:Effect):String {		
		// First we try to switch to CPU skinning
		if (this._mesh != null && this._mesh.computeBonesUsingShaders && this._mesh.numBoneInfluencers > 0 && this._mesh.material != null) {
			this._mesh.computeBonesUsingShaders = false;
			currentDefines = StringTools.replace(currentDefines, "#define NUM_BONE_INFLUENCERS " + this._mesh.numBoneInfluencers, "#define NUM_BONE_INFLUENCERS 0");
			
			var scene = this._mesh.getScene();
			for (index in 0...scene.meshes.length) {
				var otherMesh:Mesh = cast scene.meshes[index];
				
				if (otherMesh.material == null) {
					continue;
				}
				
				if (!otherMesh.computeBonesUsingShaders || otherMesh.numBoneInfluencers == 0) {
					continue;
				}
				
				if (otherMesh.material.getEffect() == effect) {
					otherMesh.computeBonesUsingShaders = false;
				} 
				else {
					for (subMesh in otherMesh.subMeshes) {
						var subMeshEffect = subMesh.effect;
						
						if (subMeshEffect == effect) {
							otherMesh.computeBonesUsingShaders = false;
							break;
						}
					}
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
