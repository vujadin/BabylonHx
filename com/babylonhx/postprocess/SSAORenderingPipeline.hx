package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.DynamicTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderEffect;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipeline;
import com.babylonhx.materials.textures.RenderTargetTexture;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SSAORenderingPipeline') class SSAORenderingPipeline extends PostProcessRenderPipeline {
	
	// Members
	/**
	* The PassPostProcess id in the pipeline that contains the original scene color
	* @type {string}
	*/
	public var SSAOOriginalSceneColorEffect:String = "SSAOOriginalSceneColorEffect";
	/**
	* The SSAO PostProcess id in the pipeline
	* @type {string}
	*/
	public var SSAORenderEffect:String = "SSAORenderEffect";
	/**
	* The horizontal blur PostProcess id in the pipeline
	* @type {string}
	*/
	public var SSAOBlurHRenderEffect:String = "SSAOBlurHRenderEffect";
	/**
	* The vertical blur PostProcess id in the pipeline
	* @type {string}
	*/
	public var SSAOBlurVRenderEffect:String = "SSAOBlurVRenderEffect";
	/**
	* The PostProcess id in the pipeline that combines the SSAO-Blur output with the original scene color (SSAOOriginalSceneColorEffect)
	* @type {string}
	*/
	public var SSAOCombineRenderEffect:String = "SSAOCombineRenderEffect";
	
	/**
    The output strength of the SSAO post-process. Default value is 1.0.
    @type {number}
    */
    public var totalStrength:Float = 1.0;

    /**
    The radius around the analyzed pixel used by the SSAO post-process. Default value is 0.0002
    */
    public var radius:Float = 0.0002;
	
	/**
	* Related to fallOff, used to interpolate SSAO samples (first interpolate function input) based on the occlusion difference of each pixel
	* Must not be equal to fallOff and superior to fallOff.
	* Default value is 0.0075
	* @type {number}
	*/
	public var area:Float = 0.0075;

	/**
	* Related to area, used to interpolate SSAO samples (second interpolate function input) based on the occlusion difference of each pixel
	* Must not be equal to area and inferior to area.
	* Default value is 0.0003
	* @type {number}
	*/
	public var fallOff:Float = 0.0003;

	private var _scene:Scene = null;
	private var _depthTexture:RenderTargetTexture = null;
	private var _randomTexture:DynamicTexture = null;

	private var _originalColorPostProcess:PassPostProcess = null;
	private var _ssaoPostProcess:PostProcess = null;
	private var _blurHPostProcess:BlurPostProcess = null;
	private var _blurVPostProcess:BlurPostProcess = null;
	private var _ssaoCombinePostProcess:PostProcess = null;

	private var _firstUpdate:Bool = true;

	
	/**
	 * @constructor
	 * @param {string} name - The rendering pipeline name
	 * @param {BABYLON.Scene} scene - The scene linked to this pipeline
	 * @param {number} ratio - The size of the postprocesses Can be a number shared between passes or an object for more precision: { ssaoRatio: 0.5, combineRatio: 1.0 }
	 * @param {BABYLON.Camera[]} cameras - The array of cameras that the rendering pipeline will be attached to
	 */
	public function new(name:String, scene:Scene, ratio:Dynamic, ?cameras:Array<Camera>) {
		super(scene.getEngine(), name);
		
		this._scene = scene;
		
		// Set up assets
		this._createRandomTexture();
		this._depthTexture = scene.enableDepthRenderer().getDepthMap(); // Force depth renderer "on"
		
		var ssaoRatio = Reflect.hasField(ratio, "ssaoRatio") ? ratio.ssaoRatio : ratio;
		var combineRatio = Reflect.hasField(ratio, "combineRatio") ? ratio.combineRatio : ratio;
		
		this._originalColorPostProcess = new PassPostProcess("SSAOOriginalSceneColor", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
		this._createSSAOPostProcess(ratio);
		this._blurHPostProcess = new BlurPostProcess("SSAOBlurH", new Vector2(1.0, 0.0), 2.0, ssaoRatio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
		this._blurVPostProcess = new BlurPostProcess("SSAOBlurV", new Vector2(0.0, 1.0), 2.0, ssaoRatio, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
		this._createSSAOCombinePostProcess();
		
		// Set up pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), this.SSAOOriginalSceneColorEffect, function() { return this._originalColorPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), this.SSAORenderEffect, function() { return this._ssaoPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), this.SSAOBlurHRenderEffect, function() { return this._blurHPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), this.SSAOBlurVRenderEffect, function() { return this._blurVPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), this.SSAOCombineRenderEffect, function() { return this._ssaoCombinePostProcess; }, true));
		
		// Finish
		scene.postProcessRenderPipelineManager.addPipeline(this);
		if (cameras != null && cameras.length > 0) {
            scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline(name, cameras);
		}
	}

	// Public Methods
	/**
	 * Returns the horizontal blur PostProcess
	 * @return {BABYLON.BlurPostProcess} The horizontal blur post-process
	 */
	public function getBlurHPostProcess():BlurPostProcess {
		return this._blurHPostProcess;
	}

	/**
	 * Returns the vertical blur PostProcess
	 * @return {BABYLON.BlurPostProcess} The vertical blur post-process
	 */
	public function getBlurVPostProcess():BlurPostProcess {
		return this._blurVPostProcess;
	}
	
	/**
	 * Removes the internal pipeline assets and detatches the pipeline from the scene cameras
	 */
	public function dispose(disableDepthRender:Bool = false) {
		this._scene.postProcessRenderPipelineManager.detachCamerasFromRenderPipeline(this._name, this._scene.cameras);
		
		this._originalColorPostProcess = null;
		this._ssaoPostProcess = null;
		this._blurHPostProcess = null;
		this._blurVPostProcess = null;
		this._ssaoCombinePostProcess = null;
		
		this._randomTexture.dispose();
		
		if (disableDepthRender) {
			this._scene.disableDepthRenderer();
		}
	}

	// Private Methods
	private function _createSSAOPostProcess(ratio:Float):PostProcess {
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
		
		var samplesFactor = 1.0 / 16.0;
		
		this._ssaoPostProcess = new PostProcess("ssao", "ssao", ["sampleSphere", "samplesFactor", "randTextureTiles", "totalStrength", "radius",  "area", "fallOff"], 
												["randomSampler"],
												ratio, null, Texture.BILINEAR_SAMPLINGMODE,
												this._scene.getEngine(), false);
												
		this._ssaoPostProcess.onApply = function(effect:Effect) {
			if (this._firstUpdate == true) {
				effect.setArray3("sampleSphere", sampleSphere);
				effect.setFloat("samplesFactor", samplesFactor);
				effect.setFloat("randTextureTiles", 4.0 / ratio);
				this._firstUpdate = false;
			}
			
			effect.setFloat("totalStrength", this.totalStrength);
			effect.setFloat("radius", this.radius);
			effect.setFloat("area", this.area);
            effect.setFloat("fallOff", this.fallOff);
			
			effect.setTexture("textureSampler", this._depthTexture);
			effect.setTexture("randomSampler", this._randomTexture);
		};
		
		return this._ssaoPostProcess;
	}

	private function _createSSAOCombinePostProcess():PostProcess {
		this._ssaoCombinePostProcess = new PostProcess("ssaoCombine", "ssaoCombine", [], ["originalColor"],
													   1.0, null, Texture.BILINEAR_SAMPLINGMODE,
													   this._scene.getEngine(), false);
													   
		this._ssaoCombinePostProcess.onApply = function(effect:Effect) {
			effect.setTextureFromPostProcess("originalColor", this._originalColorPostProcess);
		};
		
		return this._ssaoCombinePostProcess;
	}

	private function _createRandomTexture() {
		// TODO
		/*var size = 512;
		
		this._randomTexture = new DynamicTexture("SSAORandomTexture", size, this._scene, false, Texture.BILINEAR_SAMPLINGMODE);
		this._randomTexture.wrapU = Texture.WRAP_ADDRESSMODE;
		this._randomTexture.wrapV = Texture.WRAP_ADDRESSMODE;
		
		var context = this._randomTexture.getContext();
		
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		}
		
		for (x in 0...size) {
			for (y in 0...size) {
				var randVector = Vector3.Zero();
				
				randVector.x = randVector.y = randVector.z = Math.floor(rand(0.0, 1.0) * 255);
                //randVector.y = Math.floor(rand(0.0, 1.0) * 255);
                //randVector.z = Math.floor(rand(0.0, 1.0) * 255);
				
				context.fillStyle = 'rgb(' + randVector.x + ', ' + randVector.y + ', ' + randVector.z + ')';
				context.fillRect(x, y, 1, 1);
			}
		}
		
		this._randomTexture.update(false);*/
	}
	
}
