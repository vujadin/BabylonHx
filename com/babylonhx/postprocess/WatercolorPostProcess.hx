package com.babylonhx.postprocess;

import com.babylonhx.engine.Engine;
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
class WatercolorPostProcess extends PostProcess {

	// https://www.shadertoy.com/view/ltyGRV
	private static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n #define Res texSamplerRes.xy \n #define Res0 noiseTexRes.xy \n #define PI 3.14159265358979 \n #define SampNum 3 \n #define N(a)(a.yx*vec2(1,-1)) \n uniform sampler2D textureSampler,noiseTex,noiseTex2;uniform vec2 texSamplerRes,noiseTexRes,noiseTexRes2;uniform float elapsedTime;vec4 getCol(vec2 pos){vec2 uv=pos/Res;vec4 c1=texture2D(textureSampler,uv),c2=vec4(.4);float d=clamp(dot(c1.xyz,vec3(-.5,1.,-.5)),0.,1.);return mix(c1,c2,1.8*d);}vec4 getCol2(vec2 pos){vec2 uv=pos/Res;vec4 c1=texture2D(textureSampler,uv),c2=vec4(1.5);float d=clamp(dot(c1.xyz,vec3(-.5,1.,-.5)),0.,1.);return mix(c1,c2,1.8*d);}vec2 getGrad(vec2 pos,float delta){vec2 d=vec2(delta,0);return vec2(dot((getCol(pos+d.xy)-getCol(pos-d.xy)).xyz,vec3(.333)),dot((getCol(pos+d.yx)-getCol(pos-d.yx)).xyz,vec3(.333)))/delta;}vec2 getGrad2(vec2 pos,float delta){vec2 d=vec2(delta,0);return vec2(dot((getCol2(pos+d.xy)-getCol2(pos-d.xy)).xyz,vec3(.333)),dot((getCol2(pos+d.yx)-getCol2(pos-d.yx)).xyz,vec3(.333)))/delta;}vec4 getRand(vec2 pos){vec2 uv=pos/Res0;return texture2D(noiseTex,uv);}float htPattern(vec2 pos){float p,r=getRand(pos*.4/.7).x;p=clamp(pow(r+.3,2.)-.45,0.,1.);return p;}float getVal(vec2 pos,float level){return dot(getCol(pos).xyz,vec3(.333));}vec4 getBWDist(vec2 pos){return vec4(smoothstep(.9,1.1,getVal(pos,0.)*.9+htPattern(pos*.7)));}void main(){vec2 pos=(gl_FragCoord.xy-Res.xy*.5)/Res.y*Res0.y+Res0.xy*.5,pos2=pos,pos3=pos,pos4=pos,pos0=pos;vec3 col=vec3(0),col2=vec3(0);float cnt=0.,cnt2=0.;for(int i=0;i<1*SampNum;i++){vec2 gr=getGrad(pos,2.)+.0001*(getRand(pos).xy-.5),gr2=getGrad(pos2,2.)+.0001*(getRand(pos2).xy-.5),gr3=getGrad2(pos3,2.)+.0001*(getRand(pos3).xy-.5),gr4=getGrad2(pos4,2.)+.0001*(getRand(pos4).xy-.5);float grl=clamp(10.*length(gr),0.,1.),gr2l=clamp(10.*length(gr2),0.,1.);pos+=.8*normalize(N(gr));pos2-=.8*normalize(N(gr2));float fact=1.-float(i)/float(SampNum);col+=fact*mix(vec3(1.2),getBWDist(pos).xyz*2.,grl);col+=fact*mix(vec3(1.2),getBWDist(pos2).xyz*2.,gr2l);pos3+=.25*normalize(gr3)+.5*(getRand(pos0*.07).xy-.5);pos4-=.5*normalize(gr4)+.5*(getRand(pos0*.07).xy-.5);float f1=3.*fact,f2=4.*(.7-fact);col2+=f1*(getCol2(pos3).xyz+.25+.4*getRand(pos3).xyz);col2+=f2*(getCol2(pos4).xyz+.25+.4*getRand(pos4).xyz);cnt2+=f1+f2;cnt+=fact;}col/=cnt*2.5;col2/=cnt2*1.65;col=clamp(clamp(col*.9+.1,0.,1.)*col2,0.,1.);float r=length((gl_FragCoord.xy-texSamplerRes.xy*.5)/texSamplerRes.x),vign=1.-r*r*r*r;gl_FragColor=vec4(col*vign,1.);}";
	
	public var elapsedTime:Float = 0;
	private var noiseTex:DynamicTexture;
	
	private var texSamplerRes:Vector2 = new Vector2(0, 0);

	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("watercolorPixelShader")) {			
			ShadersStore.Shaders.set("watercolorPixelShader", fragmentShader);
		}
		
		super(name, "watercolor", ["elapsedTime", "texSamplerRes", "noiseTexRes"], ["noiseTex"], ratio, camera, samplingMode, engine, reusable);
		
		_createNoiseTexture();
		
		this.onSizeChangedObservable.add(function(_, _) {
			texSamplerRes.x = camera.getScene().getEngine().width;
			texSamplerRes.y = camera.getScene().getEngine().height;
		});
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			this.elapsedTime += camera.getScene().getAnimationRatio() * 0.03;
			
			effect.setFloat("elapsedTime", this.elapsedTime);			
			effect.setTexture("noiseTex", this.noiseTex);
			effect.setVector2("texSamplerRes", texSamplerRes);
			effect.setVector2("noiseTexRes", texSamplerRes);
		});
	}
	
	// creates a black and white random noise texture, 512x512
	private function _createNoiseTexture() {
		var size:Int = 512;
		
		this.noiseTex = new DynamicTexture("WNoiseTexture", { width: size, height: size }, this._scene, false, Texture.BILINEAR_SAMPLINGMODE);
		this.noiseTex.wrapU = Texture.WRAP_ADDRESSMODE;
		this.noiseTex.wrapV = Texture.WRAP_ADDRESSMODE;
		
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		};
		
		var context = this.noiseTex.getContext();
		
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
		
		this.noiseTex.update(false);
	}
	
}