package com.babylonhx.postprocess;

import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipeline;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderEffect;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.cameras.Camera;
import com.babylonhx.tools.Tools;
import com.babylonhx.math.Vector4;

/**
 * ...
 * @author Krtolica Vujadin
 */
class HDRRenderingPipeline extends PostProcessRenderPipeline {

	/**
	* Public members
	*/
	
	// Gaussian Blur
	/**
	* Gaussian blur coefficient
	* @type {number}
	*/
	public var gaussCoeff:Float = 0.3;
	/**
	* Gaussian blur mean
	* @type {number}
	*/
	public var gaussMean:Float = 1.0;
	/**
	* Gaussian blur standard derivation
	* @type {number}
	*/
	public var gaussStandDev:Float = 0.8;
	
	/**
    * Gaussian blur multiplier. Multiplies the blur effect
    * @type {number}
    */
    public var gaussMultiplier:Float = 4.0;

	// HDR
	/**
	* Exposure, controls the overall intensity of the pipeline
	* @type {number}
	*/
	public var exposure:Float = 1.0;
	/**
	* Minimum luminance that the post-process can output. Luminance is >= 0
	* @type {number}
	*/
	public var minimumLuminance:Float = 1.0;
	/**
	* Maximum luminance that the post-process can output. Must be suprerior to minimumLuminance
	* @type {number}
	*/
	public var maximumLuminance:Float = 1e20;
	/**
	* Increase rate for luminance: eye adaptation speed to bright
	* @type {number}
	*/
	public var luminanceIncreaserate:Float = 0.5;
	/**
	* Decrease rate for luminance: eye adaptation speed to dark
	* @type {number}
	*/
	public var luminanceDecreaseRate:Float = 0.5;

	// Bright pass
	/**
	* Minimum luminance needed to compute HDR
	* @type {number}
	*/
	public var brightThreshold:Float = 0.8;

	/**
	* Private members
	*/
	// Gaussian blur
	private var _guassianBlurHPostProcess:PostProcess;
	private var _guassianBlurVPostProcess:PostProcess;

	// Bright pass
	private var _brightPassPostProcess:PostProcess;

	// Texture adder
	private var _textureAdderPostProcess:PostProcess;

	// Down Sampling
	private var _downSampleX4PostProcess:PostProcess;

	// Original Post-process
	private var _originalPostProcess:PostProcess;

	// HDR
	private var _hdrPostProcess:PostProcess;
	private var _hdrCurrentLuminance:Float;
	private var _hdrOutputLuminance:Float;

	// Luminance generator
	public static var LUM_STEPS:Int = 6;
	private var _downSamplePostProcesses:Array<PostProcess>;

	// Global
	private var _needUpdate:Bool = true;

	/**
	 * @constructor
	 * @param {string} name - The rendering pipeline name
	 * @param {BABYLON.Scene} scene - The scene linked to this pipeline
	 * @param {any} ratio - The size of the postprocesses (0.5 means that your postprocess will have a width = canvas.width 0.5 and a height = canvas.height 0.5)
	 * @param {BABYLON.PostProcess} originalPostProcess - the custom original color post-process. Must be "reusable". Can be null.
	 * @param {BABYLON.Camera[]} cameras - The array of cameras that the rendering pipeline will be attached to
	 */
	public function new(name:String, scene:Scene, ratio:Float, originalPostProcess:PostProcess = null, ?cameras:Array<Camera>) {
		super(scene.getEngine(), name);
		
		// Bright pass
		this._createBrightPassPostProcess(scene, ratio);
		
		// Down sample X4
		this._createDownSampleX4PostProcess(scene, ratio);
		
		// Create gaussian blur post-processes
		this._createGaussianBlurPostProcess(scene, ratio);
		
		// Texture adder
		this._createTextureAdderPostProcess(scene, ratio);
		
		// Luminance generator
		this._createLuminanceGeneratorPostProcess(scene);
		
		// HDR
		this._createHDRPostProcess(scene, ratio);
		
		// Pass postprocess
		if (originalPostProcess == null) {
			this._originalPostProcess = new PassPostProcess("hdr", ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
		} 
		else {
			this._originalPostProcess = originalPostProcess;
		}
		
		// Configure pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRPassPostProcess", function():PostProcess { return this._originalPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRBrightPass", function():PostProcess { return this._brightPassPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRDownSampleX4", function():PostProcess { return this._downSampleX4PostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRGaussianBlurH", function():PostProcess { return this._guassianBlurHPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRGaussianBlurV", function():PostProcess { return this._guassianBlurVPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRTextureAdder", function():PostProcess { return this._textureAdderPostProcess; }, true));
		
		var addDownSamplerPostProcess = function(id:Int) {
			this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDRDownSampler" + id, function():PostProcess { return this._downSamplePostProcesses[id]; }, true));
		};
		
		var i:Int = HDRRenderingPipeline.LUM_STEPS - 1;
		while (i >= 0) {
			addDownSamplerPostProcess(i);
			i--;
		}
		
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), "HDR", function():PostProcess { return this._hdrPostProcess; }, true));
		
		// Finish
		scene.postProcessRenderPipelineManager.addPipeline(this);
		this.update();
	}

	/**
	* Tells the pipeline to update its post-processes
	*/
	public function update() {
		this._needUpdate = true;
	}

	/**
	* Returns the current calculated luminance
	*/
	public function getCurrentLuminance():Float {
		return this._hdrCurrentLuminance;
	}

	/**
	* Returns the currently drawn luminance
	*/
	public function getOutputLuminance():Float {
		return this._hdrOutputLuminance;
	}

	/**
	* Creates the HDR post-process and computes the luminance adaptation
	*/
	private function _createHDRPostProcess(scene:Scene, ratio:Float) {
		var hdrLastLuminance = 0.0;
		this._hdrOutputLuminance = -1.0;
		this._hdrCurrentLuminance = 1.0;
		this._hdrPostProcess = new PostProcess("hdr", "hdr", ["exposure", "avgLuminance"], ["otherSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define HDR");

		this._hdrPostProcess.onApply = function(effect:Effect) {
			if (this._hdrOutputLuminance < 0.0) {
				this._hdrOutputLuminance = this._hdrCurrentLuminance;
			}
			else {
				var dt = (hdrLastLuminance - (hdrLastLuminance + scene.getEngine().getDeltaTime())) / 1000.0;
				
				if (this._hdrCurrentLuminance < this._hdrOutputLuminance + this.luminanceDecreaseRate * dt) {
					this._hdrOutputLuminance += this.luminanceDecreaseRate * dt;
				}
				else if (this._hdrCurrentLuminance > this._hdrOutputLuminance - this.luminanceIncreaserate * dt) {
					this._hdrOutputLuminance -= this.luminanceIncreaserate * dt;
				}
				else {
					this._hdrOutputLuminance = this._hdrCurrentLuminance;
				}
			}
			
			this._hdrOutputLuminance = com.babylonhx.math.Tools.Clamp(this._hdrOutputLuminance, this.minimumLuminance, this.maximumLuminance);
			hdrLastLuminance += scene.getEngine().getDeltaTime();
			
			effect.setTextureFromPostProcess("textureSampler", this._textureAdderPostProcess);
			effect.setTextureFromPostProcess("otherSampler", this._originalPostProcess);
			effect.setFloat("exposure", this.exposure);
			effect.setFloat("avgLuminance", this._hdrOutputLuminance);
			
			this._needUpdate = false;
		};
	}

	/**
	* Texture Adder post-process
	*/
	private function _createTextureAdderPostProcess(scene:Scene, ratio:Float) {
		this._textureAdderPostProcess = new PostProcess("hdr", "hdr", [], ["otherSampler"], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define TEXTURE_ADDER");
		
		this._textureAdderPostProcess.onApply = function(effect:Effect) {
			effect.setTextureFromPostProcess("otherSampler", this._originalPostProcess);
		};
	}

	/**
	* Down sample X4 post-process
	*/
	private function _createDownSampleX4PostProcess(scene:Scene, ratio:Float) {
		var downSampleX4Offsets:Array<Float> = [];
		this._downSampleX4PostProcess = new PostProcess("hdr", "hdr", ["dsOffsets"], [], ratio / 4, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define DOWN_SAMPLE_X4");
		
		this._downSampleX4PostProcess.onApply = function(effect:Effect) {
			if (this._needUpdate) {
				var id = 0;
				for (i in -2...2) {
					for (j in -2...2) {
						downSampleX4Offsets[id] = (i + 0.5) * (1.0 / this._downSampleX4PostProcess.width);
						downSampleX4Offsets[id + 1] = (j + 0.5) * (1.0 / this._downSampleX4PostProcess.height);
						id += 2;
					}
				}
			}
			
			effect.setArray2("dsOffsets", downSampleX4Offsets);
		};
	}

	/**
	* Bright pass post-process
	*/
	private function _createBrightPassPostProcess(scene:Scene, ratio:Float) {
		var brightOffsets:Array<Float> = [];
		
		var brightPassCallback = function(effect:Effect) {
			if (this._needUpdate) {
				var sU = (1.0 / this._brightPassPostProcess.width);
				var sV = (1.0 / this._brightPassPostProcess.height);
				
				brightOffsets[0] = -0.5 * sU;
				brightOffsets[1] = 0.5 * sV;
				brightOffsets[2] = 0.5 * sU;
				brightOffsets[3] = 0.5 * sV;
				brightOffsets[4] = -0.5 * sU;
				brightOffsets[5] = -0.5 * sV;
				brightOffsets[6] = 0.5 * sU;
				brightOffsets[7] = -0.5 * sV;
			}
			
			effect.setArray2("dsOffsets", brightOffsets);
			effect.setFloat("brightThreshold", this.brightThreshold);
		};
		
		this._brightPassPostProcess = new PostProcess("hdr", "hdr", ["dsOffsets", "brightThreshold"], [], ratio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define BRIGHT_PASS");
		this._brightPassPostProcess.onApply = brightPassCallback;
	}

	/**
	* Luminance generator. Creates the luminance post-process and down sample post-processes
	*/
	private function _createLuminanceGeneratorPostProcess(scene:Scene) {
		var lumSteps:Int = HDRRenderingPipeline.LUM_STEPS;
		var luminanceOffsets:Array<Float> = [];
		var downSampleOffsets:Array<Float> = [];
		var halfDestPixelSize:Float = 0;
		this._downSamplePostProcesses = [];
		
		// Utils for luminance
		var luminanceUpdateSourceOffsets = function(width:Int, height:Int) {
			var sU = (1.0 / width);
			var sV = (1.0 / height);
			
			luminanceOffsets[0] = -0.5 * sU;
			luminanceOffsets[1] = 0.5 * sV;
			luminanceOffsets[2] = 0.5 * sU;
			luminanceOffsets[3] = 0.5 * sV;
			luminanceOffsets[4] = -0.5 * sU;
			luminanceOffsets[5] = -0.5 * sV;
			luminanceOffsets[6] = 0.5 * sU;
			luminanceOffsets[7] = -0.5 * sV;
		};
		
		var luminanceUpdateDestOffsets = function(width:Int, height:Int) {
			var id = 0;
			for (x in -1...2) {
				for (y in -1...2) {
					downSampleOffsets[id] = (x) / width;
					downSampleOffsets[id + 1] = (y) / height;
					id += 2;
				}
			}
		};
		
		// Luminance callback
		var luminanceCallback = function(effect:Effect) {
			if (this._needUpdate) {
				luminanceUpdateSourceOffsets(cast this._textureAdderPostProcess.width, cast this._textureAdderPostProcess.height);
			}
			
			effect.setTextureFromPostProcess("textureSampler", this._textureAdderPostProcess);
			effect.setArray2("lumOffsets", luminanceOffsets);
		}
		
		// Down sample callbacks
		var downSampleCallback = function(indice:Int):Effect->Void {
			var i = indice;
			return function(effect: Effect) {
				luminanceUpdateSourceOffsets(cast this._downSamplePostProcesses[i].width, cast this._downSamplePostProcesses[i].height);
				luminanceUpdateDestOffsets(cast this._downSamplePostProcesses[i].width, cast this._downSamplePostProcesses[i].height);
				halfDestPixelSize = 0.5 / this._downSamplePostProcesses[i].width;
				
				effect.setTextureFromPostProcess("textureSampler", this._downSamplePostProcesses[i + 1]);
				effect.setFloat("halfDestPixelSize", halfDestPixelSize);
				effect.setArray2("dsOffsets", downSampleOffsets);
			}
		};
		
		var downSampleAfterRenderCallback = function(effect:Effect) {
			// Unpack result
			var pixel = scene.getEngine().readPixels(0, 0, 1, 1);
			var bit_shift = new Vector4(1.0 / (255.0 * 255.0 * 255.0), 1.0 / (255.0 * 255.0), 1.0 / 255.0, 1.0);
			this._hdrCurrentLuminance = (pixel[0] * bit_shift.x + pixel[1] * bit_shift.y + pixel[2] * bit_shift.z + pixel[3] * bit_shift.w) / 100.0;
		};
		
		// Create luminance post-process
		var ratio = { width: Math.pow(3, lumSteps - 1), height: Math.pow(3, lumSteps - 1) };
		this._downSamplePostProcesses[lumSteps - 1] = new PostProcess("hdr", "hdr", ["lumOffsets"], [], ratio, null, Texture.NEAREST_SAMPLINGMODE, scene.getEngine(), false, "#define LUMINANCE_GENERATOR", Engine.TEXTURETYPE_FLOAT);
		this._downSamplePostProcesses[lumSteps - 1].onApply = luminanceCallback;
		
		// Create down sample post-processes
		var i:Int = lumSteps - 2;
		while (i >= 0) {
			var length = Math.pow(3, i);
			ratio = { width: length, height: length };
			
			var defines = "#define DOWN_SAMPLE\n";
			if (i == 0) {
				defines += "#define FINAL_DOWN_SAMPLE\n"; // To pack the result
			}
			
			this._downSamplePostProcesses[i] = new PostProcess("hdr", "hdr", ["dsOffsets", "halfDestPixelSize"], [], ratio, null, Texture.NEAREST_SAMPLINGMODE, scene.getEngine(), false, defines, Engine.TEXTURETYPE_FLOAT);
			this._downSamplePostProcesses[i].onApply = downSampleCallback(i);
			
			if (i == 0) {
				this._downSamplePostProcesses[i].onAfterRender = downSampleAfterRenderCallback;
			}
			
			--i;
		}
	}

	/**
	* Gaussian blur post-processes. Horizontal and Vertical
	*/
	private function _createGaussianBlurPostProcess(scene:Scene, ratio:Float) {
		var blurOffsetsW:Array<Float> = [];
		var blurOffsetsH:Array<Float> = [];
		var blurWeights:Array<Float> = [];
		var uniforms:Array<String> = ["blurOffsets", "blurWeights", "multiplier"];
		
		// Utils for gaussian blur
		var calculateBlurOffsets = function(height:Bool) {
			var lastOutputDimensions:Dynamic = {
				width: scene.getEngine().getRenderWidth(),
				height: scene.getEngine().getRenderHeight()
			};
			
			for (i in 0...9) {
				var value = (i - 4.0) * (1.0 / (height == true ? lastOutputDimensions.height : lastOutputDimensions.width));
				if (height) {
					blurOffsetsH[i] = value;
				} 
				else {
					blurOffsetsW[i] = value;
				}
			}
		};
		
		var calculateWeights = function() {
			var x:Float = 0.0;
			
			for (i in 0...9) {
				x = (i - 4.0) / 4.0;
				blurWeights[i] = this.gaussCoeff * (1.0 / Math.sqrt(2.0 * Math.PI * this.gaussStandDev * this.gaussStandDev)) * Math.exp((-((x - this.gaussMean) * (x - this.gaussMean))) / (2.0 * this.gaussStandDev * this.gaussStandDev));
			}
		}
		
		// Callback
		var gaussianBlurCallback = function(height:Bool) {
			return function(effect:Effect) {
				if (this._needUpdate) {
					calculateWeights();
					calculateBlurOffsets(height);
				}
				effect.setArray("blurOffsets", height ? blurOffsetsH : blurOffsetsW);
				effect.setArray("blurWeights", blurWeights);
				effect.setFloat("multiplier", this.gaussMultiplier);
			};
		};
		
		// Create horizontal gaussian blur post-processes
		this._guassianBlurHPostProcess = new PostProcess("hdr", "hdr", uniforms, [], ratio / 4, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define GAUSSIAN_BLUR_H");
		this._guassianBlurHPostProcess.onApply = gaussianBlurCallback(false);
		
		// Create vertical gaussian blur post-process
		this._guassianBlurVPostProcess = new PostProcess("hdr", "hdr", uniforms, [], ratio / 4, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, "#define GAUSSIAN_BLUR_V");
		this._guassianBlurVPostProcess.onApply = gaussianBlurCallback(true);
	}
	
}
