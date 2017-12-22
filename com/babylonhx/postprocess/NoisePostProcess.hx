package com.babylonhx.postprocess;

import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.NoisePostProcess') class NoisePostProcess extends PostProcess {

	// https://github.com/01010111/PostProcess-GLSL/blob/master/shaders/vignette.frag
	//static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform vec2 resolution; uniform float outerRadius; uniform float innerRadius; uniform float intensity; void main(void) { vec4 color = texture2D(textureSampler, vUV); vec2 relativePosition = gl_FragCoord.xy / resolution - 0.5; float len = length(relativePosition); float vignette = smoothstep(outerRadius, innerRadius, len); color.rgb = mix(color.rgb, color.rgb * vignette, intensity); gl_FragColor = color; }";
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform float strength;	// 36.0 gives good result \n uniform float time; \n void main(void) { \n vec4 color = texture(textureSampler, vUV); \n float x = (vUV.x + 4.0 ) * (vUV.y + 4.0 ) * (time * 10.0); vec4 grain = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength; grain = 1.0 - grain; gl_FragColor = color * grain; }";
	
	public var strength:Float = 36.0;
	var time:Float = 0.0;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("noisePixelShader")) {			
			ShadersStore.Shaders.set("noisePixelShader", fragmentShader);
		}
		
		super(name, "noise", ["strength", "time"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			this.time += camera.getScene().getAnimationRatio() * 0.03;
			effect.setFloat("strength", this.strength);
			effect.setFloat("time", this.time);
		});
	}
	
}
