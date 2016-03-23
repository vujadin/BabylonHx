package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.math.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * @filter           Hue / Saturation
 * @description      Provides rotational hue and multiplicative saturation control. RGB color space
 *                   can be imagined as a cube where the axes are the red, green, and blue color
 *                   values. Hue changing works by rotating the color vector around the grayscale
 *                   line, which is the straight line from black (0, 0, 0) to white (1, 1, 1).
 *                   Saturation is implemented by scaling all color channel values either toward
 *                   or away from the average color channel value.
 * @param hue        -1 to 1 (-1 is 180 degree rotation in the negative direction, 0 is no change,
 *                   and 1 is 180 degree rotation in the positive direction)
 * @param saturation -1 to 1 (-1 is solid gray, 0 is no change, and 1 is maximum contrast)
 */
@:expose('BABYLON.HueSaturationPostProcess') class HueSaturationPostProcess extends PostProcess {
	
	// https://github.com/evanw/glfx.js/blob/master/src/filters/adjust/huesaturation.js
	public static var fragmentShader:String = "#ifdef GL_ES\nprecision highp float;\n#endif\n varying vec2 vUV; uniform sampler2D textureSampler; uniform float hue; uniform float saturation; void main() { vec4 color = texture2D(textureSampler, vUV); float angle = hue * 3.14159265; float s = sin(angle), c = cos(angle); vec3 weights = (vec3(2.0 * c, -sqrt(3.0) * s - c, sqrt(3.0) * s - c) + 1.0) / 3.0; float len = length(color.rgb); color.rgb = vec3( dot(color.rgb, weights.xyz), dot(color.rgb, weights.zxy), dot(color.rgb, weights.yzx) ); float average = (color.r + color.g + color.b) / 3.0; if (saturation > 0.0) { color.rgb += (average - color.rgb) * (1.0 - 1.0 / (1.001 - saturation)); } else { color.rgb += (average - color.rgb) * (-saturation); } gl_FragColor = color; }";
	
	private var _hue:Float = 0.34;
	private var _saturation:Float = 0.23;
	
	public var hue(get, set):Float;
	public var saturation(get, set):Float;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("hueSaturation.fragment")) {			
			ShadersStore.Shaders.set("hueSaturation.fragment", fragmentShader);
		}
		
		super(name, "hueSaturation", ["hue", "saturation"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onApply = function(effect:Effect) {
			effect.setFloat("hue", this._hue);
			effect.setFloat("saturation", this._saturation);
		};
	}
	
	private function get_hue() {
		return this._hue;
	}
	private function set_hue(value:Float):Float {
		this._hue = Tools.Clamp(value, -1, 1);
		
		return value;
	}
	
	private function get_saturation() {
		return this._saturation;
	}
	private function set_saturation(value:Float):Float {
		this._saturation = Tools.Clamp(value, -1, 1);
		
		return value;
	}
	
}
