package com.babylonhx.postprocess.renderpipeline;

import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.Camera;
import com.babylonhx.tools.Tools;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PostProcessRenderPipeline') class PostProcessRenderPipeline {
	
	private var _engine:Engine;

	private var _renderEffects:Map<String, PostProcessRenderEffect>;
	private var _renderEffectsForIsolatedPass:Map<String, PostProcessRenderEffect>;

	private var _cameras:Map<String, Camera>;

	// private
	@serialize()
	public var _name:String;

	
	public function new(engine:Engine, name:String) {
		this._engine = engine;
		this._name = name;
		
		this._renderEffects = new Map<String, PostProcessRenderEffect>();
		this._renderEffectsForIsolatedPass = new Map<String, PostProcessRenderEffect>();
		
		this._cameras = new Map<String, Camera>();
	}
	
	public function getClassName():String {
		return "PostProcessRenderPipeline";
	}
	
	public var isSupported(get, never):Bool;
	private function get_isSupported():Bool {
		for (renderEffectName in this._renderEffects.keys()) {
			if (this._renderEffects[renderEffectName] != null) {
				if (!this._renderEffects[renderEffectName].isSupported) {
					return false;
				}
			}
		}
		
		return true;
	}

	public function addEffect(renderEffect:PostProcessRenderEffect) {
		this._renderEffects[renderEffect._name] = renderEffect;
	}
	
	public function _rebuild() {
		
	}

	public function _enableEffect(renderEffectName:String, cameras:Dynamic) {
		var renderEffects:PostProcessRenderEffect = this._renderEffects[renderEffectName];
		
		if (renderEffects == null) {
			return;
		}
		
		renderEffects._enable(Tools.MakeArray(cameras != null ? cameras : this._cameras));
	}

	public function _disableEffect(renderEffectName:String, cameras:Dynamic) {
		var renderEffects:PostProcessRenderEffect = this._renderEffects[renderEffectName];
		
		if (renderEffects == null) {
			return;
		}
		
		renderEffects._disable(Tools.MakeArray(cameras != null ? cameras : this._cameras));
	}

	public function _attachCameras(cameras:Dynamic, unique:Bool) {
		var cams:Array<Camera> = cast Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		if (cams == null) {
			return;
		}
		
		var indicesToDelete:Array<Int> = [];
		
		for (i in 0...cams.length) {
			var camera = cams[i];
			var cameraName:String = camera.name;
			
			if (!this._cameras.exists(cameraName)) {
				this._cameras[cameraName] = camera;
			}
			else if (unique) {
				indicesToDelete.push(i);
			}
		}
		
		for (i in 0...indicesToDelete.length) {
			cams.splice(indicesToDelete[i], 1);
		}
		
		for (renderEffectName in this._renderEffects.keys()) {
			if (this._renderEffects.exists(renderEffectName)) {
				this._renderEffects[renderEffectName]._attachCameras(cams);
			}
		}
	}

	public function _detachCameras(cameras:Dynamic) {
		var cams = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		for (renderEffectName in this._renderEffects.keys()) {
			if (this._renderEffects.exists(renderEffectName)) {
				this._renderEffects[renderEffectName]._detachCameras(cams);
			}
		}
		
		for (c in cams) {
			this._cameras.remove(c.name);
		}
	}

	public function _update() {
		for (renderEffectName in this._renderEffects.keys()) {
			if (this._renderEffects.exists(renderEffectName)) {
				this._renderEffects[renderEffectName]._update();
			}
		}
		
		for (key in this._cameras.keys()) {
			var cameraName = this._cameras[key].name;
			if (this._renderEffectsForIsolatedPass.exists(cameraName)) {
				this._renderEffectsForIsolatedPass[cameraName]._update();
			}
		}
	}
	
	public function _reset() {
		this._renderEffects = new Map<String, PostProcessRenderEffect>();
		this._renderEffectsForIsolatedPass = new Map<String, PostProcessRenderEffect>();
	}
	
	private function _enableMSAAOnFirstPostProcess():Bool {
		// Set samples of the very first post process to 4 to enable native anti-aliasing in browsers that support webGL 2.0 (See: https://github.com/BabylonJS/Babylon.js/issues/3754)
		var effectKeys:Array<String> = [];
		for (key in this._renderEffects.keys()) {
			effectKeys.push(key);
		}
		
		if (this._engine.webGLVersion >= 2 && effectKeys.length > 0) {
			var postProcesses = this._renderEffects[effectKeys[0]]._getPostProcesses();
			if (postProcesses != null) {
				postProcesses[0].samples = 4;
				return true;
			}
		}
		return false;
	}
	
	public function dispose(disableDepthRender:Bool = false) {
		// Must be implemented by children
	}
	
}
