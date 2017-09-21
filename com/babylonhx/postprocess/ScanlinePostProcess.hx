package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ScanlinePostProcess extends PostProcess {
	
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform float uResolutionY; uniform sampler2D textureSampler; uniform float _scale; \n void main(void) \n { \n if (mod(floor(vUV.y * uResolutionY / _scale), 2.0) == 0.0) \n gl_FragColor = texture2D(textureSampler, vUV) * vec4(0.8); \n else \n gl_FragColor = texture2D(textureSampler, vUV); \n }";

	private var uResolutionY:Float = 100;
	
	public var scale:Float = 2.0;
	
	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("scanlinePixelShader")) {			
			ShadersStore.Shaders.set("scanlinePixelShader", fragmentShader);
		}
		
		super(name, "scanline", ["uResolutionY", "_scale"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.uResolutionY = camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {		
			effect.setFloat("uResolutionY", this.uResolutionY);
			effect.setFloat("_scale", this.scale);
		});
	}
	
}
