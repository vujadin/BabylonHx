package com.babylonhx.tools.sceneoptimizer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.ParticlesOptimization') class ParticlesOptimization extends SceneOptimization {

	override public function apply(scene:Scene):Bool {
		scene.particlesEnabled = false;
		return true;
	}
	
}
