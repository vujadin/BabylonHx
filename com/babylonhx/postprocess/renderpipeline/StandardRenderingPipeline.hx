package com.babylonhx.postprocess.renderpipeline;

import com.babylonhx.materials.textures.Texture;
import com.babylonhx.rendering.DepthRenderer;
import com.babylonhx.materials.Effect;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StandardRenderingPipeline extends PostProcessRenderPipeline {

	// Post-processes
	public var originalPostProcess:PostProcess;
	public var downSampleX4PostProcess:PostProcess = null;
	public var brightPassPostProcess:PostProcess = null;
	public var gaussianBlurHPostProcesses:PostProcess[] = [];
	public var gaussianBlurVPostProcesses:PostProcess[] = [];
	public var textureAdderPostProcess:PostProcess = null;

	public var textureAdderFinalPostProcess:PostProcess = null;

	public var lensFlarePostProcess:PostProcess = null;
	public var lensFlareShiftPostProcess:PostProcess = null;
	public var lensFlareComposePostProcess:PostProcess = null;

	public var depthOfFieldPostProcess:PostProcess = null;

	public var motionBlurPostProcess:PostProcess = null;

	// Values
	public var brightThreshold:Float = 1.0;

	public var gaussianCoefficient:Float = 0.25;
	public var gaussianMean:Float = 1.0;
	public var gaussianStandardDeviation:Float = 1.0;

	public var exposure:Float = 1.0;
	public var lensTexture:Texture = null;

	public var lensColorTexture:Texture = null;
	public var lensFlareStrength:Float = 1.0;
	public var lensFlareGhostDispersal:Float = 1.0;
	public var lensFlareHaloWidth:Float = 0.4;
	public var lensFlareDistortionStrength:Float = 4.0;
	public var lensStarTexture:Texture = null;
	public var lensFlareDirtTexture:Texture = null;

	public var depthOfFieldDistance:Float = 10.0;

	/**
	* Private members
	*/
	private var _scene:Scene;

	private var _depthRenderer:DepthRenderer = null;

	// Getters and setters
	private var _depthOfFieldEnabled:Bool = true;
	private var _lensFlareEnabled:Bool = true;
	
	public var DepthOfFieldEnabled(get, set):Bool;
	private function set_DepthOfFieldEnabled(enabled:Bool):Bool {
		var blurIndex = this.gaussianBlurHPostProcesses.length - 1;
		
		if (enabled && !this._depthOfFieldEnabled) {
			this._scene.postProcessRenderPipelineManager.enableEffectInPipeline(this._name, "HDRGaussianBlurH" + blurIndex, this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.enableEffectInPipeline(this._name, "HDRGaussianBlurV" + blurIndex, this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.enableEffectInPipeline(this._name, "HDRDepthOfField", this._scene.cameras);
			this._depthRenderer = this._scene.enableDepthRenderer();
		}
		else if (!enabled && this._depthOfFieldEnabled) {
			this._scene.postProcessRenderPipelineManager.disableEffectInPipeline(this._name, "HDRGaussianBlurH" + blurIndex, this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.disableEffectInPipeline(this._name, "HDRGaussianBlurV" + blurIndex, this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.disableEffectInPipeline(this._name, "HDRDepthOfField", this._scene.cameras);
		}
		
		return this._depthOfFieldEnabled = enabled;
	}
	private inline function get_DepthOfFieldEnabled():Bool {
		return this._depthOfFieldEnabled;
	}

	public var LensFlareEnabled(get, set):Bool;
	public function set_LensFlareEnabled(enabled:Bool):Bool {
		var blurIndex = this.gaussianBlurHPostProcesses.length - 2;
		
		if (enabled && !this._lensFlareEnabled) {
			this._scene.postProcessRenderPipelineManager.enableEffectInPipeline(this._name, "HDRLensFlare", this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.enableEffectInPipeline(this._name, "HDRLensFlareShift", this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.enableEffectInPipeline(this._name, "HDRGaussianBlurH" + blurIndex, this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.enableEffectInPipeline(this._name, "HDRGaussianBlurV" + blurIndex, this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.enableEffectInPipeline(this._name, "HDRLensFlareCompose", this._scene.cameras);
			this._depthRenderer = this._scene.enableDepthRenderer();
		}
		else if (!enabled && this._lensFlareEnabled) {
			this._scene.postProcessRenderPipelineManager.disableEffectInPipeline(this._name, "HDRLensFlare", this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.disableEffectInPipeline(this._name, "HDRLensFlareShift", this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.disableEffectInPipeline(this._name, "HDRGaussianBlurH" + blurIndex, this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.disableEffectInPipeline(this._name, "HDRGaussianBlurV" + blurIndex, this._scene.cameras);
			this._scene.postProcessRenderPipelineManager.disableEffectInPipeline(this._name, "HDRLensFlareCompose", this._scene.cameras);
		}
		
		return this._lensFlareEnabled = enabled;
	}
	private inline function get_LensFlareEnabled():Bool {
		return this._lensFlareEnabled;
	}

	/**
	 * @constructor
	 * @param {string} name - The rendering pipeline name
	 * @param {BABYLON.Scene} scene - The scene linked to this pipeline
	 * @param {any} ratio - The size of the postprocesses (0.5 means that your postprocess will have a width = canvas.width 0.5 and a height = canvas.height 0.5)
	 * @param {BABYLON.PostProcess} originalPostProcess - the custom original color post-process. Must be "reusable". Can be null.
	 * @param {BABYLON.Camera[]} cameras - The array of cameras that the rendering pipeline will be attached to
	 */
	public function new(name:String, scene: Scene, ratio:Float, originalPostProcess:PostProcess = null, ?cameras:Array<Camera>) {
		super(scene.getEngine(), name);
		
		// Initialize
		this._scene = scene;
		
		// Create pass post-processe
		if (originalPostProcess == null) {
			this.originalPostProcess = new PostProcess("HDRPass", "standard", [], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), true, "#define PASS_POST_PROCESS", Engine.TEXTURETYPE_FLOAT);
		}
		else {
			this.originalPostProcess = originalPostProcess;
		}
		
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRPassPostProcess", function() { return this.originalPostProcess; }, true));
		
		// Create down sample X4 post-process
		this._createDownSampleX4PostProcess(scene, ratio / 2);
		
		// Create bright pass post-process
		this._createBrightPassPostProcess(scene, ratio / 2);
		
		// Create gaussian blur post-processes (down sampling blurs)
		this._createGaussianBlurPostProcesses(scene, ratio / 2, 0);
		this._createGaussianBlurPostProcesses(scene, ratio / 4, 1);
		this._createGaussianBlurPostProcesses(scene, ratio / 8, 2);
		this._createGaussianBlurPostProcesses(scene, ratio / 16, 3);
		
		// Create texture adder post-process
		this._createTextureAdderPostProcess(scene, ratio);
		
		// Create depth-of-field source post-process
		this.textureAdderFinalPostProcess = new PostProcess("HDRTextureAdderPostProcess", "standard", [], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), true, "#define PASS_POST_PROCESS", Engine.TEXTURETYPE_UNSIGNED_INT);
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRDepthOfFieldSource", function() { return this.textureAdderFinalPostProcess; }, true));
		
		// Create lens flare post-process
		this._createLensFlarePostProcess(scene, ratio);
		
		// Create gaussian blur used by depth-of-field
		this._createGaussianBlurPostProcesses(scene, ratio / 2, 5);
		
		// Create depth-of-field post-process
		this._createDepthOfFieldPostProcess(scene, ratio);
		
		// Finish
		scene.postProcessRenderPipelineManager.addPipeline(this);
		
		if (cameras != null && cameras.length > 0) {
			scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline(name, cameras);
		}
		
		// Deactivate
		this.LensFlareEnabled = false;
		this.DepthOfFieldEnabled = false;
	}

	// Down Sample X4 Post-Processs
	private function _createDownSampleX4PostProcess(scene:Scene, ratio:Float) {
		var downSampleX4Offsets:Array<Float> = [];
		this.downSampleX4PostProcess = new PostProcess("HDRDownSampleX4", "standard", ["dsOffsets"], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define DOWN_SAMPLE_X4", Engine.TEXTURETYPE_UNSIGNED_INT);

		this.downSampleX4PostProcess.onApply = function(effect:Effect) {
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
		
		this.brightPassPostProcess.onApply = function(effect:Effect) {
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

	// Create gaussian blur H&V post-processes
	private function _createGaussianBlurPostProcesses(scene:Scene, ratio:Float, indice:Int) {
		var blurOffsets:Array<Float> = [];
		var blurWeights:Array<Float> = [];
		var uniforms:Array<String> = ["blurOffsets", "blurWeights"];
		
		var callback = function(height:Bool, _) {
			return function(effect:Effect) {
				// Weights
				var x:Float = 0.0;
				for (i in 0...9) {
					x = (i - 4.0) / 4.0;
					blurWeights[i] =
						this.gaussianCoefficient
						* (1.0 / Math.sqrt(2.0 * Math.PI * this.gaussianStandardDeviation))
						* Math.exp((-((x - this.gaussianMean) * (x - this.gaussianMean))) / (2.0 * this.gaussianStandardDeviation * this.gaussianStandardDeviation));
				}
				
				var lastOutputDimensions = {
					width: scene.getEngine().getRenderWidth(),
					height: scene.getEngine().getRenderHeight()
				};
				
				for (i in 0...9) {
					var value = (i - 4.0) * (1.0 / (height == true ? lastOutputDimensions.height : lastOutputDimensions.width));
					blurOffsets[i] = value;
				}
				
				effect.setArray("blurOffsets", blurOffsets);
				effect.setArray("blurWeights", blurWeights);
			};
		};
		
		// Create horizontal gaussian blur post-processes
		var gaussianBlurHPostProcess = new PostProcess("HDRGaussianBlurH" + ratio, "standard", uniforms, [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define GAUSSIAN_BLUR_H", Engine.TEXTURETYPE_UNSIGNED_INT);
		gaussianBlurHPostProcess.onApply = callback(false);
		
		// Create vertical gaussian blur post-process
		var gaussianBlurVPostProcess = new PostProcess("HDRGaussianBlurV" + ratio, "standard", uniforms, [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define GAUSSIAN_BLUR_V", Engine.TEXTURETYPE_UNSIGNED_INT);
		gaussianBlurVPostProcess.onApply = callback(true);
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRGaussianBlurH" + indice, function() { return gaussianBlurHPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRGaussianBlurV" + indice, function() { return gaussianBlurVPostProcess; }, true));
		
		// Finish
		this.gaussianBlurHPostProcesses.push(gaussianBlurHPostProcess);
		this.gaussianBlurVPostProcesses.push(gaussianBlurVPostProcess);
	}

	// Create texture adder post-process
	private function _createTextureAdderPostProcess(scene:Scene, ratio:Float) {
		var lastGaussianBlurPostProcess = this.gaussianBlurVPostProcesses[3];
		
		this.textureAdderPostProcess = new PostProcess("HDRTextureAdder", "standard", ["exposure"], ["otherSampler", "lensSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define TEXTURE_ADDER", Engine.TEXTURETYPE_UNSIGNED_INT);
		this.textureAdderPostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("otherSampler", this.originalPostProcess);
			effect.setTexture("lensSampler", this.lensTexture);
			
			effect.setFloat("exposure", this.exposure);
		};
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRTextureAdder", function() { return this.textureAdderPostProcess; }, true));
	}

	// Create lens flare post-process
	private function _createLensFlarePostProcess(scene:Scene, ratio:Float) {
		this.lensFlarePostProcess = new PostProcess("HDRLensFlare", "standard", ["strength", "ghostDispersal", "haloWidth"], ["lensColorSampler"], ratio / 8, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), true, "#define LENS_FLARE", Engine.TEXTURETYPE_UNSIGNED_INT);
		this.lensFlareShiftPostProcess = new PostProcess("HDRLensFlareShift", "standard", ["resolution", "distortionStrength"], [], ratio / 8, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define LENS_FLARE_SHIFT", Engine.TEXTURETYPE_UNSIGNED_INT);
		this._createGaussianBlurPostProcesses(scene, ratio / 8, 4);
		this.lensFlareComposePostProcess = new PostProcess("HDRLensFlareCompose", "standard", ["viewMatrix", "scaleBias1", "scaleBias2"], ["otherSampler", "lensDirtSampler", "lensStarSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define LENS_FLARE_COMPOSE", Engine.TEXTURETYPE_UNSIGNED_INT);
		
		var resolution = new Vector2(0, 0);
		
		// Lens flare
		this.lensFlarePostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("textureSampler", this.textureAdderPostProcess);
			effect.setTexture("lensColorSampler", this.lensColorTexture);
			effect.setFloat("strength", this.lensFlareStrength);
			effect.setFloat("ghostDispersal", this.lensFlareGhostDispersal);
			effect.setFloat("haloWidth", this.lensFlareHaloWidth);
		};
		
		// Shift
		this.lensFlareShiftPostProcess.onApply = function(effect:Effect, _) {
			resolution.x = this.lensFlareShiftPostProcess.width;
			resolution.y = this.lensFlareShiftPostProcess.height;
			effect.setVector2("resolution", resolution);
			
			effect.setFloat("distortionStrength", this.lensFlareDistortionStrength);
		};
		
		// Compose
		var scaleBias1 = Matrix.GetAsMatrix3x3(Matrix.FromValues(
			2.0, 0.0, -1.0, 0.0,
			0.0, 2.0, -1.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 0.0
		));
		
		var scaleBias2 = Matrix.GetAsMatrix3x3(Matrix.FromValues(
			0.5, 0.0, 0.5, 0.0,
			0.0, 0.5, 0.5, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 0.0
		));
		
		this.lensFlareComposePostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("otherSampler", this.textureAdderFinalPostProcess);
			effect.setTexture("lensDirtSampler", this.lensFlareDirtTexture);
			effect.setTexture("lensStarSampler", this.lensStarTexture);
			
			effect.setMatrix("viewMatrix", this._scene.activeCamera.getViewMatrix());
			effect.setMatrix3x3("scaleBias1", scaleBias1);
			effect.setMatrix3x3("scaleBias2", scaleBias2);
		};
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRLensFlare", function() { return this.lensFlarePostProcess; }, false));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRLensFlareShift", function() { return this.lensFlareShiftPostProcess; }, false));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRLensFlareCompose", function() { return this.lensFlareComposePostProcess; }, false));
	}

	// Create depth-of-field post-process
	private function _createDepthOfFieldPostProcess(scene:Scene, ratio:Float) {
		this.depthOfFieldPostProcess = new PostProcess("HDRDepthOfField", "standard", ["distance"], ["otherSampler", "depthSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define DEPTH_OF_FIELD", Engine.TEXTURETYPE_UNSIGNED_INT);
		this.depthOfFieldPostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("otherSampler", this.textureAdderFinalPostProcess);
			effect.setTexture("depthSampler", this._depthRenderer.getDepthMap());
			
			effect.setFloat("distance", this.depthOfFieldDistance);
		};
		
		// Add to pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRDepthOfField", function() { return this.depthOfFieldPostProcess; }, true));
	}
	
}
