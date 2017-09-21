package com.babylonhx.postprocess;

import com.babylonhx.math.Vector2;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.VibrancePostProcess') class NaturalColorPostProcess extends PostProcess {

	// https://github.com/hrydgard/ppsspp/blob/master/assets/shaders/natural.fsh
	static var fragmentShader:String = "#ifdef GL_ES \n precision mediump float; \n precision mediump int; \n #endif \n varying vec2 vUV; uniform sampler2D textureSampler; varying vec4 v_texcoord0; varying vec4 v_texcoord1; varying vec4 v_texcoord2; varying vec4 v_texcoord3; const mat3 RGBtoYIQ = mat3(0.299, 0.596, 0.212, 0.587, -0.275, -0.523, 0.114, -0.321, 0.311); const mat3 YIQtoRGB = mat3(1.0, 1.0, 1.0, 0.95568806036115671171, -0.27158179694405859326, -1.1081773266826619523, 0.61985809445637075388, -0.64687381613840131330, 1.7050645599191817149); const vec3 val00 = vec3(1.2, 1.2, 1.2); void main() { vec3 c0,c1; c0 = texture2D(textureSampler, v_texcoord0.xy).xyz; c0+=(texture2D(textureSampler, v_texcoord0.zy).xyz) * 0.25; c0 += (texture2D(textureSampler, v_texcoord0.xw).xyz) * 0.25; c0 += (texture2D(textureSampler, v_texcoord0.zw).xyz) * 0.125; c0 += texture2D(textureSampler, v_texcoord1.xy).xyz; c0+=(texture2D(textureSampler, v_texcoord1.zy).xyz) * 0.25; c0 += (texture2D(textureSampler, v_texcoord1.xw).xyz) * 0.25; c0 += (texture2D(textureSampler, v_texcoord1.zw).xyz) * 0.125; c0 += texture2D(textureSampler, v_texcoord2.xy).xyz; c0+=(texture2D(textureSampler, v_texcoord2.zy).xyz) * 0.25; c0 += (texture2D(textureSampler, v_texcoord2.xw).xyz) * 0.25; c0 += (texture2D(textureSampler, v_texcoord2.zw).xyz) * 0.125; c0 += texture2D(textureSampler, v_texcoord3.xy).xyz; c0+=(texture2D(textureSampler, v_texcoord3.zy).xyz) * 0.25; c0 += (texture2D(textureSampler, v_texcoord3.xw).xyz) * 0.25; c0 += (texture2D(textureSampler, v_texcoord3.zw).xyz) * 0.125; 	c0 *= 0.153846153846; c1 = RGBtoYIQ * c0; c1 = vec3(pow(c1.x, val00.x), c1.yz * val00.yz); gl_FragColor.rgb = YIQtoRGB * c1; gl_FragColor.a = 1.0; }";
	
	// https://github.com/hrydgard/ppsspp/blob/master/assets/shaders/natural.vsh
	static var vertexShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n uniform vec2 u_texelDelta; attribute vec2 position; varying vec2 vUV; varying vec4 v_texcoord0; varying vec4 v_texcoord1; varying vec4 v_texcoord2; varying vec4 v_texcoord3; const vec2 madd = vec2(0.5, 0.5); void main() { vUV = position * madd + madd; gl_Position = vec4(position, 0.0, 1.0); v_texcoord0 = vUV.xyxy + vec4(-0.5,-0.5,-1.5,-1.5) * u_texelDelta.xyxy; v_texcoord1 = vUV.xyxy + vec4( 0.5,-0.5, 1.5,-1.5) * u_texelDelta.xyxy; v_texcoord2 = vUV.xyxy + vec4(-0.5, 0.5,-1.5, 1.5) * u_texelDelta.xyxy; v_texcoord3 = vUV.xyxy + vec4( 0.5, 0.5, 1.5, 1.5) * u_texelDelta.xyxy; }";
	
	public var texelDelta:Vector2 = new Vector2(1, 1);
	

	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("naturalPixelShader")) {			
			ShadersStore.Shaders.set("naturalPixelShader", fragmentShader);
			ShadersStore.Shaders.set("naturalVertexShader", vertexShader);
		}
		
		super(name, "natural", ["u_texelDelta"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onSizeChangedObservable.add(function(_, _) {
			this.texelDelta.x = 1 / camera.getScene().getEngine().getRenderWidth();
			this.texelDelta.y = 1 / camera.getScene().getEngine().getRenderHeight();
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			effect.setVector2("u_texelDelta", this.texelDelta);
		});
	}
	
	override public function updateEffect(defines:String = null, uniforms:Array<String> = null, samplers:Array<String> = null, ?indexParameters:Dynamic, ?onCompiled:Effect->Void, ?onError:Effect->String->Void) {
		this._effect = this._engine.createEffect({ vertex: "natural", fragment: "natural" },
			["position"],
			this._parameters,
			this._samplers, defines);
	}
	
}
