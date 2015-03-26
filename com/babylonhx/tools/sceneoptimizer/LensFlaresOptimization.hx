package com.babylonhx.tools.sceneoptimizer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.LensFlaresOptimization') class LensFlaresOptimization extends SceneOptimization {

	override public function apply(scene:Scene):Bool {
		scene.lensFlaresEnabled = false;
		return true;
	}
	
}
