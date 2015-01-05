package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */

class BlackAndWhitePostProcess extends PostProcess {
	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Float, ?engine:Engine, reusable:Bool = false/*?reusable:Bool*/) {
		super(name, "blackAndWhite", null, null, ratio, camera, samplingMode, engine, reusable);
	}
	
}
