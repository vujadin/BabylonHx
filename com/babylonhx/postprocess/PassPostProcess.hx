package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PassPostProcess') class PassPostProcess extends PostProcess {
	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false/*?reusable:Bool*/) {
		super(name, "pass", null, null, ratio, camera, samplingMode, engine, reusable);
	}
	
}
