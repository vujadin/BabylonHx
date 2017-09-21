package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CrossHatchingPostProcess') class CrossHatchingPostProcess extends PostProcess {
	
	// http://www.geeks3d.com/20110219/shader-library-crosshatching-glsl-filter/
	public static var fragmentShader:String = "#ifdef GL_ES\nprecision highp float;\n#endif\n varying vec2 vUV; uniform sampler2D textureSampler; uniform float vx_offset; uniform float hatch_y_offset; uniform float lum_threshold_1; uniform float lum_threshold_2; uniform float lum_threshold_3; uniform float lum_threshold_4; void main(void) { vec3 tc = vec3(1.0, 0.0, 0.0); if (vUV.x < vx_offset) { float lum = length(texture2D(textureSampler, vUV).rgb); tc = vec3(1.0, 1.0, 1.0); if (lum < lum_threshold_1) { if (mod(gl_FragCoord.x + gl_FragCoord.y, 10.0) == 0.0) tc = vec3(0.0, 0.0, 0.0); } if (lum < lum_threshold_2) { if (mod(gl_FragCoord.x - gl_FragCoord.y, 10.0) == 0.0) tc = vec3(0.0, 0.0, 0.0); } if (lum < lum_threshold_3) { if (mod(gl_FragCoord.x + gl_FragCoord.y - hatch_y_offset, 10.0) == 0.0) tc = vec3(0.0, 0.0, 0.0); } if (lum < lum_threshold_4) { if (mod(gl_FragCoord.x - gl_FragCoord.y - hatch_y_offset, 10.0) == 0.0) tc = vec3(0.0, 0.0, 0.0); } } else { tc = texture2D(textureSampler, vUV).rgb; } gl_FragColor = vec4(tc, 1.0); }";
	
	public var vx_offset:Float = 1.0;
	public var hatch_y_offset:Float = 5.0;
	public var lum_threshold_1:Float = 1.0;
	public var lum_threshold_2:Float = 0.7;
	public var lum_threshold_3:Float = 0.5;
	public var lum_threshold_4:Float = 0.3;
	
	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("crossHatchingPixelShader")) {			
			ShadersStore.Shaders.set("crossHatchingPixelShader", fragmentShader);
		}
		
		super(name, "crossHatching", ["vx_offset", "hatch_y_offset", "lum_threshold_1", "lum_threshold_2", "lum_threshold_3", "lum_threshold_4"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setFloat("vx_offset", this.vx_offset);
			effect.setFloat("hatch_y_offset", this.hatch_y_offset);
			effect.setFloat("lum_threshold_1", this.lum_threshold_1);
			effect.setFloat("lum_threshold_2", this.lum_threshold_2);
			effect.setFloat("lum_threshold_3", this.lum_threshold_3);
			effect.setFloat("lum_threshold_4", this.lum_threshold_4);
		});
	}
	
}
