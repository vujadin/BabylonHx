package com.babylonhx.materials;

import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Tools;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This groups together the common properties used for image processing either in direct forward pass
 * or through post processing effect depending on the use of the image processing pipeline in your scene 
 * or not.
 */
class ImageProcessingConfiguration {
	
	// Static constants associated to the image processing.
	public static var VIGNETTEMODE_MULTIPLY:Int = 0;
	public static var VIGNETTEMODE_OPAQUE:Int = 1;

	/**
	 * Color curves setup used in the effect if colorCurvesEnabled is set to true 
	 */
	@serializeAsColorCurves()
	public var colorCurves:ColorCurves = new ColorCurves();

	@serialize()
	private var _colorCurvesEnabled:Bool = false;
	
	public var colorCurvesEnabled(get, set):Bool;
	/**
	 * Gets wether the color curves effect is enabled.
	 */
	private function get_colorCurvesEnabled():Bool {
		return this._colorCurvesEnabled;
	}
	/**
	 * Sets wether the color curves effect is enabled.
	 */
	private function set_colorCurvesEnabled(value:Bool):Bool {
		if (this._colorCurvesEnabled == value) {
			return value;
		}
		
		this._colorCurvesEnabled = value;
		this._updateParameters();
		return value;
	}

	/**
	 * Color grading LUT texture used in the effect if colorGradingEnabled is set to true 
	 */
	@serializeAsTexture()
	public var colorGradingTexture:BaseTexture;

	@serialize()
	private var _colorGradingEnabled:Bool = false;
	
	public var colorGradingEnabled(get, set):Bool;
	/**
	 * Gets wether the color grading effect is enabled.
	 */
	private function get_colorGradingEnabled():Bool {
		return this._colorGradingEnabled;
	}
	/**
	 * Sets wether the color grading effect is enabled.
	 */
	private function set_colorGradingEnabled(value:Bool) {
		if (this._colorGradingEnabled == value) {
			return value;
		}
		
		this._colorGradingEnabled = value;
		this._updateParameters();
		return value;
	}

	@serialize()
	private var _colorGradingWithGreenDepth:Bool = false;
	
	public var colorGradingWithGreenDepth(get, set):Bool;
	/**
	 * Gets wether the color grading effect is using a green depth for the 3d Texture.
	 */
	private function get_colorGradingWithGreenDepth():Bool {
		return this._colorGradingWithGreenDepth;
	}
	/**
	 * Sets wether the color grading effect is using a green depth for the 3d Texture.
	 */
	private function set_colorGradingWithGreenDepth(value:Bool):Bool {
		if (this._colorGradingWithGreenDepth == value) {
			return value;
		}
		
		this._colorGradingWithGreenDepth = value;
		this._updateParameters();
		return value;
	}

	@serialize()
	private var _colorGradingBGR:Bool = false;
	
	public var colorGradingBGR(get, set):Bool;
	/**
	 * Gets wether the color grading texture contains BGR values.
	 */
	private function get_colorGradingBGR():Bool {
		return this._colorGradingBGR;
	}
	/**
	 * Sets wether the color grading texture contains BGR values.
	 */
	private function set_colorGradingBGR(value:Bool):Bool {
		if (this._colorGradingBGR == value) {
			return value;
		}
		
		this._colorGradingBGR = value;
		this._updateParameters();
		return value;
	}

	@serialize()
	private var _exposure:Float = 1.0;
	
	public var exposure(get, set):Float;
	/**
	 * Gets the Exposure used in the effect.
	 */
	inline private function get_exposure():Float {
		return this._exposure;
	}
	/**
	 * Sets the Exposure used in the effect.
	 */
	private function set_exposure(value:Float):Float {
		if (this._exposure == value) {
			return value;
		}
		
		this._exposure = value;
		this._updateParameters();
		return value;
	}

	@serialize()
	private var _toneMappingEnabled:Bool = false;
	
	public var toneMappingEnabled(get, set):Bool;
	/**
	 * Gets wether the tone mapping effect is enabled.
	 */
	private function get_toneMappingEnabled():Bool {
		return this._toneMappingEnabled;
	}
	/**
	 * Sets wether the tone mapping effect is enabled.
	 */
	private function set_toneMappingEnabled(value:Bool):Bool {
		if (this._toneMappingEnabled == value) {
			return value;
		}
		
		this._toneMappingEnabled = value;
		this._updateParameters();
		return value;
	}

	@serialize()
	private var _contrast:Float = 1.0;
	
	public var contrast(get, set):Float;
	/**
	 * Gets the contrast used in the effect.
	 */
	private function get_contrast():Float {
		return this._contrast;
	}
	/**
	 * Sets the contrast used in the effect.
	 */
	private function set_contrast(value:Float):Float {
		if (this._contrast == value) {
			return value;
		}
		
		this._contrast = value;
		this._updateParameters();
		return value;
	}

	/**
	 * Vignette stretch size.
	 */
	@serialize()
	public var vignetteStretch:Float = 0;

	/**
	 * Vignette centre X Offset.
	 */
	@serialize()
	public var vignetteCentreX:Float = 0;

	/**
	 * Vignette centre Y Offset.
	 */
	@serialize()
	public var vignetteCentreY:Float = 0;

	/**
	 * Vignette weight or intensity of the vignette effect.
	 */
	@serialize()
	public var vignetteWeight:Float = 1.5;

	/**
	 * Color of the vignette applied on the screen through the chosen blend mode (vignetteBlendMode)
	 * if vignetteEnabled is set to true.
	 */
	@serializeAsColor4()
	public var vignetteColor:Color4 = new Color4(0, 0, 0, 0);

	/**
	 * Camera field of view used by the Vignette effect.
	 */
	@serialize()
	public var vignetteCameraFov:Float = 0.5;

	@serialize()
	private var _vignetteBlendMode:Int = ImageProcessingConfiguration.VIGNETTEMODE_MULTIPLY;
	
	public var vignetteBlendMode(get, set):Int;
	/**
	 * Gets the vignette blend mode allowing different kind of effect.
	 */
	private function get_vignetteBlendMode():Int {
		return this._vignetteBlendMode;
	}
	/**
	 * Sets the vignette blend mode allowing different kind of effect.
	 */
	private function set_vignetteBlendMode(value:Int):Int {
		if (this._vignetteBlendMode == value) {
			return value;
		}
		
		this._vignetteBlendMode = value;
		this._updateParameters();
		return value;
	}

	@serialize()
	private var _vignetteEnabled:Bool = false;
	
	public var vignetteEnabled(get, set):Bool;
	/**
	 * Gets wether the vignette effect is enabled.
	 */
	private function get_vignetteEnabled():Bool {
		return this._vignetteEnabled;
	}
	/**
	 * Sets wether the vignette effect is enabled.
	 */
	private function set_vignetteEnabled(value:Bool):Bool {
		if (this._vignetteEnabled == value) {
			return value;
		}
		
		this._vignetteEnabled = value;
		this._updateParameters();
		return value;
	}

	@serialize()
	private var _applyByPostProcess:Bool = false;
	
	public var applyByPostProcess(get, set):Bool;
	/**
	 * Gets wether the image processing is applied through a post process or not.
	 */
	private function get_applyByPostProcess():Bool {
		return this._applyByPostProcess;
	}
	/**
	 * Sets wether the image processing is applied through a post process or not.
	 */
	private function set_applyByPostProcess(value:Bool):Bool {
		if (this._applyByPostProcess == value) {
			return value;
		}
		
		this._applyByPostProcess = value;
		this._updateParameters();
		return value;
	}

	/**
	* An event triggered when the configuration changes and requires Shader to Update some parameters.
	* @type {BABYLON.Observable}
	*/
	public var onUpdateParameters:Observable<ImageProcessingConfiguration> = new Observable<ImageProcessingConfiguration>();
	
	
	public function new() { }

	/**
	 * Method called each time the image processing information changes requires to recompile the effect.
	 */
	public function _updateParameters() {
		this.onUpdateParameters.notifyObservers(this);
	}
	
	public function getClassName():String {
		return "ImageProcessingConfiguration";
	}

	/**
	 * Prepare the list of uniforms associated with the Image Processing effects.
	 * @param uniformsList The list of uniforms used in the effect
	 * @param defines the list of defines currently in use
	 */
	public static function PrepareUniforms(uniforms:Array<String>, defines:IImageProcessingConfigurationDefines) {
		if (defines.EXPOSURE) {
			uniforms.push("exposureLinear");
		}
		if (defines.CONTRAST) {
			uniforms.push("contrast");
		}
		if (defines.COLORGRADING) {
			uniforms.push("colorTransformSettings");
		}
		if (defines.VIGNETTE) {
			uniforms.push("vInverseScreenSize");
			uniforms.push("vignetteSettings1");
			uniforms.push("vignetteSettings2");
		}
		if (defines.COLORCURVES) {
			ColorCurves.PrepareUniforms(uniforms);
		}
	}

	/**
	 * Prepare the list of samplers associated with the Image Processing effects.
	 * @param uniformsList The list of uniforms used in the effect
	 * @param defines the list of defines currently in use
	 */
	public static function PrepareSamplers(samplersList:Array<String>, defines:IImageProcessingConfigurationDefines) {
		if (defines.COLORGRADING) {
			samplersList.push("txColorTransform");
		}
	}

	/**
	 * Prepare the list of defines associated to the shader.
	 * @param defines the list of defines to complete
	 */
	public function prepareDefines(defines:IImageProcessingConfigurationDefines, forPostProcess:Bool = false) {
		if (forPostProcess != this.applyByPostProcess) {
            defines.VIGNETTE = false;
            defines.TONEMAPPING = false;
            defines.CONTRAST = false;
            defines.EXPOSURE = false;
            defines.COLORCURVES = false;
            defines.COLORGRADING = false;  
            defines.IMAGEPROCESSING = false;              
            defines.IMAGEPROCESSINGPOSTPROCESS = this.applyByPostProcess;
            return;
        }
		defines.VIGNETTE = this.vignetteEnabled;
		defines.VIGNETTEBLENDMODEMULTIPLY = (this.vignetteBlendMode == ImageProcessingConfiguration.VIGNETTEMODE_MULTIPLY);
		defines.VIGNETTEBLENDMODEOPAQUE = !defines.VIGNETTEBLENDMODEMULTIPLY;
		defines.TONEMAPPING = this.toneMappingEnabled;
		defines.CONTRAST = (this.contrast != 1.0);
		defines.EXPOSURE = (this.exposure != 1.0);
		defines.COLORCURVES = (this.colorCurvesEnabled && this.colorCurves != null);
		defines.COLORGRADING = (this.colorGradingEnabled && this.colorGradingTexture != null);
		defines.SAMPLER3DGREENDEPTH = this.colorGradingWithGreenDepth;
		defines.SAMPLER3DBGRMAP = this.colorGradingBGR;
		defines.IMAGEPROCESSINGPOSTPROCESS = this.applyByPostProcess;
		defines.IMAGEPROCESSING = defines.VIGNETTE || defines.TONEMAPPING || defines.CONTRAST || defines.EXPOSURE || defines.COLORCURVES || defines.COLORGRADING;
	}

	/**
	 * Returns true if all the image processing information are ready.
	 */
	public function isReady() {
		// Color Grading texure can not be none blocking.
		return !this.colorGradingEnabled || this.colorGradingTexture == null || this.colorGradingTexture.isReady();
	}

	/**
	 * Binds the image processing to the shader.
	 * @param effect The effect to bind to
	 */
	public function bind(effect:Effect, aspectRatio:Float = 1) {
		// Color Curves
		if (this._colorCurvesEnabled) {
			ColorCurves.Bind(this.colorCurves, effect);
		}
		
		// Vignette
		if (this._vignetteEnabled) {
			var inverseWidth = 1 / effect.getEngine().getRenderWidth();
			var inverseHeight = 1 / effect.getEngine().getRenderHeight();
			effect.setFloat2("vInverseScreenSize", inverseWidth, inverseHeight);
			
			var vignetteScaleY = Math.tan(this.vignetteCameraFov * 0.5);
			var vignetteScaleX = vignetteScaleY * aspectRatio;
			
			var vignetteScaleGeometricMean = Math.sqrt(vignetteScaleX * vignetteScaleY);
			vignetteScaleX = Tools.Mix(vignetteScaleX, vignetteScaleGeometricMean, this.vignetteStretch);
			vignetteScaleY = Tools.Mix(vignetteScaleY, vignetteScaleGeometricMean, this.vignetteStretch);
			
			effect.setFloat4("vignetteSettings1", vignetteScaleX, vignetteScaleY, -vignetteScaleX * this.vignetteCentreX, -vignetteScaleY * this.vignetteCentreY);
			
			var vignettePower = -2.0 * this.vignetteWeight;
			effect.setFloat4("vignetteSettings2", this.vignetteColor.r, this.vignetteColor.g, this.vignetteColor.b, vignettePower);
		}
		
		// Exposure
		effect.setFloat("exposureLinear", this.exposure);
		
		// Contrast
		effect.setFloat("contrast", this.contrast);
		
		// Color transform settings
		if (this.colorGradingTexture != null) {
			effect.setTexture("txColorTransform", this.colorGradingTexture);
			var textureSize = this.colorGradingTexture.getSize().height;
			
			effect.setFloat4("colorTransformSettings",
				(textureSize - 1) / textureSize, // textureScale
				0.5 / textureSize, // textureOffset
				textureSize, // textureSize
				this.colorGradingTexture.level // weight
			);
		}
	}

	/**
	 * Clones the current image processing instance.
	 * @return The cloned image processing
	 */
	public function clone():ImageProcessingConfiguration {
		return SerializationHelper.Clone(function() { return new ImageProcessingConfiguration(); }, this);
	}

	/**
	 * Serializes the current image processing instance to a json representation.
	 * @return a JSON representation
	 */
	public function serialize() {
		// VK TODO:
		//return SerializationHelper.Serialize(this);
		return null;
	}

	/**
	 * Parses the image processing from a json representation.
	 * @param source the JSON source to parse
	 * @return The parsed image processing
	 */      
	public static function Parse(source:Dynamic):ImageProcessingConfiguration {
		return SerializationHelper.Parse(function() { return new ImageProcessingConfiguration(); }, source, null, null);
	}
	
}
