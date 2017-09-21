package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * @filter         Ink
 * @description    Simulates outlining the image in ink by darkening edges stronger than a
 *                 certain threshold. The edge detection value is the difference of two
 *                 copies of the image, each blurred using a blur of a different radius.
 * @param strength The multiplicative scale of the ink edges. Values in the range 0 to 1
 *                 are usually sufficient, where 0 doesn't change the image and 1 adds lots
 *                 of black edges. Negative strength values will create white ink edges
 *                 instead of black ones.
 */
@:expose('BABYLON.InkPostProcess') class InkPostProcess extends PostProcess {
	
	// https://github.com/evanw/glfx.js/blob/master/src/filters/fun/ink.js
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform float strength; uniform vec2 screenSize; void main() { vec2 dx = vec2(1.0 / screenSize.x, 0.0); vec2 dy = vec2(0.0, 1.0 / screenSize.y); vec4 color = texture2D(textureSampler, vUV); float bigTotal = 0.0; float smallTotal = 0.0; vec3 bigAverage = vec3(0.0); vec3 smallAverage = vec3(0.0); for (float x = -2.0; x <= 2.0; x += 1.0) { for (float y = -2.0; y <= 2.0; y += 1.0) { vec3 _sample = texture2D(textureSampler, vUV + dx * x + dy * y).rgb; bigAverage += _sample; bigTotal += 1.0; if (abs(x) + abs(y) < 2.0) { smallAverage += _sample; smallTotal += 1.0; } } } vec3 edge = max(vec3(0.0), bigAverage / bigTotal - smallAverage / smallTotal); gl_FragColor = vec4(color.rgb - dot(edge, edge) * strength * 100000.0, color.a); }";

	public var screenSize:Vector2 = new Vector2(100, 100);
	public var strength:Float = 0.1;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("inkPixelShader")) {			
			ShadersStore.Shaders.set("inkPixelShader", fragmentShader);
		}
		
		super(name, "ink", ["screenSize", "strength"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.screenSize.x = camera.getScene().getEngine().getRenderWidth();
			this.screenSize.y = camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setVector2("screenSize", this.screenSize);
			effect.setFloat("strength", this.strength);
		});
	}
	
}
