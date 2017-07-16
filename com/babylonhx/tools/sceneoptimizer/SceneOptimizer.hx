package com.babylonhx.tools.sceneoptimizer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.SceneOptimizer') class SceneOptimizer {

	static function _CheckCurrentState(scene:Scene, options:SceneOptimizerOptions, currentPriorityLevel:Int, ?onSuccess:Void->Void, ?onFailure:Void->Void) {
		// TODO: add an epsilon
		if (scene.getEngine().getFps() >= options.targetFrameRate) {
			if (onSuccess != null) {
				onSuccess();
			}
			
			return;
		}
		
		// Apply current level of optimizations
		var allDone = true;
		var noOptimizationApplied = true;
		for (index in 0...options.optimizations.length) {
			var optimization = options.optimizations[index];
			
			if (optimization.priority == currentPriorityLevel) {
				noOptimizationApplied = false;
				allDone = allDone && optimization.apply(scene);
			}
		}
		
		// If no optimization was applied, this is a failure :(
		if (noOptimizationApplied) {
			if (onFailure != null) {
				onFailure();
			}
			
			return;
		}
		
		// If all optimizations were done, move to next level
		if (allDone) {
			currentPriorityLevel++;
		}
		
		// Let's the system running for a specific amount of time before checking FPS
		scene.executeWhenReady(function() {
			Tools.delay(function() {
				SceneOptimizer._CheckCurrentState(scene, options, currentPriorityLevel, onSuccess, onFailure);
			}, cast options.trackerDuration);
		});
	}

	public static function OptimizeAsync(scene:Scene, ?options:SceneOptimizerOptions, ?onSuccess:Void->Void, ?onFailure:Void->Void) {
		if (options == null) {
			options = SceneOptimizerOptions.ModerateDegradationAllowed();
		}
		
		// Let's the system running for a specific amount of time before checking FPS
		scene.executeWhenReady(function() {
			Tools.delay(function() {
				SceneOptimizer._CheckCurrentState(scene, options, 0, onSuccess, onFailure);
			}, cast options.trackerDuration);
		});
	}
	
}
