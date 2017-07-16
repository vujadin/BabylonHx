package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Blur2PostProcess') class Blur2PostProcess extends PostProcess {

	// https://www.shadertoy.com/view/XssSDs
	public static var fragmentShader:String = "#ifdef GL_ES\nprecision highp float;\n#endif\n varying vec2 vUV; uniform sampler2D textureSampler; uniform vec2 screenSize; vec2 Circle(float Start, float Points, float Point) { float Rad = (6.283185 * (1.0 / Points)) * (Point + Start); return vec2(sin(Rad), cos(Rad)); } void main() { vec2 PixelOffset = 1.0 / screenSize.xy; float Start = 0.1428571; vec2 Scale = 6.6 * PixelOffset.xy; vec3 N0 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 0.0) * Scale).rgb; vec3 N1 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 1.0) * Scale).rgb; vec3 N2 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 2.0) * Scale).rgb; vec3 N3 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 3.0) * Scale).rgb; vec3 N4 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 4.0) * Scale).rgb; vec3 N5 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 5.0) * Scale).rgb; vec3 N6 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 6.0) * Scale).rgb; vec3 N7 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 7.0) * Scale).rgb; vec3 N8 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 8.0) * Scale).rgb; vec3 N9 = texture2D(textureSampler, vUV + Circle(Start, 14.0, 9.0) * Scale).rgb;  vec3 N10 = texture2D(textureSampler, vUV).rgb; float W = 1.0 / 15.0; vec3 color = vec3(0,0,0); color.rgb = (N0 * W) + (N1 * W) + (N2 * W) + (N3 * W) + (N4 * W) + (N5 * W) + (N6 * W) + (N7 * W) + (N8 * W) + (N9 * W) + (N10 * W); gl_FragColor = vec4(color.rgb + vec3(0.1, 0.1, 0.1), 1.0); }";
	
	public var screenSize:Vector2 = new Vector2(1, 1);
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("blur2.fragment")) {			
			ShadersStore.Shaders.set("blur2.fragment", fragmentShader);
		}
		
		super(name, "blur2", ["screenSize"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChanged = function(_, _) {
			this.screenSize.x = camera.getScene().getEngine().getRenderWidth();
			this.screenSize.y = camera.getScene().getEngine().getRenderHeight();
		};
		
		this.onApply = function(effect:Effect, _) {
			effect.setVector2("screenSize", this.screenSize);
		};
		
		this.onSizeChanged(this._effect, null);
	}
	
}
