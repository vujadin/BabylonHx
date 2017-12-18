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
class NotebookDrawingsPostProcess extends PostProcess {
	
	// https://www.shadertoy.com/view/XtVGD1
	private static var fragmentShader:String = "#ifdef GL_ES \n precision highp float; \n #endif \n #define Res0 texSamplerRes.xy \n #define Res1 noiseTexRes.xy \n #define iResolution Res0 \n #define Res  iResolution.xy \n #define randSamp noiseTex \n #define colorSamp textureSampler \n uniform sampler2D textureSampler; \n varying vec2 vUV; \n uniform sampler2D noiseTex; \n uniform float elapsedTime; \n uniform vec2 texSamplerRes; \n uniform vec2 noiseTexRes; \n vec4 getRand(vec2 pos) \n { \n return texture2D(noiseTex,pos/Res1/iResolution.y*1080.); \n } \n vec4 getCol(vec2 pos) \n { \n vec2 uv=((pos-Res.xy*.5)/Res.y*Res0.y)/Res0.xy+.5; \n vec4 c1=texture2D(textureSampler,uv); \n vec4 e=smoothstep(vec4(-0.05),vec4(-0.0),vec4(uv,vec2(1)-uv)); \n c1=mix(vec4(1,1,1,0),c1,e.x*e.y*e.z*e.w); \n float d=clamp(dot(c1.xyz,vec3(-.5,1.,-.5)),0.0,1.0); \n vec4 c2=vec4(.7); \n return min(mix(c1,c2,1.8*d),.7); \n } \n vec4 getColHT(vec2 pos) \n { \n return smoothstep(.95,1.05,getCol(pos)*.8+.2+getRand(pos*.7)); \n } \n float getVal(vec2 pos) \n { \n vec4 c=getCol(pos); \n return pow(dot(c.xyz,vec3(.333)),1.)*1.; \n } \n vec2 getGrad(vec2 pos, float eps) \n { \n vec2 d=vec2(eps,0); \n return vec2(getVal(pos+d.xy)-getVal(pos-d.xy), getVal(pos+d.yx)-getVal(pos-d.yx))/eps/2.; \n } \n #define AngleNum 2 \n #define SampNum 8 \n #define PI2 6.28318530717959 \n void main(void)  \n { \n vec2 pos = gl_FragCoord.xy+4.0*sin(elapsedTime*1.*vec2(1,1.7))*iResolution.y/400.; \n vec3 col = vec3(0); \n vec3 col2 = vec3(0); \n float sum=0.; \n for(int i=0;i<AngleNum;i++) \n { \n float ang=PI2/float(AngleNum)*(float(i)+.8); \n vec2 v=vec2(cos(ang),sin(ang)); \n for(int j=0;j<SampNum;j++) \n { \n vec2 dpos  = v.yx*vec2(1,-1)*float(j)*iResolution.y/400.; \n vec2 dpos2 = v.xy*float(j*j)/float(SampNum)*.5*iResolution.y/400.; \n vec2 g; \n float fact; \n float fact2; \n for(float s=-1.;s<=1.;s+=2.) \n { \n vec2 pos2=pos+s*dpos+dpos2; \n vec2 pos3=pos+(s*dpos+dpos2).yx*vec2(1,-1)*2.; \n g=getGrad(pos2,.4); \n fact=dot(g,v)-.5*abs(dot(g,v.yx*vec2(1,-1)))/**(1.-getVal(pos2))*/; \n fact2=dot(normalize(g+vec2(.0001)),v.yx*vec2(1,-1)); \n fact=clamp(fact,0.,.05); \n fact2=abs(fact2); \n fact*=1.-float(j)/float(SampNum); \n col += fact; \n col2 += fact2*getColHT(pos3).xyz; \n sum+=fact2; \n } \n } \n } \n col/=float(SampNum*AngleNum)*.75/sqrt(iResolution.y); \n col2/=sum; \n col.x*=(.6+.8*getRand(pos*.7).x); \n col.x=1.-col.x; \n col.x*=col.x*col.x; \n vec2 s=sin(pos.xy*.1/sqrt(iResolution.y/400.)); \n vec3 karo=vec3(1); \n karo-=.5*vec3(.25,.1,.1)*dot(exp(-s*s*80.),vec2(1)); \n float r=length(pos-iResolution.xy*.5)/iResolution.x; \n float vign=1.-r*r*r; \n gl_FragColor = vec4(vec3(col.x*col2*karo*vign),1); \n }";
	
	public var elapsedTime:Float = 0;
	private var _noiseTex:DynamicTexture;
	
	private var noiseTexRes:Vector2 = new Vector2(256, 256);
	private var texSamplerRes:Vector2 = new Vector2(0, 0);

	
	public function new(name:String, ratio:Float, camera:Camera, ?samplingMode:Int, ?engine:Engine, reusable:Bool = false) {
		if (!ShadersStore.Shaders.exists("notebookDrawingsPixelShader")) {			
			ShadersStore.Shaders.set("notebookDrawingsPixelShader", fragmentShader);
		}
		
		super(name, "notebookDrawings", ["elapsedTime", "texSamplerRes", "noiseTexRes"], ["noiseTex"], ratio, camera, samplingMode, engine, reusable);
		
		_createNoiseTexture();
		
		this.onApplyObservable.add(function(effect:Effect, _) {
			this.elapsedTime += camera.getScene().getAnimationRatio() * 0.0003;
			texSamplerRes.x = camera.getScene().getEngine().width;
			texSamplerRes.y = camera.getScene().getEngine().height;
			effect.setFloat("elapsedTime", this.elapsedTime);			
			effect.setTexture("noiseTex", this._noiseTex);
			effect.setVector2("texSamplerRes", texSamplerRes);
			effect.setVector2("noiseTexRes", noiseTexRes);
		});
	}
	
	// creates a black and white random noise texture, 512x512
	private function _createNoiseTexture() {
		var size:Int = 256;
		
		this._noiseTex = new DynamicTexture("NDNoiseTexture", { width: size, height: size }, this._scene, false, Texture.BILINEAR_SAMPLINGMODE);
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
