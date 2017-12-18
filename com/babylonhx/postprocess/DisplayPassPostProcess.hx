package com.babylonhx.postprocess;

import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.DisplayPassPostProcess') class DisplayPassPostProcess extends PostProcess {
	
	public function new(name:String, options:Dynamic, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		super(name, "displayPass", ["passSampler"], ["passSampler"], options, camera, samplingMode, engine, reusable);
	}
	
}
