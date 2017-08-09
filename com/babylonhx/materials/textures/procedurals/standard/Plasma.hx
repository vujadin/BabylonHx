package com.babylonhx.materials.textures.procedurals.standard;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

 
/*
 precision highp float;

uniform vec2 texRes;
uniform float time;

float len(vec3 p) {
    return max(abs(p.x)*0.5+abs(p.z)*0.5,max(abs(p.y)*0.5+abs(p.x)*0.5,abs(p.z)*0.5+abs(p.y)*0.5));
}

void main(void)
{
	vec2 R = texRes.xy, uv = (gl_FragCoord.xy - .5*R) / texRes.y;
    
    vec3 rp = vec3(0.,20./50.,time+20./50.);
    vec3 rd = normalize(vec3(uv,1.));
    
    vec3 c = vec3(0.);
    float s = 0.;
    
    float viewVary = cos(time*0.05)*.15;
    
    for (int i = 0; i < 50; i++) {
        vec3 hp = rp+rd*s;
        float d = len(cos(hp*.6+cos(hp*.3+time*.5)))-.75;
        float cc = min(1.,pow(max(0., 1.-abs(d)*10.25),1.))/(float(i)*1.+10.);        
        
        c += (cos(vec3(hp.xy,s))*.5+.5 + cos(vec3(s+time,hp.yx)*.1)*.5+.5 + 1.)/2.*cc;
        
        s += max(abs(d),0.35+viewVary);
        rd = normalize(rd+vec3(sin(s*0.5),cos(s*0.5),0.)*d*0.05*clamp(s-1.,0.,1.));
    }
    
    gl_FragColor = vec4(c, 1.);
}
*/
@:expose("BABYLON.PlasmaProceduralTexture") class Plasma extends ProceduralTexture {
	
	public static var fragmentShader:String = "#ifdef GL_ES precision highp float; #endif \nuniform vec2 texRes;uniform float time;float len(vec3 p){return max(abs(p.x)*.5+abs(p.z)*.5,max(abs(p.y)*.5+abs(p.x)*.5,abs(p.z)*.5+abs(p.y)*.5));}void main(){vec2 R=texRes.xy,uv=(gl_FragCoord.xy-.5*R)/texRes.y;vec3 rp=vec3(0.,.4,time+.4),rd=normalize(vec3(uv,1.)),c=vec3(0.);float s=0.,viewVary=cos(time*.05)*.15;for(int i=0;i<50;i++){vec3 hp=rp+rd*s;float d=len(cos(hp*.6+cos(hp*.3+time*.5)))-.75,cc=min(1.,pow(max(0.,1.-abs(d)*10.25),1.))/(float(i)+10.);c+=(cos(vec3(hp.xy,s))*.5+.5+cos(vec3(s+time,hp.yx)*.1)*.5+.5+1.)/2.*cc;s+=max(abs(d),.35+viewVary);rd=normalize(rd+vec3(sin(s*.5),cos(s*.5),0.)*d*.05*clamp(s-1.,0.,1.));} gl_FragColor=vec4(c,1.);}";

	
	private var _time:Float = 0.0;
	private var _resolution:Vector2 = new Vector2(0, 0);
	

	public function new(name:String, size:Float, scene:Scene, ?fallbackTexture:Texture, ?generateMipMaps:Bool) {
		if (!ShadersStore.Shaders.exists("combustiontextureFragmentShader")) {
			ShadersStore.Shaders.set("combustiontextureFragmentShader", fragmentShader);
		}
		
		super(name, size, "combustiontexture", scene, fallbackTexture, generateMipMaps);
		
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
