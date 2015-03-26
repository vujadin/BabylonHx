package com.babylonhx.tools.sceneoptimizer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.RenderTargetsOptimization') class RenderTargetsOptimization extends SceneOptimization {

	override public function apply(scene:Scene):Bool {
		scene.renderTargetsEnabled = false;
		return true;
	}
	
}
