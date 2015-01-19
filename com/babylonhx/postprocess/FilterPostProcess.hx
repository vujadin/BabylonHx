package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.FilterPostProcess') class FilterPostProcess extends PostProcess {
	
	public var kernelMatrix:Matrix;
	
	
	public function new(name:String, kernelMatrix:Matrix, ratio:Float, ?camera:Camera, ?samplingMode:Float, ?engine:Engine, reusable:Bool = false/*?reusable:Bool*/) {
		super(name, "filter", ["kernelMatrix"], null, ratio, camera, samplingMode, engine, reusable);

		this.kernelMatrix = kernelMatrix;
		
		this.onApply = function(effect:Effect) {
			effect.setMatrix("kernelMatrix", this.kernelMatrix);
		}
	}
	
}