package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.engine.Engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class HighlightsPostProcess extends PostProcess {

	public function new(name:String, options:Dynamic, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false, textureType:Int = Engine.TEXTURETYPE_UNSIGNED_INT) {
		super(name, "highlights", null, null, options, camera, samplingMode, engine, reusable, null, textureType);
	}
	
}
