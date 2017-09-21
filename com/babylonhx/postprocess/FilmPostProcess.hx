package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Color3;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.DynamicTexture;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

// https://shawn0326.github.io/zen-3d/examples/#postprocessing_film
/*
 #ifdef GL_ES \n precision highp float; \n #endif \n 
 
 #extension GL_OES_standard_derivatives : enable

precision highp float;
precision highp int;

float pow2( const in float x ) {
    return x*x;
}
#define LOG2 1.442695
#define RECIPROCAL_PI 0.31830988618
#define PI 3.14159265359
#define EPSILON 1e-6

#define saturate(a) clamp( a, 0.0, 1.0 )
#define whiteCompliment(a) ( 1.0 - saturate( a ) )

highp float rand( const in vec2 uv ) {
    const highp float a = 12.9898, b = 78.233, c = 43758.5453;
    highp float dt = dot( uv.xy, vec2( a, b ) ), sn = mod( dt, PI );
    return fract(sin(sn) * c);
}

uniform float elapsedTime;
uniform bool grayscale;
uniform float nIntensity;
uniform float sIntensity;
uniform float sCount;
uniform sampler2D textureSampler;
varying vec2 vUV;
void main() {
    vec4 cTextureScreen = texture2D( textureSampler, vUV );
    float dx = rand( vUV + elapsedTime );
    vec3 cResult = cTextureScreen.rgb + cTextureScreen.rgb * clamp( 0.1 + dx, 0.0, 1.0 );
    vec2 sc = vec2( sin( vUV.y * sCount ), cos( vUV.y * sCount ) );
    cResult += cTextureScreen.rgb * vec3( sc.x, sc.y, sc.x ) * sIntensity;
    cResult = cTextureScreen.rgb + clamp( nIntensity, 0.0, 1.0 ) * ( cResult - cTextureScreen.rgb );
    if( grayscale ) {
        cResult = vec3( cResult.r * 0.3 + cResult.g * 0.59 + cResult.b * 0.11 );
    }
    gl_FragColor = vec4( cResult, cTextureScreen.a );
}
*/
 
class FilmPostProcess extends PostProcess {

	private static var fragmentShader:String = "#extension GL_OES_standard_derivatives : enable \n precision highp float; \n precision highp int; \n float pow2( const in float x ) { \n return x*x; \n } \n #define PI 3.14159265359 \n highp float rand( const in vec2 uv ) { \n const highp float a = 12.9898, b = 78.233, c = 43758.5453; \n highp float dt = dot( uv.xy, vec2( a, b ) ), sn = mod( dt, PI ); \n return fract(sin(sn) * c); \n } \n uniform float elapsedTime; uniform bool grayscale; uniform float nIntensity; uniform float sIntensity; uniform float sCount; uniform sampler2D textureSampler; varying vec2 vUV; \n void main() { \n vec4 cTextureScreen = texture2D( textureSampler, vUV ); float dx = rand( vUV + elapsedTime ); vec3 cResult = cTextureScreen.rgb + cTextureScreen.rgb * clamp( 0.1 + dx, 0.0, 1.0 ); vec2 sc = vec2( sin( vUV.y * sCount ), cos( vUV.y * sCount ) ); cResult += cTextureScreen.rgb * vec3( sc.x, sc.y, sc.x ) * sIntensity; cResult = cTextureScreen.rgb + clamp( nIntensity, 0.0, 1.0 ) * ( cResult - cTextureScreen.rgb ); if( grayscale ) { cResult = vec3( cResult.r * 0.3 + cResult.g * 0.59 + cResult.b * 0.11 ); } gl_FragColor = vec4( cResult, cTextureScreen.a ); \n }";
	
	public var elapsedTime:Float = 0;
	public var grayscale:Bool = true;
	public var nIntensity:Float = 0.8;
	public var sIntensity:Float = 0.3;
	public var sCount:Float = 4096;
	
	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("filmPixelShader")) {			
			ShadersStore.Shaders.set("filmPixelShader", fragmentShader);
		}
		
		super(name, "film", ["elapsedTime", "grayscale", "nIntensity", "sIntensity", "sCount"], null, ratio, camera, samplingMode, engine, reusable);
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			this.elapsedTime += camera.getScene().getAnimationRatio() * 0.00001;
			effect.setFloat("elapsedTime", this.elapsedTime);			
			effect.setBool("grayscale", this.grayscale);
			effect.setFloat("nIntensity", this.nIntensity);
			effect.setFloat("sIntensity", this.sIntensity);
			effect.setFloat("sCount", this.sCount);
		});
	}
	
}
