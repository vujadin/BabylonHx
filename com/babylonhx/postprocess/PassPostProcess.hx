package com.babylonhx.postprocess;

import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PassPostProcess') class PassPostProcess extends PostProcess {
	
	public function new(name:String, options:Dynamic, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false, textureType:Int = Engine.TEXTURETYPE_UNSIGNED_INT, blockCompilation:Bool = false) {
		super(name, "pass", null, null, options, camera, samplingMode, engine, reusable, null, textureType, "postprocess", null, blockCompilation);
	}
	
}
