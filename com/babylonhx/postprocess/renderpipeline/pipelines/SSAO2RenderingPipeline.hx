package com.babylonhx.postprocess.renderpipeline.pipelines;

import com.babylonhx.tools.Tools;
import com.babylonhx.math.Vector3;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.DynamicTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SSAO2RenderingPipeline extends PostProcessRenderPipeline {

	// Members

	/**
	* The PassPostProcess id in the pipeline that contains the original scene color
	* @type {string}
	*/
	public inline static var SSAOOriginalSceneColorEffect:String = "SSAOOriginalSceneColorEffect";
	/**
	* The SSAO PostProcess id in the pipeline
	* @type {string}
	*/
	public inline static var SSAORenderEffect:String = "SSAORenderEffect";
	/**
	* The horizontal blur PostProcess id in the pipeline
	* @type {string}
	*/
	public inline static var SSAOBlurHRenderEffect:String = "SSAOBlurHRenderEffect";
	/**
	* The vertical blur PostProcess id in the pipeline
	* @type {string}
	*/
	public inline static var SSAOBlurVRenderEffect:String = "SSAOBlurVRenderEffect";
	/**
	* The PostProcess id in the pipeline that combines the SSAO-Blur output with the original scene color (SSAOOriginalSceneColorEffect)
	* @type {string}
	*/
	public inline static var SSAOCombineRenderEffect:String = "SSAOCombineRenderEffect";

	/**
	* The output strength of the SSAO post-process. Default value is 1.0.
	* @type {number}
	*/
	@serialize()
	public var totalStrength:Float = 1.0;

	/**
	* Maximum depth value to still render AO. A smooth falloff makes the dimming more natural, so there will be no abrupt shading change.
	* @type {number}
	*/
	@serialize()
	public var maxZ:Float = 100.0;

	/**
	* In order to save performances, SSAO radius is clamped on close geometry. This ratio changes by how much
	* @type {number}
	*/
	@serialize()
	public var minZAspect:Float = 0.2;

	/**
	* Number of samples used for the SSAO calculations. Default value is 8
	* @type {number}
	*/
	@serialize("samples")
	private var _samples:Int = 8;

	/**
	* Dynamically generated sphere sampler.
	* @type {number[]}
	*/
	private var _sampleSphere:Array<Float>;

	/**
	* Blur filter offsets
	* @type {number[]}
	*/
	private var _samplerOffsets:Array<Float>;

	public var samples(get, set):Int;
	private function set_samples(n:Int):Int {
		this._ssaoPostProcess.updateEffect("#define SAMPLES " + n + "\n#define SSAO");
		this._samples = n;
		this._sampleSphere = this._generateHemisphere();
		
		this._firstUpdate = true;
		return n;
	}
	inline private function get_samples():Int {
		return this._samples;
	}

	/**
	* Are we using bilateral blur ?
	* @type {boolean}
	*/
	@serialize("expensiveBlur")
	private var _expensiveBlur:Bool = true;
	public var expensiveBlur(get, set):Bool;
	private function set_expensiveBlur(b:Bool):Bool {
		this._blurHPostProcess.updateEffect("#define BILATERAL_BLUR\n#define BILATERAL_BLUR_H\n#define SAMPLES 16\n#define EXPENSIVE " + (b ? "1" : "0") + "\n", null, ["textureSampler", "depthSampler"]);
		this._blurVPostProcess.updateEffect("#define BILATERAL_BLUR\n#define SAMPLES 16\n#define EXPENSIVE " + (b ? "1" : "0") + "\n", null, ["textureSampler", "depthSampler"]);
		this._expensiveBlur = b;
		this._firstUpdate = true;
		return b;
	}
	inline private function get_expensiveBlur():Bool {
		return this._expensiveBlur;
	}

	/**
	* The radius around the analyzed pixel used by the SSAO post-process. Default value is 2.0
	* @type {number}
	*/
	@serialize()
	public var radius:Float = 2.0;

	/**
	* The base color of the SSAO post-process
	* The final result is "base + ssao" between [0, 1]
	* @type {number}
	*/
	@serialize()
	public var base:Float = 0.1;

	/**
	*  Support test.
	* @type {boolean}
	*/
	public static var IsSupported(get, never):Bool;
	inline private static function get_IsSupported():Bool {
		var engine = Engine.LastCreatedEngine;
		return engine.webGLVersion > 1;
	}

	private var _scene:Scene;
	private var _depthTexture:Texture;
	private var _normalTexture:Texture;
	private var _randomTexture:DynamicTexture;

	private var _originalColorPostProcess:PassPostProcess;
	private var _ssaoPostProcess:PostProcess;
	private var _blurHPostProcess:PostProcess;
	private var _blurVPostProcess:PostProcess;
	private var _ssaoCombinePostProcess:PostProcess;

	private var _firstUpdate:Bool = true;

	@serialize()
	private var _ratio:Dynamic;

	/**
	 * @constructor
	 * @param {string} name - The rendering pipeline name
	 * @param {BABYLON.Scene} scene - The scene linked to this pipeline
	 * @param {any} ratio - The size of the postprocesses. Can be a number shared between passes or an object for more precision: { ssaoRatio: 0.5, blurRatio: 1.0 }
	 * @param {BABYLON.Camera[]} cameras - The array of cameras that the rendering pipeline will be attached to
	 */
	public function new(name:String, scene:Scene, ratio:Dynamic, ?cameras:Dynamic) {
		super(scene.getEngine(), name);
		
		this._scene = scene;
		
		if (!this.isSupported) {
			Tools.Error("SSAO 2 needs WebGL 2 support.");
			return;
		}
		
		var ssaoRatio = ratio.ssaoRatio != null ? ratio.ssaoRatio : ratio;
		var blurRatio = ratio.blurRatio != null ? ratio.blurRatio : ratio;
		this._ratio = {
			ssaoRatio: ssaoRatio,
			blurRatio: blurRatio
		};
		
		// Set up assets
		this._createRandomTexture();
		this._depthTexture = scene.enableGeometryBufferRenderer().getGBuffer().textures[0]; 
		this._normalTexture = scene.enableGeometryBufferRenderer().getGBuffer().textures[1];
		
		this._originalColorPostProcess = new PassPostProcess("SSAOOriginalSceneColor", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
		this._createSSAOPostProcess(1.0);
		this._createBlurPostProcess(ssaoRatio, blurRatio);
		this._createSSAOCombinePostProcess(blurRatio);
		
		// Set up pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), SSAOOriginalSceneColorEffect, function() { return this._originalColorPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), SSAORenderEffect, function() { return this._ssaoPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), SSAOBlurHRenderEffect, function() { return this._blurHPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), SSAOBlurVRenderEffect, function() { return this._blurVPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), SSAOCombineRenderEffect, function() { return this._ssaoCombinePostProcess; }, true));
		
		// Finish
		scene.postProcessRenderPipelineManager.addPipeline(this);
		if (cameras != null) {
			scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline(name, cameras);
		}
	}

	// Public Methods

	/**
	 * Removes the internal pipeline assets and detatches the pipeline from the scene cameras
	 */
	override public function dispose(disableGeometryBufferRenderer:Bool = false) {
		for (i in 0...this._scene.cameras.length) {
			var camera = this._scene.cameras[i];
			
			this._originalColorPostProcess.dispose(camera);
			this._ssaoPostProcess.dispose(camera);
			this._blurHPostProcess.dispose(camera);
			this._blurVPostProcess.dispose(camera);
			this._ssaoCombinePostProcess.dispose(camera);
		}
		
		this._randomTexture.dispose();
		
		if (disableGeometryBufferRenderer) {
			this._scene.disableGeometryBufferRenderer();
		}
		
		this._scene.postProcessRenderPipelineManager.detachCamerasFromRenderPipeline(this._name, this._scene.cameras);
		
		super.dispose();
	}

	// Private Methods
	private function _createBlurPostProcess(ssaoRatio:Float, blurRatio:Float) {
		var samples:Int = 16;
		this._samplerOffsets = [];
		var expensive = this.expensiveBlur;
		
		for (i in -8...8) {
			this._samplerOffsets.push(i * 2 + 0.5);
		}
		
		this._blurHPostProcess = new PostProcess("BlurH", "ssao2", ["outSize", "samplerOffsets", "near", "far", "radius"], ["depthSampler"], ssaoRatio, null, Texture.TRILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, "#define BILATERAL_BLUR\n#define BILATERAL_BLUR_H\n#define SAMPLES 16\n#define EXPENSIVE " + (expensive ? "1" : "0") + "\n");
		this._blurHPostProcess.onApply = function(effect:Effect, _) {
			effect.setFloat("outSize", this._ssaoCombinePostProcess.width);
			effect.setFloat("near", this._scene.activeCamera.minZ);
			effect.setFloat("far", this._scene.activeCamera.maxZ);
			effect.setFloat("radius", this.radius);
			effect.setTexture("depthSampler", this._depthTexture);
			
			if (this._firstUpdate) {
				effect.setArray("samplerOffsets", this._samplerOffsets);
			}
		};
		
		this._blurVPostProcess = new PostProcess("BlurV", "ssao2", ["outSize", "samplerOffsets", "near", "far", "radius"], ["depthSampler"], blurRatio, null, Texture.TRILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, "#define BILATERAL_BLUR\n#define BILATERAL_BLUR_V\n#define SAMPLES 16\n#define EXPENSIVE " + (expensive ? "1" : "0") + "\n");
		this._blurVPostProcess.onApply = function(effect:Effect, _) {
			effect.setFloat("outSize", this._ssaoCombinePostProcess.height);
			effect.setFloat("near", this._scene.activeCamera.minZ);
			effect.setFloat("far", this._scene.activeCamera.maxZ);
			effect.setFloat("radius", this.radius);
			effect.setTexture("depthSampler", this._depthTexture);
			
			if (this._firstUpdate) {
				effect.setArray("samplerOffsets", this._samplerOffsets);
				this._firstUpdate = false;
			}
		};
	}

	private function _generateHemisphere():Array<Float> {
		var numSamples = this.samples;
		var result:Array<Float> = [];
		var vector:Vector3 = null;
		var scale:Float = 0;
		
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		};

		var lerp = function(start:Float, end:Float, percent:Float):Float {
			return (start + percent*(end - start));
		};
		
		var i = 0;
		var normal = new Vector3(0, 0, 1);
		while (i < numSamples) {
		   vector = new Vector3(rand(-1.0, 1.0), rand(-1.0, 1.0), rand(0.30, 1.0));
		   vector.normalize();
		   scale = i / numSamples;
		   scale = lerp(0.1, 1.0, scale*scale);
		   vector.scaleInPlace(scale);
		   
		   result.push(vector.x);
		   result.push(vector.y);
		   result.push(vector.z);
		   i++;
		}
		
		return result;
	}

	private function _createSSAOPostProcess(ratio:Float) {
		var numSamples = this.samples;
		
		this._sampleSphere = this._generateHemisphere();
		
		this._ssaoPostProcess = new PostProcess("ssao2", "ssao2",
			[
				"sampleSphere", "samplesFactor", "randTextureTiles", "totalStrength", "radius",
				"base", "range", "projection", "near", "far", "texelSize",
				"xViewport", "yViewport", "maxZ", "minZAspect"
			],
			["randomSampler", "normalSampler"],
			ratio, null, Texture.BILINEAR_SAMPLINGMODE,
			this._scene.getEngine(), false,
			"#define SAMPLES " + numSamples + "\n#define SSAO");
			
		this._ssaoPostProcess.onApply = function(effect:Effect, _) {
			if (this._firstUpdate) {
				effect.setArray3("sampleSphere", this._sampleSphere);
				effect.setFloat("randTextureTiles", 4.0);
			}
			
			effect.setFloat("samplesFactor", 1 / this.samples);
			effect.setFloat("totalStrength", this.totalStrength);
			effect.setFloat2("texelSize", 1 / this._ssaoPostProcess.width, 1 / this._ssaoPostProcess.height);
			effect.setFloat("radius", this.radius);
			effect.setFloat("maxZ", this.maxZ);
			effect.setFloat("minZAspect", this.minZAspect);
			effect.setFloat("base", this.base);
			effect.setFloat("near", this._scene.activeCamera.minZ);
			effect.setFloat("far", this._scene.activeCamera.maxZ);
			effect.setFloat("xViewport", Math.tan(this._scene.activeCamera.fov / 2) * this._scene.getEngine().getAspectRatio(this._scene.activeCamera, true));
			effect.setFloat("yViewport", Math.tan(this._scene.activeCamera.fov / 2));
			effect.setMatrix("projection", this._scene.getProjectionMatrix());
			
			effect.setTexture("textureSampler", this._depthTexture);
			effect.setTexture("normalSampler", this._normalTexture);
			effect.setTexture("randomSampler", this._randomTexture);
		};
	}

	private function _createSSAOCombinePostProcess(ratio:Float) {
		this._ssaoCombinePostProcess = new PostProcess("ssaoCombine", "ssaoCombine", [], ["originalColor"],
			ratio, null, Texture.BILINEAR_SAMPLINGMODE,
			this._scene.getEngine(), false);
			
		this._ssaoCombinePostProcess.onApply = function(effect:Effect, _) {
			effect.setTextureFromPostProcess("originalColor", this._originalColorPostProcess);
		};
	}

	private function _createRandomTexture() {
		var size:Int = 512;
		
		this._randomTexture = new DynamicTexture("SSAORandomTexture", size, this._scene, false, Texture.TRILINEAR_SAMPLINGMODE);
		this._randomTexture.wrapU = Texture.WRAP_ADDRESSMODE;
		this._randomTexture.wrapV = Texture.WRAP_ADDRESSMODE;
		
		var context = this._randomTexture.getContext();
		
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		};
		
		var randVector:Vector3 = Vector3.Zero();
		
		var value:Int = 0;
		var totalPixelsCount = size * size * 4;
		var i:Int = 0;
		while (i < totalPixelsCount) {
			randVector.x = rand(0.0, 1.0);
			randVector.y = rand(0.0, 1.0);
			randVector.z = 0.0;
			
			randVector.normalize();
			
			randVector.scaleInPlace(255);
			randVector.x = Math.floor(randVector.x);
			randVector.y = Math.floor(randVector.y);
			
			context[i] = cast randVector.x;
			context[i + 1] = cast randVector.y;
			context[i + 2] = cast randVector.z;
			context[i + 3] = 255;
			
			i += 4;
		}
		
		this._randomTexture.update(false);
	}
	
}
