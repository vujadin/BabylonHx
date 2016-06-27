package com.babylonhx.postprocess.renderpipeline;

import com.babylonhx.cameras.Camera;
import com.babylonhx.tools.Tools;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PostProcessRenderPipeline') class PostProcessRenderPipeline {
	
	private static inline var PASS_EFFECT_NAME:String = "passEffect";
	private static inline var PASS_SAMPLER_NAME:String = "passSampler";
	
	private var _engine:Engine;

	private var _renderEffects:Map<String, PostProcessRenderEffect>;
	private var _renderEffectsForIsolatedPass:Map<String, PostProcessRenderEffect>;

	private var _cameras:Map<String, Camera>;
	
	public var isSupported(get, never):Bool;

	// private
	public var _name:String;

	
	public function new(engine:Engine, name:String) {
		this._engine = engine;
		this._name = name;
		
		this._renderEffects = new Map<String, PostProcessRenderEffect>();
		this._renderEffectsForIsolatedPass = new Map<String, PostProcessRenderEffect>();
		
		this._cameras = new Map<String, Camera>();
	}
	
	private function get_isSupported():Bool {
		for (renderEffectName in this._renderEffects.keys()) {
			if (!this._renderEffects[renderEffectName].isSupported) {
				return false;
			}
		}
		
		return true;
	}

	public function addEffect(renderEffect:PostProcessRenderEffect) {
		this._renderEffects[renderEffect._name] = renderEffect;
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
		var _cam:Array<Camera> = cast Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		var indicesToDelete:Array<Int> = [];
		
		for (i in 0..._cam.length) {
			var camera = _cam[i];
			var cameraName:String = camera.name;
			
			if (!this._cameras.exists(cameraName)) {
				this._cameras[cameraName] = camera;
			}
			else if (unique) {
				indicesToDelete.push(i);
			}
		}
		
		for (i in 0...indicesToDelete.length) {
			_cam.splice(indicesToDelete[i], 1);
		}
		
		for (renderEffectName in this._renderEffects.keys()) {
			this._renderEffects[renderEffectName]._attachCameras(_cam);
		}
	}

	public function _detachCameras(cameras:Dynamic) {
		var _cam = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		for (renderEffectName in this._renderEffects.keys()) {
			this._renderEffects[renderEffectName]._detachCameras(_cam);
		}
		
		for (c in _cam) {
			this._cameras.remove(c.name);
		}
	}

	public function _enableDisplayOnlyPass(passName:String, cameras:Dynamic) {
		var _cam = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		var pass:PostProcessRenderPass = null;
		
		for (renderEffectName in this._renderEffects.keys()) {
			pass = this._renderEffects[renderEffectName].getPass(passName);
			
			if (pass != null) {
				break;
			}
		}
		
		if (pass == null) {
			return;
		}
		
		for (renderEffectName in this._renderEffects.keys()) {
			this._renderEffects[renderEffectName]._disable(_cam);
		}
		
		pass._name = PostProcessRenderPipeline.PASS_SAMPLER_NAME;
		
		for (c in _cam) {
			var camera:Camera = c;
			var cameraName = c.name;
			
			this._renderEffectsForIsolatedPass[cameraName] = this._renderEffectsForIsolatedPass[cameraName] != null ? this._renderEffectsForIsolatedPass[cameraName] : new PostProcessRenderEffect(this._engine, PostProcessRenderPipeline.PASS_EFFECT_NAME, function() { return new DisplayPassPostProcess(PostProcessRenderPipeline.PASS_EFFECT_NAME, 1.0, null, null, this._engine, true); } );
			this._renderEffectsForIsolatedPass[cameraName].emptyPasses();
			this._renderEffectsForIsolatedPass[cameraName].addPass(pass);
			this._renderEffectsForIsolatedPass[cameraName]._attachCameras(camera);
		}
	}

	public function _disableDisplayOnlyPass(cameras:Dynamic) {
		var _cam = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		for (c in _cam) {
			var camera:Camera = c;
			var cameraName = c.name;
			
			this._renderEffectsForIsolatedPass[cameraName] = this._renderEffectsForIsolatedPass[cameraName] != null ? this._renderEffectsForIsolatedPass[cameraName] : new PostProcessRenderEffect(this._engine, PostProcessRenderPipeline.PASS_EFFECT_NAME,  function() { return new DisplayPassPostProcess(PostProcessRenderPipeline.PASS_EFFECT_NAME, 1.0, null, null, this._engine, true); } );
			this._renderEffectsForIsolatedPass[cameraName]._disable(camera);
		}
		
		for (renderEffectName in this._renderEffects.keys()) {
			this._renderEffects[renderEffectName]._enable(_cam);
		}
	}

	public function _update() {
		for (renderEffectName in this._renderEffects.keys()) {
			this._renderEffects[renderEffectName]._update();
		}
		
		for (key in this._cameras.keys()) {
			var cameraName = this._cameras[key].name;
			if (this._renderEffectsForIsolatedPass.exists(cameraName)) {
				this._renderEffectsForIsolatedPass[cameraName]._update();
			}
		}
	}
	
	public function dispose(disableDepthRender:Bool = false) {
		// Must be implemented by children
	}
	
}
