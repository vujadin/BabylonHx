package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.ScreenDistortionPostProcess') class ScreenDistortionPostProcess extends PostProcess {

	// https://www.shadertoy.com/view/XlX3D4
	public static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform vec2 screenSize; uniform float elapsedTime; uniform float waveFrequency; uniform float waveAmplitude; void main(void) { vec2 baseUV = gl_FragCoord.xy / screenSize.xy; float time1 = elapsedTime * 0.6; vec2 mainUV = baseUV; mainUV.x += sin(time1 + mainUV.y * waveFrequency) * waveAmplitude; mainUV.y += sin(time1 + mainUV.x * waveFrequency) * waveAmplitude; vec2 differenceInUV = mainUV - baseUV; vec4 surfaceColor = texture2D(textureSampler, baseUV + differenceInUV); gl_FragColor = vec4(surfaceColor.xyz, 1.0); }";
	
	public var screenSize:Vector2 = new Vector2(100, 100);
	public var elapsedTime:Float = 0.0;
	public var waveFrequency:Float = 2.0;
	public var waveAmplitude:Float = 0.06;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("screenDistortion.fragment")) {			
			ShadersStore.Shaders.set("screenDistortion.fragment", fragmentShader);
		}
		
		super(name, "screenDistortion", ["screenSize", "elapsedTime", "waveFrequency", "waveAmplitude"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChanged = function(_, _) {
			this.screenSize.x = camera.getScene().getEngine().getRenderWidth() * 1.1;
			this.screenSize.y = camera.getScene().getEngine().getRenderHeight() * 1.1;
		};
		
		this.onApply = function(effect:Effect, _) {
			this.elapsedTime += camera.getScene().getAnimationRatio() * 0.03;
			effect.setFloat("elapsedTime", this.elapsedTime);
			effect.setVector2("screenSize", this.screenSize);
			effect.setFloat("waveFrequency", this.waveFrequency);
			effect.setFloat("waveAmplitude", this.waveAmplitude);
		};
		
		this.onSizeChanged(this._effect, null);
	}
	
}
