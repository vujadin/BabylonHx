package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.CrossStitchingPostProcess') class CrossStitchingPostProcess extends PostProcess {
	
	// http://www.geeks3d.com/20110408/cross-stitching-post-processing-shader-glsl-filter-geexlab-pixel-bender/
	public static var fragmentShader:String = "#ifdef GL_ES\nprecision highp float;\n#endif\n varying vec2 vUV; uniform sampler2D textureSampler; uniform float rt_w; uniform float rt_h; uniform float stitching_size; uniform float _invert; vec4 PostFX(sampler2D tex, vec2 uv) { vec4 c = vec4(0.0); vec2 cPos = uv * vec2(rt_w, rt_h); vec2 tlPos = floor(cPos / vec2(stitching_size, stitching_size)); tlPos *= stitching_size; int remX = int(mod(cPos.x, stitching_size)); int remY = int(mod(cPos.y, stitching_size)); if (remX == 0 && remY == 0) tlPos = cPos; vec2 blPos = tlPos; blPos.y += (stitching_size - 1.0); if ((remX == remY) || (((int(cPos.x) - int(blPos.x)) == (int(blPos.y) - int(cPos.y))))) { if (_invert == 1.0) c = vec4(0.2, 0.15, 0.05, 1.0); else c = texture2D(tex, tlPos * vec2(1.0/rt_w, 1.0/rt_h)) * 1.4; } else { if (_invert == 1.0)  c = texture2D(tex, tlPos * vec2(1.0/rt_w, 1.0/rt_h)) * 1.4; else c = vec4(0.0, 0.0, 0.0, 1.0); } return c; } void main (void) { vec2 uv = vUV.st; gl_FragColor = PostFX(textureSampler, uv); }";

	public var stitching_size:Float = 6.0;
	public var invert:Bool = false;
	
	private var resolution:Vector2 = new Vector2(1, 1);
	
	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("crossStitchingPixelShader")) {			
			ShadersStore.Shaders.set("crossStitchingPixelShader", fragmentShader);
		}
		
		super(name, "crossStitching", ["rt_w", "rt_h", "stitching_size", "_invert"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.resolution.x = camera.getScene().getEngine().getRenderWidth();
			this.resolution.y = camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setFloat("rt_w", this.resolution.x);
			effect.setFloat("rt_h", this.resolution.y);
			effect.setFloat("stitching_size", this.stitching_size);
			effect.setFloat("_invert", this.invert ? 1.0 : 0.0);
		});
	}
	
}
