package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.LimbDarkeningPostProcess') class LimbDarkeningPostProcess extends PostProcess {
	
	// https://github.com/neilmendoza/ofxPostProcessing/blob/master/src/LimbDarkeningPass.cpp
	static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; uniform float fAspect; uniform vec3 startColor; uniform vec3 endColor; uniform float radialScale; uniform float brightness; void main() { vec2 vSunPositionScreenSpace = vec2(0.5); vec2 diff = vUV - vSunPositionScreenSpace; diff.x *= fAspect; float prop = length( diff ) / radialScale; prop = clamp( 2.5 * pow( 1.0 - prop, 3.0 ), 0.0, 1.0 ); vec3 color = mix( startColor, endColor, 1.0 - prop ); vec4 base = texture2D(textureSampler, vUV); gl_FragColor = vec4(base.xyz * color, 1.0); }";

	public var aspect:Float = 1.78;
	public var startColor:Color3 = Color3.Blue();
	public var endColor:Color3 = Color3.Red();
	public var radialScale:Float = 1.0;
	public var brightness:Float = 0.02;
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("limbDarkeningPixelShader")) {			
			ShadersStore.Shaders.set("limbDarkeningPixelShader", fragmentShader);
		}
		
		super(name, "limbDarkening", ["fAspect", "startColor", "endColor", "radialScale", "brightness"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.aspect = camera.getScene().getEngine().getRenderWidth() / camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {	
			effect.setFloat("fAspect", this.aspect);
			effect.setFloat("radialScale", this.radialScale);
			effect.setFloat("brightness", this.brightness);
			effect.setColor3("startColor", this.startColor);
			effect.setColor3("endColor", this.endColor);
		});
	}
	
}
