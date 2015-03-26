package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.BabylonTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;

import com.babylonhx.utils.GL;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.PostProcess') class PostProcess {
	
	public var name:String;
	
	public var onApply:Effect->Void;
	public var onBeforeRender:Effect->Void;
	public var onSizeChanged:Void->Void;
	public var onActivate:Camera->Void;
	public var width:Float = -1;
	public var height:Float = -1;
	public var renderTargetSamplingMode:Int;
	public var clearColor:Color4;

	private var _camera:Camera;
	private var _scene:Scene;
	private var _engine:Engine;
	private var _renderRatio:Float;
	private var _reusable:Bool = false;
	public var _textures:SmartArray = new SmartArray(2);// SmartArray<BabylonTexture> = new SmartArray<BabylonTexture>(2);
	public var _currentRenderTextureId:Int = 0;
	private var _effect:Effect;
	

	public function new(name:String, fragmentUrl:String, parameters:Array<String>, samplers:Array<String>, ratio:Float, camera:Camera, samplingMode:Int = Texture.NEAREST_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false, defines:String = "") {
		if (camera != null) {
			this._camera = camera;
			this._scene = camera.getScene();
			camera.attachPostProcess(this);
			this._engine = this._scene.getEngine();
		}
		else {
			this._engine = engine;
		}
		
		this._renderRatio = ratio;
		this.renderTargetSamplingMode = samplingMode;
		this._reusable = reusable;
		
		samplers = samplers != null ? samplers : [];
		samplers.push("textureSampler");
		
		this._effect = this._engine.createEffect({ vertex: "postprocess", fragment: fragmentUrl },
			["position"],
			parameters != null ? parameters : [],
			samplers, defines);
	}

	public function isReusable():Bool {
		return this._reusable;
	}

	public function activate(camera:Camera, ?sourceTexture:BabylonTexture) {
		camera = camera != null ? camera : this._camera;
		
		var scene = camera.getScene();
		var maxSize = camera.getEngine().getCaps().maxTextureSize;
		var desiredWidth = (sourceTexture != null ? sourceTexture._width : this._engine.getRenderWidth()) * this._renderRatio;
        var desiredHeight = (sourceTexture != null ? sourceTexture._height : this._engine.getRenderHeight()) * this._renderRatio;
        desiredWidth = Tools.GetExponantOfTwo(Std.int(desiredWidth), maxSize);
		desiredHeight = Tools.GetExponantOfTwo(Std.int(desiredHeight), maxSize);
				     
		if (this.width != desiredWidth || this.height != desiredHeight) {
			if (this._textures.length > 0) {
				for (i in 0...this._textures.length) {
					this._engine._releaseTexture(this._textures.data[i]);
				}
				this._textures.reset();
			}
			this.width = desiredWidth;
			this.height = desiredHeight;
			
			this._textures.push(this._engine.createRenderTargetTexture( { width: this.width, height: this.height }, { generateMipMaps: false, generateDepthBuffer: camera._postProcesses.indexOf(this) == camera._postProcessesTakenIndices[0], samplingMode: this.renderTargetSamplingMode } ));
			
			if (this._reusable) {
				this._textures.push(this._engine.createRenderTargetTexture({ width: this.width, height: this.height }, { generateMipMaps: false, generateDepthBuffer: camera._postProcesses.indexOf(this) == camera._postProcessesTakenIndices[0], samplingMode: this.renderTargetSamplingMode }));
			}
			
			if (this.onSizeChanged != null) {
				this.onSizeChanged();
			}
		}
		
		this._engine.bindFramebuffer(this._textures.data[this._currentRenderTextureId]);
		
		if (this.onActivate != null) {
			this.onActivate(camera);
		}
		
		// Clear
		if (this.clearColor != null) {
            this._engine.clear(this.clearColor, true, true);
        } else {
            this._engine.clear(scene.clearColor, scene.autoClear || scene.forceWireframe, true);
        }
		
		if (this._reusable) {
			this._currentRenderTextureId = (this._currentRenderTextureId + 1) % 2;
		}
	}

	public function apply():Effect {
		// Check
		if (!this._effect.isReady()) {
			return null;
		}
		
		// States
		this._engine.enableEffect(this._effect);
		this._engine.setState(false);
		this._engine.setAlphaMode(Engine.ALPHA_DISABLE);
		this._engine.setDepthBuffer(false);
		this._engine.setDepthWrite(false);
		
		// Texture
		this._effect._bindTexture("textureSampler", this._textures.data[this._currentRenderTextureId]);
		
		// Parameters
		if (this.onApply != null) {
			this.onApply(this._effect);
		}
		
		return this._effect;
	}

	public function dispose(?camera:Camera) {
		camera = camera != null ? camera : this._camera;
		
		if (this._textures.length > 0) {
			for (i in 0...this._textures.length) {
				this._engine._releaseTexture(this._textures.data[i]);
			}
			this._textures.reset();
		}
		
		if (camera == null) {
			return;
		}
		camera.detachPostProcess(this);
		
		var index = camera._postProcesses.indexOf(this);
		if (index == camera._postProcessesTakenIndices[0] && camera._postProcessesTakenIndices.length > 0) {
			// invalidate frameBuffer to hint the postprocess to create a depth buffer
			this._camera._postProcesses[camera._postProcessesTakenIndices[0]].width = -1; 
		}
	}
	
}
