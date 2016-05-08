package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.WebGLTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
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
	public var onAfterRender:Effect->Void;
	public var onSizeChanged:Void->Void;
	public var onActivate:Camera->Void;
	public var width:Int = -1;
	public var height:Int = -1;
	public var renderTargetSamplingMode:Int;
	public var clearColor:Color4;
	
	/*
        Enable Pixel Perfect mode where texture is not scaled to be power of 2.
        Can only be used on a single postprocess or on the last one of a chain.
    */ 
    public var enablePixelPerfectMode:Bool = false;
	
	public var isSupported(get, never):Bool;

	private var _camera:Camera;
	private var _scene:Scene;
	private var _engine:Engine;
	private var _renderRatio:Dynamic;// Float;
	private var _reusable:Bool = false;
	private var _textureType:Int;
	public var _textures:SmartArray<WebGLTexture> = new SmartArray<WebGLTexture>(2);
	public var _currentRenderTextureInd:Int = 0;
	
	@:allow(com.babylonhx.shaderbuilder.ShaderMaterialHelper)
	private var _effect:Effect;
	
	private var _samplers:Array<String>;
    private var _fragmentUrl:String;
    private var _parameters:Array<String>;
	private var _scaleRatio:Vector2 = new Vector2(1, 1);
	

	public function new(name:String, fragmentUrl:String, parameters:Array<String>, samplers:Array<String>, ratio:Dynamic, camera:Camera, samplingMode:Int = Texture.NEAREST_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false, defines:String = "", textureType:Int = Engine.TEXTURETYPE_UNSIGNED_INT) {
		if (camera != null) {
			this._camera = camera;
			this._scene = camera.getScene();
			camera.attachPostProcess(this);
			this._engine = this._scene.getEngine();
		}
		else {
			this._engine = engine;
		}
		
		this.name = name;
		
		this._renderRatio = ratio;
		this.renderTargetSamplingMode = samplingMode;
		this._reusable = reusable;
		this._textureType = textureType;
		
		this._samplers = samplers != null ? samplers : [];
		this._samplers.push("textureSampler");
		
		this._fragmentUrl = fragmentUrl;
		this._parameters = parameters != null ? parameters : [];
		
		this._parameters.push("scale");
		
		this.updateEffect(defines);
	}
	
	public function updateEffect(defines:String = "") {
		this._effect = this._engine.createEffect({ vertex: "postprocess", fragment: this._fragmentUrl },
			["position"],
			this._parameters,
			this._samplers, defines);
	}

	public function isReusable():Bool {
		return this._reusable;
	}

	public function activate(camera:Camera, ?sourceTexture:WebGLTexture) {
		camera = camera != null ? camera : this._camera;
		
		var scene = camera.getScene();
		var maxSize = camera.getEngine().getCaps().maxTextureSize;
		
		var requiredWidth:Int = cast ((sourceTexture != null ? sourceTexture._width : this._engine.getRenderWidth()) * this._renderRatio);
        var requiredHeight:Int = cast ((sourceTexture != null ? sourceTexture._height : this._engine.getRenderHeight()) * this._renderRatio);

        var desiredWidth = this._renderRatio.width != null ? this._renderRatio.width : requiredWidth;
        var desiredHeight = this._renderRatio.height != null ? this._renderRatio.height : requiredHeight;
		
		if (this.renderTargetSamplingMode != Texture.NEAREST_SAMPLINGMODE) {
            if (this._renderRatio.width == null) {
                desiredWidth = com.babylonhx.math.Tools.GetExponentOfTwo(desiredWidth, maxSize);
            }
			
            if (this._renderRatio.height == null) {
                desiredHeight = com.babylonhx.math.Tools.GetExponentOfTwo(desiredHeight, maxSize);
            }
        }
		
		if (this.width != desiredWidth || this.height != desiredHeight) {
			if (this._textures.length > 0) {
				for (i in 0...this._textures.length) {
					this._engine._releaseTexture(this._textures.data[i]);
				}
				this._textures.reset();
			}
			this.width = desiredWidth;
			this.height = desiredHeight;
			
			this._textures.push(this._engine.createRenderTargetTexture( { width: this.width, height: this.height }, { generateMipMaps: false, generateDepthBuffer: camera._postProcesses.indexOf(this) == camera._postProcessesTakenIndices[0], samplingMode: this.renderTargetSamplingMode, type: this._textureType } ));
			
			if (this._reusable) {
				this._textures.push(this._engine.createRenderTargetTexture({ width: this.width, height: this.height }, { generateMipMaps: false, generateDepthBuffer: camera._postProcesses.indexOf(this) == camera._postProcessesTakenIndices[0], samplingMode: this.renderTargetSamplingMode, type: this._textureType }));
			}
			
			if (this.onSizeChanged != null) {
				this.onSizeChanged();
			}			
		}
		
		if (this.enablePixelPerfectMode) {
            this._scaleRatio.copyFromFloats(requiredWidth / desiredWidth, requiredHeight / desiredHeight);
            this._engine.bindFramebuffer(this._textures.data[this._currentRenderTextureInd], 0, requiredWidth, requiredHeight);
        }
        else {
            this._scaleRatio.copyFromFloats(1, 1);
            this._engine.bindFramebuffer(this._textures.data[this._currentRenderTextureInd]);
        }
		
		if (this.onActivate != null) {
			this.onActivate(camera);
		}
		
		// Clear
		if (this.clearColor != null) {
            this._engine.clear(this.clearColor, true, true);
        } 
		else {
            this._engine.clear(scene.clearColor, scene.autoClear || scene.forceWireframe, true);
        }
		
		if (this._reusable) {
			this._currentRenderTextureInd = (this._currentRenderTextureInd + 1) % 2;
		}
	}
	
	private function get_isSupported():Bool {
        return this._effect.isSupported;
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
		if(this._textures.length > 0) {		
			this._effect._bindTexture("textureSampler", this._textures.data[this._currentRenderTextureInd]);
		}
		
		// Parameters
		this._effect.setVector2("scale", this._scaleRatio);
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
