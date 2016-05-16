package com.babylonhx.materials.lib.sky;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef SMD = SkyMaterialDefines
 
class SkyMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float;\n\nvarying vec3 vPositionW;\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneFragmentDeclaration>\n\nuniform vec3 cameraPosition;\nuniform float luminance;\nuniform float turbidity;\nuniform float rayleigh;\nuniform float mieCoefficient;\nuniform float mieDirectionalG;\nuniform vec3 sunPosition;\n\n#include<fogFragmentDeclaration>\n\nconst float e=2.71828182845904523536028747135266249775724709369995957;\nconst float pi=3.141592653589793238462643383279502884197169;\nconst float n=1.0003;\nconst float N=2.545E25;\nconst float pn=0.035;\nconst vec3 lambda=vec3(680E-9,550E-9,450E-9);\nconst vec3 K=vec3(0.686,0.678,0.666);\nconst float v=4.0;\nconst float rayleighZenithLength=8.4E3;\nconst float mieZenithLength=1.25E3;\nconst vec3 up=vec3(0.0,1.0,0.0);\nconst float EE=1000.0;\nconst float sunAngularDiameterCos=0.999956676946448443553574619906976478926848692873900859324;\nconst float cutoffAngle=pi/1.95;\nconst float steepness=1.5;\nvec3 totalRayleigh(vec3 lambda)\n{\nreturn (8.0*pow(pi,3.0)*pow(pow(n,2.0)-1.0,2.0)*(6.0+3.0*pn))/(3.0*N*pow(lambda,vec3(4.0))*(6.0-7.0*pn));\n}\nvec3 simplifiedRayleigh()\n{\nreturn 0.0005/vec3(94,40,18);\n}\nfloat rayleighPhase(float cosTheta)\n{ \nreturn (3.0/(16.0*pi))*(1.0+pow(cosTheta,2.0));\n}\nvec3 totalMie(vec3 lambda,vec3 K,float T)\n{\nfloat c=(0.2*T )*10E-18;\nreturn 0.434*c*pi*pow((2.0*pi)/lambda,vec3(v-2.0))*K;\n}\nfloat hgPhase(float cosTheta,float g)\n{\nreturn (1.0/(4.0*pi))*((1.0-pow(g,2.0))/pow(1.0-2.0*g*cosTheta+pow(g,2.0),1.5));\n}\nfloat sunIntensity(float zenithAngleCos)\n{\nreturn EE*max(0.0,1.0-exp(-((cutoffAngle-acos(zenithAngleCos))/steepness)));\n}\nfloat A=0.15;\nfloat B=0.50;\nfloat C=0.10;\nfloat D=0.20;\nfloat EEE=0.02;\nfloat F=0.30;\nfloat W=1000.0;\nvec3 Uncharted2Tonemap(vec3 x)\n{\nreturn ((x*(A*x+C*B)+D*EEE)/(x*(A*x+B)+D*F))-EEE/F;\n}\nvoid main(void) {\n\n#include<clipPlaneFragment>\n\nfloat sunfade=1.0-clamp(1.0-exp((sunPosition.y/450000.0)),0.0,1.0);\nfloat rayleighCoefficient=rayleigh-(1.0*(1.0-sunfade));\nvec3 sunDirection=normalize(sunPosition);\nfloat sunE=sunIntensity(dot(sunDirection,up));\nvec3 betaR=simplifiedRayleigh()*rayleighCoefficient;\nvec3 betaM=totalMie(lambda,K,turbidity)*mieCoefficient;\nfloat zenithAngle=acos(max(0.0,dot(up,normalize(vPositionW-cameraPosition))));\nfloat sR=rayleighZenithLength/(cos(zenithAngle)+0.15*pow(93.885-((zenithAngle*180.0)/pi),-1.253));\nfloat sM=mieZenithLength/(cos(zenithAngle)+0.15*pow(93.885-((zenithAngle*180.0)/pi),-1.253));\nvec3 Fex=exp(-(betaR*sR+betaM*sM));\nfloat cosTheta=dot(normalize(vPositionW-cameraPosition),sunDirection);\nfloat rPhase=rayleighPhase(cosTheta*0.5+0.5);\nvec3 betaRTheta=betaR*rPhase;\nfloat mPhase=hgPhase(cosTheta,mieDirectionalG);\nvec3 betaMTheta=betaM*mPhase;\nvec3 Lin=pow(sunE*((betaRTheta+betaMTheta)/(betaR+betaM))*(1.0-Fex),vec3(1.5));\nLin*=mix(vec3(1.0),pow(sunE*((betaRTheta+betaMTheta)/(betaR+betaM))*Fex,vec3(1.0/2.0)),clamp(pow(1.0-dot(up,sunDirection),5.0),0.0,1.0));\nvec3 direction=normalize(vPositionW-cameraPosition);\nfloat theta=acos(direction.y);\nfloat phi=atan(direction.z,direction.x);\nvec2 uv=vec2(phi,theta)/vec2(2.0*pi,pi)+vec2(0.5,0.0);\nvec3 L0=vec3(0.1)*Fex;\nfloat sundisk=smoothstep(sunAngularDiameterCos,sunAngularDiameterCos+0.00002,cosTheta);\nL0+=(sunE*19000.0*Fex)*sundisk;\nvec3 whiteScale=1.0/Uncharted2Tonemap(vec3(W));\nvec3 texColor=(Lin+L0); \ntexColor*=0.04 ;\ntexColor+=vec3(0.0,0.001,0.0025)*0.3;\nfloat g_fMaxLuminance=1.0;\nfloat fLumScaled=0.1/luminance; \nfloat fLumCompressed=(fLumScaled*(1.0+(fLumScaled/(g_fMaxLuminance*g_fMaxLuminance))))/(1.0+fLumScaled); \nfloat ExposureBias=fLumCompressed;\nvec3 curr=Uncharted2Tonemap((log2(2.0/pow(luminance,4.0)))*texColor);\nvec3 skyColor=curr*whiteScale;\nvec3 retColor=pow(skyColor,vec3(1.0/(1.2+(1.2*sunfade))));\nvec4 baseColor=vec4(retColor,1.0);\n\n\nfloat alpha=1.0;\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\nvec3 diffuseBase=vec3(1.0,1.0,1.0);\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n\nvec4 color=vec4(baseColor.rgb,alpha);\n\n#include<fogFragment>\ngl_FragColor=color;\n}";
	
	static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n\nuniform mat4 world;\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\nvoid main(void) {\ngl_Position=viewProjection*world*vec4(position,1.0);\nvec4 worldPos=world*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}\n";
	
	
	// Public members
	@serialize()
	public var luminance:Float = 1.0;
	@serialize()
	public var turbidity:Float = 10.0;
	@serialize()
	public var rayleigh:Float = 2.0;
	@serialize()
	public var mieCoefficient:Float = 0.005;
	@serialize()
	public var mieDirectionalG:Float = 0.8;
	
	public var distance:Float = 500;
	
	@serialize()
	public var inclination:Float = 0.49;
	@serialize()
	public var azimuth:Float = 0.25;
	
	@serializeAsVector()
	public var sunPosition:Vector3 = new Vector3(0, 100, 0);
	
	@serialize()
	public var useSunPosition:Bool = false;
	
	// Private members
	private var _cameraPosition:Vector3 = Vector3.Zero();
	
	private var _renderId:Int;
	
	private var _defines:SkyMaterialDefines = new SkyMaterialDefines();
	private var _cachedDefines:SkyMaterialDefines = new SkyMaterialDefines();
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("skymat.fragment")) {
			ShadersStore.Shaders.set("skymat.fragment", fragmentShader);
			ShadersStore.Shaders.set("skymat.vertex", vertexShader);
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
	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (mesh._materialDefines != null && mesh._materialDefines.isEqual(this._defines)) {
			return true;
		}
		
		return false;
	}

	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (this.checkReadyOnlyOnce) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall) {
			if (this._renderId == scene.getRenderId()) {
				if (this._checkCache(scene, mesh, useInstances)) {
					return true;
				}
			}
		}
		
		var engine:Engine = scene.getEngine();
		this._defines.reset();
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.defines["CLIPPLANE"] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.defines["POINTSIZE"] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.defines["FOG"] = true;
		}
		
		// Attribs
		if (mesh != null) {
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this._defines.defines["VERTEXCOLOR"] = true;
				
				if (mesh.hasVertexAlpha) {
					this._defines.defines["VERTEXALPHA"] = true;
				}
			}
		}
		
		// Get correct effect      
		if (!this._defines.isEqual(this._cachedDefines) || this._effect == null) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks:EffectFallbacks = new EffectFallbacks();             
			if (this._defines.defines["FOG"]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this._defines.defines["VERTEXCOLOR"]) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			// Legacy browser patch
			var shaderName:String = "skymat";
			
			var join:String = this._defines.toString();
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs,
				["world", "viewProjection", "view",
					"vFogInfos", "vFogColor", "pointSize", "vClipPlane",
					"luminance", "turbidity", "rayleigh", "mieCoefficient", "mieDirectionalG", "sunPosition",
					"cameraPosition"
				],
				[],
				join, fallbacks, this.onCompiled, this.onError);
		}
		
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		if (mesh != null) {
			if (mesh._materialDefines == null) {
				mesh._materialDefines = new SkyMaterialDefines();
			}
			
			this._defines.cloneTo(mesh._materialDefines);
		}
		
		return true;
	}

	override public function bindOnlyWorldMatrix(world:Matrix) {
		this._effect.setMatrix("world", world);
	}

	override public function bind(world:Matrix, ?mesh:Mesh) {
		var scene = this.getScene();
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		this._effect.setMatrix("viewProjection", scene.getTransformMatrix());
		
		if (scene.getCachedMaterial() != this) {
			// Clip plane
			if (scene.clipPlane != null) {
				var clipPlane = scene.clipPlane;
				this._effect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
			}
			
			// Point size
			if (this.pointsCloud) {
				this._effect.setFloat("pointSize", this.pointSize);
			}               
		}
		
		// View && Fog
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}
		
		MaterialHelper.BindFogParameters(scene, mesh, this._effect);
		
		// Sky
		var camera = scene.activeCamera;
		if (camera != null) {
			var cameraWorldMatrix = camera.getWorldMatrix();
			this._cameraPosition.x = cameraWorldMatrix.m[12];
			this._cameraPosition.y = cameraWorldMatrix.m[13];
			this._cameraPosition.z = cameraWorldMatrix.m[14];
			this._effect.setVector3("cameraPosition", this._cameraPosition);
		}
			
		this._effect.setFloat("luminance", this.luminance);
		this._effect.setFloat("turbidity", this.turbidity);
		this._effect.setFloat("rayleigh", this.rayleigh);
		this._effect.setFloat("mieCoefficient", this.mieCoefficient);
		this._effect.setFloat("mieDirectionalG", this.mieDirectionalG);
		
		if (!this.useSunPosition) {
			var theta = Math.PI * (this.inclination - 0.5);
			var phi = 2 * Math.PI * (this.azimuth - 0.5);
			
			this.sunPosition.x = this.distance * Math.cos(phi);
			this.sunPosition.y = this.distance * Math.sin(phi) * Math.sin(theta);
			this.sunPosition.z = this.distance * Math.sin(phi) * Math.cos(theta);
		}
		
		this._effect.setVector3("sunPosition", this.sunPosition);
		
		super.bind(world, mesh);
	}

	public function getAnimatables():Array<IAnimatable> {
		return [];
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):Material {
		var newMaterial = new SkyMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		newMaterial.luminance = this.luminance;
		newMaterial.turbidity = this.turbidity;
		newMaterial.rayleigh = this.rayleigh;
		newMaterial.mieCoefficient = this.mieCoefficient;
		newMaterial.mieDirectionalG = this.mieDirectionalG;
		newMaterial.distance = this.distance;
		newMaterial.inclination = this.inclination;
		newMaterial.azimuth = this.azimuth;
		
		return newMaterial;
	}
	
	override public function serialize():Dynamic {		
		return SerializationHelper.Serialize(SkyMaterial, this, super.serialize());
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):SkyMaterial {
		var material = new SkyMaterial(source.name, scene);
		
		material.alpha = source.alpha;
		material.id = source.id;
		
		Tags.AddTagsTo(material, source.tags);
		material.backFaceCulling = source.backFaceCulling;
		material.wireframe = source.wireframe;
		
		if (source.checkReadyOnlyOnce) {
			material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
		}
		
		material.luminance = source.luminance;
		material.turbidity = source.turbidity;
		material.rayleigh = source.rayleigh;
		material.mieCoefficient = source.mieCoefficient;
		material.mieDirectionalG = source.mieDirectionalG;
		material.distance = source.distance;
		material.inclination = source.inclination;
		material.azimuth = source.azimuth;
		
		return material;
	}
	
}
