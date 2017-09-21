package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.BleachBypassPostProcess') class BleachBypassPostProcess extends PostProcess {
	
	// https://github.com/neilmendoza/ofxPostProcessing/blob/master/src/BleachBypassPass.cpp
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform float opacity; void main() { vec4 base = texture2D(textureSampler, vUV); vec3 lumCoeff = vec3(0.25, 0.65, 0.1); float lum = dot(lumCoeff, base.rgb); vec3 blend = vec3(lum); float L = min( 1.0, max(0.0, 10.0 * (lum - 0.45))); vec3 result1 = 2.0 * base.rgb * blend; vec3 result2 = 1.0 - 2.0 * (1.0 - blend) * (1.0 - base.rgb); vec3 newColor = mix(result1, result2, L); float A2 = opacity * base.a; vec3 mixRGB = A2 * newColor.rgb; mixRGB += ((1.0 - A2) * base.rgb); gl_FragColor = vec4(mixRGB, base.a); }";
	
	public var opacity:Float = 1.5;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("bleachBypassPixelShader")) {			
			ShadersStore.Shaders.set("bleachBypassPixelShader", fragmentShader);
		}
		
		super(name, "bleachBypass", ["opacity"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setFloat("opacity", this.opacity);
		});
	}
	
}
