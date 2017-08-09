package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Vector2;

/*

// Alexander Lemke, 2016
// Update 10/12/16: Hash function update to fix artifacts on mobile. 

const float     EPSILON         = 0.001;
const float     PI              = 3.14159265359;

uniform vec2 texRes;
uniform float time;

// noise functions based on iq's https://www.shadertoy.com/view/MslGD8
float Hash(in vec2 p)
{
    return -1.0 + 2.0 * fract(sin(dot(p, vec2(12.0, 78.0))) * 43758.0);
}

float Noise(in vec2 p)
{
    vec2 n = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(Hash(n), Hash(n + vec2(1.0, 0.0)), u.x),
               mix(Hash(n + vec2(0.0, 1.0)), Hash(n + vec2(1.0)), u.x), u.y);
}

float Spiral(in vec2 texCoord, in float rotation)
{   
    float spiral = sin(50.0 * (pow(length(texCoord), 0.25) - 0.02 * atan(texCoord.x, texCoord.y) - rotation));
    return clamp(spiral, 0.0, 1.0);
}

vec3 ColoredSpiral(in vec2 texCoord, in float rotation, in vec3 c0, in vec3 c1)
{
    return mix(c0, c1, Spiral(texCoord, rotation));
}

void main(void)
{
    vec2 screenCoord = (gl_FragCoord.xy / texRes.xy);
    vec4 finalColor = vec4(1.0);

    vec2 portalCenter = vec2(sin(time * 2.0), cos(time * 2.0)) * 0.025;
    vec2 portalTexCoord = portalCenter + vec2((screenCoord.x * 2.0 - 1.0) * (texRes.x / texRes.y), (screenCoord.y * 2.0 - 1.0));
    
    vec2 pushDirection = normalize(portalTexCoord + vec2(EPSILON));
    float noise = Noise(pushDirection + time) * 0.15 * length(portalTexCoord);

    portalTexCoord = portalTexCoord + (-noise * pushDirection);
    float r = length(portalTexCoord);

    vec3 portalColor = ColoredSpiral(portalTexCoord, 0.1 * time, vec3(0.0, 0.6, 0.0), vec3(0.35, 1.0, 0.0)); 
    finalColor.rgb = mix(finalColor.rgb, mix(portalColor, vec3(0.6, 1.0, 0.35), 0.01 + (r * r)), step(r, 1.0));     

    gl_FragColor = finalColor;
}

*/
/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose("BABYLON.SpiralProceduralTexture") class Spiral extends ProceduralTexture {

	public static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n \nconst float EPSILON=.001,PI=3.14159;uniform vec2 texRes;uniform float time;float Hash(in vec2 p){return-1.+2.*fract(sin(dot(p,vec2(12.,78.)))*43758.);}float Noise(in vec2 p){vec2 n=floor(p),f=fract(p),u=f*f*(3.-2.*f);return mix(mix(Hash(n),Hash(n+vec2(1.,0.)),u.x),mix(Hash(n+vec2(0.,1.)),Hash(n+vec2(1.)),u.x),u.y);}float Spiral(in vec2 texCoord,in float rotation){float spiral=sin(50.*(pow(length(texCoord),.25)-.02*atan(texCoord.x,texCoord.y)-rotation));return clamp(spiral,0.,1.);}vec3 ColoredSpiral(in vec2 texCoord,in float rotation,in vec3 c0,in vec3 c1){return mix(c0,c1,Spiral(texCoord,rotation));}void main(){vec2 screenCoord=gl_FragCoord.xy/texRes.xy;vec4 finalColor=vec4(1.);vec2 portalCenter=vec2(sin(time*2.),cos(time*2.))*.025,portalTexCoord=portalCenter+vec2((screenCoord.x*2.-1.)*(texRes.x/texRes.y),screenCoord.y*2.-1.),pushDirection=normalize(portalTexCoord+vec2(EPSILON));float noise=Noise(pushDirection+time)*.15*length(portalTexCoord);portalTexCoord=portalTexCoord+-noise*pushDirection;float r=length(portalTexCoord);vec3 portalColor=ColoredSpiral(portalTexCoord,.1*time,vec3(0.,.6,0.),vec3(.35,1.,0.));finalColor.xyz=mix(finalColor.xyz,mix(portalColor,vec3(.6,1.,.35),.01+r*r),step(r,1.));gl_FragColor=finalColor;}";

	
	private var _time:Float = 0.0;
	private var _resolution:Vector2 = new Vector2(0, 0);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("spiraltextureFragmentShader")) {
			ShadersStore.Shaders.set("spiraltextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "spiraltexture", scene, fallbackTexture, generateMipMaps);
		
		this._resolution.copyFromFloats(size, size);
		
		this.updateShaderUniforms();
		this.refreshRate = 1;
	}
	
	public function updateShaderUniforms() {
		this.setFloat("time", this._time);
		this.setVector2("texRes", this._resolution);
	}

	override public function render(useCameraPostProcess:Bool = false) {
		this._time += this.getScene().getAnimationRatio() * 0.03;
		this.updateShaderUniforms();
		
		super.render(useCameraPostProcess);
	}
	
}
