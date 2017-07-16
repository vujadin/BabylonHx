package com.babylonhx.tools.sceneoptimizer;

import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.SceneOptimization') class SceneOptimization {
	
	public var priority:Int;
	

	public function new(priority:Int = 0) {
		this.priority = priority;
	}
	
	public function apply(scene:Scene, updateSelectionTree:Bool = false):Bool {
		return true;   // Return true if everything that can be done was applied
	}
	
}
