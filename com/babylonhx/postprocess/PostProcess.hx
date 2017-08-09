package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.WebGLTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef PostProcessOption = {
	var width:Float;
	var height:Float;
}

@:expose('BABYLON.PostProcess') class PostProcess {
	
	public var name:String;
	
	public var width:Int = -1;
	public var height:Int = -1;
	public var renderTargetSamplingMode:Int;
	public var clearColor:Color4;
	public var autoClear:Bool = true;
	public var alphaMode:Int = Engine.ALPHA_DISABLE;
	public var alphaConstants:Color4;  
	
	/*
        Enable Pixel Perfect mode where texture is not scaled to be power of 2.
        Can only be used on a single postprocess or on the last one of a chain.
    */ 
    public var enablePixelPerfectMode:Bool = false;
	
	public var scaleMode:Int = Engine.SCALEMODE_FLOOR;
	public var alwaysForcePOT:Bool = false;
	public var samples:Int = 1;

	private var _camera:Camera;
	private var _scene:Scene;
	private var _engine:Engine;
	private var _options:Dynamic; // number | PostProcessOptions
	private var _reusable:Bool = false;
	private var _textureType:Int;
	public var _textures:SmartArray<WebGLTexture> = new SmartArray<WebGLTexture>(2);
	public var _currentRenderTextureInd:Int = 0;
	public var _effect:Effect;	
	private var _samplers:Array<String>;
    private var _fragmentUrl:String;
	private var _vertexUrl:String;
    private var _parameters:Array<String>;
	private var _scaleRatio:Vector2 = new Vector2(1, 1);
	public var _indexParameters:Dynamic;
	private var _shareOutputWithPostProcess:PostProcess;
	private var _texelSize:Vector2 = Vector2.Zero();
	private var _forcedOutputTexture:WebGLTexture;
	
	// Events

	/**
	* An event triggered when the postprocess is activated.
	* @type {BABYLON.Observable}
	*/
	public var onActivateObservable:Observable<Camera> = new Observable<Camera>();

	private var _onActivateObserver:Observer<Camera>;
	public var onActivate(never, set):Camera->Null<EventState>->Void;
	private function set_onActivate(callback:Camera->Null<EventState>->Void):Camera->Null<EventState>->Void {
		if (this._onActivateObserver != null) {
			this.onActivateObservable.remove(this._onActivateObserver);
		}
		this._onActivateObserver = this.onActivateObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered when the postprocess changes its size.
	* @type {BABYLON.Observable}
	*/
	public var onSizeChangedObservable:Observable<PostProcess> = new Observable<PostProcess>();
	private var _onSizeChangedObserver:Observer<PostProcess>;
	public var onSizeChanged:PostProcess->Null<EventState>->Void;
	private function set_onSizeChanged(callback:PostProcess->Null<EventState>->Void):PostProcess->Null<EventState>->Void {
		if (this._onSizeChangedObserver != null) {
			this.onSizeChangedObservable.remove(this._onSizeChangedObserver);
		}
		this._onSizeChangedObserver = this.onSizeChangedObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered when the postprocess applies its effect.
	* @type {BABYLON.Observable}
	*/
	public var onApplyObservable:Observable<Effect> = new Observable<Effect>();
	private var _onApplyObserver:Observer<Effect>;
	public var onApply(never, set):Effect->Null<EventState>->Void;
	private function set_onApply(callback:Effect->Null<EventState>->Void):Effect->Null<EventState>->Void {
		if (this._onApplyObserver != null) {
			this.onApplyObservable.remove(this._onApplyObserver);
		}
		this._onApplyObserver = this.onApplyObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered before rendering the postprocess
	* @type {BABYLON.Observable}
	*/
	public var onBeforeRenderObservable:Observable<Effect> = new Observable<Effect>();
	private var _onBeforeRenderObserver:Observer<Effect>;
	public var onBeforeRender:Effect->Null<EventState>->Void;
	private function set_onBeforeRender(callback:Effect->Null<EventState>->Void):Effect->Null<EventState>->Void {
		if (this._onBeforeRenderObserver != null) {
			this.onBeforeRenderObservable.remove(this._onBeforeRenderObserver);
		}
		this._onBeforeRenderObserver = this.onBeforeRenderObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered after rendering the postprocess
	* @type {BABYLON.Observable}
	*/
	public var onAfterRenderObservable:Observable<Effect> = new Observable<Effect>();

	private var _onAfterRenderObserver:Observer<Effect>;
	public var onAfterRender:Effect->Null<EventState>->Void;
	private function set_onAfterRender(callback:Effect->Null<EventState>->Void):Effect->Null<EventState>->Void {
		if (this._onAfterRenderObserver != null) {
			this.onAfterRenderObservable.remove(this._onAfterRenderObserver);
		}
		this._onAfterRenderObserver = this.onAfterRenderObservable.add(callback);
		
		return callback;
	}
	
	public var outputTexture(get, set):WebGLTexture;
	private function get_outputTexture():WebGLTexture {
		return this._textures.data[this._currentRenderTextureInd];
	}
	private function set_outputTexture(value:WebGLTexture):WebGLTexture {
		return this._forcedOutputTexture = value;
	}

	public function getCamera():Camera {
		return this._camera;
	}

	public var texelSize(get, never):Vector2;
	private function get_texelSize():Vector2 {
		if (this._shareOutputWithPostProcess != null) {
			return this._shareOutputWithPostProcess.texelSize;
		}
		
		if (this._forcedOutputTexture != null) {
            this._texelSize.copyFromFloats(1.0 / this._forcedOutputTexture._width, 1.0 / this._forcedOutputTexture._height);
        }
		
		return this._texelSize;
	}
	

	public function new(name:String, fragmentUrl:String, parameters:Array<String>, samplers:Array<String>, options:Dynamic, camera:Camera, samplingMode:Int = Texture.NEAREST_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false, defines:String = "", textureType:Int = Engine.TEXTURETYPE_UNSIGNED_INT, vertexUrl:String = "postprocess", ?indexParameters:Dynamic, blockCompilation:Bool = false) {
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
		
		this._options = options;
		this.renderTargetSamplingMode = samplingMode;
		this._reusable = reusable;
		this._textureType = textureType;
		
		this._samplers = samplers != null ? samplers : [];
		this._samplers.push("textureSampler");
		
		this._fragmentUrl = fragmentUrl;
		this._vertexUrl = vertexUrl;
		this._parameters = parameters != null ? parameters : [];
		
		this._parameters.push("scale");
		
		this._indexParameters = indexParameters;
		
		if (!blockCompilation) {
			this.updateEffect(defines);
		}
	}
	
	inline public function getEngine():Engine {
		return this._engine;
	}
	
	inline public function getEffect():Effect {
		return this._effect;
	}

	public function shareOutputWith(postProcess:PostProcess):PostProcess {
		this._disposeTextures();
		
		this._shareOutputWithPostProcess = postProcess;
		
		return this;
	}
	
	public function updateEffect(defines:String = null, uniforms:Array<String> = null, samplers:Array<String> = null, ?indexParameters:Dynamic, ?onCompiled:Effect->Void, ?onError:Effect->String->Void) {
		this._effect = this._engine.createEffect({ vertex: this._vertexUrl, fragment: this._fragmentUrl },
			["position"],
			uniforms != null ? uniforms : this._parameters,
			samplers != null ? samplers : this._samplers, 
			defines != null ? defines : "",
			null,
			onCompiled,
			onError,
			indexParameters != null ? indexParameters : this._indexParameters
		);
		trace(name + " - " + samplers + " , " + this._samplers);
	}

	public function isReusable():Bool {
		return this._reusable;
	}
	
	/** invalidate frameBuffer to hint the postprocess to create a depth buffer */
    public function markTextureDirty() {
        this.width = -1;
    }

	public function activate(camera:Camera, ?sourceTexture:WebGLTexture, forceDepthStencil:Bool = false) {
		if (camera == null) {
			camera = this._camera;
		}
		
		var scene = camera.getScene();
		var engine = scene.getEngine();
        var maxSize = engine.getCaps().maxTextureSize;
		
		var requiredWidth = sourceTexture != null ? sourceTexture._width : this._engine.getRenderWidth();
		var requiredHeight = sourceTexture != null ? sourceTexture._height : this._engine.getRenderHeight();
		
		var desiredWidth = this._options.width != null ? this._options.width : requiredWidth;
		var desiredHeight = this._options.height != null ? this._options.height : requiredHeight;
		
		if (this._shareOutputWithPostProcess == null && this._forcedOutputTexture == null) {
			var maxSize = camera.getEngine().getCaps().maxTextureSize;
			
			if (this.renderTargetSamplingMode == Texture.TRILINEAR_SAMPLINGMODE || this.alwaysForcePOT) {
				if (this._options.width == null) {
					desiredWidth = engine.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(desiredWidth, maxSize, this.scaleMode) : desiredWidth;
				}
				
				if (this._options.height == null) {
					desiredHeight = engine.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(desiredHeight, maxSize, this.scaleMode) : desiredHeight;
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
				
				var textureSize = { width: this.width, height: this.height };
				var textureOptions = { 
					generateMipMaps: false, 
					generateDepthBuffer: forceDepthStencil || camera._postProcesses.indexOf(this) == 0, 
					generateStencilBuffer: (forceDepthStencil || camera._postProcesses.indexOf(this) == 0) && this._engine.isStencilEnable,
					samplingMode: this.renderTargetSamplingMode, 
					type: this._textureType 
				};
				
				this._textures.push(this._engine.createRenderTargetTexture(textureSize, textureOptions));
				
				if (this._reusable) {
					this._textures.push(this._engine.createRenderTargetTexture(textureSize, textureOptions));
				}
				
				this._texelSize.copyFromFloats(1.0 / this.width, 1.0 / this.height);
				
				this.onSizeChangedObservable.notifyObservers(this);
			}
			
			for (texture in this._textures.data) {
				if (texture.samples != this.samples) {
					this._engine.updateRenderTargetTextureSampleCount(texture, this.samples);
				}
			}
		}
		
		var target:WebGLTexture = null;
        
        if (this._shareOutputWithPostProcess != null) {
            target = this._shareOutputWithPostProcess.outputTexture;
        } 
		else if (this._forcedOutputTexture != null) {
            target = this._forcedOutputTexture;
			
			this.width = this._forcedOutputTexture._width;
            this.height = this._forcedOutputTexture._height;
        } 
		else {
            target = this.outputTexture;
        }
		
		if (this.enablePixelPerfectMode) {
			this._scaleRatio.copyFromFloats(requiredWidth / desiredWidth, requiredHeight / desiredHeight);
			this._engine.bindFramebuffer(target, 0, requiredWidth, requiredHeight);
		}
		else {
			this._scaleRatio.copyFromFloats(1, 1);
			this._engine.bindFramebuffer(target);
		}
		
		this.onActivateObservable.notifyObservers(camera);
		
		// Clear
		if (this.autoClear && this.alphaMode == Engine.ALPHA_DISABLE) {
			this._engine.clear(this.clearColor != null ? this.clearColor : scene.clearColor, true, true, true);
		}
		
		if (this._reusable) {
			this._currentRenderTextureInd = (this._currentRenderTextureInd + 1) % 2;
		}
	}
	
	public var isSupported(get, never):Bool;
	private function get_isSupported():Bool {
        return this._effect.isSupported;
    }
	
	public var aspectRatio(get, never):Float;
	private function get_aspectRatio():Float {
		if (this._shareOutputWithPostProcess != null) {
			return this._shareOutputWithPostProcess.aspectRatio;
		}
		
		if (this._forcedOutputTexture != null) {
            var size = this._forcedOutputTexture._width / this._forcedOutputTexture._height;
        }
		
		return this.width / this.height;
	}

	public function apply():Effect {
		// Check
		if (this._effect == null || !this._effect.isReady()) {
			return null;
		}
		
		// States
		this._engine.enableEffect(this._effect);
		this._engine.setState(false);
		this._engine.setDepthBuffer(false);
		this._engine.setDepthWrite(false);
		
		// Alpha
		this._engine.setAlphaMode(this.alphaMode);
		if (this.alphaConstants != null) {
			this.getEngine().setAlphaConstants(this.alphaConstants.r, this.alphaConstants.g, this.alphaConstants.b, this.alphaConstants.a);
		}
		
		// Texture
		var source:WebGLTexture = null;                        
        if (this._shareOutputWithPostProcess != null) {
            source = this._shareOutputWithPostProcess.outputTexture;
        } 
		else if (this._forcedOutputTexture != null) {
            source = this._forcedOutputTexture;
        } 
		else {
            source = this.outputTexture;
        }
		this._effect._bindTexture("textureSampler", source != null ? source.data : null);
		
		// Parameters
		this._effect.setVector2("scale", this._scaleRatio);
		this.onApplyObservable.notifyObservers(this._effect);
		
		return this._effect;
	}
	
	private function _disposeTextures() {
		if (this._shareOutputWithPostProcess != null || this._forcedOutputTexture != null) {
			return;
		}
		
		if (this._textures.length > 0) {
			for (i in 0...this._textures.length) {
				this._engine._releaseTexture(this._textures.data[i]);
			}
		}
		this._textures.dispose();
	}

	public function dispose(?camera:Camera) {
		camera = camera != null ? camera : this._camera;
		
		this._disposeTextures();
		
		if (camera == null) {
			return;
		}
		camera.detachPostProcess(this);
		
		var index = camera._postProcesses.indexOf(this);
		if (index == 0 && camera._postProcesses.length > 0) {
            this._camera._postProcesses[0].markTextureDirty(); 
        }
		
		this.onActivateObservable.clear();
        this.onAfterRenderObservable.clear();
        this.onApplyObservable.clear();
        this.onBeforeRenderObservable.clear();
        this.onSizeChangedObservable.clear();
	}
	
}
