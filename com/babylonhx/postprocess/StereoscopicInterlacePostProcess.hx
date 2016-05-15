package com.babylonhx.postprocess;

import com.babylonhx.math.Vector2;
import com.babylonhx.materials.Effect;
import com.babylonhx.cameras.Camera;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StereoscopicInterlacePostProcess extends PostProcess {
	
	private var _stepSize:Vector2;
	private var _passedProcess:PostProcess;
	

	public function new(name:String, rigCameras:Array<Camera>, isStereoscopicHoriz:Bool, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		super(name, "stereoscopicInterlace", ['stepSize'], ['camASampler'], 1, rigCameras[1], samplingMode, engine, reusable, isStereoscopicHoriz ? "#define IS_STEREOSCOPIC_HORIZ 1" : "");
		
		this._passedProcess = rigCameras[0]._rigPostProcess;
		this._stepSize = new Vector2(1 / this.width, 1 / this.height);
		
		this.onSizeChangedObservable.add(function(effect:Effect, eventState:EventState = null) {
			this._stepSize = new Vector2(1 / this.width, 1 / this.height);
		});
		
		this.onApplyObservable.add(function(effect:Effect, eventState:EventState = null) {
			effect.setTextureFromPostProcess("camASampler", this._passedProcess);
			effect.setFloat2("stepSize", this._stepSize.x, this._stepSize.y);
		});
	}
	
}
