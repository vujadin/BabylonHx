package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*
 
//Noise animation - Electric
//by nimitz (stormoid.com) (twitter: @stormoid)

//The domain is displaced by two fbm calls one for each axis.
//Turbulent fbm (aka ridged) is used for better effect.

#define time _time*0.15
#define tau 6.2831853

uniform vec2 texRes;
uniform float _time;
uniform sampler2D noiseTex;

mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(c,-s,s,c);}
float noise( in vec2 x ){return texture2D(tmplTex, x*.01).x;}

float fbm(in vec2 p)
{	
	float z=2.;
	float rz = 0.;
	vec2 bp = p;
	for (float i= 1.;i < 6.;i++)
	{
		rz+= abs((noise(p)-0.5)*2.)/z;
		z = z*2.;
		p = p*2.;
	}
	return rz;
}

float dualfbm(in vec2 p)
{
    //get two rotated fbm calls and displace the domain
	vec2 p2 = p*.7;
	vec2 basis = vec2(fbm(p2-time*1.6),fbm(p2+time*1.7));
	basis = (basis-.5)*.2;
	p += basis;
	
	//coloring
	return fbm(p*makem2(time*0.2));
}

float circ(vec2 p) 
{
	float r = length(p);
	r = log(sqrt(r));
	return abs(mod(r*4.,tau)-3.14)*3.+.2;

}

void main(void)
{
	//setup system
	vec2 p = gl_FragCoord.xy / texRes.xy-0.5;
	p.x *= texRes.x/texRes.y;
	p*=4.;
	
    float rz = dualfbm(p);
	
	//rings
	p /= exp(mod(time*10.,3.14159));
	rz *= pow(abs((0.1-circ(p))),.9);
	
	//final color
	vec3 col = vec3(.2,0.1,0.4)/rz;
	col=pow(abs(col),vec3(.99));
	gl_FragColor = vec4(col,1.);
}

*/
 
@:expose("BABYLON.ElectricProceduralTexture") class Electric extends ProceduralTexture {
	
	public static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n#define time _time*0.15\n#define tau 6.2831853\nuniform vec2 texRes;uniform float _time;uniform sampler2D noiseTex;mat2 makem2(in float theta){float c=cos(theta),s=sin(theta);return mat2(c,-s,s,c);}float noise(in vec2 x){return texture2D(noiseTex,x*.01).x;}float fbm(in vec2 p){float z=2.,rz=0.;vec2 bp=p;for(float i=1.;i<6.;i++)rz+=abs((noise(p)-.5)*2.)/z,z=z*2.,p=p*2.;return rz;}float dualfbm(in vec2 p){vec2 p2=p*.7,basis=vec2(fbm(p2-time*1.6),fbm(p2+time*1.7));basis=(basis-.5)*.2;p+=basis;return fbm(p*makem2(time*.2));}float circ(vec2 p){float r=length(p);r=log(sqrt(r));return abs(mod(r*4.,tau)-3.14)*3.+.2;}void main(){vec2 p=gl_FragCoord.xy/texRes.xy-.5;p.x*=texRes.x/texRes.y;p*=4.;float rz=dualfbm(p);p/=exp(mod(time*10.,3.14159));rz*=pow(abs(.1-circ(p)),.9);vec3 col=vec3(.2,.1,.4)/rz;col=pow(abs(col),vec3(.49));gl_FragColor=vec4(col,1.);}";

	
	private var _time:Float = 0.0;
	private var _resolution:Vector2 = new Vector2(0, 0);
	
	private var noiseTex:Texture;
	

	public function new(name:String, size:Float, scene:Scene, ?noiseTexture:Texture, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("electrictextureFragmentShader")) {
			ShadersStore.Shaders.set("electrictextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "electrictexture", scene, fallbackTexture, generateMipMaps);
		
		noiseTexture != null ? this.noiseTex = noiseTexture : _createNoiseTexture();
		
		this._resolution.copyFromFloats(size, size);
		
		this.updateShaderUniforms();
		this.refreshRate = 1;
	}
	
	public function updateShaderUniforms() {
		this.setFloat("_time", this._time);
		this.setVector2("texRes", this._resolution);
		this.setTexture("noiseTex", this.noiseTex);
	}

	override public function render(useCameraPostProcess:Bool = false) {
		this._time += this.getScene().getAnimationRatio() * 0.02;
		this.updateShaderUniforms();
		
		super.render(useCameraPostProcess);
	}
	
	// creates a black and white random noise texture, 512x512
	private function _createNoiseTexture() {
		var size:Int = 512;
		
		this.noiseTex = new DynamicTexture("ElNoiseTexture", { width: size, height: size }, this._scene, false, Texture.BILINEAR_SAMPLINGMODE);
		this.noiseTex.wrapU = Texture.WRAP_ADDRESSMODE;
		this.noiseTex.wrapV = Texture.WRAP_ADDRESSMODE;
		
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		};
		
		var context = cast (this.noiseTex, DynamicTexture).getContext();
		
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
		
		cast (this.noiseTex, DynamicTexture).update(false);
	}
	
}
