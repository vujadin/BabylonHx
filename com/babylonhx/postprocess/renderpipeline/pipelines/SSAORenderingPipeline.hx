package com.babylonhx.postprocess.renderpipeline.pipelines;

import com.babylonhx.tools.Tools;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.DynamicTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SSAORenderingPipeline extends PostProcessRenderPipeline {

	// Members

	/**
	* The PassPostProcess id in the pipeline that contains the original scene color
	* @type {string}
	*/
	static public inline var SSAOOriginalSceneColorEffect:String = "SSAOOriginalSceneColorEffect";
	/**
	* The SSAO PostProcess id in the pipeline
	* @type {string}
	*/
	static public inline var SSAORenderEffect:String = "SSAORenderEffect";
	/**
	* The horizontal blur PostProcess id in the pipeline
	* @type {string}
	*/
	static public inline var SSAOBlurHRenderEffect:String = "SSAOBlurHRenderEffect";
	/**
	* The vertical blur PostProcess id in the pipeline
	* @type {string}
	*/
	static public inline var SSAOBlurVRenderEffect:String = "SSAOBlurVRenderEffect";
	/**
	* The PostProcess id in the pipeline that combines the SSAO-Blur output with the original scene color (SSAOOriginalSceneColorEffect)
	* @type {string}
	*/
	static public inline var SSAOCombineRenderEffect:String = "SSAOCombineRenderEffect";

	/**
	* The output strength of the SSAO post-process. Default value is 1.0.
	* @type {number}
	*/
	@serialize()
	public var totalStrength:Float = 1.0;

	/**
	* The radius around the analyzed pixel used by the SSAO post-process. Default value is 0.0006
	* @type {number}
	*/
	@serialize()
	public var radius:Float = 0.0001;

	/**
	* Related to fallOff, used to interpolate SSAO samples (first interpolate function input) based on the occlusion difference of each pixel
	* Must not be equal to fallOff and superior to fallOff.
	* Default value is 0.975
	* @type {number}
	*/
	@serialize()
	public var area:Float = 0.0075;

	/**
	* Related to area, used to interpolate SSAO samples (second interpolate function input) based on the occlusion difference of each pixel
	* Must not be equal to area and inferior to area.
	* Default value is 0.0
	* @type {number}
	*/
	@serialize()
	public var fallOff:Float = 0.000001;

	/**
	* The base color of the SSAO post-process
	* The final result is "base + ssao" between [0, 1]
	* @type {number}
	*/
	@serialize()
	public var base:Float = 0.5;

	private var _scene:Scene;
	private var _depthTexture:RenderTargetTexture;
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
	 * @param {any} ratio - The size of the postprocesses. Can be a number shared between passes or an object for more precision: { ssaoRatio: 0.5, combineRatio: 1.0 }
	 * @param {BABYLON.Camera[]} cameras - The array of cameras that the rendering pipeline will be attached to
	 */
	public function new(name:String, scene:Scene, ratio:Dynamic, ?cameras:Dynamic) {
		super(scene.getEngine(), name);
		
		this._scene = scene;
		
		// Set up assets
		this._createRandomTexture();
		this._depthTexture = scene.enableDepthRenderer().getDepthMap(); // Force depth renderer "on"
		
		var ssaoRatio = ratio.ssaoRatio != null ? ratio.ssaoRatio : ratio;
		var combineRatio = ratio.combineRatio != null ? ratio.combineRatio : ratio;
		this._ratio = {
			ssaoRatio: ssaoRatio,
			combineRatio: combineRatio
		};
		
		this._originalColorPostProcess = new PassPostProcess("SSAOOriginalSceneColor", combineRatio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
		this._createSSAOPostProcess(ssaoRatio);
		this._createBlurPostProcess(ssaoRatio);
		this._createSSAOCombinePostProcess(combineRatio);
		
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
	override public function dispose(disableDepthRender:Bool = false) {
		for (i in 0...this._scene.cameras.length) {
			var camera = this._scene.cameras[i];
			
			this._originalColorPostProcess.dispose(camera);
			this._ssaoPostProcess.dispose(camera);
			this._blurHPostProcess.dispose(camera);
			this._blurVPostProcess.dispose(camera);
			this._ssaoCombinePostProcess.dispose(camera);
		}
		
		this._randomTexture.dispose();
		
		if (disableDepthRender) {
			this._scene.disableDepthRenderer();
		}
		
		this._scene.postProcessRenderPipelineManager.detachCamerasFromRenderPipeline(this._name, this._scene.cameras);
		
		super.dispose();
	}

	// Private Methods
	private function _createBlurPostProcess(ratio:Float) {
		/*
		var samplerOffsets = [
			-8.0, -6.0, -4.0, -2.0,
			0.0,
			2.0, 4.0, 6.0, 8.0
		];
		*/
		var samples = 16;
		var samplerOffsets:Array<Float> = [];
		
		for (i in -8...8) {
			samplerOffsets.push(i * 2);
		}
		
		this._blurHPostProcess = new PostProcess("BlurH", "ssao", ["outSize", "samplerOffsets"], ["depthSampler"], ratio, null, Texture.TRILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, "#define BILATERAL_BLUR\n#define BILATERAL_BLUR_H\n#define SAMPLES 16");
		this._blurHPostProcess.onApply = function(effect:Effect, _) {
			effect.setFloat("outSize", this._ssaoCombinePostProcess.width);
			effect.setTexture("depthSampler", this._depthTexture);
			
			if (this._firstUpdate) {
				effect.setArray("samplerOffsets", samplerOffsets);
			}
		};
		
		this._blurVPostProcess = new PostProcess("BlurV", "ssao", ["outSize", "samplerOffsets"], ["depthSampler"], ratio, null, Texture.TRILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, "#define BILATERAL_BLUR\n#define SAMPLES 16");
		this._blurVPostProcess.onApply = function(effect:Effect, _) {
			effect.setFloat("outSize", this._ssaoCombinePostProcess.height);
			effect.setTexture("depthSampler", this._depthTexture);
			
			if (this._firstUpdate) {
				effect.setArray("samplerOffsets", samplerOffsets);
				this._firstUpdate = false;
			}
		};
	}

	private function _createSSAOPostProcess(ratio:Float) {
		var numSamples = 16;
		var sampleSphere = [
			0.5381, 0.1856, -0.4319,
			0.1379, 0.2486, 0.4430,
			0.3371, 0.5679, -0.0057,
			-0.6999, -0.0451, -0.0019,
			0.0689, -0.1598, -0.8547,
			0.0560, 0.0069, -0.1843,
			-0.0146, 0.1402, 0.0762,
			0.0100, -0.1924, -0.0344,
			-0.3577, -0.5301, -0.4358,
			-0.3169, 0.1063, 0.0158,
			0.0103, -0.5869, 0.0046,
			-0.0897, -0.4940, 0.3287,
			0.7119, -0.0154, -0.0918,
			-0.0533, 0.0596, -0.5411,
			0.0352, -0.0631, 0.5460,
			-0.4776, 0.2847, -0.0271
		];
		var samplesFactor = 1.0 / numSamples;
		
		this._ssaoPostProcess = new PostProcess("ssao", "ssao",
			[
				"sampleSphere", "samplesFactor", "randTextureTiles", "totalStrength", "radius",
				"area", "fallOff", "base", "range", "viewport"
			],
			["randomSampler"],
			ratio, null, Texture.BILINEAR_SAMPLINGMODE,
			this._scene.getEngine(), false,
			"#define SAMPLES " + numSamples + "\n#define SSAO");
			
		var viewport = new Vector2(0, 0);
		
		this._ssaoPostProcess.onApply = function(effect:Effect, _) {
			if (this._firstUpdate) {
				effect.setArray3("sampleSphere", sampleSphere);
				effect.setFloat("samplesFactor", samplesFactor);
				effect.setFloat("randTextureTiles", 4.0);
			}
			
			effect.setFloat("totalStrength", this.totalStrength);
			effect.setFloat("radius", this.radius);
			effect.setFloat("area", this.area);
			effect.setFloat("fallOff", this.fallOff);
			effect.setFloat("base", this.base);
			
			effect.setTexture("textureSampler", this._depthTexture);
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
			randVector.x = Math.floor(rand(-1.0, 1.0) * 255);
			randVector.y = Math.floor(rand(-1.0, 1.0) * 255);
			randVector.z = Math.floor(rand( -1.0, 1.0) * 255);
			
			context[i] = cast randVector.x;
			context[i + 1] = cast randVector.y;
			context[i + 2] = cast randVector.z;
			context[i + 3] = 255;
			
			i += 4;
		}
		
		this._randomTexture.update(false);
	}
	
}
