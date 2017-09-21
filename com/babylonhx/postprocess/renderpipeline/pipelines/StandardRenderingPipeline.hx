package com.babylonhx.postprocess.renderpipeline.pipelines;

import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Tools in MathTools;
import com.babylonhx.math.Scalar;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.rendering.DepthRenderer;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.materials.Effect;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Matrix;
import com.babylonhx.lights.Light;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StandardRenderingPipeline extends PostProcessRenderPipeline implements IDisposable implements IAnimatable {
	
	// Luminance steps
	public static var LuminanceSteps:Int = 6;

	/**
	* Public members
	*/
	// Post-processes
	public var originalPostProcess:PostProcess;
	public var downSampleX4PostProcess:PostProcess = null;
	public var brightPassPostProcess:PostProcess = null;
	public var blurHPostProcesses:Array<PostProcess> = [];
	public var blurVPostProcesses:Array<PostProcess> = [];
	public var textureAdderPostProcess:PostProcess = null;

	public var volumetricLightPostProcess:PostProcess = null;
	public var volumetricLightSmoothXPostProcess:BlurPostProcess = null;
	public var volumetricLightSmoothYPostProcess:BlurPostProcess = null;
	public var volumetricLightMergePostProces:PostProcess = null;
	public var volumetricLightFinalPostProcess:PostProcess = null;

	public var luminancePostProcess:PostProcess = null;
	public var luminanceDownSamplePostProcesses:Array<PostProcess> = [];
	public var hdrPostProcess:PostProcess = null;

	public var textureAdderFinalPostProcess:PostProcess = null;
	public var lensFlareFinalPostProcess:PostProcess = null;
	public var hdrFinalPostProcess:PostProcess = null;

	public var lensFlarePostProcess:PostProcess = null;
	public var lensFlareComposePostProcess:PostProcess = null;

	public var motionBlurPostProcess:PostProcess = null;

	public var depthOfFieldPostProcess:PostProcess = null;

	// Values
	@serialize()
	public var brightThreshold:Float = 1.0;

	@serialize()
	public var blurWidth:Float = 512.0;
	@serialize()
	public var horizontalBlur:Bool = false;

	@serialize()
	public var exposure:Float = 1.0;
	@serializeAsTexture("lensTexture")
	public var lensTexture:Texture = null;

	@serialize()
	public var volumetricLightCoefficient:Float = 0.2;
	@serialize()
	public var volumetricLightPower:Float = 4.0;
	@serialize()
	public var volumetricLightBlurScale:Float = 64.0;

	// SpotLight | DirectionalLight
	public var sourceLight:Light = null;

	@serialize()
	public var hdrMinimumLuminance:Float = 1.0;
	@serialize()
	public var hdrDecreaseRate:Float = 0.5;
	@serialize()
	public var hdrIncreaseRate:Float = 0.5;

	@serializeAsTexture("lensColorTexture")
	public var lensColorTexture:Texture = null;
	@serialize()
	public var lensFlareStrength:Float = 20.0;
	@serialize()
	public var lensFlareGhostDispersal:Float = 1.4;
	@serialize()
	public var lensFlareHaloWidth:Float = 0.7;
	@serialize()
	public var lensFlareDistortionStrength:Float = 16.0;
	@serializeAsTexture("lensStarTexture")
	public var lensStarTexture:Texture = null;
	@serializeAsTexture("lensFlareDirtTexture")
	public var lensFlareDirtTexture:Texture = null;

	@serialize()
	public var depthOfFieldDistance:Float = 10.0;

	@serialize()
	public var depthOfFieldBlurWidth:Float = 64.0;

	@serialize()
	public var motionStrength:Float = 1.0;

	// IAnimatable
	public var animations:Array<Animation> = [];

	/**
	* Private members
	*/
	private var _scene:Scene;
	private var _currentDepthOfFieldSource:PostProcess = null;
	private var _basePostProcess:PostProcess;

	private var _hdrCurrentLuminance:Float = 1.0;

	private var _floatTextureType:Int;
	private var _ratio:Float;

	// Getters and setters
	private var _bloomEnabled:Bool = true;
	private var _depthOfFieldEnabled:Bool = false;
	private var _vlsEnabled:Bool = false;
	private var _lensFlareEnabled:Bool = false;
	private var _hdrEnabled:Bool = false;
	private var _motionBlurEnabled:Bool = false;

	private var _motionBlurSamples:Float = 64.0;
	private var _volumetricLightStepsCount:Float = 50.0;

	@serialize()
	public var BloomEnabled(get, set):Bool;
	inline private function get_BloomEnabled():Bool {
		return this._bloomEnabled;
	}
	private function set_BloomEnabled(enabled:Bool):Bool {
		if (this._bloomEnabled == enabled) {
			return enabled;
		}
		
		this._bloomEnabled = enabled;
		this._buildPipeline();
		return enabled;
	}

	@serialize()
	public var DepthOfFieldEnabled(get, set):Bool;
	private function get_DepthOfFieldEnabled():Bool {
		return this._depthOfFieldEnabled;
	}
	private function set_DepthOfFieldEnabled(enabled:Bool):Bool {
		if (this._depthOfFieldEnabled == enabled) {
			return enabled;
		}
		
		this._depthOfFieldEnabled = enabled;
		this._buildPipeline();
		return enabled;
	}

	@serialize()
	public var LensFlareEnabled(get, set):Bool;
	inline private function get_LensFlareEnabled():Bool {
		return this._lensFlareEnabled;
	}
	private function set_LensFlareEnabled(enabled:Bool):Bool {
		if (this._lensFlareEnabled == enabled) {
			return enabled;
		}
		
		this._lensFlareEnabled = enabled;
		this._buildPipeline();
		return enabled;
	}

	@serialize()
	public var HDREnabled(get, set):Bool;
	inline private function get_HDREnabled():Bool {
		return this._hdrEnabled;
	}
	private function set_HDREnabled(enabled:Bool):Bool {
		if (this._hdrEnabled == enabled) {
			return enabled;
		}
		
		this._hdrEnabled = enabled;
		this._buildPipeline();
		return enabled;
	}

	@serialize()
	public var VLSEnabled(get, set):Bool;
	inline private function get_VLSEnabled():Bool {
		return this._vlsEnabled;
	}
	private function set_VLSEnabled(enabled:Bool):Bool {
		if (this._vlsEnabled == enabled) {
			return enabled;
		}
		
		if (enabled) {
			var geometry = this._scene.enableGeometryBufferRenderer();
			if (geometry == null) {
				com.babylonhx.tools.Tools.Warn("Geometry renderer is not supported, cannot create volumetric lights in Standard Rendering Pipeline");
				return enabled;
			}
		}
		
		this._vlsEnabled = enabled;
		this._buildPipeline();
		return enabled;
	}

	@serialize()
	public var MotionBlurEnabled(get, set):Bool;
	inline private function get_MotionBlurEnabled():Bool {
		return this._motionBlurEnabled;
	}
	private function set_MotionBlurEnabled(enabled:Bool):Bool {
		if (this._motionBlurEnabled == enabled) {
			return enabled;
		}
		
		this._motionBlurEnabled = enabled;
		this._buildPipeline();
		return enabled;
	}

	@serialize()
	public var volumetricLightStepsCount(get, set):Float;
	inline private function get_volumetricLightStepsCount():Float {
		return this._volumetricLightStepsCount;
	}
	private function set_volumetricLightStepsCount(count:Float):Float {
		if (this.volumetricLightPostProcess != null) {
			this.volumetricLightPostProcess.updateEffect("#define VLS\n#define NB_STEPS " + MathTools.Round(count, 1));
		}
		this._volumetricLightStepsCount = count;
		return count;
	}

	@serialize()
	public var motionBlurSamples(get, set):Float;
	inline private function get_motionBlurSamples():Float {
		return this._motionBlurSamples;
	}
	private function set_motionBlurSamples(samples:Float):Float {
		if (this.motionBlurPostProcess != null) {
			this.motionBlurPostProcess.updateEffect("#define MOTION_BLUR\n#define MAX_MOTION_SAMPLES " + MathTools.Round(samples, 1));
		}
		this._motionBlurSamples = samples;
		return samples;
	}
	

	/**
	 * @constructor
	 * @param {string} name - The rendering pipeline name
	 * @param {BABYLON.Scene} scene - The scene linked to this pipeline
	 * @param {any} ratio - The size of the postprocesses (0.5 means that your postprocess will 
	 * 	have a width = canvas.width 0.5 and a height = canvas.height 0.5)
	 * @param {BABYLON.PostProcess} originalPostProcess - the custom original color post-process. Must be "reusable". Can be null.
	 * @param {BABYLON.Camera[]} cameras - The array of cameras that the rendering pipeline will be attached to
	 */
	public function new(name:String, scene:Scene, ratio:Float, originalPostProcess:PostProcess = null, ?cameras:Map<String, Camera>) {
		super(scene.getEngine(), name);
		this._cameras = cameras != null ? cameras : new Map();
		
		// Initialize
		this._scene = scene;
		this._basePostProcess = originalPostProcess;
		this._ratio = ratio;
		
		// Misc
		this._floatTextureType = scene.getEngine().getCaps().textureFloatRender ? Engine.TEXTURETYPE_FLOAT : Engine.TEXTURETYPE_HALF_FLOAT;
		
		// Finish
		scene.postProcessRenderPipelineManager.addPipeline(this);
		this._buildPipeline();
	}

	private function _buildPipeline() {
		var ratio = this._ratio;
		var scene = this._scene;
		
		this._disposePostProcesses();
		this._reset();
		
		// Create pass post-process
		if (this._basePostProcess == null) {
			this.originalPostProcess = new PostProcess("HDRPass", "standard", [], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define PASS_POST_PROCESS", this._floatTextureType);
			this.originalPostProcess.onApply = function(_, _) {
				this._currentDepthOfFieldSource = this.originalPostProcess;
			};
		}
		else {
			this.originalPostProcess = this._basePostProcess;
		}
		
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRPassPostProcess", function() { return this.originalPostProcess; }, true));
		
		this._currentDepthOfFieldSource = this.originalPostProcess;
		
		if (this._vlsEnabled) {
			// Create volumetric light
			this._createVolumetricLightPostProcess(scene, ratio);
			
			// Create volumetric light final post-process
			this.volumetricLightFinalPostProcess = new PostProcess("HDRVLSFinal", "standard", [], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define PASS_POST_PROCESS", Engine.TEXTURETYPE_UNSIGNED_INT);
			this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRVLSFinal", function() { return this.volumetricLightFinalPostProcess; }, true));
		}
		
		if (this._bloomEnabled) {
			// Create down sample X4 post-process
			this._createDownSampleX4PostProcess(scene, ratio / 2);
			
			// Create bright pass post-process
			this._createBrightPassPostProcess(scene, ratio / 2);
			
			// Create gaussian blur post-processes (down sampling blurs)
			this._createBlurPostProcesses(scene, ratio / 4, 1);
			
			// Create texture adder post-process
			this._createTextureAdderPostProcess(scene, ratio);
			
			// Create depth-of-field source post-process
			this.textureAdderFinalPostProcess = new PostProcess("HDRDepthOfFieldSource", "standard", [], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define PASS_POST_PROCESS", Engine.TEXTURETYPE_UNSIGNED_INT);
			this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRBaseDepthOfFieldSource", function() { return this.textureAdderFinalPostProcess; }, true));
		}
		
		if (this._lensFlareEnabled) {
			// Create lens flare post-process
			this._createLensFlarePostProcess(scene, ratio);
			
			// Create depth-of-field source post-process post lens-flare and disable it now
			this.lensFlareFinalPostProcess = new PostProcess("HDRPostLensFlareDepthOfFieldSource", "standard", [], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define PASS_POST_PROCESS", Engine.TEXTURETYPE_UNSIGNED_INT);
			this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRPostLensFlareDepthOfFieldSource", function() { return this.lensFlareFinalPostProcess; }, true));
		}
		
		if (this._hdrEnabled) {
			// Create luminance
			this._createLuminancePostProcesses(scene, this._floatTextureType);
			
			// Create HDR
			this._createHdrPostProcess(scene, ratio);
			
			// Create depth-of-field source post-process post hdr and disable it now
			this.hdrFinalPostProcess = new PostProcess("HDRPostHDReDepthOfFieldSource", "standard", [], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define PASS_POST_PROCESS", Engine.TEXTURETYPE_UNSIGNED_INT);
			this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRPostHDReDepthOfFieldSource", function() { return this.hdrFinalPostProcess; }, true));
		}
		
		if (this._depthOfFieldEnabled) {
			// Create gaussian blur used by depth-of-field
			this._createBlurPostProcesses(scene, ratio / 2, 3, "depthOfFieldBlurWidth");
			
			// Create depth-of-field post-process
			this._createDepthOfFieldPostProcess(scene, ratio);
		}
		
		if (this._motionBlurEnabled) {
			// Create motion blur post-process
			this._createMotionBlurPostProcess(scene, ratio);
		}
		
		if (this._cameras != null) {
			this._scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline(this._name, this._cameras);
		}
	}

	// Down Sample X4 Post-Processs
	private function _createDownSampleX4PostProcess(scene:Scene, ratio:Float) {
		var downSampleX4Offsets:Array<Float> = [];
		this.downSampleX4PostProcess = new PostProcess("HDRDownSampleX4", "standard", ["dsOffsets"], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define DOWN_SAMPLE_X4", Engine.TEXTURETYPE_UNSIGNED_INT);
		
		this.downSampleX4PostProcess.onApply = function(effect:Effect, _) {
			var id = 0;
			for (i in -2...2) {
				for (j in -2...2) {
					downSampleX4Offsets[id] = (i + 0.5) * (1.0 / this.downSampleX4PostProcess.width);
					downSampleX4Offsets[id + 1] = (j + 0.5) * (1.0 / this.downSampleX4PostProcess.height);
					id += 2;
				}
			}
			
			effect.setArray2("dsOffsets", downSampleX4Offsets);
		};
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRDownSampleX4", function() { return this.downSampleX4PostProcess; }, true));
	}

	// Brightpass Post-Process
	private function _createBrightPassPostProcess(scene:Scene, ratio:Float) {
		var brightOffsets:Array<Float> = [];
		this.brightPassPostProcess = new PostProcess("HDRBrightPass", "standard", ["dsOffsets", "brightThreshold"], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define BRIGHT_PASS", Engine.TEXTURETYPE_UNSIGNED_INT);

		this.brightPassPostProcess.onApply = function(effect:Effect, _) {
			var sU = (1.0 / this.brightPassPostProcess.width);
			var sV = (1.0 / this.brightPassPostProcess.height);
			
			brightOffsets[0] = -0.5 * sU;
			brightOffsets[1] = 0.5 * sV;
			brightOffsets[2] = 0.5 * sU;
			brightOffsets[3] = 0.5 * sV;
			brightOffsets[4] = -0.5 * sU;
			brightOffsets[5] = -0.5 * sV;
			brightOffsets[6] = 0.5 * sU;
			brightOffsets[7] = -0.5 * sV;
			
			effect.setArray2("dsOffsets", brightOffsets);
			effect.setFloat("brightThreshold", this.brightThreshold);
		}
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRBrightPass", function() { return this.brightPassPostProcess; }, true));
	}

	// Create blur H&V post-processes
	private function _createBlurPostProcesses(scene:Scene, ratio:Float, indice:Int, blurWidthKey:String = "blurWidth") {
		var engine = scene.getEngine();
		
		var blurX = new BlurPostProcess("HDRBlurH" + "_" + indice, new Vector2(1, 0), Reflect.getProperty(this, blurWidthKey), ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, Engine.TEXTURETYPE_UNSIGNED_INT);
		var blurY = new BlurPostProcess("HDRBlurV" + "_" + indice, new Vector2(0, 1), Reflect.getProperty(this, blurWidthKey), ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, Engine.TEXTURETYPE_UNSIGNED_INT);
		
		blurX.onActivateObservable.add(function(_, _) {
			var dw = blurX.width / engine.getRenderingCanvas().width;
			blurX.kernel = Reflect.getProperty(this, blurWidthKey) * dw;
		});
		
		blurY.onActivateObservable.add(function(_, _) {
			var dw = blurY.height / engine.getRenderingCanvas().height;
			blurY.kernel = this.horizontalBlur ? 64 * dw : Reflect.getProperty(this, blurWidthKey) * dw;
		});
		
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRBlurH" + indice, function() { return blurX; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRBlurV" + indice, function() { return blurY; }, true));
		
		this.blurHPostProcesses.push(blurX);
		this.blurVPostProcesses.push(blurY);
	}

	// Create texture adder post-process
	private function _createTextureAdderPostProcess(scene:Scene, ratio:Float) {
		this.textureAdderPostProcess = new PostProcess("HDRTextureAdder", "standard", ["exposure"], ["otherSampler", "lensSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define TEXTURE_ADDER", Engine.TEXTURETYPE_UNSIGNED_INT);
		this.textureAdderPostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("otherSampler", this._vlsEnabled ? this._currentDepthOfFieldSource : this.originalPostProcess);
			effect.setTexture("lensSampler", this.lensTexture);
			
			effect.setFloat("exposure", this.exposure);
			
			this._currentDepthOfFieldSource = this.textureAdderFinalPostProcess;
		};
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRTextureAdder", function() { return this.textureAdderPostProcess; }, true));
	}

	private function _createVolumetricLightPostProcess(scene:Scene, ratio:Float) {
		var geometryRenderer = scene.enableGeometryBufferRenderer();
		geometryRenderer.enablePosition = true;
		
		var geometry = geometryRenderer.getGBuffer();
		
		// Base post-process
		this.volumetricLightPostProcess = new PostProcess("HDRVLS", "standard",
			["shadowViewProjection", "cameraPosition", "sunDirection", "sunColor", "scatteringCoefficient", "scatteringPower", "depthValues"],
			["shadowMapSampler", "positionSampler" ],
			ratio / 8,
			null,
			Texture.BILINEAR_SAMPLINGMODE,
			scene.getEngine(),
			false, "#define VLS\n#define NB_STEPS " + MathTools.Round(this._volumetricLightStepsCount, 1));
			
		var depthValues = Vector2.Zero();
		
		this.volumetricLightPostProcess.onApply = function(effect:Effect, _) {
			if (this.sourceLight != null && this.sourceLight.getShadowGenerator() != null) {
				var generator = this.sourceLight.getShadowGenerator();
				
				effect.setTexture("shadowMapSampler", generator.getShadowMap());
				effect.setTexture("positionSampler", geometry.textures[2]);
				
				effect.setColor3("sunColor", this.sourceLight.diffuse);
				effect.setVector3("sunDirection", untyped this.sourceLight.getShadowDirection());
				
				effect.setVector3("cameraPosition", scene.activeCamera.globalPosition);
				effect.setMatrix("shadowViewProjection", generator.getTransformMatrix());
				
				effect.setFloat("scatteringCoefficient", this.volumetricLightCoefficient);
				effect.setFloat("scatteringPower", this.volumetricLightPower);
				
				depthValues.x = generator.getLight().getDepthMinZ(this._scene.activeCamera);
				depthValues.y = generator.getLight().getDepthMaxZ(this._scene.activeCamera);
				effect.setVector2("depthValues", depthValues);
			}
		};
		
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRVLS", function() { return this.volumetricLightPostProcess; }, true));
		
		// Smooth
		this._createBlurPostProcesses(scene, ratio / 4, 0, "volumetricLightBlurScale");
		
		// Merge
		this.volumetricLightMergePostProces = new PostProcess("HDRVLSMerge", "standard", [], ["originalSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define VLSMERGE");
		
		this.volumetricLightMergePostProces.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("originalSampler", this.originalPostProcess);
			
			this._currentDepthOfFieldSource = this.volumetricLightFinalPostProcess;
		};
		
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRVLSMerge", function() { return this.volumetricLightMergePostProces; }, true));
	}

	// Create luminance
	private function _createLuminancePostProcesses(scene:Scene, textureType:Int) {
		// Create luminance
		var size = Std.int(Math.pow(3, StandardRenderingPipeline.LuminanceSteps));
		this.luminancePostProcess = new PostProcess("HDRLuminance", "standard", ["lumOffsets"], [], { width: size, height: size }, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define LUMINANCE", textureType);
		
		var offsets:Array<Float> = [];
		this.luminancePostProcess.onApply = function(effect:Effect, _) {
			var sU = (1.0 / this.luminancePostProcess.width);
			var sV = (1.0 / this.luminancePostProcess.height);
			
			offsets[0] = -0.5 * sU;
			offsets[1] = 0.5 * sV;
			offsets[2] = 0.5 * sU;
			offsets[3] = 0.5 * sV;
			offsets[4] = -0.5 * sU;
			offsets[5] = -0.5 * sV;
			offsets[6] = 0.5 * sU;
			offsets[7] = -0.5 * sV;
			
			effect.setArray2("lumOffsets", offsets);
		};
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRLuminance", function() { return this.luminancePostProcess; }, true));
		
		// Create down sample luminance
		var i = StandardRenderingPipeline.LuminanceSteps - 1;
		while (i >= 0) {
			var size = Std.int(Math.pow(3, i));
			
			var defines = "#define LUMINANCE_DOWN_SAMPLE\n";
			if (i == 0) {
				defines += "#define FINAL_DOWN_SAMPLER";
			}
			
			var postProcess = new PostProcess("HDRLuminanceDownSample" + i, "standard", ["dsOffsets", "halfDestPixelSize"], [], { width: size, height: size }, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, defines, textureType);
			this.luminanceDownSamplePostProcesses.push(postProcess);
			--i;
		}
		
		// Create callbacks and add effects
		var lastLuminance = this.luminancePostProcess;
		for (index in 0...this.luminanceDownSamplePostProcesses.length) {
			var pp = this.luminanceDownSamplePostProcesses[index];
			var downSampleOffsets:Array<Float> = [];
			
			pp.onApply = function(effect:Effect, _) {
				var id = 0;
				for (x in -1...2) {
					for (y in -1...2) {
						downSampleOffsets[id] = x / lastLuminance.width;
						downSampleOffsets[id + 1] = y / lastLuminance.height;
						id += 2;
					}
				}
				
				effect.setArray2("dsOffsets", downSampleOffsets);
				effect.setFloat("halfDestPixelSize", 0.5 / lastLuminance.width);
				
				if (index == this.luminanceDownSamplePostProcesses.length - 1) {
					lastLuminance = this.luminancePostProcess;
				} 
				else {
					lastLuminance = pp;
				}
			};
			
			if (index == this.luminanceDownSamplePostProcesses.length - 1) {
				pp.onAfterRender = function(effect:Effect, _) {
					var pixel = scene.getEngine().readPixels(0, 0, 1, 1);
					var bit_shift = new Vector4(1.0 / (255.0 * 255.0 * 255.0), 1.0 / (255.0 * 255.0), 1.0 / 255.0, 1.0);
					this._hdrCurrentLuminance = (pixel[0] * bit_shift.x + pixel[1] * bit_shift.y + pixel[2] * bit_shift.z + pixel[3] * bit_shift.w) / 100.0;
				};
			}
			
			this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRLuminanceDownSample" + index, function() { return pp; }, true));
		}
	}

	// Create HDR post-process
	private function _createHdrPostProcess(scene:Scene, ratio:Float) {
		this.hdrPostProcess = new PostProcess("HDR", "standard", ["averageLuminance"], ["textureAdderSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define HDR", Engine.TEXTURETYPE_UNSIGNED_INT);
		
		var outputLiminance:Float = 1;
		var time:Float = 0;
		var lastTime:Float = 0;
		
		this.hdrPostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("textureAdderSampler", this._currentDepthOfFieldSource);
			
			time += scene.getEngine().getDeltaTime();
			
			if (outputLiminance < 0) {
				outputLiminance = this._hdrCurrentLuminance;
			} 
			else {
				var dt = (lastTime - time) / 1000.0;
				
				if (this._hdrCurrentLuminance < outputLiminance + this.hdrDecreaseRate * dt) {
					outputLiminance += this.hdrDecreaseRate * dt;
				}
				else if (this._hdrCurrentLuminance > outputLiminance - this.hdrIncreaseRate * dt) {
					outputLiminance -= this.hdrIncreaseRate * dt;
				}
				else {
					outputLiminance = this._hdrCurrentLuminance;
				}
			}
			
			outputLiminance = Scalar.Clamp(outputLiminance, this.hdrMinimumLuminance, 1e20);
			
			effect.setFloat("averageLuminance", outputLiminance);
			
			lastTime = time;
			
			this._currentDepthOfFieldSource = this.hdrFinalPostProcess;
		};
		
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDR", function() { return this.hdrPostProcess; }, true));
	}

	// Create lens flare post-process
	private function _createLensFlarePostProcess(scene:Scene, ratio:Float) {
		this.lensFlarePostProcess = new PostProcess("HDRLensFlare", "standard", ["strength", "ghostDispersal", "haloWidth", "resolution", "distortionStrength"], ["lensColorSampler"], ratio / 2, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define LENS_FLARE", Engine.TEXTURETYPE_UNSIGNED_INT);
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRLensFlare", function() { return this.lensFlarePostProcess; }, true));
		
		this._createBlurPostProcesses(scene, ratio / 4, 2);
		
		this.lensFlareComposePostProcess = new PostProcess("HDRLensFlareCompose", "standard", ["lensStarMatrix"], ["otherSampler", "lensDirtSampler", "lensStarSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define LENS_FLARE_COMPOSE", Engine.TEXTURETYPE_UNSIGNED_INT);
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRLensFlareCompose", function() { return this.lensFlareComposePostProcess; }, true));
		
		var resolution = new Vector2(0, 0);
		
		// Lens flare
		this.lensFlarePostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("textureSampler", this._bloomEnabled ? this.blurHPostProcesses[0] : this.originalPostProcess);
			effect.setTexture("lensColorSampler", this.lensColorTexture);
			effect.setFloat("strength", this.lensFlareStrength);
			effect.setFloat("ghostDispersal", this.lensFlareGhostDispersal);
			effect.setFloat("haloWidth", this.lensFlareHaloWidth);
			
			// Shift
			resolution.x = this.lensFlarePostProcess.width;
			resolution.y = this.lensFlarePostProcess.height;
			effect.setVector2("resolution", resolution);
			
			effect.setFloat("distortionStrength", this.lensFlareDistortionStrength);
		};
		
		// Compose
		var scaleBias1 = Matrix.FromValues(
			2.0, 0.0, -1.0, 0.0,
			0.0, 2.0, -1.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		);
		
		var scaleBias2 = Matrix.FromValues(
			0.5, 0.0, 0.5, 0.0,
			0.0, 0.5, 0.5, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		);
		
		this.lensFlareComposePostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("otherSampler", this._currentDepthOfFieldSource);
			effect.setTexture("lensDirtSampler", this.lensFlareDirtTexture);
			effect.setTexture("lensStarSampler", this.lensStarTexture);
			
			// Lens start rotation matrix
			var camerax = this._scene.activeCamera.getViewMatrix().getRow(0);
			var cameraz = this._scene.activeCamera.getViewMatrix().getRow(2);
			var camRot = Vector3.Dot(camerax.toVector3(), new Vector3(1.0, 0.0, 0.0)) + Vector3.Dot(cameraz.toVector3(), new Vector3(0.0, 0.0, 1.0));
			camRot *= 4.0;
			
			var starRotation = Matrix.FromValues(
				Math.cos(camRot) * 0.5, -Math.sin(camRot), 0.0, 0.0,
				Math.sin(camRot), Math.cos(camRot) * 0.5, 0.0, 0.0,
				0.0, 0.0, 1.0, 0.0,
				0.0, 0.0, 0.0, 1.0
			);
			
			var lensStarMatrix = scaleBias2.multiply(starRotation).multiply(scaleBias1);
			
			effect.setMatrix("lensStarMatrix", lensStarMatrix);
			
			this._currentDepthOfFieldSource = this.lensFlareFinalPostProcess;
		};
	}

	// Create depth-of-field post-process
	private function _createDepthOfFieldPostProcess(scene:Scene, ratio:Float) {
		this.depthOfFieldPostProcess = new PostProcess("HDRDepthOfField", "standard", ["distance"], ["otherSampler", "depthSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define DEPTH_OF_FIELD", Engine.TEXTURETYPE_UNSIGNED_INT);
		this.depthOfFieldPostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("otherSampler", this._currentDepthOfFieldSource);
			effect.setTexture("depthSampler", this._getDepthTexture());
			
			effect.setFloat("distance", this.depthOfFieldDistance);
		};
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRDepthOfField", function() { return this.depthOfFieldPostProcess; }, true));
	}

	// Create motion blur post-process
	private function _createMotionBlurPostProcess(scene:Scene, ratio:Float) {
		this.motionBlurPostProcess = new PostProcess("HDRMotionBlur", "standard",
			["inverseViewProjection", "prevViewProjection", "screenSize", "motionScale", "motionStrength"],
			["depthSampler"],
			ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define MOTION_BLUR\n#define MAX_MOTION_SAMPLES " + MathTools.Round(this.motionBlurSamples, 1), Engine.TEXTURETYPE_UNSIGNED_INT);
			
		var motionScale:Float = 0;
		var prevViewProjection = Matrix.Identity();
		var invViewProjection = Matrix.Identity();
		var viewProjection = Matrix.Identity();
		var screenSize = Vector2.Zero();
		
		this.motionBlurPostProcess.onApply = function(effect:Effect, _) {
			viewProjection = scene.getProjectionMatrix().multiply(scene.getViewMatrix());
			
			viewProjection.invertToRef(invViewProjection);
			effect.setMatrix("inverseViewProjection", invViewProjection);
			
			effect.setMatrix("prevViewProjection", prevViewProjection);
			prevViewProjection = viewProjection;
			
			screenSize.x = this.motionBlurPostProcess.width;
			screenSize.y = this.motionBlurPostProcess.height;
			effect.setVector2("screenSize", screenSize);
			
			motionScale = scene.getEngine().getFps() / 60.0;
			effect.setFloat("motionScale", motionScale);
			effect.setFloat("motionStrength", this.motionStrength);
			
			effect.setTexture("depthSampler", this._getDepthTexture());
		};
		
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRMotionBlur", function() { return this.motionBlurPostProcess; }, true));
	}

	private function _getDepthTexture():Texture {
		if (this._scene.getEngine().getCaps().drawBuffersExtension) {
            return this._scene.enableGeometryBufferRenderer().getGBuffer().textures[0];
        }
		
		return this._scene.enableDepthRenderer().getDepthMap();
	}

	private function _disposePostProcesses() {
		for (i in this._cameras.keys()) {
			var camera = this._cameras[i];
			
			if (this.originalPostProcess != null) { this.originalPostProcess.dispose(camera); }
			
			if (this.downSampleX4PostProcess != null) { this.downSampleX4PostProcess.dispose(camera); }
			if (this.brightPassPostProcess != null) { this.brightPassPostProcess.dispose(camera); }
			if (this.textureAdderPostProcess != null) { this.textureAdderPostProcess.dispose(camera); }
			if (this.textureAdderFinalPostProcess != null) { this.textureAdderFinalPostProcess.dispose(camera); }
			
			if (this.volumetricLightPostProcess != null) { this.volumetricLightPostProcess.dispose(camera); }
			if (this.volumetricLightSmoothXPostProcess != null) { this.volumetricLightSmoothXPostProcess.dispose(camera); }
			if (this.volumetricLightSmoothYPostProcess != null) { this.volumetricLightSmoothYPostProcess.dispose(camera); }
			if (this.volumetricLightMergePostProces != null) { this.volumetricLightMergePostProces.dispose(camera); }
			if (this.volumetricLightFinalPostProcess != null) { this.volumetricLightFinalPostProcess.dispose(camera); }
			
			if (this.lensFlarePostProcess != null) { this.lensFlarePostProcess.dispose(camera); }
			if (this.lensFlareComposePostProcess != null) { this.lensFlareComposePostProcess.dispose(camera); }
			
			for (j in 0...this.luminanceDownSamplePostProcesses.length) {
				this.luminanceDownSamplePostProcesses[j].dispose(camera);
			}
			
			if (this.luminancePostProcess != null) { this.luminancePostProcess.dispose(camera); }
			if (this.hdrPostProcess != null) { this.hdrPostProcess.dispose(camera); }
			if (this.hdrFinalPostProcess != null) { this.hdrFinalPostProcess.dispose(camera); }
			
			if (this.depthOfFieldPostProcess != null) { this.depthOfFieldPostProcess.dispose(camera); }
			
			if (this.motionBlurPostProcess != null) { this.motionBlurPostProcess.dispose(camera); }
			
			for (j in 0...this.blurHPostProcesses.length) {
				this.blurHPostProcesses[j].dispose(camera);
			}
			
			for (j in 0...this.blurVPostProcesses.length) {
				this.blurVPostProcesses[j].dispose(camera);
			}
		}
		
		this.originalPostProcess = null;
		this.downSampleX4PostProcess = null;
		this.brightPassPostProcess = null;
		this.textureAdderPostProcess = null;
		this.textureAdderFinalPostProcess = null;
		this.volumetricLightPostProcess = null;
		this.volumetricLightSmoothXPostProcess = null;
		this.volumetricLightSmoothYPostProcess = null;
		this.volumetricLightMergePostProces = null;
		this.volumetricLightFinalPostProcess = null;
		this.lensFlarePostProcess = null;
		this.lensFlareComposePostProcess = null;
		this.luminancePostProcess = null;
		this.hdrPostProcess = null;
		this.hdrFinalPostProcess = null;
		this.depthOfFieldPostProcess = null;
		this.motionBlurPostProcess = null;
		
		this.luminanceDownSamplePostProcesses = [];
		this.blurHPostProcesses = [];
		this.blurVPostProcesses = [];
	}

	// Dispose
	override public function dispose(disableDepthRender:Bool = false) {
		this._disposePostProcesses();
		
		this._scene.postProcessRenderPipelineManager.detachCamerasFromRenderPipeline(this._name, this._cameras);
		
		super.dispose();
	}

	// Serialize rendering pipeline
	public function serialize():Dynamic {
		// VK TODO
		/*var serializationObject = SerializationHelper.Serialize(this);
		serializationObject.customType = "StandardRenderingPipeline";
		
		return serializationObject;*/
		return null;
	}

	/**
	 * Static members
	 */

	// Parse serialized pipeline
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):StandardRenderingPipeline {
		return SerializationHelper.Parse(function() { return new StandardRenderingPipeline(source._name, scene, source._ratio); }, source, scene, rootUrl);
	}
	
}
