package com.babylonhx.tools.sceneoptimizer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.ParticlesOptimization') class ParticlesOptimization extends SceneOptimization {

	override public function apply(scene:Scene, updateSelectionTree:Bool = false):Bool {
		scene.particlesEnabled = false;
		return true;
	}
	
}
