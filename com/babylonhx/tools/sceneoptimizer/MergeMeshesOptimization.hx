package com.babylonhx.tools.sceneoptimizer;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.MergeMeshesOptimization') class MergeMeshesOptimization extends SceneOptimization {
	
	public static var UpdateSelectionTree:Bool = false;

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
		
		if (mesh.skeleton != null || mesh.hasLODLevels != null) {
			return false;
		}
		
		return true;
	}
	
	override public function apply(scene:Scene, updateSelectionTree:Bool = false):Bool {
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
			var subIndex:Int = index + 1;
			while (subIndex < globalLength) {			
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
		
		if (updateSelectionTree || MergeMeshesOptimization.UpdateSelectionTree) {
			scene.createOrUpdateSelectionOctree();
		}
		
		return true;
	}
	
}
