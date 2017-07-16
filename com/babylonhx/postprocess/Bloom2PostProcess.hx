package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Bloom2PostProcess extends PostProcess {
	
	static var fragmentShader:String = "#ifdef GL_ES \n precision mediump float; \n precision mediump int; \n #endif \n uniform sampler2D textureSampler; \n varying vec2 vUV; \n void main() \n { \n vec4 sum = vec4(0); \n int j; \n int i; \n for(i= -4 ; i < 4; i++) \n { \n for (j = -3; j < 3; j++) \n { \n sum += texture2D(textureSampler, vUV + vec2(j, i) * 0.004) * 0.25; \n } \n } \n if (texture2D(textureSampler, vUV).r < 0.3) \n { \n gl_FragColor = sum * sum * 0.012 + texture2D(textureSampler, vUV); \n } \n else \n { \n if (texture2D(textureSampler, vUV).r < 0.5) \n { \n gl_FragColor = sum * sum * 0.009 + texture2D(textureSampler, vUV); \n } \n else \n { \n gl_FragColor = sum * sum * 0.0075 + texture2D(textureSampler, vUV); \n } \n } \n }";
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {	
		if (!ShadersStore.Shaders.exists("bloom2FragmentShader")) {			
			ShadersStore.Shaders.set("bloom2FragmentShader", fragmentShader);
		}
		
		super(name, "bloom2", null, null, ratio, camera, samplingMode, engine, reusable);
	}
	
}
