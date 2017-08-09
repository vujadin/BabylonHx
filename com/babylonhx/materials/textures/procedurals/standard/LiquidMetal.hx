package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*

// http://pixelshaders.com/editor/
// Iterated Fractional Brownian Motion
//Based on: http://www.iquilezles.org/www/articles/warp/warp.htm


precision mediump float;

varying vec2 position;
uniform float time;
uniform vec2 resolution;

// makes a pseudorandom number between 0 and 1
float hash(float n) {
  return fract(sin(n)*93942.234);
}

// smoothsteps a grid of random numbers at the integers
float noise(vec2 p) {
  vec2 w = floor(p);
  vec2 k = fract(p);
  k = k*k*(3.-2.*k); // smooth it
  
  float n = w.x + w.y*57.;
  
  float a = hash(n);
  float b = hash(n+1.);
  float c = hash(n+57.);
  float d = hash(n+58.);
  
  return mix(
    mix(a, b, k.x),
    mix(c, d, k.x),
    k.y);
}

// rotation matrix
mat2 m = mat2(0.6,0.8,-0.8,0.6);

// fractional brownian motion (i.e. photoshop clouds)
float fbm(vec2 p) {
  float f = 0.;
  f += 0.5000*noise(p); p *= 2.02*m;
  f += 0.2500*noise(p); p *= 2.01*m;
  f += 0.1250*noise(p); p *= 2.03*m;
  f += 0.0625*noise(p);
  f /= 0.9375;
  return f;
}

void main() {
  // relative coordinates
  vec2 p = vec2(position*6.)*vec2(resolution.x/resolution.y, 1.);
  float t = time * .009;
  
  // calling fbm on itself
  vec2 a = vec2(fbm(p+t*3.), fbm(p-t*3.+8.1));
  vec2 b = vec2(fbm(p+t*4. + a*7. + 3.1), fbm(p-t*4. + a*7. + 91.1));
  float c = fbm(b*9. + t*20.);
  
  // increase contrast
  c = smoothstep(0.15,0.98,c);
  
  // mix in some color
  vec3 col = vec3(c);
  col.rb += b*0.17;
  
  gl_FragColor = vec4(col, 1.);
}

*/
 
@:expose("BABYLON.LiquidMetalProceduralTexture") class LiquidMetal extends ProceduralTexture {
	
	public static var fragmentShader:String = "#ifdef GL_ES precision mediump float; #endif \n uniform float time; \n varying vec2 vPosition; \n uniform vec2 resolution; \n float hash(float n) { return fract(sin(n)*93942.234); } \n float noise(vec2 p) { vec2 w = floor(p); vec2 k = fract(p); k = k*k*(3.-2.*k); float n = w.x + w.y*57.; float a = hash(n); float b = hash(n+1.); float c = hash(n+57.); float d = hash(n+58.); return mix(mix(a, b, k.x), mix(c, d, k.x), k.y); } \n mat2 m = mat2(0.3,0.4,-0.4,0.4); \n float fbm(vec2 p) { float f = 0.; f += 0.5000*noise(p); p *= 2.02*m; f += 0.2500*noise(p); p *= 2.01*m; f += 0.1250*noise(p); p *= 2.03*m; f += 0.0625*noise(p); f /= 0.9375; return f; } \n void main(void) { vec2 p = vec2(vPosition*6.)*vec2(resolution.x/resolution.y, 1.); float t = time * .009; vec2 a = vec2(fbm(p+t*3.), fbm(p-t*3.+8.1)); vec2 b = vec2(fbm(p+t*4. + a*7. + 3.1), fbm(p-t*4. + a*7. + 91.1)); float c = fbm(b*9. + t*20.); c = smoothstep(0.15,0.98,c); vec3 col = vec3(c); col.rb += b*0.17; gl_FragColor = vec4(col, 1.); }";

	private var _time:Float = 0.0;
	private var _resolution:Vector2 = new Vector2(0, 0);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("liquidmetaltextureFragmentShader")) {
			ShadersStore.Shaders.set("liquidmetaltextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "liquidmetaltexture", scene, fallbackTexture, generateMipMaps);
		
		this._resolution.copyFromFloats(size, size);
		
		this.updateShaderUniforms();
		this.refreshRate = 1;
	}
	
	public function updateShaderUniforms() {
		this.setFloat("time", this._time);
		this.setVector2("resolution", this._resolution);
	}

	override public function render(useCameraPostProcess:Bool = false) {
		this._time += this.getScene().getAnimationRatio() * 0.03;
		this.updateShaderUniforms();
		
		super.render(useCameraPostProcess);
	}
	
}
