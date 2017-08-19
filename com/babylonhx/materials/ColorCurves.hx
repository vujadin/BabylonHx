package com.babylonhx.materials;

import com.babylonhx.math.Color4;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The color grading curves provide additional color adjustmnent that is applied after any color grading transform (3D LUT). 
 * They allow basic adjustment of saturation and small exposure adjustments, along with color filter tinting to provide white balance adjustment or more stylistic effects.
 * These are similar to controls found in many professional imaging or colorist software. The global controls are applied to the entire image. For advanced tuning, extra controls are provided to adjust the shadow, midtone and highlight areas of the image; 
 * corresponding to low luminance, medium luminance, and high luminance areas respectively.
 */
class ColorCurves {

	private var _dirty:Bool = true;
    
	private var _tempColor:Color4 = new Color4(0, 0, 0, 0);
	
	private var _globalCurve:Color4 = new Color4(0, 0, 0, 0);
	private var _highlightsCurve:Color4 = new Color4(0, 0, 0, 0);
	private var _midtonesCurve:Color4 = new Color4(0, 0, 0, 0);
	private var _shadowsCurve:Color4 = new Color4(0, 0, 0, 0);
	
	private var _positiveCurve:Color4 = new Color4(0, 0, 0, 0);
	private var _negativeCurve:Color4 = new Color4(0, 0, 0, 0);
	
	@serialize()
	private var _globalHue:Float = 30;
	
	@serialize()
	private var _globalDensity:Float = 0;
	
	@serialize()
	private var _globalSaturation:Float = 0;
	
	@serialize()
	private var _globalExposure:Float = 0;
	
	public var globalHue(get, set):Float;
	/**
	 * Gets the global Hue value.
	 * The hue value is a standard HSB hue in the range [0,360] where 0=red, 120=green and 240=blue. The default value is 30 degrees (orange).
	 */
	private function get_globalHue():Float {
		return this._globalHue;
	}
	/**
	 * Sets the global Hue value.
	 * The hue value is a standard HSB hue in the range [0,360] where 0=red, 120=green and 240=blue. The default value is 30 degrees (orange).
	 */
	private function set_globalHue(value:Float):Float {
		this._globalHue = value;
		this._dirty = true;
		
		return value;
	}
	
	public var globalDensity(get, set):Float;
	/**
	 * Gets the global Density value.
	 * The density value is in range [-100,+100] where 0 means the color filter has no effect and +100 means the color filter has maximum effect. 
	 * Values less than zero provide a filter of opposite hue.
	 */
	private function get_globalDensity():Float {
		return this._globalDensity;
	}
	/**
	 * Sets the global Density value.
	 * The density value is in range [-100,+100] where 0 means the color filter has no effect and +100 means the color filter has maximum effect. 
	 * Values less than zero provide a filter of opposite hue.
	 */
	private function set_globalDensity(value:Float):Float {
		this._globalDensity = value;
		this._dirty = true;
		
		return value;
	}
	
	public var globalSaturation(get, set):Float;
	/**
	 * Gets the global Saturation value.
	 * This is an adjustment value in the range [-100,+100], where the default value of 0.0 makes no adjustment, positive values increase saturation and negative values decrease saturation.
	 */
	private function get_globalSaturation():Float {
		return this._globalSaturation;
	}
	/**
	 * Sets the global Saturation value.
	 * This is an adjustment value in the range [-100,+100], where the default value of 0.0 makes no adjustment, positive values increase saturation and negative values decrease saturation.
	 */
	private function set_globalSaturation(value:Float):Float {
		this._globalSaturation = value;
		this._dirty = true;
		
		return value;
	}
	
	@serialize()
	private var _highlightsHue:Float = 30;
	
	@serialize()
	private var _highlightsDensity:Float = 0;
	
	@serialize()
	private var _highlightsSaturation:Float = 0;
	
	@serialize()
	private var _highlightsExposure:Float = 0;
	
	public var highlightsHue(get, set):Float;
	/**
	 * Gets the highlights Hue value.
	 * The hue value is a standard HSB hue in the range [0,360] where 0=red, 120=green and 240=blue. The default value is 30 degrees (orange).
	 */
	private function get_highlightsHue():Float {
		return this._highlightsHue;
	}
	/**
	 * Sets the highlights Hue value.
	 * The hue value is a standard HSB hue in the range [0,360] where 0=red, 120=green and 240=blue. The default value is 30 degrees (orange).
	 */
	private function set_highlightsHue(value:Float):Float {
		this._highlightsHue = value;
		this._dirty = true;
		
		return value;
	}
	
	public var highlightsDensity(get, set):Float;
	/**
	 * Gets the highlights Density value.
	 * The density value is in range [-100,+100] where 0 means the color filter has no effect and +100 means the color filter has maximum effect. 
	 * Values less than zero provide a filter of opposite hue.
	 */
	private function get_highlightsDensity():Float {
		return this._highlightsDensity;
	}
	/**
	 * Sets the highlights Density value.
	 * The density value is in range [-100,+100] where 0 means the color filter has no effect and +100 means the color filter has maximum effect. 
	 * Values less than zero provide a filter of opposite hue.
	 */
	private function set_highlightsDensity(value:Float):Float {
		this._highlightsDensity = value;
		this._dirty = true;
		
		return value;
	}
	
	public var highlightsSaturation(get, set):Float;
	/**
	 * Gets the highlights Saturation value.
	 * This is an adjustment value in the range [-100,+100], where the default value of 0.0 makes no adjustment, positive values increase saturation and negative values decrease saturation.
	 */
	private function get_highlightsSaturation():Float {
		return this._highlightsSaturation;
	}
	/**
	 * Sets the highlights Saturation value.
	 * This is an adjustment value in the range [-100,+100], where the default value of 0.0 makes no adjustment, positive values increase saturation and negative values decrease saturation.
	 */
	private function set_highlightsSaturation(value:Float):Float {
		this._highlightsSaturation = value;
		this._dirty = true;
		
		return value;
	}
	
	public var highlightsExposure(get, set):Float;
	/**
	 * Gets the highlights Exposure value.
	 * This is an adjustment value in the range [-100,+100], where the default value of 0.0 makes no adjustment, positive values increase exposure and negative values decrease exposure.
	 */
	private function get_highlightsExposure():Float {
		return this._highlightsExposure;
	}
	/**
	 * Sets the highlights Exposure value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase exposure and negative values decrease exposure.
	 */
	private function set_highlightsExposure(value:Float):Float {
		this._highlightsExposure = value;
		this._dirty = true;
		
		return value;
	}
	
	@serialize()
	private var _midtonesHue:Float = 30;
	
	@serialize()
	private var _midtonesDensity:Float = 0;
	
	@serialize()
	private var _midtonesSaturation:Float = 0;
	
	@serialize()
	private var _midtonesExposure:Float = 0;
	
	public var hidtonesHue(get, set):Float;
	/**
	 * Gets the midtones Hue value.
	 * The hue value is a standard HSB hue in the range [0, 360] where 0=red, 120=green and 240=blue. The default value is 30 degrees (orange).
	 */
	private function get_hidtonesHue():Float {
		return this._midtonesHue;
	}
	/**
	 * Sets the midtones Hue value.
	 * The hue value is a standard HSB hue in the range [0, 360] where 0=red, 120=green and 240=blue. The default value is 30 degrees (orange).
	 */
	private function set_hidtonesHue(value:Float):Float {
		this._midtonesHue = value;
		this._dirty = true;
		
		return value;
	}
	
	public var midtonesDensity(get, set):Float;
	/**
	 * Gets the midtones Density value.
	 * The density value is in range [-100, +100] where 0 means the color filter has no effect and +100 means the color filter has maximum effect. 
	 * Values less than zero provide a filter of opposite hue.
	 */
	private function get_midtonesDensity():Float {
		return this._midtonesDensity;
	}
	/**
	 * Sets the midtones Density value.
	 * The density value is in range [-100, +100] where 0 means the color filter has no effect and +100 means the color filter has maximum effect. 
	 * Values less than zero provide a filter of opposite hue.
	 */
	private function set_midtonesDensity(value:Float):Float {
		this._midtonesDensity = value;
		this._dirty = true;
		
		return value;
	}
	
	public var midtonesSaturation(get, set):Float;
	/**
	 * Gets the midtones Saturation value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase saturation and negative values decrease saturation.
	 */
	private function get_midtonesSaturation():Float {
		return this._midtonesSaturation;
	}
	/**
	 * Sets the midtones Saturation value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase saturation and negative values decrease saturation.
	 */
	private function set_midtonesSaturation(value:Float):Float {
		this._midtonesSaturation = value;
		this._dirty = true;
		
		return value;
	}
	
	public var midtonesExposure(get, set):Float;
	/**
	 * Gets the midtones Exposure value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase exposure and negative values decrease exposure.
	 */
	private function get_midtonesExposure():Float {
		return this._midtonesExposure;
	}
	/**
	 * Sets the midtones Exposure value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase exposure and negative values decrease exposure.
	 */
	private function set_midtonesExposure(value:Float):Float {
		this._midtonesExposure = value;
		this._dirty = true;
		
		return value;
	}
	
	private var _shadowsHue:Float = 30;
	private var _shadowsDensity:Float = 0;
	private var _shadowsSaturation:Float = 0;
	private var _shadowsExposure:Float = 0;
	
	public var shadowsHue(get, set):Float;
	/**
	 * Gets the shadows Hue value.
	 * The hue value is a standard HSB hue in the range [0, 360] where 0=red, 120=green and 240=blue. The default value is 30 degrees (orange).
	 */
	private function get_shadowsHue():Float {
		return this._shadowsHue;
	}
	/**
	 * Sets the shadows Hue value.
	 * The hue value is a standard HSB hue in the range [0, 360] where 0=red, 120=green and 240=blue. The default value is 30 degrees (orange).
	 */
	private function set_shadowsHue(value:Float):Float {
		this._shadowsHue = value;
		this._dirty = true;
		
		return value;
	}
	
	public var shadowsDensity(get, set):Float;
	/**
	 * Gets the shadows Density value.
	 * The density value is in range [-100, +100] where 0 means the color filter has no effect and +100 means the color filter has maximum effect. 
	 * Values less than zero provide a filter of opposite hue.
	 */
	private function get_shadowsDensity():Float {
		return this._shadowsDensity;
	}
	/**
	 * Sets the shadows Density value.
	 * The density value is in range [-100, +100] where 0 means the color filter has no effect and +100 means the color filter has maximum effect. 
	 * Values less than zero provide a filter of opposite hue.
	 */
	private function set_shadowsDensity(value:Float):Float {
		this._shadowsDensity = value;
		this._dirty = true;
		
		return value;
	}
	
	public var shadowsSaturation(get, set):Float;
	/**
	 * Gets the shadows Saturation value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase saturation and negative values decrease saturation.
	 */
	private function get_shadowsSaturation():Float {
		return this._shadowsSaturation;
	}
	/**
	 * Sets the shadows Saturation value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase saturation and negative values decrease saturation.
	 */
	private function set_shadowsSaturation(value:Float):Float {
		this._shadowsSaturation = value;
		this._dirty = true;
		
		return value;
	}
	
	public var shadowsExposure(get, set):Float;
	/**
	 * Gets the shadows Exposure value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase exposure and negative values decrease exposure.
	 */
	private function get_shadowsExposure():Float {
		return this._shadowsExposure;
	}
	/**
	 * Sets the shadows Exposure value.
	 * This is an adjustment value in the range [-100, +100], where the default value of 0.0 makes no adjustment, positive values increase exposure and negative values decrease exposure.
	 */
	private function set_shadowsExposure(value:Float):Float {
		this._shadowsExposure = value;
		this._dirty = true;
		
		return value;
	}
	
	public function getClassName():String {
		return "ColorCurves";
	}
	
	public function new() { }
	
	/**
	 * Binds the color curves to the shader.
	 * @param colorCurves The color curve to bind
	 * @param effect The effect to bind to
	 */
	public static function Bind(colorCurves:ColorCurves, effect:Effect) {
		if (colorCurves._dirty) {
			colorCurves._dirty = false;
			
			// Fill in global info.
			colorCurves.getColorGradingDataToRef(
				colorCurves._globalHue,
				colorCurves._globalDensity,
				colorCurves._globalSaturation,
				colorCurves._globalExposure,
				colorCurves._globalCurve
			);
			
			// Compute highlights info.
			colorCurves.getColorGradingDataToRef(
				colorCurves._highlightsHue,
				colorCurves._highlightsDensity,
				colorCurves._highlightsSaturation,
				colorCurves._highlightsExposure,
				colorCurves._tempColor
			);
			
			colorCurves._tempColor.multiplyToRef(colorCurves._globalCurve, colorCurves._highlightsCurve);
			
			// Compute midtones info.
			colorCurves.getColorGradingDataToRef(
				colorCurves._midtonesHue,
				colorCurves._midtonesDensity,
				colorCurves._midtonesSaturation,
				colorCurves._midtonesExposure,
				colorCurves._tempColor
			);
			
			colorCurves._tempColor.multiplyToRef(colorCurves._globalCurve, colorCurves._midtonesCurve);
			
			// Compute shadows info.
			colorCurves.getColorGradingDataToRef(
				colorCurves._shadowsHue,
				colorCurves._shadowsDensity,
				colorCurves._shadowsSaturation,
				colorCurves._shadowsExposure,
				colorCurves._tempColor
			);
			
			colorCurves._tempColor.multiplyToRef(colorCurves._globalCurve, colorCurves._shadowsCurve);
			
			// Compute deltas (neutral is midtones).
			colorCurves._highlightsCurve.subtractToRef(colorCurves._midtonesCurve, colorCurves._positiveCurve);
			colorCurves._midtonesCurve.subtractToRef(colorCurves._shadowsCurve, colorCurves._negativeCurve);            
		}
		
		effect.setFloat4("vCameraColorCurvePositive", 
			colorCurves._positiveCurve.r,
			colorCurves._positiveCurve.g,
			colorCurves._positiveCurve.b,
			colorCurves._positiveCurve.a);
			
		effect.setFloat4("vCameraColorCurveNeutral", 
			colorCurves._midtonesCurve.r,
			colorCurves._midtonesCurve.g,
			colorCurves._midtonesCurve.b,
			colorCurves._midtonesCurve.a);
			
		effect.setFloat4("vCameraColorCurveNegative", 
			colorCurves._negativeCurve.r,
			colorCurves._negativeCurve.g,
			colorCurves._negativeCurve.b,
			colorCurves._negativeCurve.a);
	}
	
	/**
	 * Prepare the list of uniforms associated with the ColorCurves effects.
	 * @param uniformsList The list of uniforms used in the effect
	 */
	public static function PrepareUniforms(uniformsList:Array<String>) {
		uniformsList.push("vCameraColorCurveNeutral");
		uniformsList.push("vCameraColorCurvePositive");
		uniformsList.push("vCameraColorCurveNegative");
	}
	
	/**
	 * Returns color grading data based on a hue, density, saturation and exposure value.
	 * @param filterHue The hue of the color filter.
	 * @param filterDensity The density of the color filter.
	 * @param saturation The saturation.
	 * @param exposure The exposure.
	 * @param result The result data container.
	 */
	private function getColorGradingDataToRef(?hue:Float, density:Float, saturation:Float, exposure:Float, result:Color4) {
		if (hue == null) {
			return;
		}
		
		hue = ColorCurves.clamp(hue, 0, 360);
		density = ColorCurves.clamp(density, -100, 100);
		saturation = ColorCurves.clamp(saturation, -100, 100);
		exposure = ColorCurves.clamp(exposure, -100, 100);
		
		// Remap the slider/config filter density with non-linear mapping and also scale by half
		// so that the maximum filter density is only 50% control. This provides fine control 
		// for small values and reasonable range.
		density = ColorCurves.applyColorGradingSliderNonlinear(density);
		density *= 0.5;
		
		exposure = ColorCurves.applyColorGradingSliderNonlinear(exposure);
		
		if (density < 0) {
			density *= -1;
			hue = (hue + 180) % 360;
		}
		
		ColorCurves.fromHSBToRef(hue, density, 50 + 0.25 * exposure, result);            
		result.scaleToRef(2, result);
		result.a = 1 + 0.01 * saturation;
	}
	
	/**
	 * Takes an input slider value and returns an adjusted value that provides extra control near the centre.
	 * @param value The input slider value in range [-100,100].
	 * @returns Adjusted value.
	 */
	private static function applyColorGradingSliderNonlinear(value:Float):Float {
		value /= 100;
		
		var x:Float = Math.abs(value);
		x = Math.pow(x, 2);
		
		if (value < 0) {
			x *= -1;
		}
		
		x *= 100;
		
		return x;
	}
	
	/**
	 * Returns an RGBA Color4 based on Hue, Saturation and Brightness (also referred to as value, HSV).
	 * @param hue The hue (H) input.
	 * @param saturation The saturation (S) input.
	 * @param brightness The brightness (B) input.
	 * @result An RGBA color represented as Vector4.
	 */
	private static function fromHSBToRef(hue:Float, saturation:Float, brightness:Float, result:Color4) {
		var h:Float = ColorCurves.clamp(hue, 0, 360);
		var s:Float = ColorCurves.clamp(saturation / 100, 0, 1);
		var v:Float = ColorCurves.clamp(brightness / 100, 0, 1);
		
		if (s == 0) {
			result.r = v;
			result.g = v;
			result.b = v;
		} 
		else {
			// sector 0 to 5
			h /= 60;
			var i = Math.floor(h);
			
			// fractional part of h
			var f = h - i;
			var p = v * (1 - s);
			var q = v * (1 - s * f);
			var t = v * (1 - s * (1 - f));
			
			switch (i) {
				case 0:
					result.r = v;
					result.g = t;
					result.b = p;
					
				case 1:
					result.r = q;
					result.g = v;
					result.b = p;
					
				case 2:
					result.r = p;
					result.g = v;
					result.b = t;
					
				case 3:
					result.r = p;
					result.g = q;
					result.b = v;
					
				case 4:
					result.r = t;
					result.g = p;
					result.b = v;
					
				default:       // case 5:
					result.r = v;
					result.g = p;
					result.b = q;
					
			}
		}
		
		result.a = 1;
	}
	
	/**
	 * Returns a value clamped between min and max
	 * @param value The value to clamp
	 * @param min The minimum of value
	 * @param max The maximum of value
	 * @returns The clamped value.
	 */
	private static function clamp(value:Float, min:Float, max:Float):Float {
		return Math.min(Math.max(value, min), max);
	}

	/**
	 * Clones the current color curve instance.
	 * @return The cloned curves
	 */
	public function clone():ColorCurves {
		return SerializationHelper.Clone(function():ColorCurves { return new ColorCurves(); }, this);
	}

	/**
	 * Serializes the current color curve instance to a json representation.
	 * @return a JSON representation
	 */
	public function serialize():Dynamic {
		return SerializationHelper.Serialize(ColorCurves, this);
	}

	/**
	 * Parses the color curve from a json representation.
	 * @param source the JSON source to parse
	 * @return The parsed curves
	 */      
	public static function Parse(source:Dynamic):ColorCurves {
		return SerializationHelper.Parse(function():ColorCurves { return new ColorCurves(); }, source, null, null);
	}
	
}
