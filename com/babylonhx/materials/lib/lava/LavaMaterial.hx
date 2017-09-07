package com.babylonhx.materials.lib.lava;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.Tags;
import com.babylonhx.animations.IAnimatable;

/**
 * ...
 * @author Krtolica Vujadin
 */ 
class LavaMaterial extends PushMaterial {
	
	static var fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n\nvarying vec3 vPositionW;\n\nuniform float time;\nuniform float speed;\nuniform float movingSpeed;\nuniform vec3 fogColor;\nuniform sampler2D noiseTexture;\nuniform float fogDensity;\n\nvarying float noise;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<__decl__lightFragment>[0]\n#include<__decl__lightFragment>[1]\n#include<__decl__lightFragment>[2]\n#include<__decl__lightFragment>[3]\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\nfloat random( vec3 scale,float seed ){\nreturn fract( sin( dot( gl_FragCoord.xyz+seed,scale ) )*43758.5453+seed ) ;\n}\nvoid main(void) {\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(1.,1.,1.,1.);\nvec3 diffuseColor=vDiffuseColor.rgb;\n\nfloat alpha=vDiffuseColor.a;\n#ifdef DIFFUSE\n\nvec4 noiseTex=texture2D( noiseTexture,vDiffuseUV );\nvec2 T1=vDiffuseUV+vec2( 1.5,-1.5 )*time*0.02;\nvec2 T2=vDiffuseUV+vec2( -0.5,2.0 )*time*0.01*speed;\nT1.x+=noiseTex.x*2.0;\nT1.y+=noiseTex.y*2.0;\nT2.x-=noiseTex.y*0.2+time*0.001*movingSpeed;\nT2.y+=noiseTex.z*0.2+time*0.002*movingSpeed;\nfloat p=texture2D( noiseTexture,T1*3.0 ).a;\nvec4 lavaColor=texture2D( diffuseSampler,T2*4.0);\nvec4 temp=lavaColor*( vec4( p,p,p,p )*2. )+( lavaColor*lavaColor-0.1 );\nbaseColor=temp;\nfloat depth=gl_FragCoord.z*4.0;\nconst float LOG2=1.442695;\nfloat fogFactor=exp2(-fogDensity*fogDensity*depth*depth*LOG2 );\nfogFactor=1.0-clamp( fogFactor,0.0,1.0 );\nbaseColor=mix( baseColor,vec4( fogColor,baseColor.w ),fogFactor );\ndiffuseColor=baseColor.rgb;\n\n\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\nbaseColor.rgb*=vDiffuseInfos.y;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\nfloat glossiness=0.;\n#include<lightFragment>[0]\n#include<lightFragment>[1]\n#include<lightFragment>[2]\n#include<lightFragment>[3]\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\nvec3 finalDiffuse=clamp(diffuseBase*diffuseColor,0.0,1.0)*baseColor.rgb;\n\nvec4 color=vec4(finalDiffuse,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}";
	
	static var vertexShader:String = "precision highp float;\n\nuniform float time;\nuniform float lowFrequencySpeed;\n\nvarying float noise;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<__decl__lightFragment>[0..maxSimultaneousLights]\n\n\n\nvec3 mod289(vec3 x)\n{\nreturn x-floor(x*(1.0/289.0))*289.0;\n}\nvec4 mod289(vec4 x)\n{\nreturn x-floor(x*(1.0/289.0))*289.0;\n}\nvec4 permute(vec4 x)\n{\nreturn mod289(((x*34.0)+1.0)*x);\n}\nvec4 taylorInvSqrt(vec4 r)\n{\nreturn 1.79284291400159-0.85373472095314*r;\n}\nvec3 fade(vec3 t) {\nreturn t*t*t*(t*(t*6.0-15.0)+10.0);\n}\n\nfloat pnoise(vec3 P,vec3 rep)\n{\nvec3 Pi0=mod(floor(P),rep); \nvec3 Pi1=mod(Pi0+vec3(1.0),rep); \nPi0=mod289(Pi0);\nPi1=mod289(Pi1);\nvec3 Pf0=fract(P); \nvec3 Pf1=Pf0-vec3(1.0); \nvec4 ix=vec4(Pi0.x,Pi1.x,Pi0.x,Pi1.x);\nvec4 iy=vec4(Pi0.yy,Pi1.yy);\nvec4 iz0=Pi0.zzzz;\nvec4 iz1=Pi1.zzzz;\nvec4 ixy=permute(permute(ix)+iy);\nvec4 ixy0=permute(ixy+iz0);\nvec4 ixy1=permute(ixy+iz1);\nvec4 gx0=ixy0*(1.0/7.0);\nvec4 gy0=fract(floor(gx0)*(1.0/7.0))-0.5;\ngx0=fract(gx0);\nvec4 gz0=vec4(0.5)-abs(gx0)-abs(gy0);\nvec4 sz0=step(gz0,vec4(0.0));\ngx0-=sz0*(step(0.0,gx0)-0.5);\ngy0-=sz0*(step(0.0,gy0)-0.5);\nvec4 gx1=ixy1*(1.0/7.0);\nvec4 gy1=fract(floor(gx1)*(1.0/7.0))-0.5;\ngx1=fract(gx1);\nvec4 gz1=vec4(0.5)-abs(gx1)-abs(gy1);\nvec4 sz1=step(gz1,vec4(0.0));\ngx1-=sz1*(step(0.0,gx1)-0.5);\ngy1-=sz1*(step(0.0,gy1)-0.5);\nvec3 g000=vec3(gx0.x,gy0.x,gz0.x);\nvec3 g100=vec3(gx0.y,gy0.y,gz0.y);\nvec3 g010=vec3(gx0.z,gy0.z,gz0.z);\nvec3 g110=vec3(gx0.w,gy0.w,gz0.w);\nvec3 g001=vec3(gx1.x,gy1.x,gz1.x);\nvec3 g101=vec3(gx1.y,gy1.y,gz1.y);\nvec3 g011=vec3(gx1.z,gy1.z,gz1.z);\nvec3 g111=vec3(gx1.w,gy1.w,gz1.w);\nvec4 norm0=taylorInvSqrt(vec4(dot(g000,g000),dot(g010,g010),dot(g100,g100),dot(g110,g110)));\ng000*=norm0.x;\ng010*=norm0.y;\ng100*=norm0.z;\ng110*=norm0.w;\nvec4 norm1=taylorInvSqrt(vec4(dot(g001,g001),dot(g011,g011),dot(g101,g101),dot(g111,g111)));\ng001*=norm1.x;\ng011*=norm1.y;\ng101*=norm1.z;\ng111*=norm1.w;\nfloat n000=dot(g000,Pf0);\nfloat n100=dot(g100,vec3(Pf1.x,Pf0.yz));\nfloat n010=dot(g010,vec3(Pf0.x,Pf1.y,Pf0.z));\nfloat n110=dot(g110,vec3(Pf1.xy,Pf0.z));\nfloat n001=dot(g001,vec3(Pf0.xy,Pf1.z));\nfloat n101=dot(g101,vec3(Pf1.x,Pf0.y,Pf1.z));\nfloat n011=dot(g011,vec3(Pf0.x,Pf1.yz));\nfloat n111=dot(g111,Pf1);\nvec3 fade_xyz=fade(Pf0);\nvec4 n_z=mix(vec4(n000,n100,n010,n110),vec4(n001,n101,n011,n111),fade_xyz.z);\nvec2 n_yz=mix(n_z.xy,n_z.zw,fade_xyz.y);\nfloat n_xyz=mix(n_yz.x,n_yz.y,fade_xyz.x);\nreturn 2.2*n_xyz;\n}\n\nfloat turbulence( vec3 p ) {\nfloat w=100.0;\nfloat t=-.5;\nfor (float f=1.0 ; f<=10.0 ; f++ ){\nfloat power=pow( 2.0,f );\nt+=abs( pnoise( vec3( power*p ),vec3( 10.0,10.0,10.0 ) )/power );\n}\nreturn t;\n}\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\n#ifdef NORMAL\n\nnoise=10.0*-.10*turbulence( .5*normal+time*1.15 );\n\nfloat b=lowFrequencySpeed*5.0*pnoise( 0.05*position +vec3(time*1.025),vec3( 100.0 ) );\n\nfloat displacement =-1.5*noise+b;\n\nvec3 newPosition=position+normal*displacement;\ngl_Position=viewProjection*finalWorld*vec4( newPosition,1.0 );\nvec4 worldPos=finalWorld*vec4(newPosition,1.0);\nvPositionW=vec3(worldPos);\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef DIFFUSE\nif (vDiffuseInfos.x == 0.)\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n#include<shadowsVertex>[0..maxSimultaneousLights]\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}";
	

	@serializeAsTexture("diffuseTexture")
	private var _diffuseTexture:BaseTexture;
	@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var diffuseTexture(get, set):BaseTexture;
	inline private function get_diffuseTexture():BaseTexture {
		return _diffuseTexture;
	}
	inline private function set_diffuseTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _diffuseTexture = value;
	}
	
	@serializeAsTexture()
	public var noiseTexture:BaseTexture;
	
	@serializeAsColor3()
	public var fogColor:Color3;
	
	@serialize()
	public var speed:Float = 1;
	
	@serialize()
	public var movingSpeed:Float = 1;
	
	@serialize()
	public var lowFrequencySpeed:Float = 1;
	
	@serialize()
	public var fogDensity:Float = 0.15;

	private var _lastTime:Float = 0;

	@serializeAsColor3()
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	
	@serialize("disableLighting")
	private var _disableLighting:Bool = false;
	@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var disableLighting(get, set):Bool;
	inline private function get_disableLighting():Bool {
		return _disableLighting;
	}
	inline private function set_disableLighting(value:Bool):Bool {
		_markAllSubMeshesAsLightsDirty();
		return _disableLighting = value;
	}

	@serialize("maxSimultaneousLights")
	private var _maxSimultaneousLights:Int = 4;
	@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var maxSimultaneousLights(get, set):Int;
	inline private function get_maxSimultaneousLights():Int {
		return _maxSimultaneousLights;
	}
	inline private function set_maxSimultaneousLights(value:Int):Int {
		_markAllSubMeshesAsLightsDirty();
		return _maxSimultaneousLights = value;
	}

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("lavaPixelShader")) {
			ShadersStore.Shaders.set("lavaPixelShader", fragmentShader);
			ShadersStore.Shaders.set("lavaVertexShader", vertexShader);
		}
	}

	override public function needAlphaBlending():Bool {
		return (this.alpha < 1.0);
	}

	override public function needAlphaTesting():Bool {
		return false;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return null;
	}

	// Methods
	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {
		if (this.isFrozen) {
			if (this._wasPreviouslyReady && subMesh.effect != null) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new LavaMaterialDefines();
		}
		
		var defines:LavaMaterialDefines = cast subMesh._materialDefines;
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall && subMesh.effect != null) {
			if (this._renderId == scene.getRenderId()) {
				return true;
			}
		}
		
		var engine = scene.getEngine();
		
		// Textures
		if (defines._areTexturesDirty) {
			defines._needUVs = false;
			if (scene.texturesEnabled) {
				if (this._diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					if (!this._diffuseTexture.isReady()) {
						return false;
					} 
					else {
						defines._needUVs = true;
						defines.DIFFUSE = true;
					}
				}                
			}
		}
		
		// Misc.
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, false, this.pointsCloud, this.fogEnabled, defines);
		
		// Lights
		defines._needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, false, this._maxSimultaneousLights);
		
		// Values that need to be evaluated on every frame
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances);
		
		// Attribs
		MaterialHelper.PrepareDefinesForAttributes(mesh, defines, true, true);
		
		// Get correct effect      
		if (defines.isDirty) {
			defines.markAsProcessed();
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks:EffectFallbacks = new EffectFallbacks();
			if (defines.FOG) {
				fallbacks.addFallback(1, "FOG");
			}
			
			MaterialHelper.HandleFallbacksForShadows(defines, fallbacks);
			
			if (defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (defines.NORMAL) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (defines.UV1) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (defines.UV2) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (defines.VERTEXCOLOR) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, defines.NUM_BONE_INFLUENCERS, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, defines);
			
			// Legacy browser patch
			var shaderName:String = "lava";
			var join:String = defines.toString();
			
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vDiffuseInfos",
				"mBones",
				"vClipPlane", "diffuseMatrix",
				"time", "speed","movingSpeed",
				"fogColor","fogDensity", "lowFrequencySpeed"
			];
			
			var samplers:Array<String> = ["diffuseSampler",
				"noiseTexture"
			];
			var uniformBuffers:Array<String> = [];
			
			MaterialHelper.PrepareUniformsAndSamplersList({
				uniformsNames: uniforms, 
				uniformBuffersNames: uniformBuffers,
				samplers: samplers, 
				defines: defines, 
				maxSimultaneousLights: this.maxSimultaneousLights
			});
			
			subMesh.setEffect(scene.getEngine().createEffect(shaderName,
				{
					attributes: attribs,
					uniformsNames: uniforms,
					uniformBuffersNames: uniformBuffers,
					samplers: samplers,
					defines: join,
					fallbacks: fallbacks,
					onCompiled: this.onCompiled,
					onError: this.onError,
					indexParameters: { maxSimultaneousLights: this.maxSimultaneousLights }
				}, engine), defines);
		}
		if (!subMesh.effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		return true;
	}
	
	override public function bindForSubMesh(world:Matrix, mesh:Mesh, subMesh:SubMesh) {
		var scene = this.getScene();
		
		var defines:LavaMaterialDefines = cast subMesh._materialDefines;
		if (defines == null) {
			return;
		}
		
		var effect = subMesh.effect;
		this._activeEffect = effect;
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		this._activeEffect.setMatrix("viewProjection", scene.getTransformMatrix());
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._activeEffect);
		
		if (scene.getCachedMaterial() != this) {
			// Textures        
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				this._activeEffect.setTexture("diffuseSampler", this.diffuseTexture);
				
				this._activeEffect.setFloat2("vDiffuseInfos", this.diffuseTexture.coordinatesIndex, this.diffuseTexture.level);
				this._activeEffect.setMatrix("diffuseMatrix", this.diffuseTexture.getTextureMatrix());
			}
			
			if (this.noiseTexture != null) {
				this._activeEffect.setTexture("noiseTexture", this.noiseTexture);
			}
			
			// Clip plane
			MaterialHelper.BindClipPlane(this._activeEffect, scene);
			
			// Point size
			if (this.pointsCloud) {
				this._activeEffect.setFloat("pointSize", this.pointSize);
			}
			
			this._activeEffect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.position);    
		}
		
		this._activeEffect.setColor4("vDiffuseColor", this._scaledDiffuse, this.alpha * mesh.visibility);
		
		if (scene.lightsEnabled && !this.disableLighting) {
			MaterialHelper.BindLights(scene, mesh, this._activeEffect, false);
		}
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._activeEffect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._activeEffect);
		
		this._lastTime += scene.getEngine().getDeltaTime();
		this._activeEffect.setFloat("time", this._lastTime * this.speed / 1000);
		
		if (this.fogColor == null) {
			this.fogColor = Color3.Black();
		}
		this._activeEffect.setColor3("fogColor", this.fogColor);
		this._activeEffect.setFloat("fogDensity", this.fogDensity);
		
		this._activeEffect.setFloat("lowFrequencySpeed", this.lowFrequencySpeed);
        this._activeEffect.setFloat("movingSpeed", this.movingSpeed);
		
		this._afterBind(mesh, this._activeEffect);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.diffuseTexture  != null && this.diffuseTexture.animations != null && this.diffuseTexture.animations.length > 0) {
			results.push(this.diffuseTexture);
		}
		
		if (this.noiseTexture != null && this.noiseTexture.animations != null && this.noiseTexture.animations.length > 0) {
			results.push(this.noiseTexture);
		}
		
		return results;
	}
	
	override public function getActiveTextures():Array<BaseTexture> {
		var activeTextures = super.getActiveTextures();
		
		if (this._diffuseTexture != null) {
			activeTextures.push(this._diffuseTexture);
		}
		
		return activeTextures;
	}

	override public function hasTexture(texture:BaseTexture):Bool {
		if (super.hasTexture(texture)) {
			return true;
		}
		
		if (this.diffuseTexture == texture) {
			return true;
		}
		
		return false;    
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (this.diffuseTexture != null) {
			this.diffuseTexture.dispose();
		}
		if (this.noiseTexture != null) {
			this.noiseTexture.dispose();
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):LavaMaterial {
		var newMaterial:LavaMaterial = new LavaMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		// Lava material
		if (this.diffuseTexture != null) {
			newMaterial.diffuseTexture = this.diffuseTexture.clone();
		}
		if (this.noiseTexture != null) {
			newMaterial.noiseTexture = this.noiseTexture.clone();
		}
		if (this.fogColor != null) {
			newMaterial.fogColor = this.fogColor.clone();
		}
		
		return newMaterial;
	}
	
	override public function serialize():Dynamic {
		var serializationObject = super.serialize();
		serializationObject.customType         = "LavaMaterial";
		serializationObject.diffuseColor       = this.diffuseColor.asArray();
		serializationObject.fogColor           = this.fogColor.asArray();
		serializationObject.speed              = this.speed;
		serializationObject.movingSpeed        = this.movingSpeed;
		serializationObject.lowFrequencySpeed  = this.lowFrequencySpeed;
		serializationObject.fogDensity         = this.fogDensity;
		serializationObject.checkReadyOnlyOnce = this.checkReadyOnlyOnce;
		
		if (this.diffuseTexture != null) {
			serializationObject.diffuseTexture = this.diffuseTexture.serialize();
		}
		if (this.noiseTexture != null) {
			serializationObject.noiseTexture = this.noiseTexture.serialize();
		}
		
		return serializationObject;
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):LavaMaterial {
		var material = new LavaMaterial(source.name, scene);
		
		material.diffuseColor      = Color3.FromArray(source.diffuseColor);
		material.speed             = source.speed;
		material.fogColor          = Color3.FromArray(source.fogColor);
		material.movingSpeed       = source.movingSpeed;
		material.lowFrequencySpeed = source.lowFrequencySpeed;
		material.fogDensity        =  source.lowFrequencySpeed;
		
		material.alpha          = source.alpha;
		
		material.id             = source.id;
		
		Tags.AddTagsTo(material, source.tags);
		material.backFaceCulling = source.backFaceCulling;
		material.wireframe = source.wireframe;
		
		if (source.diffuseTexture != null) {
			material.diffuseTexture = Texture.Parse(source.diffuseTexture, scene, rootUrl);
		}
		
		if (source.noiseTexture != null) {
			material.noiseTexture = Texture.Parse(source.noiseTexture, scene, rootUrl);
		}
		
		if (source.checkReadyOnlyOnce) {
			material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
		}
		
		return material;
	}
	
}
