package com.babylonhx.postprocess.renderpipeline;

import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * This represents a set of one or more post processes in Babylon.
 * A post process can be used to apply a shader to a texture after it is rendered.
 * @example https://doc.babylonjs.com/how_to/how_to_use_postprocessrenderpipeline
 */
@:expose('BABYLON.PostProcessRenderEffect') class PostProcessRenderEffect {
	
	private var _engine:Engine;

	private var _postProcesses:Map<String, Array<PostProcess>>;
	@:allow(com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipeline)
	private var _getPostProcesses:Void->Array<PostProcess>;

	private var _singleInstance:Bool;

	private var _cameras:Map<String, Camera>;
	private var _indicesForCamera:Map<String, Array<Int>>;

	// private
	public var _name:String;
	

	/**
	 * Instantiates a post process render effect.
	 * A post process can be used to apply a shader to a texture after it is rendered.
	 * @param engine The engine the effect is tied to
	 * @param name The name of the effect
	 * @param getPostProcesses A function that returns a set of post processes which the effect will run in order to be run.
	 * @param singleInstance False if this post process can be run on multiple cameras. (default: true)
	 */
	public function new(engine:Engine, name:String, getPostProcesses:Void->Array<PostProcess>, singleInstance:Bool = true) {
		this._engine = engine;
		this._name = name;
		this._singleInstance = singleInstance;
		
		this._getPostProcesses = getPostProcesses;
		
		this._cameras = new Map<String, Camera>();
		this._indicesForCamera = new Map<String, Array<Int>>();
		
		this._postProcesses = new Map();
	}
	
	/**
	 * Checks if all the post processes in the effect are supported.
	 */
	public var isSupported(get, never):Bool;
	private function get_isSupported():Bool {
		for (index in this._postProcesses.keys()) {
			for (ppIndex in 0...this._postProcesses[index].length) {
				if (!this._postProcesses[index][ppIndex].isSupported) {
					return false;
				}
			}
		}
		
		return true;
	}

	/**
	 * Updates the current state of the effect
	 */
	public function _update() { }

	/**
	 * Attaches the effect on cameras
	 * @param cameras The camera to attach to.
	 */
	public function _attachCameras(cameras:Dynamic) {
		var cameraKey:String = "";
		
		var cams = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		if (cams == null) {
			return;
		}
		
		for (c in cams) {
			var camera:Camera = c;
			var cameraName = camera.name;
			
			if (this._singleInstance) {
				cameraKey = "0";
			}
			else {
				cameraKey = cameraName;
			}
			
			if (this._postProcesses[cameraKey] == null) {
				var postProcess = this._getPostProcesses();
				if (postProcess != null) {
					this._postProcesses[cameraKey] = postProcess;
				}
			}
			
			if (this._indicesForCamera[cameraName] == null) {
				this._indicesForCamera[cameraName] = [];
			}
			
			for (postProcess in this._postProcesses[cameraKey]) {
				var index = camera.attachPostProcess(postProcess);
				
				this._indicesForCamera[cameraName].push(index);
			}
			
			if (this._cameras[cameraName] == null) {
				this._cameras[cameraName] = camera;
			}
		}
	}

	/**
	 * Detatches the effect on cameras
	 * @param cameras The camera to detatch from.
	 */
	public function _detachCameras(cameras:Dynamic) {
		var cams = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		if (cams == null) {
			return;
		}
		
		for (c in cams) {
			var camera:Camera = c;
			var cameraName = camera.name;
			
			for (postProcess in this._postProcesses[this._singleInstance ? "0" : cameraName]) {
				camera.detachPostProcess(postProcess);
			}
			
			if (this._cameras[cameraName] != null) {
				//this._indicesForCamera.splice(index, 1);
				this._cameras[cameraName] = null;
			}
		}
	}

	/**
	 * Enables the effect on given cameras
	 * @param cameras The camera to enable.
	 */
	public function _enable(cameras:Dynamic) {
		var cams = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		if (cams == null) {
			return;
		}
		
		for (c in cams) {
			var camera:Camera = c;
			var cameraName = camera.name;
			
			for (j in 0...this._indicesForCamera[cameraName].length) {
				if (camera._postProcesses[this._indicesForCamera[cameraName][j]] == null) {
					for (postProcess in this._postProcesses[this._singleInstance ? "0" : cameraName]) {
						camera.attachPostProcess(postProcess, this._indicesForCamera[cameraName][j]);
					}
				}
			}
		}
	}

	/**
	 * Disables the effect on the given cameras
	 * @param cameras The camera to disable.
	 */
	public function _disable(cameras:Dynamic) {
		var cams = Tools.MakeArray(cameras != null ? cameras : this._cameras);
		
		if (cams == null) {
			return;
		}
		
		for (c in cams) {
			var camera:Camera = c;
			var cameraName = c.name;
			
			for (postProcess in this._postProcesses[this._singleInstance ? "0" : cameraName]) {
				camera.detachPostProcess(postProcess);
			}
		}
	}

	/**
	 * Gets a list of the post processes contained in the effect.
	 * @param camera The camera to get the post processes on.
	 * @returns The list of the post processes in the effect.
	 */
	public function getPostProcess(?camera:Camera):Array<PostProcess> {
		if (this._singleInstance) {
			return this._postProcesses["0"];
		}
		else {
			if (camera == null) {
				return null;
			}
			return this._postProcesses[camera.name];
		}
	}
	
}
