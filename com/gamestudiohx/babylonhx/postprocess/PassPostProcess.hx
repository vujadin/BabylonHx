package com.gamestudiohx.babylonhx.postprocess;

import com.gamestudiohx.babylonhx.cameras.Camera;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class PassPostProcess extends PostProcess {

	public function new(name:String, ratio:Float, camera:Camera, samplingMode:Int = 1) {
		super(name, "pass", null, null, ratio, camera, samplingMode);		
	}
	
}