package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.DreamVisionPostProcess') class DreamVisionPostProcess extends PostProcess {
	
	// http://www.geeks3d.com/20091112/shader-library-dream-vision-post-processing-filter-glsl/
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; void main (void) { vec4 color = texture2D(textureSampler, vUV); color += texture2D(textureSampler, vUV+0.001); color += texture2D(textureSampler, vUV+0.003); color += texture2D(textureSampler, vUV+0.005); color += texture2D(textureSampler, vUV+0.007); color += texture2D(textureSampler, vUV+0.009); color += texture2D(textureSampler, vUV+0.011); color += texture2D(textureSampler, vUV-0.001); color += texture2D(textureSampler, vUV-0.003); color += texture2D(textureSampler, vUV-0.005); color += texture2D(textureSampler, vUV-0.007); color += texture2D(textureSampler, vUV-0.009); color += texture2D(textureSampler, vUV-0.011); color.rgb = vec3((color.r+color.g+color.b)/3.0); color = color / 9.5; gl_FragColor = color; }";
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("dreamVisionPixelShader")) {			
			ShadersStore.Shaders.set("dreamVisionPixelShader", fragmentShader);
		}
		
		super(name, "dreamVision", null, null, ratio, camera, samplingMode, engine, reusable);
	}
	
}
