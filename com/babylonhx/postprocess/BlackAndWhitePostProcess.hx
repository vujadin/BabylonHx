package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BlackAndWhitePostProcess') class BlackAndWhitePostProcess extends PostProcess {
	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false/*?reusable:Bool*/) {
		super(name, "blackAndWhite", null, null, ratio, camera, samplingMode, engine, reusable);
	}
	
}
