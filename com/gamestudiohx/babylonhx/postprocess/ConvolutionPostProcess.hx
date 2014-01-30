package com.gamestudiohx.babylonhx.postprocess;

import com.gamestudiohx.babylonhx.cameras.Camera;
import com.gamestudiohx.babylonhx.materials.Effect;
import com.gamestudiohx.babylonhx.tools.math.Matrix;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class ConvolutionPostProcess extends PostProcess {
	
	public var kernelMatrix:Matrix;
	public var onApply:Effect->Void;
	

	public function new(name:String, kernelMatrix:Matrix, ratio:Float, camera:Camera, samplingMode:Int = 1) {
		super(name, "convolution", ["kernelMatrix"], null, ratio, camera, samplingMode);
        
        this.kernelMatrix = kernelMatrix;
		
        this.onApply = function(effect:Effect):Void {
            effect.setMatrix("kernelMatrix", that.kernelMatrix);
        };
		
	}
	
}