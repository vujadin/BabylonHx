package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.FilterPostProcess') class FilterPostProcess extends PostProcess {
	
	public var kernelMatrix:Matrix;
	
	
	public function new(name:String, kernelMatrix:Matrix, options:Dynamic, ?camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		super(name, "filter", ["kernelMatrix"], null, options, camera, samplingMode, engine, reusable);
		
		this.kernelMatrix = kernelMatrix;
		
		this.onApply = function(effect:Effect, _) {
			effect.setMatrix("kernelMatrix", this.kernelMatrix);
		}
	}
	
}