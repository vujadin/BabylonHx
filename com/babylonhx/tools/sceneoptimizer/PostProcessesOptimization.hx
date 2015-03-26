package com.babylonhx.tools.sceneoptimizer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.PostProcessesOptimization') class PostProcessesOptimization extends SceneOptimization {

	override public function apply(scene:Scene):Bool {
		scene.postProcessesEnabled = false;
		return true;
	}
	
}
