package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.DreamVisionPostProcess') class DreamVisionPostProcess extends PostProcess {
	
	// http://www.geeks3d.com/20091112/shader-library-dream-vision-post-processing-filter-glsl/
	static var fragmentShader:String = "#ifdef GL_ES\nprecision highp float;\n#endif\n varying vec2 vUV; uniform sampler2D textureSampler; void main (void) { vec4 c = texture2D(textureSampler, vUV); c += texture2D(textureSampler, vUV+0.001); c += texture2D(textureSampler, vUV+0.003); c += texture2D(textureSampler, vUV+0.005); c += texture2D(textureSampler, vUV+0.007); c += texture2D(textureSampler, vUV+0.009); c += texture2D(textureSampler, vUV+0.011); c += texture2D(textureSampler, vUV-0.001); c += texture2D(textureSampler, vUV-0.003); c += texture2D(textureSampler, vUV-0.005); c += texture2D(textureSampler, vUV-0.007); c += texture2D(textureSampler, vUV-0.009); c += texture2D(textureSampler, vUV-0.011); c.rgb = vec3((c.r+c.g+c.b)/3.0); c = c / 9.5; gl_FragColor = c; }";
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("dreamVision.fragment")) {			
			ShadersStore.Shaders.set("dreamVision.fragment", fragmentShader);
		}
		
		super(name, "dreamVision", null, null, ratio, camera, samplingMode, engine, reusable);
	}
	
}
