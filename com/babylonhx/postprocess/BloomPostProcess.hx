package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BloomPostProcess extends PostProcess {
	
	static var fragmentShader:String = "#ifdef GL_ES \n precision mediump float; \n precision mediump int; \n #endif \n uniform sampler2D textureSampler; varying vec2 vUV;	float amount = 0.60; float power = 0.5; void main() { vec3 color = texture2D(textureSampler, vUV.xy).xyz; vec4 sum = vec4(0); vec3 bloom; for(int i= -3 ;i < 3; i++) { sum += texture2D(textureSampler, vUV + vec2(-1, i)*0.004) * amount; sum += texture2D(textureSampler, vUV + vec2(0, i)*0.004) * amount; sum += texture2D(textureSampler, vUV + vec2(1, i)*0.004) * amount; } if (color.r < 0.3 && color.g < 0.3 && color.b < 0.3) { bloom = sum.xyz * sum.xyz * 0.012 + color; } else { if (color.r < 0.5 && color.g < 0.5 && color.b < 0.5) { bloom = sum.xyz * sum.xyz * 0.009 + color; } else { bloom = sum.xyz * sum.xyz * 0.0075 + color; } } bloom = mix(color, bloom, power); gl_FragColor.rgb = bloom; }";
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {	
		if (!ShadersStore.Shaders.exists("bloom.fragment")) {			
			ShadersStore.Shaders.set("bloom.fragment", fragmentShader);
		}
		
		super(name, "bloom", null, null, ratio, camera, samplingMode, engine, reusable);
	}
	
}
