package com.babylonhx.tools.sceneoptimizer;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.MergeMeshesOptimization') class MergeMeshesOptimization extends SceneOptimization {

	private function _canBeMerged(abstractMesh:AbstractMesh):Bool {
		if (!Std.is(abstractMesh, Mesh)) {
			return false;
		}
		
		var mesh:Mesh = cast abstractMesh;
		
		if (!mesh.isVisible || !mesh.isEnabled()) {
			return false;
		}
		
		if (mesh.instances.length > 0) {
			return false;
		}
		
		if (mesh.skeleton || mesh.hasLODLevels) {
			return false;
		}
		
		return true;
	}
	
	override public function apply(scene:Scene):Bool {
		var globalPool:Array<AbstractMesh> = scene.meshes.slice(0);
		var globalLength:Int = globalPool.length;
		
		for (index in 0...globalLength) {
			var currentPool:Array<Mesh> = [];
			var current:AbstractMesh = globalPool[index];
			
			// Checks
			if (!this._canBeMerged(current)) {
				continue;
			}
			
			currentPool.push(cast current);
			
			// Find compatible meshes
			for (subIndex in index + 1...globalLength) {
				var otherMesh = globalPool[subIndex];
				
				if (!this._canBeMerged(otherMesh)) {
					continue;
				}
				
				if (otherMesh.material != current.material) {
					continue;
				}
				
				if (otherMesh.checkCollisions != current.checkCollisions) {
					continue;
				}
				
				currentPool.push(cast otherMesh);
				globalLength--;
				
				globalPool.splice(subIndex, 1);
				
				subIndex--;
			}
			
			if (currentPool.length < 2) {
				continue;
			}
			
			// Merge meshes
			Mesh.MergeMeshes(currentPool);
		}
		
		return true;
	}
	
}
