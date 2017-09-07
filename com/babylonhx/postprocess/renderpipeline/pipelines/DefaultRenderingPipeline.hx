package com.babylonhx.postprocess.renderpipeline.pipelines;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DefaultRenderingPipeline extends PostProcessRenderPipeline implements IDisposable implements IAnimatable {
	
	private var _scene:Scene;     

	var PassPostProcessId:String = "PassPostProcessEffect";           
	var HighLightsPostProcessId:String = "HighLightsPostProcessEffect";  
	var BlurXPostProcessId:String = "BlurXPostProcessEffect";  
	var BlurYPostProcessId:String = "BlurYPostProcessEffect";  
	var CopyBackPostProcessId:String = "CopyBackPostProcessEffect";  
	var ImageProcessingPostProcessId:String = "ImageProcessingPostProcessEffect";  
	var FxaaPostProcessId:String = "FxaaPostProcessEffect";           
	var FinalMergePostProcessId:String = "FinalMergePostProcessEffect";

	// Post-processes
	public var pass:PassPostProcess;
	public var highlights:HighlightsPostProcess;
	public var blurX:BlurPostProcess;
	public var blurY:BlurPostProcess;
	public var copyBack:PassPostProcess;
	public var fxaa:FxaaPostProcess;
	public var imageProcessing:ImageProcessingPostProcess;
	public var finalMerge:PassPostProcess;        

	// IAnimatable
	public var animations:Array<Animation> = [];        

	// Values       
	private var _bloomEnabled:Bool = false;
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
	public function new(name:String, hdr:Bool, scene:Scene, ?cameras:Dynamic, automaticBuild:Bool = true) {
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
		
		if (this.bloomEnabled) {
			this.pass = new PassPostProcess("sceneRenderTarget", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, this.PassPostProcessId, function() { return this.pass; }, true));
			
			if (!this._hdr) { // Need to enhance highlights if not using float rendering
				this.highlights = new HighlightsPostProcess("highlights", this.bloomScale, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
				this.addEffect(new PostProcessRenderEffect(engine, this.HighLightsPostProcessId, function() { return this.highlights; }, true));
				this.highlights.autoClear = false;
				this.highlights.alwaysForcePOT = true;
			}
			
			this.blurX = new BlurPostProcess("horizontal blur", new Vector2(1.0, 0), 10.0, this.bloomScale, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, this.BlurXPostProcessId, function() { return this.blurX; }, true));
			this.blurX.alwaysForcePOT = true;
			this.blurX.autoClear = false;
			this.blurX.onActivateObservable.add(function(_, _) {
				var dw = this.blurX.width / engine.getRenderingCanvas().width;
				this.blurX.kernel = this.bloomKernel * dw;
			});
			
			this.blurY = new BlurPostProcess("vertical blur", new Vector2(0, 1.0), 10.0, this.bloomScale, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, this.BlurYPostProcessId, function() { return this.blurY; }, true));
			this.blurY.alwaysForcePOT = true;
			this.blurY.autoClear = false;
			this.blurY.onActivateObservable.add(function(_, _) {
				var dh = this.blurY.height / engine.getRenderingCanvas().height;
				this.blurY.kernel = this.bloomKernel * dh;
			});
			
			this.copyBack = new PassPostProcess("bloomBlendBlit", this.bloomScale, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);			
			this.addEffect(new PostProcessRenderEffect(engine, this.CopyBackPostProcessId, function() { return this.copyBack; }, true));
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
				this.addEffect(new PostProcessRenderEffect(engine, this.ImageProcessingPostProcessId, function() { return this.imageProcessing; }, true));
			}
			else {
                this._scene.imageProcessingConfiguration.applyByPostProcess = false;
            }
		}
		
		if (this.fxaaEnabled) {
			this.fxaa = new FxaaPostProcess("fxaa", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, this.FxaaPostProcessId, function() { return this.fxaa; }, true));
			
			this.fxaa.autoClear = !this.bloomEnabled && this.imageProcessing == null;
		} 
		else {
			this.finalMerge = new PassPostProcess("finalMerge", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._defaultPipelineTextureType);
			this.addEffect(new PostProcessRenderEffect(engine, this.FinalMergePostProcessId, function() { return this.finalMerge; }, true)); 
			
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
	}

	private function _disposePostProcesses() {
		for (key in this._cameras.keys()) {
			var camera = this._cameras[key];
			
			if (this.pass != null) {
				this.pass.dispose(camera);
				this.pass = null;
			}
			
			if (this.highlights != null) {
				this.highlights.dispose(camera);
				this.highlights = null;
			}
			
			if (this.blurX != null) {
				this.blurX.dispose(camera);
				this.blurX = null;
			}
			
			if (this.blurY != null) {
				this.blurY.dispose(camera);
				this.blurY = null;
			}
			
			if (this.copyBack != null) {
				this.copyBack.dispose(camera);
				this.copyBack = null;
			}
			
			if (this.imageProcessing != null) {
				this.imageProcessing.dispose(camera);
				this.imageProcessing = null;
			}       
			
			if (this.fxaa != null) {
				this.fxaa.dispose(camera);
				this.fxaa = null;
			}
			
			if (this.finalMerge != null) {
				this.finalMerge.dispose(camera);
				this.finalMerge = null;
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

	// Parse serialized pipeline
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):DefaultRenderingPipeline {
		return SerializationHelper.Parse(function() { return new DefaultRenderingPipeline(source._name, source._name._hdr, scene); }, source, scene, rootUrl);
	}
	
}
