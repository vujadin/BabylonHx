package com.babylonhx.tools.sceneoptimizer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.ShadowsOptimization') class ShadowsOptimization extends SceneOptimization {

	override public function apply(scene:Scene):Bool {
		scene.shadowsEnabled = false;
		return true;
	}
	
}
