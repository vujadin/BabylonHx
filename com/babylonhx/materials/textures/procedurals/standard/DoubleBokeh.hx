package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*


const vec3 colorLeft = vec3(0.9, 0.1, 0.0);
const vec3 colorRight = vec3(0.0, 0.8, 0.26);

uniform vec2 iResolution;
uniform float iTime;

float rand(float x) {
    return fract(sin(x) * 458.5453123);
}

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5357);
}

float circle(vec2 p, vec2 b, float r) {
  return length(max(abs(p),0.0))-r;
}

void main(void) {
	const float speed = 0.03;
	const float ySpread = 1.8;
	const int numBlocks = 60;

	float pulse = 0.4;
	
	vec2 uv = gl_FragCoord.xy / iResolution.xy - 0.5;
	float aspect = iResolution.x / iResolution.y;
	vec3 baseColor = uv.x > 0.0 ? colorRight : colorLeft;
	
	vec3 color = pulse*baseColor*0.5*(0.9-cos(uv.x*8.0));
	uv.x *= aspect;
	
	for (int i = 0; i < numBlocks; i++) {
		float z = 1.0-rand(float(i)); // 0=far, 1=near
		float tickTime = iTime*z*speed + float(i);
		float tick = floor(tickTime);
		
		vec2 pos = vec2(0.6*aspect*(rand(tick)-0.5), sign(uv.x)*ySpread*(0.5-fract(tickTime)));
		pos.x += 0.25*sign(pos.x); // move aside
		
		vec2 size = vec2(5.0, 3.0);
		float b = circle(uv-pos, size, 0.05);
		float dust = z*smoothstep(0.22, 0.0, b)*pulse*0.5;
		
		float block = 0.6*z*smoothstep(0.028, 0.0, b / 1.4);
		color += dust*baseColor + block*z;
	}
	
	//color -= rand(uv)*0.09; // grain
	gl_FragColor = vec4(color, 1.0);
}

*/
@:expose("BABYLON.DoubleBokehProceduralTexture") class DoubleBokeh extends ProceduralTexture {

	public static var fragmentShader:String = "#extension GL_OES_standard_derivatives : enable\n #ifdef GL_ES \n precision highp float; \n #endif \n const vec3 colorLeft=vec3(.9,.1,0.),colorRight=vec3(0.,.8,.26);uniform vec2 iResolution;uniform float iTime;float rand(float x){return fract(sin(x)*458.545);}float rand(vec2 co){return fract(sin(dot(co.xy,vec2(12.9898,78.233)))*43758.5);}float circle(vec2 p,vec2 b,float r){return length(max(abs(p),0.))-r;}void main(){const float speed=.03,ySpread=1.8;const int numBlocks=60;float pulse=.4;vec2 uv=gl_FragCoord.xy/iResolution.xy-.5;float aspect=iResolution.x/iResolution.y;vec3 baseColor=uv.x>0.?colorRight:colorLeft,color=pulse*baseColor*.5*(.9-cos(uv.x*8.));uv.x*=aspect;for(int i=0;i<numBlocks;i++){float z=1.-rand(float(i)),tickTime=iTime*z*speed+float(i),tick=floor(tickTime);vec2 pos=vec2(.6*aspect*(rand(tick)-.5),sign(uv.x)*ySpread*(.5-fract(tickTime)));pos.x+=.25*sign(pos.x);vec2 size=vec2(5.,3.);float b=circle(uv-pos,size,.05),dust=z*smoothstep(.22,0.,b)*pulse*.5,block=.6*z*smoothstep(.028,0.,b);color+=dust*baseColor+block*z;}gl_FragColor=vec4(color,1.);}";

	
	private var _time:Float = 0.0;
	private var _resolution:Vector2 = new Vector2(0, 0);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("doublebokehtextureFragmentShader")) {
			ShadersStore.Shaders.set("doublebokehtextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "doublebokehtexture", scene, fallbackTexture, generateMipMaps);
		
		this._resolution.copyFromFloats(size, size);
		
		this.updateShaderUniforms();
		this.refreshRate = 1;
	}
	
	public function updateShaderUniforms() {
		this.setFloat("iTime", this._time);
		this.setVector2("iResolution", this._resolution);
	}

	override public function render(useCameraPostProcess:Bool = false) {
		this._time += this.getScene().getAnimationRatio() * 0.05;
		this.updateShaderUniforms();
		
		super.render(useCameraPostProcess);
	}
	
}