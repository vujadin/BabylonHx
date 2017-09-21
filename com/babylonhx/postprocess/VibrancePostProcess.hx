package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * https://github.com/evanw/glfx.js/
 * 
 * @filter       Vibrance
 * @description  Modifies the saturation of desaturated colors, leaving saturated colors unmodified.
 * @param amount -1 to 1 (-1 is minimum vibrance, 0 is no change, and 1 is maximum vibrance)
 */
@:expose('BABYLON.VibrancePostProcess') class VibrancePostProcess extends PostProcess {
	
	// https://github.com/evanw/glfx.js/blob/master/src/filters/adjust/vibrance.js
	public static var fragmentShader:String = "#ifdef GL_ES\nprecision highp float;\n#endif\n varying vec2 vUV; uniform sampler2D textureSampler; uniform float amount; void main() { vec4 color = texture2D(textureSampler, vUV); float average = (color.r + color.g + color.b) / 3.0; float mx = max(color.r, max(color.g, color.b)); float amt = (mx - average) * (-amount * 3.0); color.rgb = mix(color.rgb, vec3(mx), amt); gl_FragColor = color; }";
	
	public var amount:Float = 0.2;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("vibrancePixelShader")) {			
			ShadersStore.Shaders.set("vibrance.fragment", fragmentShader);
		}
		
		super(name, "vibrance", ["amount"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onApply = function(effect:Effect, _) {
			effect.setFloat("amount", this.amount);
		};
	}
	
}
