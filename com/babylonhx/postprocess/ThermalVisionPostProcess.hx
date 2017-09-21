package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.ThermalVisionPostProcess') class ThermalVisionPostProcess extends PostProcess {
	
	// http://www.geeks3d.com/20101123/shader-library-predators-thermal-vision-post-processing-filter-glsl/
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; void main(void) { vec3 tc = vec3(1.0, 0.0, 0.0); vec3 pixcol = texture2D(textureSampler, vUV).rgb; vec3 colors[3]; colors[0] = vec3(0., 0., 1.); colors[1] = vec3(1., 1., 0.); colors[2] = vec3(1., 0., 0.); float lum = dot(vec3(0.30, 0.59, 0.11), pixcol.rgb); tc = (lum < 0.5) ? mix(colors[0], colors[1], lum / 0.5) : mix(colors[1], colors[2], (lum - 0.5) / 0.5); gl_FragColor.rgb = tc; }";
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("thermalVisionPixelShader")) {			
			ShadersStore.Shaders.set("thermalVisionPixelShader", fragmentShader);
		}
		
		super(name, "thermalVision", null, null, ratio, camera, samplingMode, engine, reusable);
	}
	
}
