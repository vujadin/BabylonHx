package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.VignettePostProcess') class VignettePostProcess extends PostProcess {
	
	// https://github.com/01010111/PostProcess-GLSL/blob/master/shaders/vignette.frag
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform vec2 resolution; uniform float outerRadius; uniform float innerRadius; uniform float intensity; void main(void) { vec4 color = texture2D(textureSampler, vUV); vec2 relativePosition = gl_FragCoord.xy / resolution - 0.5; float len = length(relativePosition); float vignette = smoothstep(outerRadius, innerRadius, len); color.rgb = mix(color.rgb, color.rgb * vignette, intensity); gl_FragColor = color; }";
	
	private var resolution:Vector2 = new Vector2(100, 100);
	
	public var outerRadius:Float = 0.6;
	public var innerRadius:Float = 0.3;
	public var intensity:Float = 0.7;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("vignettePixelShader")) {			
			ShadersStore.Shaders.set("vignettePixelShader", fragmentShader);
		}
		
		super(name, "vignette", ["resolution", "outerRadius", "innerRadius", "intensity"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.resolution.x = camera.getScene().getEngine().getRenderWidth();
			this.resolution.y = camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setVector2("resolution", this.resolution);
			effect.setFloat("outerRadius", this.outerRadius);
			effect.setFloat("innerRadius", this.innerRadius);
			effect.setFloat("intensity", this.intensity);
		});
	}
	
}
