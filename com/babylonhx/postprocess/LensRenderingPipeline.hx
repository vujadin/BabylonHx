package com.babylonhx.postprocess;

import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.DynamicTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.cameras.Camera;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderEffect;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderPipeline;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.LensRenderingPipeline') class LensRenderingPipeline extends PostProcessRenderPipeline {

	// Lens effects can be of the following:
	// - chromatic aberration (slight shift of RGB colors)
	// - blur on the edge of the lens
	// - lens distortion
	// - depth-of-field blur & highlights enhancing
	// - depth-of-field 'bokeh' effect (shapes appearing in blurred areas)
	// - grain effect (noise or custom texture)

	// Two additional texture samplers are needed:
	// - depth map (for depth-of-field)
	// - grain texture

	/**
	* The chromatic aberration PostProcess id in the pipeline
	* @type {string}
	*/
	public var LensChromaticAberrationEffect:String = "LensChromaticAberrationEffect";
	/**
	* The highlights enhancing PostProcess id in the pipeline
	* @type {string}
	*/
	public var HighlightsEnhancingEffect:String = "HighlightsEnhancingEffect";
	/**
	* The depth-of-field PostProcess id in the pipeline
	* @type {string}
	*/
	public var LensDepthOfFieldEffect:String = "LensDepthOfFieldEffect";

	private var _scene:Scene;
	private var _depthTexture:RenderTargetTexture;
	private var _grainTexture:DynamicTexture;

	private var _chromaticAberrationPostProcess:PostProcess;
	private var _highlightsPostProcess:PostProcess;
	private var _depthOfFieldPostProcess:PostProcess;

	private var _edgeBlur:Float;
	private var _grainAmount:Float;
	private var _chromaticAberration:Float;
	private var _distortion:Float;
	private var _highlightsGain:Float;
	private var _highlightsThreshold:Float;
	private var _dofDistance:Float;
	private var _dofAperture:Float;
	private var _dofDarken:Float;
	private var _dofPentagon:Bool;
	private var _blurNoise:Bool;


	/**
	 * @constructor
	 *
	 * Effect parameters are as follow:
	 * {
	 *      chromatic_aberration: number;       // from 0 to x (1 for realism)
	 *      edge_blur: number;                  // from 0 to x (1 for realism)
	 *      distortion: number;                 // from 0 to x (1 for realism)
	 *      grain_amount: number;               // from 0 to 1
	 *      grain_texture: BABYLON.Texture;     // texture to use for grain effect; if unset, use random B&W noise
	 *      dof_focus_distance: number;         // depth-of-field: focus distance; unset to disable (disabled by default)
	 *      dof_aperture: number;               // depth-of-field: focus blur bias (default: 1)
	 *      dof_darken: number;                 // depth-of-field: darken that which is out of focus (from 0 to 1, disabled by default)
	 *      dof_pentagon: boolean;              // depth-of-field: makes a pentagon-like "bokeh" effect
	 *      dof_gain: number;                   // depth-of-field: highlights gain; unset to disable (disabled by default)
	 *      dof_threshold: number;              // depth-of-field: highlights threshold (default: 1)
	 *      blur_noise: boolean;                // add a little bit of noise to the blur (default: true)
	 * }
	 * Note: if an effect parameter is unset, effect is disabled
	 *
	 * @param {string} name - The rendering pipeline name
	 * @param {object} parameters - An object containing all parameters (see above)
	 * @param {BABYLON.Scene} scene - The scene linked to this pipeline
	 * @param {number} ratio - The size of the postprocesses (0.5 means that your postprocess will have a width = canvas.width 0.5 and a height = canvas.height 0.5)
	 * @param {BABYLON.Camera[]} cameras - The array of cameras that the rendering pipeline will be attached to
	 */
	public function new(name:String, parameters:Dynamic, scene:Scene, ratio:Float = 1.0, ?cameras:Array<Camera>) {
		super(scene.getEngine(), name);
		
		this._scene = scene;
		
		// Fetch texture samplers
		this._depthTexture = scene.enableDepthRenderer().getDepthMap(); // Force depth renderer "on"
		if (parameters.grain_texture != null) { 
			this._grainTexture = parameters.grain_texture; 
		}
		else { 
			this._createGrainTexture(); 
		}
		
		// save parameters
		this._edgeBlur = parameters.edge_blur != null ? parameters.edge_blur : 0;
		this._grainAmount = parameters.grain_amount != null ? parameters.grain_amount : 0;
		this._chromaticAberration = parameters.chromatic_aberration != null ? parameters.chromatic_aberration : 0;
		this._distortion = parameters.distortion != null ? parameters.distortion : 0;
		this._highlightsGain = parameters.dof_gain != null ? parameters.dof_gain : -1;
		this._highlightsThreshold = parameters.dof_threshold != null ? parameters.dof_threshold : 1;
		this._dofDistance = parameters.dof_focus_distance != null ? parameters.dof_focus_distance : -1;
		this._dofAperture = parameters.dof_aperture != null ? parameters.dof_aperture : 1;
		this._dofDarken = parameters.dof_darken != null ? parameters.dof_darken : 0;
		this._dofPentagon = parameters.dof_pentagon != null ? parameters.dof_pentagon : true;
		this._blurNoise = parameters.blur_noise != null ? parameters.blur_noise : true;
		
		// Create effects
		this._createChromaticAberrationPostProcess(ratio);
		this._createHighlightsPostProcess(ratio);
		this._createDepthOfFieldPostProcess(ratio / 4);
		
		// Set up pipeline
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), this.LensChromaticAberrationEffect, function():PostProcess { return this._chromaticAberrationPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), this.HighlightsEnhancingEffect, function():PostProcess { return this._highlightsPostProcess; }, true));
		this.addEffect(new PostProcessRenderEffect(scene.getEngine(), this.LensDepthOfFieldEffect, function():PostProcess { return this._depthOfFieldPostProcess; }, true));
		
		if(this._highlightsGain == -1) {
			this._disableEffect(this.HighlightsEnhancingEffect, null);
		}
		
		// Finish
		scene.postProcessRenderPipelineManager.addPipeline(this);
		if(cameras != null) {
			scene.postProcessRenderPipelineManager.attachCamerasToRenderPipeline(name, cameras);
		}
	}

	// public methods (self explanatory)
	public function setEdgeBlur(amount:Float) { 
		this._edgeBlur = amount; 
	}
	public function disableEdgeBlur() { 
		this._edgeBlur = 0; 
	}
	public function setGrainAmount(amount:Float) { 
		this._grainAmount = amount; 
	}
	public function disableGrain() { 
		this._grainAmount = 0; 
	}
	public function setChromaticAberration(amount:Float) { 
		this._chromaticAberration = amount; 
	}
	public function disableChromaticAberration() { 
		this._chromaticAberration = 0; 
	}
	public function setEdgeDistortion(amount:Float) { 
		this._distortion = amount; 
	}
	public function disableEdgeDistortion() { 
		this._distortion = 0; 
	}
	public function setFocusDistance(amount:Float) { 
		this._dofDistance = amount; 
	}
	public function disableDepthOfField() { 
		this._dofDistance = -1; 
	}
	public function setAperture(amount:Float) { 
		this._dofAperture = amount; 
	}
	public function setDarkenOutOfFocus(amount:Float) { 
		this._dofDarken = amount; 
	}
	public function enablePentagonBokeh() { 
		this._highlightsPostProcess.updateEffect("#define PENTAGON\n"); 
	}
	public function disablePentagonBokeh() { 
		this._highlightsPostProcess.updateEffect(); 
	}
	public function enableNoiseBlur() { 
		this._blurNoise = true; 
	}
	public function disableNoiseBlur() { 
		this._blurNoise = false; 
	}
	public function setHighlightsGain(amount:Float) {
		this._highlightsGain = amount;
	}
	public function setHighlightsThreshold(amount:Float) {
		if(this._highlightsGain == -1) {
			this._highlightsGain = 1.0;
		}
		this._highlightsThreshold = amount;
	}
	public function disableHighlights() {
		this._highlightsGain = -1;
	}

	/**
	 * Removes the internal pipeline assets and detaches the pipeline from the scene cameras
	 */
	override public function dispose(disableDepthRender:Bool = false) {
		this._scene.postProcessRenderPipelineManager.detachCamerasFromRenderPipeline(this._name, this._scene.cameras);
		
		this._chromaticAberrationPostProcess = null;
		this._highlightsPostProcess = null;
		this._depthOfFieldPostProcess = null;
		
		this._grainTexture.dispose();
		
		if (disableDepthRender) {
			this._scene.disableDepthRenderer();
		}
	}

	// colors shifting and distortion
	private function _createChromaticAberrationPostProcess(ratio:Float) {
		this._chromaticAberrationPostProcess = new PostProcess("LensChromaticAberration", "chromaticAberration",
			["chromatic_aberration", "screen_width", "screen_height"],		// uniforms
			[],																// samplers
			ratio, null, Texture.TRILINEAR_SAMPLINGMODE,
			this._scene.getEngine(), false);
			
		this._chromaticAberrationPostProcess.onApply = function(effect:Effect, es:EventState = null) {
			effect.setFloat('chromatic_aberration', this._chromaticAberration);
			effect.setFloat('screen_width', this._scene.getEngine().getRenderWidth());
			effect.setFloat('screen_height', this._scene.getEngine().getRenderHeight());
		};
	}

	// highlights enhancing
	private function _createHighlightsPostProcess(ratio:Float) {
		this._highlightsPostProcess = new PostProcess("LensHighlights", "lensHighlights",
			["gain", "threshold", "screen_width", "screen_height"],      // uniforms
			[],     // samplers
			ratio, 
			null, Texture.TRILINEAR_SAMPLINGMODE,
			this._scene.getEngine(), false, this._dofPentagon ? "#define PENTAGON\n" : "");
			
		this._highlightsPostProcess.onApply = function(effect:Effect, es:EventState = null) {
			effect.setFloat('gain', this._highlightsGain);
			effect.setFloat('threshold', this._highlightsThreshold);
			effect.setTextureFromPostProcess("textureSampler", this._chromaticAberrationPostProcess);
			effect.setFloat('screen_width', this._scene.getEngine().getRenderWidth());
			effect.setFloat('screen_height', this._scene.getEngine().getRenderHeight());
		};
	}

	// colors shifting and distortion
	private function _createDepthOfFieldPostProcess(ratio:Float) {
		this._depthOfFieldPostProcess = new PostProcess("LensDepthOfField", "depthOfField",
			[
				"grain_amount", "blur_noise", "screen_width", "screen_height", "distortion", "dof_enabled",
                "screen_distance", "aperture", "darken", "edge_blur", "highlights", "near", "far"
			],
			["depthSampler", "grainSampler", "highlightsSampler"],
			ratio, null, Texture.TRILINEAR_SAMPLINGMODE,
			this._scene.getEngine(), false);
			
		this._depthOfFieldPostProcess.onApply = function(effect:Effect, es:EventState = null) {
			
			effect.setTexture("depthSampler", this._depthTexture);
			effect.setTexture("grainSampler", this._grainTexture);
			effect.setTextureFromPostProcess("textureSampler", this._highlightsPostProcess);
			effect.setTextureFromPostProcess("highlightsSampler", this._depthOfFieldPostProcess);
			
			effect.setFloat('grain_amount', this._grainAmount);
            effect.setBool('blur_noise', this._blurNoise);
			
			effect.setFloat('screen_width', this._scene.getEngine().getRenderWidth());
			effect.setFloat('screen_height', this._scene.getEngine().getRenderHeight());
			
			effect.setFloat('distortion', this._distortion);
			
			effect.setBool('dof_enabled', (this._dofDistance != -1));
			effect.setFloat('screen_distance', 1.0 / (0.1 - 1.0 / this._dofDistance));
			effect.setFloat('aperture', this._dofAperture);
			effect.setFloat('darken', this._dofDarken);
			
			effect.setFloat('edge_blur', this._edgeBlur);
			
			effect.setBool('highlights', (this._highlightsGain != -1));
			
			effect.setFloat('near', this._scene.activeCamera.minZ);
			effect.setFloat('far', this._scene.activeCamera.maxZ);
		};
	}

	// creates a black and white random noise texture, 512x512
	private function _createGrainTexture() {
		var size:Int = 512;
		
		this._grainTexture = new DynamicTexture("LensNoiseTexture", { width: size, height: size }, this._scene, false, Texture.BILINEAR_SAMPLINGMODE);
		this._grainTexture.wrapU = Texture.WRAP_ADDRESSMODE;
		this._grainTexture.wrapV = Texture.WRAP_ADDRESSMODE;
		
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		};
		
		var context = this._grainTexture.getContext();
		
		var value:Int = 0;
		var totalPixelsCount = size * size * 4;
		var i:Int = 0;
		while (i < totalPixelsCount) {		
			value = Math.floor(rand(0.42, 0.58) * 255);
			context[i] = value;
			context[i + 1] = value;
			context[i + 2] = value;
			context[i + 3] = 255;
			
			i += 4;
		}
		
		this._grainTexture.update(false);
	}

}
