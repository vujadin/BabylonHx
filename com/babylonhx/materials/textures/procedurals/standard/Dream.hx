package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*

// Made by k-mouse (2016-11-23)
// Modified from David Hoskins (2013-07-07) and joltz0r (2013-07-04)

#extension GL_OES_standard_derivatives : enable

precision highp float;

#define TAU 6.28318530718

#define TILING_FACTOR 1.0
#define MAX_ITER 4

uniform vec2 iResolution;
uniform float iTime;


float waterHighlight(vec2 p, float time, float foaminess) {
    vec2 i = vec2(p);
	float c = 0.0;
    float foaminess_factor = mix(1.0, 8.0, foaminess);
	float inten = .007 * foaminess_factor;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (6.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)),p.y / (cos(i.y+t))));
	}
	c = 0.2 + c / (inten * float(MAX_ITER));
	c = 1.17-pow(c, 1.4);
    c = pow(abs(c), 4.0);
	return c / sqrt(foaminess_factor);
}


void main(void) {
	float time = iTime * 0.1+23.0;
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 uv_square = vec2(uv.x * iResolution.x / iResolution.y, uv.y);
    float dist_center = pow(2.0*length(uv - 0.5), 2.0);
    
    float foaminess = smoothstep(0.4, 1.8, dist_center);
    float clearness = 0.1 + 0.9*smoothstep(0.1, 0.25, dist_center);
    
	vec2 p = mod(uv_square*TAU*TILING_FACTOR, TAU)-150.0;
    
    float c = waterHighlight(p, time, foaminess);
    
    vec3 water_color = vec3(0.1, 0.25, 0.7);
	vec3 color = vec3(c);
    color = clamp(color + water_color, 0.1, 1.0);
    
    color = mix(water_color, color, clearness);

	gl_FragColor = vec4(color, 1.0);
}

*/
@:expose("BABYLON.DreamProceduralTexture") class Dream extends ProceduralTexture {

	public static var fragmentShader:String = "#extension GL_OES_standard_derivatives : enable\n #ifdef GL_ES \n precision highp float; \n #endif \n#define TAU 6.28318530718 \n #define TILING_FACTOR 1.0 \n #define MAX_ITER 4 \n uniform vec2 iResolution;uniform float iTime;float waterHighlight(vec2 p,float time,float foaminess){vec2 i=vec2(p);float c=0.,foaminess_factor=mix(1.,8.,foaminess),inten=.007*foaminess_factor;for(int n=0;n<MAX_ITER;n++){float t=time*(1.-6.5/float(n+1));i=p+vec2(cos(t-i.x)+sin(t+i.y),sin(t-i.y)+cos(t+i.x));c+=1./length(vec2(p.x/sin(i.x+t),p.y/cos(i.y+t)));}c=.2+c/(inten*float(MAX_ITER));c=1.17-pow(c,1.4);c=pow(abs(c),4.);return c/sqrt(foaminess_factor);}void main(){float time=iTime*.1+23.;vec2 uv=gl_FragCoord.xy/iResolution.xy,uv_square=vec2(uv.x*iResolution.x/iResolution.y,uv.y);float dist_center=pow(2.*length(uv-.5),2.),foaminess=smoothstep(.4,1.8,dist_center),clearness=.1+.9*smoothstep(.1,.25,dist_center);vec2 p=mod(uv_square*TAU*TILING_FACTOR,TAU)-150.;float c=waterHighlight(p,time,foaminess);vec3 water_color=vec3(.1,.25,.7),color=vec3(c);color=clamp(color+water_color,.1,1.);color=mix(water_color,color,clearness);gl_FragColor=vec4(color,1.);}";

	
	private var _time:Float = 0.0;
	private var _resolution:Vector2 = new Vector2(0, 0);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("dreamtextureFragmentShader")) {
			ShadersStore.Shaders.set("dreamtextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "dreamtexture", scene, fallbackTexture, generateMipMaps);
		
		this._resolution.copyFromFloats(size, size);
		
		this.updateShaderUniforms();
		this.refreshRate = 1;
	}
	
	public function updateShaderUniforms() {
		this.setFloat("iTime", this._time);
		this.setVector2("iResolution", this._resolution);
	}

	override public function render(useCameraPostProcess:Bool = false) {
		this._time += this.getScene().getAnimationRatio() * 0.005;
		this.updateShaderUniforms();
		
		super.render(useCameraPostProcess);
	}
	
}
