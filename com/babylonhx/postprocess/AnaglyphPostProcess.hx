package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.AnaglyphPostProcess') class AnaglyphPostProcess extends PostProcess {
	
	private var _passedProcess:PostProcess;
	
	public function new(name:String, ratio:Float, rigCameras:Array<Camera>, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		super(name, "anaglyph", null, ["leftSampler"], ratio, rigCameras[1], samplingMode, engine, reusable);
		
		this._passedProcess = rigCameras[0]._rigPostProcess;
		
		this.onApplyObservable.add(function(effect:Effect, eventState:EventState = null) {
			effect.setTextureFromPostProcess("leftSampler", this._passedProcess);
		});
	}
	
}
