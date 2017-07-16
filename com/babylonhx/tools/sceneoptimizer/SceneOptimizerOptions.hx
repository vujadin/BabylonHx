package com.babylonhx.tools.sceneoptimizer;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.SceneOptimizerOptions') class SceneOptimizerOptions {
	
	public var optimizations:Array<SceneOptimization> = [];
	public var targetFrameRate:Float = 60;
	public var trackerDuration:Float = 2000;
	

	public function new(targetFrameRate:Float = 60, trackerDuration:Float = 2000) {
		this.targetFrameRate = targetFrameRate;
		this.trackerDuration = trackerDuration;
	}
	
	public static function LowDegradationAllowed(?targetFrameRate:Float):SceneOptimizerOptions {
		var result = new SceneOptimizerOptions(targetFrameRate);
		
		var priority:Int = 0;
		result.optimizations.push(new MergeMeshesOptimization(priority));
		result.optimizations.push(new ShadowsOptimization(priority));
		result.optimizations.push(new LensFlaresOptimization(priority));
		
		// Next priority
		priority++;
		result.optimizations.push(new PostProcessesOptimization(priority));
		result.optimizations.push(new ParticlesOptimization(priority));
		
		// Next priority
		priority++;
		result.optimizations.push(new TextureOptimization(priority, 1024));
		
		return result;
	}
	
	public static function ModerateDegradationAllowed(?targetFrameRate:Float):SceneOptimizerOptions {
		var result = new SceneOptimizerOptions(targetFrameRate);
		
		var priority:Int = 0;
		result.optimizations.push(new MergeMeshesOptimization(priority));
		result.optimizations.push(new ShadowsOptimization(priority));
		result.optimizations.push(new LensFlaresOptimization(priority));
		
		// Next priority
		priority++;
		result.optimizations.push(new PostProcessesOptimization(priority));
		result.optimizations.push(new ParticlesOptimization(priority));
		
		// Next priority
		priority++;
		result.optimizations.push(new TextureOptimization(priority, 512));
		
		// Next priority
		priority++;
		result.optimizations.push(new RenderTargetsOptimization(priority));
		
		// Next priority
		priority++;
		result.optimizations.push(new HardwareScalingOptimization(priority, 2));
		
		return result;
	}
	
	public static function HighDegradationAllowed(?targetFrameRate:Float):SceneOptimizerOptions {
		var result = new SceneOptimizerOptions(targetFrameRate);
		
		var priority:Int = 0;
		result.optimizations.push(new MergeMeshesOptimization(priority));
		result.optimizations.push(new ShadowsOptimization(priority));
		result.optimizations.push(new LensFlaresOptimization(priority));
		
		// Next priority
		priority++;
		result.optimizations.push(new PostProcessesOptimization(priority));
		result.optimizations.push(new ParticlesOptimization(priority));
		
		// Next priority
		priority++;
		result.optimizations.push(new TextureOptimization(priority, 256));
		
		// Next priority
		priority++;
		result.optimizations.push(new RenderTargetsOptimization(priority));
		
		// Next priority
		priority++;
		result.optimizations.push(new HardwareScalingOptimization(priority, 4));
		
		return result;
	}
	
}
