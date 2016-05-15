package com.babylonhx.postprocess.renderpipeline;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PostProcessRenderEffect') class PostProcessRenderEffect {
	
	private var _engine:Engine;

	private var _postProcesses:Map<String, PostProcess>;
	private var _getPostProcess:Void->PostProcess;

	private var _singleInstance:Bool;

	private var _cameras:Map<String, Camera>;
	private var _indicesForCamera:Map<String, Array<Int>>;

	private var _renderPasses:Map<String, PostProcessRenderPass>;
	private var _renderEffectAsPasses:Map<String, PostProcessRenderEffect>;

	// private
	public var _name:String;

	public var applyParameters:PostProcess->Void;
	
	public var isSupported(get, never):Bool;
	

	public function new(engine:Engine, name:String, getPostProcess:Void->PostProcess, singleInstance:Bool = true) {
		this._engine = engine;
		this._name = name;
		this._singleInstance = singleInstance;
		
		this._getPostProcess = getPostProcess;
		
		this._cameras = new Map<String, Camera>();
		this._indicesForCamera = new Map<String, Array<Int>>();
		
		this._postProcesses = new Map<String, PostProcess>();
		
		this._renderPasses = new Map<String, PostProcessRenderPass>();
		this._renderEffectAsPasses = new Map<String, PostProcessRenderEffect>();
	}
	
	private function get_isSupported():Bool {
		for (index in this._postProcesses.keys()) {
			if (!this._postProcesses[index].isSupported) {
				return false;
			}
		}
		
		return true;
	}

	public function _update() {
		for (renderPassName in this._renderPasses.keys()) {
			this._renderPasses[renderPassName]._update();
		}
	}

	public function addPass(renderPass:PostProcessRenderPass) {
		this._renderPasses.set(renderPass._name, renderPass);
		
		this._linkParameters();
	}

	public function removePass(renderPass:PostProcessRenderPass) {
		this._renderPasses[renderPass._name] = null;
		this._renderPasses.remove(renderPass._name);
		
		this._linkParameters();
	}

	public function addRenderEffectAsPass(renderEffect:PostProcessRenderEffect) {
		this._renderEffectAsPasses.set(renderEffect._name, renderEffect);
		
		this._linkParameters();
	}

	public function getPass(passName:String):PostProcessRenderPass {
		for (renderPassName in this._renderPasses.keys()) {
			if (renderPassName == passName) {
				return this._renderPasses[passName];
			}
		}
		return null;
	}

	public function emptyPasses() {
		this._renderPasses = new Map<String, PostProcessRenderPass>();
		
		this._linkParameters();
	}

	// private
	public function _attachCameras(cameras:Dynamic) {
		var cameraKey:String = "";
		
		var _cam = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		for (c in _cam) {
			var camera:Camera = c;
			var cameraName = camera.name;
			
			if (this._singleInstance) {
				cameraKey = "0";
			}
			else {
				cameraKey = cameraName;
			}
			
			this._postProcesses.set(cameraKey, this._postProcesses.exists(cameraKey) ? this._postProcesses[cameraKey] : this._getPostProcess());
			
			var index = camera.attachPostProcess(this._postProcesses[cameraKey]);
			
			if (!this._indicesForCamera.exists(cameraName)) {
				this._indicesForCamera.set(cameraName, []);
			}
			
			this._indicesForCamera[cameraName].push(index);
			
			if (!this._cameras.exists(camera.name)) {
				this._cameras.set(cameraName, camera);
			}
			
			for (passName in this._renderPasses.keys()) {
				this._renderPasses[passName]._incRefCount();
			}
		}
		
		this._linkParameters();
	}

	// private
	//public _detachCameras(cameras:Camera);
	//public _detachCameras(cameras:Camera[]);
	public function _detachCameras(cameras:Dynamic) {
		var _cam = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		for (c in _cam) {
			var camera:Camera = c;
			var cameraName = camera.name;
			
			camera.detachPostProcess(this._postProcesses[this._singleInstance ? "0" : cameraName], this._indicesForCamera[cameraName]);
			
			this._cameras.remove(cameraName);
			this._indicesForCamera.remove(cameraName);
			
			for (passName in this._renderPasses.keys()) {
				this._renderPasses[passName]._decRefCount();
			}
		}
	}

	// private
	//public _enable(cameras:Camera);
	//public _enable(cameras:Camera[]);
	public function _enable(cameras:Dynamic) {
		var _cam = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		for (c in _cam) {
			var camera:Camera = c;
			var cameraName = camera.name;
			
			for (j in 0...this._indicesForCamera[cameraName].length) {
				if (camera._postProcesses[this._indicesForCamera[cameraName][j]] == null) {
					c.attachPostProcess(this._postProcesses[this._singleInstance ? "0" : cameraName], this._indicesForCamera[cameraName][j]);
				}
			}
			
			for (passName in this._renderPasses.keys()) {
				this._renderPasses[passName]._incRefCount();
			}
		}
	}

	// private
	//public _disable(cameras:Camera);
	//public _disable(cameras:Camera[]);
	public function _disable(cameras:Dynamic) {
		var _cam = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		for (c in _cam) {
			var camera:Camera = c;
			var cameraName = c.name;
			
			camera.detachPostProcess(this._postProcesses[this._singleInstance ? "0" : cameraName], this._indicesForCamera[cameraName]);
			
			for (passName in this._renderPasses.keys()) {
				this._renderPasses[passName]._decRefCount();
			}
		}
	}

	public function getPostProcess(?camera:Camera):PostProcess {
		if (this._singleInstance) {
			return this._postProcesses["0"];
		}
		else {
			return this._postProcesses[camera.name];
		}
	}

	private function _linkParameters() {
		for (index in this._postProcesses.keys()) {
			if (this.applyParameters != null) {
				this.applyParameters(this._postProcesses[index]);
			}
			
			this._postProcesses[index].onBeforeRenderObservable.add(function(effect:Effect, es:EventState = null) {
				this._linkTextures(effect);
			});
		}
	}

	private function _linkTextures(effect:Effect) {
		for (renderPassName in this._renderPasses.keys()) {
			effect.setTexture(renderPassName, this._renderPasses[renderPassName].getRenderTexture());
		}
		
		for (renderEffectName in this._renderEffectAsPasses.keys()) {
			effect.setTextureFromPostProcess(renderEffectName + "Sampler", this._renderEffectAsPasses[renderEffectName].getPostProcess());
		}
	}
	
}
