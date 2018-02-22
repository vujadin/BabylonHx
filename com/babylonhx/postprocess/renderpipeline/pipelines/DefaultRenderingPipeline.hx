package com.babylonhx.postprocess.renderpipeline.pipelines;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.engine.Engine;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.cameras.Camera;
import com.babylonhx.postprocess.DepthOfFieldEffectBlurLevel;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * The default rendering pipeline can be added to a scene to apply common post processing effects such as anti-aliasing or depth of field.
 * See https://doc.babylonjs.com/how_to/using_default_rendering_pipeline
 */
class DefaultRenderingPipeline extends PostProcessRenderPipeline implements IDisposable implements IAnimatable {
	
	private var _scene:Scene;     

	/**
	 * ID of the pass post process used for bloom
	 */
	static inline var PassPostProcessId:String = "PassPostProcessEffect";
	/**
	 * ID of the highlight post process used for bloom
	 */
	static inline var HighLightsPostProcessId:String = "HighLightsPostProcessEffect";
	/**
	 * ID of the blurX post process used for bloom
	 */
	static inline var BlurXPostProcessId:String = "BlurXPostProcessEffect";
	/**
	 * ID of the blurY post process used for bloom
	 */
	static inline var BlurYPostProcessId:String = "BlurYPostProcessEffect";
	/**
	 * ID of the copy back post process used for bloom
	 */
	static inline var CopyBackPostProcessId:String = "CopyBackPostProcessEffect";
	/**
	 * ID of the image processing post process
	 */
	static inline var ImageProcessingPostProcessId:String = "ImageProcessingPostProcessEffect";
	/**
	 * ID of the Fast Approximate Anti-Aliasing post process
	 */
	static inline var FxaaPostProcessId:String = "FxaaPostProcessEffect";
	/**
	 * ID of the final merge post process;
	 */
	static inline var FinalMergePostProcessId:String = "FinalMergePostProcessEffect";

	// Post-processes
	/**
	 * First pass of bloom to capture the original image texture for later use.
	 */
	public var pass:PassPostProcess;
	/**
	 * Second pass of bloom used to brighten bright portions of the image.
	 */
	public var highlights:HighlightsPostProcess;
	/**
	 * BlurX post process used in coordination with blurY to guassian blur the highlighted image.
	 */
	public var blurX:BlurPostProcess;
	/**
	 * BlurY post process used in coordination with blurX to guassian blur the highlighted image.
	 */
	public var blurY:BlurPostProcess;
	/**
	 * Final pass run for bloom to copy the resulting bloom texture back to screen.
	 */
	public var copyBack:PassPostProcess;
	/**
	 * Depth of field effect, applies a blur based on how far away objects are from the focus distance.
	 */
	public var depthOfField:DepthOfFieldEffect;
	/**
	 * The Fast Approximate Anti-Aliasing post process which attemps to remove aliasing from an image.
	 */
	public var fxaa:FxaaPostProcess;
	/**
	 * Image post processing pass used to perform operations such as tone mapping or color grading.
	 */
	public var imageProcessing:ImageProcessingPostProcess;
	/**
	 * Final post process to merge results of all previous passes
	 */
	public var finalMerge:PassPostProcess;        

	/**
	 * Animations which can be used to tweak settings over a period of time
	 */
	public var animations:Array<Animation> = [];        

	// Values       
	private var _bloomEnabled:Bool = false;
	private var _depthOfFieldEnabled:Bool = false;
	private var _depthOfFieldBlurLevel:DepthOfFieldEffectBlurLevel = DepthOfFieldEffectBlurLevel.Low;
	private var _fxaaEnabled:Bool = false;
	private var _imageProcessingEnabled:Bool = true;
	private var _defaultPipelineTextureType:Int;
	private var _bloomScale:Float = 0.6;
	
	private var _buildAllowed:Bool = true;

	/**
	 * Specifies the size of the bloom blur kernel, relative to the final output size
	 */
	@serialize()
	public var bloomKernel:Int = 64;

	/**
	 * Specifies the weight of the bloom in the final rendering
	 */
	@serialize()
	private var _bloomWeight:Float = 0.15;        

	@serialize()
	private var _hdr:Bool;

	@serialize()
	public var bloomWeight(get, set):Float;
	private function set_bloomWeight(value:Float):Float {
		if (this._bloomWeight == value) {
			return value;
		}
		this._bloomWeight = value;
		
		if (this._hdr && this.copyBack != null) {
			this.copyBack.alphaConstants = new Color4(value, value, value, value);	
		}
		return value;
	}
	inline private function get_bloomWeight():Float {
		return this._bloomWeight;
	}          

	@serialize()
	public var bloomScale(get, set):Float;
	private function set_bloomScale(value:Float):Float {
		if (this._bloomScale == value) {
			return value;
		}
		this._bloomScale = value;
		
		this._buildPipeline();
		return value;
	}	
	inline private function get_bloomScale():Float {
		return this._bloomScale;
	}          

	@serialize()
	public var bloomEnabled(get, set):Bool;
	private function set_bloomEnabled(enabled:Bool):Bool {
		if (this._bloomEnabled == enabled) {
			return enabled;
		}
		this._bloomEnabled = enabled;
		
		this._buildPipeline();
		return enabled;
	}
	inline private function get_bloomEnabled():Bool {
		return this._bloomEnabled;
	}
	
	/**
	 * If the depth of field is enabled.
	 */
	@serialize()
	public var depthOfFieldEnabled(get, set):Bool;
	inline function get_depthOfFieldEnabled():Bool {
		return this._depthOfFieldEnabled;
	}	
	inline function set_depthOfFieldEnabled(enabled:Bool):Bool {
		if (this._depthOfFieldEnabled == enabled) {
			return enabled;
		}
		this._depthOfFieldEnabled = enabled;
		
		this._buildPipeline();
		return enabled;
	}
	
	/**
	 * Blur level of the depth of field effect. (Higher blur will effect performance)
	 */
	@serialize()
	public var depthOfFieldBlurLevel(get, set):DepthOfFieldEffectBlurLevel;
	inline function get_depthOfFieldBlurLevel():DepthOfFieldEffectBlurLevel {
		return this._depthOfFieldBlurLevel;
	}	
	function set_depthOfFieldBlurLevel(value:DepthOfFieldEffectBlurLevel):DepthOfFieldEffectBlurLevel {
		if (this._depthOfFieldBlurLevel == value) {
			return value;
		}
		this._depthOfFieldBlurLevel = value;
		this._buildPipeline();
		return value;
	}

	@serialize()
	public var fxaaEnabled(get, set):Bool;
	private function set_fxaaEnabled(enabled:Bool):Bool {
		if (this._fxaaEnabled == enabled) {
			return enabled;
		}
		this._fxaaEnabled = enabled;
		
		this._buildPipeline();
		return enabled;
	}
	private function get_fxaaEnabled():Bool {
		return this._fxaaEnabled;
	}

	@serialize()
	public var imageProcessingEnabled(get, set):Bool;
	private function set_imageProcessingEnabled(enabled:Bool):Bool {
		if (this._imageProcessingEnabled == enabled) {
			return enabled;
		}
		this._imageProcessingEnabled = enabled;
		
		this._buildPipeline();
		return enabled;
	}
	inline private function get_imageProcessingEnabled():Bool {
		return this._imageProcessingEnabled;
	}
	

	/**
	 * @constructor
	 * @param {string} name - The rendering pipeline name
	 * @param {BABYLON.Scene} scene - The scene linked to this pipeline
	 * @param {any} ratio - The size of the postprocesses (0.5 means that your postprocess will have a width = canvas.width 0.5 and a height = canvas.height 0.5)
	 * @param {BABYLON.Camera[]} cameras - The array of cameras that the rendering pipeline will be attached to
	 * @param {boolean} automaticBuild - if false, you will have to manually call prepare() to update the pipeline
	 */
	public function new(name:String, hdr:Bool, scene:Scene, ?cameras:Map<String, Camera>, automaticBuild:Bool = true) {
		super(scene.getEngine(), name);
		this._cameras = cameras != null ? cameras : new Map();
		
		this._buildAllowed = automaticBuild;
		
		// Initialize
		this._scene = scene;
		var caps = this._scene.getEngine().getCaps();
		this._hdr = hdr && (caps.textureHalfFloatRender || caps.textureFloatRender);
		
		// Misc
		if (this._hdr) {
			if (caps.textureHalfFloatRender) {
				this._defaultPipelineTextureType  = Engine.TEXTURETYPE_HALF_FLOAT;
			}
			else if (caps.textureFloatRender) {
				this._defaultPipelineTextureType  = Engine.TEXTURETYPE_FLOAT;
			}
		} 
		else {
			this._defaultPipelineTextureType = Engine.TEXTURETYPE_UNSIGNED_INT;
		}
		
		// Attach
		scene.postProcessRenderPipelineManager.addPipeline(this);
		
		this._buildPipeline();
	}
	
	/**
     * Force the compilation of the entire pipeline.
     */
    public function prepare() {
        var previousState = this._buildAllowed;
        this._buildAllowed = true;
        this._buildPipeline();
        this._buildAllowed = previousState;
    }

	private function _buildPipeline() {
		if (!this._buildAllowed) {
			return;
		}
		
		var engine = this._scene.getEngine();
		
		this._disposePostProcesses();
		this._reset();
		
		if(this.depthOfFieldEnabled){
			// Enable and get current depth map
			var depthTexture = this._scene.enableDepthRenderer(this._cameras["0"]).getDepthMap();
			
			this.depthOfField = new DepthOfFieldEffect(this._scene, depthTexture, this._depthOfFieldBlurLevel, this._defaultPipelineTextureType);
			this.addEffect(this.depthOfField);
		}
		
		if (this.bloomEnabled) {
			this.pass = new PassPostProcess("sceneRenderTarget", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, PassPostProcessId, function() { return [this.pass]; }, true));
			
			if (!this._hdr) { // Need to enhance highlights if not using float rendering
				this.highlights = new HighlightsPostProcess("highlights", this.bloomScale, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
				this.addEffect(new PostProcessRenderEffect(engine, HighLightsPostProcessId, function() { return [this.highlights]; }, true));
				this.highlights.autoClear = false;
				this.highlights.alwaysForcePOT = true;
			}
			
			this.blurX = new BlurPostProcess("horizontal blur", new Vector2(1.0, 0), 10.0, this.bloomScale, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, BlurXPostProcessId, function() { return [this.blurX]; }, true));
			this.blurX.alwaysForcePOT = true;
			this.blurX.autoClear = false;
			this.blurX.onActivateObservable.add(function(_, _) {
				var dw = this.blurX.width / engine.getRenderWidth();
				this.blurX.kernel = this.bloomKernel * dw;
			});
			
			this.blurY = new BlurPostProcess("vertical blur", new Vector2(0, 1.0), 10.0, this.bloomScale, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, BlurYPostProcessId, function() { return [this.blurY]; }, true));
			this.blurY.alwaysForcePOT = true;
			this.blurY.autoClear = false;
			this.blurY.onActivateObservable.add(function(_, _) {
				var dh = this.blurY.height / engine.getRenderHeight();
				this.blurY.kernel = this.bloomKernel * dh;
			});
			
			this.copyBack = new PassPostProcess("bloomBlendBlit", this.bloomScale, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);			
			this.addEffect(new PostProcessRenderEffect(engine, CopyBackPostProcessId, function() { return [this.copyBack]; }, true));
			this.copyBack.alwaysForcePOT = true;
			if (this._hdr) {
				this.copyBack.alphaMode = Engine.ALPHA_INTERPOLATE;
				var w = this.bloomWeight;
				this.copyBack.alphaConstants = new Color4(w, w, w, w);			
			} 
			else {
				this.copyBack.alphaMode = Engine.ALPHA_SCREENMODE;
			}
			this.copyBack.autoClear = false;
		}
		
		if (this._imageProcessingEnabled) {
			this.imageProcessing = new ImageProcessingPostProcess("imageProcessing",  1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			if (this._hdr) {
				this.addEffect(new PostProcessRenderEffect(engine, ImageProcessingPostProcessId, function() { return [this.imageProcessing]; }, true));
			}
			else {
                this._scene.imageProcessingConfiguration.applyByPostProcess = false;
            }
		}
		
		if (this.fxaaEnabled) {
			this.fxaa = new FxaaPostProcess("fxaa", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, FxaaPostProcessId, function() { return [this.fxaa]; }, true));
			
			this.fxaa.autoClear = !this.bloomEnabled && this.imageProcessing == null;
		} 
		else {
			this.finalMerge = new PassPostProcess("finalMerge", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, FinalMergePostProcessId, function() { return [this.finalMerge]; }, true)); 
			
			this.finalMerge.autoClear = !this.bloomEnabled && this.imageProcessing == null;
		}
		
		if (this.bloomEnabled) {
			if (this._hdr) { // Share render targets to save memory
				this.copyBack.shareOutputWith(this.blurX);	
				if (this.imageProcessing != null) {	
					this.imageProcessing.shareOutputWith(this.pass);			
					this.imageProcessing.autoClear = false;
				} 
				else if (this.fxaa != null) {
					this.fxaa.shareOutputWith(this.pass);		
				} 
				else {
					this.finalMerge.shareOutputWith(this.pass);	
				} 
			} 
			else  {
				if (this.fxaa != null) {
					this.fxaa.shareOutputWith(this.pass);		
				} 
				else {
					this.finalMerge.shareOutputWith(this.pass);	
				} 
			}
		}
		
		if (this._cameras != null) {
			this._scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline(this._name, this._cameras);
		}
		
		this._enableMSAAOnFirstPostProcess();
	}

	private function _disposePostProcesses() {
		for (key in this._cameras.keys()) {
			var camera = this._cameras[key];
			
			if (this.pass != null) {
				this.pass.dispose(camera);
			}
			
			if (this.highlights != null) {
				this.highlights.dispose(camera);
			}
			
			if (this.blurX != null) {
				this.blurX.dispose(camera);
			}
			
			if (this.blurY != null) {
				this.blurY.dispose(camera);
			}
			
			if (this.copyBack != null) {
				this.copyBack.dispose(camera);
			}
			
			if (this.imageProcessing != null) {
				this.imageProcessing.dispose(camera);
			}       
			
			if (this.fxaa != null) {
				this.fxaa.dispose(camera);
			}
			
			if (this.finalMerge != null) {
				this.finalMerge.dispose(camera);
			}
			
			if (this.depthOfField != null) {
				this.depthOfField.disposeEffects(camera);
			}
		}
		
		this.pass = null;
		this.highlights = null;
		this.blurX = null;
		this.blurY = null;
		this.copyBack = null;
		this.imageProcessing = null;
		this.fxaa = null;
		this.finalMerge = null;
		this.depthOfField = null;
	}

	// Dispose
	override public function dispose(disableDepthRender:Bool = false) {
		this._disposePostProcesses();
		
		this._scene.postProcessRenderPipelineManager.detachCamerasFromRenderPipeline(this._name, this._cameras);
		
		super.dispose();
	}

	// Serialize rendering pipeline
	public function serialize():Dynamic {
		/*var serializationObject = SerializationHelper.Serialize(this);   
		serializationObject.customType = "DefaultRenderingPipeline";
		
		return serializationObject;*/
		return null;
	}

	/**
	 * Parse the serialized pipeline
	 * @param source Source pipeline.
	 * @param scene The scene to load the pipeline to.
	 * @param rootUrl The URL of the serialized pipeline.
	 * @returns An instantiated pipeline from the serialized object.
	 */
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):DefaultRenderingPipeline {
		return SerializationHelper.Parse(function() { return new DefaultRenderingPipeline(source._name, source._name._hdr, scene); }, source, scene, rootUrl);
	}
	
}
