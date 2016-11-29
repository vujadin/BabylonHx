package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Color3;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.DynamicTexture;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.NightVisionPostProcess') class NightVisionPostProcess extends PostProcess {
	
	// http://www.geeks3d.com/20091009/shader-library-night-vision-post-processing-filter-glsl/
	public static var fragmentShader:String = "#ifdef GL_ES\nprecision highp float;\n#endif\n varying vec2 vUV; uniform sampler2D textureSampler; uniform sampler2D noiseTex; uniform sampler2D maskTex; uniform float elapsedTime; uniform float luminanceThreshold; uniform float colorAmplification; uniform float vx_offset; void main (void) { vec4 finalColor; if (vUV.x < vx_offset) {   vec2 uv; uv.x = 0.4*sin(elapsedTime*50.0); uv.y = 0.4*cos(elapsedTime*50.0); float m = texture2D(maskTex, vUV.st).r; vec3 n = texture2D(noiseTex,  (vUV.st*3.5) + uv).rgb; vec3 c = texture2D(textureSampler, vUV.st + (n.xy*0.005)).rgb; float lum = dot(vec3(0.30, 0.59, 0.11), c); if (lum < luminanceThreshold) c *= colorAmplification; vec3 visionColor = vec3(0.1, 0.95, 0.2); finalColor.rgb = (c + (n*0.2)) * visionColor * m; } else { finalColor = texture2D(textureSampler, vUV.st); } gl_FragColor.rgb = finalColor.rgb; gl_FragColor.a = 1.0; }";
	
	public var elapsedTime:Float = 0;
	public var luminanceThreshold:Float = 0.4;
	public var colorAmplification:Float = 14.0;
	public var vx_offset:Float = 1.0;
	
	private var _maskTex:Texture;
	private var _noiseTex:DynamicTexture;
	
	
	public function new(name:String, maskTextureUrl:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("nightVision.fragment")) {			
			ShadersStore.Shaders.set("nightVision.fragment", fragmentShader);
		}
		
		super(name, "nightVision", ["elapsedTime", "luminanceThreshold", "colorAmplification", "vx_offset"], ["noiseTex", "maskTex"], ratio, camera, samplingMode, engine, reusable);
		
		this._maskTex = new Texture(maskTextureUrl, camera.getScene());
		_createNoiseTexture();
		
		this.onApply = function(effect:Effect, _) {
			this.elapsedTime += camera.getScene().getAnimationRatio() * 0.03;
			effect.setFloat("elapsedTime", this.elapsedTime);
			effect.setFloat("luminanceThreshold", this.luminanceThreshold);
			effect.setFloat("colorAmplification", this.colorAmplification);
			effect.setFloat("vx_offset", this.vx_offset);
			
			effect.setTexture("noiseTex", this._noiseTex);
			effect.setTexture("maskTex", this._maskTex);
		};
	}
	
	// creates a black and white random noise texture, 512x512
	private function _createNoiseTexture() {
		var size:Int = 512;
		
		this._noiseTex = new DynamicTexture("NVNoiseTexture", { width: size, height: size }, this._scene, false, Texture.BILINEAR_SAMPLINGMODE);
		this._noiseTex.wrapU = Texture.WRAP_ADDRESSMODE;
		this._noiseTex.wrapV = Texture.WRAP_ADDRESSMODE;
		
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		};
		
		var context = this._noiseTex.getContext();
		
		var value:Int = 0;
		var totalPixelsCount = size * size * 4;
		var i:Int = 0;
		while (i < totalPixelsCount) {		
			value = Math.floor((Math.random() * (0.02 - 0.95) + 0.95) * 255);
			context[i] = value;
			context[i + 1] = value;
			context[i + 2] = value;
			context[i + 3] = 255;
			
			i += 4;
		}
		
		this._noiseTex.update(false);
	}
	
}
