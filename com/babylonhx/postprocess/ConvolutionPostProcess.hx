package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ConvolutionPostProcess') class ConvolutionPostProcess extends PostProcess {
	
	// Based on http://en.wikipedia.org/wiki/Kernel_(image_processing)
    public static var EdgeDetect0Kernel:Array<Float> = [1, 0, -1, 0, 0, 0, -1, 0, 1];
    public static var EdgeDetect1Kernel:Array<Float> = [0, 1, 0, 1, -4, 1, 0, 1, 0];
    public static var EdgeDetect2Kernel:Array<Float> = [-1, -1, -1, -1, 8, -1, -1, -1, -1];
    public static var SharpenKernel:Array<Float> = [0, -1, 0, -1, 5, -1, 0, -1, 0];
    public static var EmbossKernel:Array<Float> = [-2, -1, 0, -1, 1, 1, 0, 1, 2];
    public static var GaussianKernel:Array<Float> = [0, 1, 0, 1, 1, 1, 0, 1, 0];
	
	public var kernel:Array<Float>;
	
	
	public function new(name:String, kernel:Array<Float>, options:Dynamic, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		super(name, "convolution", ["kernel", "screenSize"], null, options, camera, samplingMode, engine, reusable);
		
		this.kernel = kernel;
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setFloat2("screenSize", this.width, this.height);
			effect.setArray("kernel", this.kernel);
		});
	}
    
}
