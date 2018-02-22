package com.babylonhx.postprocess;

import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.animations.Animation;
import com.babylonhx.materials.textures.InternalTexture;
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

/**
 * PostProcess can be used to apply a shader to a texture after it has been rendered
 * See https://doc.babylonjs.com/how_to/how_to_use_postprocesses
 */
@:expose('BABYLON.PostProcess') class PostProcess {
	
	public var name:String;
	
	/**
	 * Width of the texture to apply the post process on
	 */
	public var width:Int = -1;
	/**
	 * Height of the texture to apply the post process on
	 */
	public var height:Int = -1;
	/**
	 * Sampling mode used by the shader
	 * See https://doc.babylonjs.com/classes/3.1/texture
	 */
	public var renderTargetSamplingMode:Int;
	/**
	 * Clear color to use when screen clearing
	 */
	public var clearColor:Color4;
	/**
	 * If the buffer needs to be cleared before applying the post process. (default: true)
	 * Should be set to false if shader will overwrite all previous pixels.
	 */
	public var autoClear:Bool = true;
	/**
	 * Type of alpha mode to use when performing the post process (default: Engine.ALPHA_DISABLE)
	 */
	public var alphaMode:Int = Engine.ALPHA_DISABLE;
	/**
	 * Sets the setAlphaBlendConstants of the babylon engine
	 */
	public var alphaConstants:Color4;
	/**
	 * Animations to be used for the post processing 
	 */
	public var animations:Array<Animation> = [];
	
	/*
        Enable Pixel Perfect mode where texture is not scaled to be power of 2.
        Can only be used on a single postprocess or on the last one of a chain.
    */ 
    public var enablePixelPerfectMode:Bool = false;
	
	/**
	 * Scale mode for the post process (default: Engine.SCALEMODE_FLOOR)
	 */
	public var scaleMode:Int = Engine.SCALEMODE_FLOOR;
	/**
	 * Force textures to be a power of two (default: false)
	 */
	public var alwaysForcePOT:Bool = false;
	/**
	 * Number of sample textures (default: 1)
	 */
	public var samples:Int = 1;
	/**
	 * Modify the scale of the post process to be the same as the viewport (default: false)
	 */
	public var adaptScaleToCurrentViewport:Bool = false;

	private var _camera:Camera;
	private var _scene:Scene;
	private var _engine:Engine;
	private var _options:Dynamic; // number | PostProcessOptions
	private var _reusable:Bool = false;
	private var _textureType:Int;
	/**
	 * Smart array of input and output textures for the post process.
	 */
	public var _textures:SmartArray<InternalTexture> = new SmartArray<InternalTexture>(2);
	/**
	 * The index in _textures that corresponds to the output texture.
	 */
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
	private var _forcedOutputTexture:InternalTexture;
	
	// Events

	/**
	* An event triggered when the postprocess is activated.
	* @type {BABYLON.Observable}
	*/
	public var onActivateObservable:Observable<Camera> = new Observable<Camera>();

	private var _onActivateObserver:Observer<Camera>;
	public var onActivate(default, set):Camera->Null<EventState>->Void;
	private function set_onActivate(callback:Camera->Null<EventState>->Void) {
		if (this._onActivateObserver != null) {
			this.onActivateObservable.remove(this._onActivateObserver);
		}
		if (callback != null) {
			this._onActivateObserver = this.onActivateObservable.add(callback);
		}
		
		return callback;
	}

	/**
	* An event triggered when the postprocess changes its size.
	* @type {BABYLON.Observable}
	*/
	public var onSizeChangedObservable:Observable<PostProcess> = new Observable<PostProcess>();
	private var _onSizeChangedObserver:Observer<PostProcess>;
	public var onSizeChanged(default, set):PostProcess->Null<EventState>->Void;
	private function set_onSizeChanged(callback:PostProcess->Null<EventState>->Void) {
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
	public var onApply(default, set):Effect->Null<EventState>->Void;
	private function set_onApply(callback:Effect->Null<EventState>->Void) {
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
	public var onBeforeRender(default, set):Effect->Null<EventState>->Void;
	private function set_onBeforeRender(callback:Effect->Null<EventState>->Void) {
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
	public var onAfterRender(default, set):Effect->Null<EventState>->Void;
	private function set_onAfterRender(callback:Effect->Null<EventState>->Void) {
		if (this._onAfterRenderObserver != null) {
			this.onAfterRenderObservable.remove(this._onAfterRenderObserver);
		}
		this._onAfterRenderObserver = this.onAfterRenderObservable.add(callback);
		
		return callback;
	}
	
	public var inputTexture(get, set):InternalTexture;
	private function get_inputTexture():InternalTexture {
		return this._textures.data[this._currentRenderTextureInd];
	}
	private function set_inputTexture(value:InternalTexture):InternalTexture {
		return this._forcedOutputTexture = value;
	}

	public function getCamera():Camera {
		return this._camera;
	}

	/**
	 * Gets the texel size of the postprocess.
	 * See https://en.wikipedia.org/wiki/Texel_(graphics)
	 */
	public var texelSize(get, never):Vector2;
	private function get_texelSize():Vector2 {
		if (this._shareOutputWithPostProcess != null) {
			return this._shareOutputWithPostProcess.texelSize;
		}
		
		if (this._forcedOutputTexture != null) {
            this._texelSize.copyFromFloats(1.0 / this._forcedOutputTexture.width, 1.0 / this._forcedOutputTexture.height);
        }
		
		return this._texelSize;
	}
	

	/**
	 * Creates a new instance of @see PostProcess
	 * @param name The name of the PostProcess.
	 * @param fragmentUrl The url of the fragment shader to be used.
	 * @param parameters Array of the names of uniform non-sampler2D variables that will be passed to the shader.
	 * @param samplers Array of the names of uniform sampler2D variables that will be passed to the shader.
	 * @param options The required width/height ratio to downsize to before computing the render pass. (Use 1.0 for full size)
	 * @param camera The camera to apply the render pass to.
	 * @param samplingMode The sampling mode to be used when computing the pass. (default: 0)
	 * @param engine The engine which the post process will be applied. (default: current engine)
	 * @param reusable If the post process can be reused on the same frame. (default: false)
	 * @param defines String of defines that will be set when running the fragment shader. (default: null)
	 * @param textureType Type of textures used when performing the post process. (default: 0)
	 * @param vertexUrl The url of the vertex shader to be used. (default: "postprocess")
	 * @param indexParameters The index parameters to be used for babylons include syntax "#include<kernelBlurVaryingDeclaration>[0..varyingCount]". (default: undefined) See usage in babylon.blurPostProcess.ts and kernelBlur.vertex.fx
	 * @param blockCompilation If the shader should not be compiled imediatly. (default: false) 
	 */
	public function new(name:String, fragmentUrl:String, parameters:Array<String>, samplers:Array<String>, options:Dynamic, camera:Camera, samplingMode:Int = Texture.NEAREST_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false, defines:String = "", textureType:Int = Engine.TEXTURETYPE_UNSIGNED_INT, vertexUrl:String = "postprocess", ?indexParameters:Dynamic, blockCompilation:Bool = false) {
		if (camera != null) {
			this._camera = camera;
			this._scene = camera.getScene();
			camera.attachPostProcess(this);
			this._engine = this._scene.getEngine();
			
			this._scene.postProcesses.push(this);
		}
		else {
			this._engine = engine;
			this._engine.postProcesses.push(this);
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

	/**
	 * To avoid multiple redundant textures for multiple post process, the output the output texture for this post process can be shared with another.
	 * @param postProcess The post process to share the output with.
	 * @returns This post process.
	 */
	public function shareOutputWith(postProcess:PostProcess):PostProcess {
		this._disposeTextures();
		
		this._shareOutputWithPostProcess = postProcess;
		
		return this;
	}
	
	/**
	 * Updates the effect with the current post process compile time values and recompiles the shader.
	 * @param defines Define statements that should be added at the beginning of the shader. (default: null)
	 * @param uniforms Set of uniform variables that will be passed to the shader. (default: null)
	 * @param samplers Set of Texture2D variables that will be passed to the shader. (default: null)
	 * @param indexParameters The index parameters to be used for babylons include syntax "#include<kernelBlurVaryingDeclaration>[0..varyingCount]". (default: undefined) See usage in babylon.blurPostProcess.ts and kernelBlur.vertex.fx
	 * @param onCompiled Called when the shader has been compiled.
	 * @param onError Called if there is an error when compiling a shader.
	 */
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
	}

	/**
	 * The post process is reusable if it can be used multiple times within one frame.
	 * @returns If the post process is reusable
	 */
	public function isReusable():Bool {
		return this._reusable;
	}
	
	/** invalidate frameBuffer to hint the postprocess to create a depth buffer */
    public function markTextureDirty() {
        this.width = -1;
    }

	/**
	 * Activates the post process by intializing the textures to be used when executed. Notifies onActivateObservable.
	 * When this post process is used in a pipeline, this is call will bind the input texture of this post process to the output of the previous.
	 * @param camera The camera that will be used in the post process. This camera will be used when calling onActivateObservable.
	 * @param sourceTexture The source texture to be inspected to get the width and height if not specified in the post process constructor. (default: null)
	 * @param forceDepthStencil If true, a depth and stencil buffer will be generated. (default: false)
	 */
	public function activate(camera:Camera = null, ?sourceTexture:InternalTexture, forceDepthStencil:Bool = false) {
		if (camera == null) {
			camera = this._camera;
		}
		
		var scene = camera.getScene();
		var engine = scene.getEngine();
		var maxSize = engine.getCaps().maxTextureSize;
		
		var requiredWidth = sourceTexture != null ? sourceTexture.width : this._engine.getRenderWidth();
		var requiredHeight = sourceTexture != null ? sourceTexture.height : this._engine.getRenderHeight();
		
		var desiredWidth = this._options.width != null ? this._options.width : requiredWidth;
		var desiredHeight = this._options.height != null ? this._options.height : requiredHeight;
		
		if (this._shareOutputWithPostProcess == null && this._forcedOutputTexture == null) {
			if (this.adaptScaleToCurrentViewport) {
				var currentViewport = scene.getEngine().currentViewport;
				
				if (currentViewport != null) {
					desiredWidth = Std.int(desiredWidth *currentViewport.width);
					desiredHeight = Std.int(desiredHeight * currentViewport.height);
				}
			}
				
			if (this.renderTargetSamplingMode == Texture.TRILINEAR_SAMPLINGMODE || this.alwaysForcePOT) {
				if (this._options.width == null) {
					desiredWidth = this._engine.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(desiredWidth, maxSize, this.scaleMode) : desiredWidth;
				}
				
				if (this._options.height == null) {
					desiredHeight = this._engine.needPOTTextures ? com.babylonhx.math.Tools.GetExponentOfTwo(desiredHeight, maxSize, this.scaleMode) : desiredHeight;
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
		
		var target:InternalTexture = null;
        
        if (this._shareOutputWithPostProcess != null) {
            target = this._shareOutputWithPostProcess.inputTexture;
        } 
		else if (this._forcedOutputTexture != null) {
            target = this._forcedOutputTexture;
			
			this.width = this._forcedOutputTexture.width;
            this.height = this._forcedOutputTexture.height;
        } 
		else {
            target = this.inputTexture;
        }
		
		// Bind the input of this post process to be used as the output of the previous post process.
		if (this.enablePixelPerfectMode) {
			this._scaleRatio.copyFromFloats(requiredWidth / desiredWidth, requiredHeight / desiredHeight);
			this._engine.bindFramebuffer(target, 0, requiredWidth, requiredHeight, true);
		}
		else {
			this._scaleRatio.copyFromFloats(1, 1);
			this._engine.bindFramebuffer(target, 0, null, null, true);
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
	
	/**
	 * If the post process is supported.
	 */
	public var isSupported(get, never):Bool;
	private function get_isSupported():Bool {
        return this._effect.isSupported;
    }
	
	/**
	 * The aspect ratio of the output texture.
	 */
	public var aspectRatio(get, never):Float;
	private function get_aspectRatio():Float {
		if (this._shareOutputWithPostProcess != null) {
			return this._shareOutputWithPostProcess.aspectRatio;
		}
		
		if (this._forcedOutputTexture != null) {
            var size = this._forcedOutputTexture.width / this._forcedOutputTexture.height;
        }
		
		return this.width / this.height;
	}
	
	/**
     * Get a value indicating if the post-process is ready to be used
     * @returns true if the post-process is ready (shader is compiled)
     */
    public function isReady():Bool {
        return this._effect != null && this._effect.isReady();
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
		var source:InternalTexture = null;                        
        if (this._shareOutputWithPostProcess != null) {
            source = this._shareOutputWithPostProcess.inputTexture;
        } 
		else if (this._forcedOutputTexture != null) {
            source = this._forcedOutputTexture;
        } 
		else {
            source = this.inputTexture;
        }
		this._effect._bindTexture("textureSampler", source != null ? source : null);
		
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
		
		if (this._scene != null) {
            var index = this._scene.postProcesses.indexOf(this);
            if (index != -1) {
                this._scene.postProcesses.splice(index, 1);
			}                
		}
		else {
            var index = this._engine.postProcesses.indexOf(this);
            if (index != -1) {
                this._engine.postProcesses.splice(index, 1);
            }         
        }
		
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
