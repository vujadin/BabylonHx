package com.babylonhx.materials.lib.water;

import com.babylonhx.math.Plane;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */
 
class WaterMaterial extends PushMaterial {
	
	static var _fragmentShader:String = "#ifdef LOGARITHMICDEPTH\n#extension GL_EXT_frag_depth : enable\n#endif\nprecision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n#ifdef SPECULARTERM\nuniform vec4 vSpecularColor;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<helperFunctions>\n\n#include<__decl__lightFragment>[0..maxSimultaneousLights]\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n\n#ifdef BUMP\nvarying vec2 vNormalUV;\nvarying vec2 vNormalUV2;\nuniform sampler2D normalSampler;\nuniform vec2 vNormalInfos;\n#endif\nuniform sampler2D refractionSampler;\nuniform sampler2D reflectionSampler;\n\nconst float LOG2=1.442695;\nuniform vec3 cameraPosition;\nuniform vec4 waterColor;\nuniform float colorBlendFactor;\nuniform vec4 waterColor2;\nuniform float colorBlendFactor2;\nuniform float bumpHeight;\nuniform float time;\n\nvarying vec3 vRefractionMapTexCoord;\nvarying vec3 vReflectionMapTexCoord;\nvarying vec3 vPosition;\n#include<clipPlaneFragmentDeclaration>\n#include<logDepthDeclaration>\n\n#include<fogFragmentDeclaration>\nvoid main(void) {\n\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(1.,1.,1.,1.);\nvec3 diffuseColor=vDiffuseColor.rgb;\n\nfloat alpha=vDiffuseColor.a;\n#ifdef BUMP\n#ifdef BUMPSUPERIMPOSE\nbaseColor=0.6*texture2D(normalSampler,vNormalUV)+0.4*texture2D(normalSampler,vec2(vNormalUV2.x,vNormalUV2.y));\n#else\nbaseColor=texture2D(normalSampler,vNormalUV);\n#endif\nvec3 bumpColor=baseColor.rgb;\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\nbaseColor.rgb*=vNormalInfos.y;\n#else\nvec3 bumpColor=vec3(1.0);\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec2 perturbation=bumpHeight*(baseColor.rg-0.5);\n#ifdef BUMPAFFECTSREFLECTION\nvec3 normalW=normalize(vNormalW+vec3(perturbation.x*8.0,0.0,perturbation.y*8.0));\nif (normalW.y<0.0) {\nnormalW.y=-normalW.y;\n}\n#else\nvec3 normalW=normalize(vNormalW);\n#endif\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\nvec2 perturbation=bumpHeight*(vec2(1.0,1.0)-0.5);\n#endif\n#ifdef FRESNELSEPARATE\n#ifdef REFLECTION\n\nvec3 eyeVector=normalize(vEyePosition-vPosition);\nvec2 projectedRefractionTexCoords=clamp(vRefractionMapTexCoord.xy/vRefractionMapTexCoord.z+perturbation*0.5,0.0,1.0);\nvec4 refractiveColor=texture2D(refractionSampler,projectedRefractionTexCoords);\nvec2 projectedReflectionTexCoords=clamp(vec2(\nvReflectionMapTexCoord.x/vReflectionMapTexCoord.z+perturbation.x*0.3,\nvReflectionMapTexCoord.y/vReflectionMapTexCoord.z+perturbation.y\n),0.0,1.0);\nvec4 reflectiveColor=texture2D(reflectionSampler,projectedReflectionTexCoords);\nvec3 upVector=vec3(0.0,1.0,0.0);\nfloat fresnelTerm=clamp(abs(pow(dot(eyeVector,upVector),3.0)),0.05,0.65);\nfloat IfresnelTerm=1.0-fresnelTerm;\nrefractiveColor=colorBlendFactor*waterColor+(1.0-colorBlendFactor)*refractiveColor;\nreflectiveColor=IfresnelTerm*colorBlendFactor2*waterColor+(1.0-colorBlendFactor2*IfresnelTerm)*reflectiveColor;\nvec4 combinedColor=refractiveColor*fresnelTerm+reflectiveColor*IfresnelTerm;\nbaseColor=combinedColor;\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\n#ifdef SPECULARTERM\nfloat glossiness=vSpecularColor.a;\nvec3 specularBase=vec3(0.,0.,0.);\nvec3 specularColor=vSpecularColor.rgb;\n#else\nfloat glossiness=0.;\n#endif\n#include<lightFragment>[0..maxSimultaneousLights]\nvec3 finalDiffuse=clamp(baseColor.rgb,0.0,1.0);\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n#ifdef SPECULARTERM\nvec3 finalSpecular=specularBase*specularColor;\n#else\nvec3 finalSpecular=vec3(0.0);\n#endif\n#else \n#ifdef REFLECTION\n\nvec3 eyeVector=normalize(vEyePosition-vPosition);\nvec2 projectedRefractionTexCoords=clamp(vRefractionMapTexCoord.xy/vRefractionMapTexCoord.z+perturbation,0.0,1.0);\nvec4 refractiveColor=texture2D(refractionSampler,projectedRefractionTexCoords);\nvec2 projectedReflectionTexCoords=clamp(vReflectionMapTexCoord.xy/vReflectionMapTexCoord.z+perturbation,0.0,1.0);\nvec4 reflectiveColor=texture2D(reflectionSampler,projectedReflectionTexCoords);\nvec3 upVector=vec3(0.0,1.0,0.0);\nfloat fresnelTerm=max(dot(eyeVector,upVector),0.0);\nvec4 combinedColor=refractiveColor*fresnelTerm+reflectiveColor*(1.0-fresnelTerm);\nbaseColor=colorBlendFactor*waterColor+(1.0-colorBlendFactor)*combinedColor;\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\n#ifdef SPECULARTERM\nfloat glossiness=vSpecularColor.a;\nvec3 specularBase=vec3(0.,0.,0.);\nvec3 specularColor=vSpecularColor.rgb;\n#else\nfloat glossiness=0.;\n#endif\n#include<lightFragment>[0..maxSimultaneousLights]\nvec3 finalDiffuse=clamp(baseColor.rgb,0.0,1.0);\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n#ifdef SPECULARTERM\nvec3 finalSpecular=specularBase*specularColor;\n#else\nvec3 finalSpecular=vec3(0.0);\n#endif\n#endif\n\nvec4 color=vec4(finalDiffuse+finalSpecular,alpha);\n#include<logDepthFragment>\n#include<fogFragment>\ngl_FragColor=color;\n}\n";
	
	static var _vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef BUMP\nvarying vec2 vNormalUV;\n#ifdef BUMPSUPERIMPOSE\nvarying vec2 vNormalUV2;\n#endif\nuniform mat4 normalMatrix;\nuniform vec2 vNormalInfos;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<__decl__lightFragment>[0..maxSimultaneousLights]\n#include<logDepthDeclaration>\n\nuniform mat4 worldReflectionViewProjection;\nuniform vec2 windDirection;\nuniform float waveLength;\nuniform float time;\nuniform float windForce;\nuniform float waveHeight;\nuniform float waveSpeed;\n\nvarying vec3 vPosition;\nvarying vec3 vRefractionMapTexCoord;\nvarying vec3 vReflectionMapTexCoord;\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef BUMP\nif (vNormalInfos.x == 0.)\n{\nvNormalUV=vec2(normalMatrix*vec4((uv*1.0)/waveLength+time*windForce*windDirection,1.0,0.0));\n#ifdef BUMPSUPERIMPOSE\nvNormalUV2=vec2(normalMatrix*vec4((uv*0.721)/waveLength+time*1.2*windForce*windDirection,1.0,0.0));\n#endif\n}\nelse\n{\nvNormalUV=vec2(normalMatrix*vec4((uv2*1.0)/waveLength+time*windForce*windDirection ,1.0,0.0));\n#ifdef BUMPSUPERIMPOSE\nvNormalUV2=vec2(normalMatrix*vec4((uv2*0.721)/waveLength+time*1.2*windForce*windDirection ,1.0,0.0));\n#endif\n}\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n\n#include<shadowsVertex>[0..maxSimultaneousLights]\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\nvec3 p=position;\nfloat newY=(sin(((p.x/0.05)+time*waveSpeed))*waveHeight*windDirection.x*5.0)\n+(cos(((p.z/0.05)+time*waveSpeed))*waveHeight*windDirection.y*5.0);\np.y+=abs(newY);\ngl_Position=viewProjection*finalWorld*vec4(p,1.0);\n#ifdef REFLECTION\nworldPos=viewProjection*finalWorld*vec4(p,1.0);\n\nvPosition=position;\nvRefractionMapTexCoord.x=0.5*(worldPos.w+worldPos.x);\nvRefractionMapTexCoord.y=0.5*(worldPos.w+worldPos.y);\nvRefractionMapTexCoord.z=worldPos.w;\nworldPos=worldReflectionViewProjection*vec4(position,1.0);\nvReflectionMapTexCoord.x=0.5*(worldPos.w+worldPos.x);\nvReflectionMapTexCoord.y=0.5*(worldPos.w+worldPos.y);\nvReflectionMapTexCoord.z=worldPos.w;\n#endif\n#include<logDepthVertex>\n}\n";
	
	
	/*
	* Public members
	*/
	@serializeAsTexture("bumpTexture")
	private var _bumpTexture:BaseTexture;
	@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var bumpTexture(get, set):BaseTexture;
	private inline function get_bumpTexture():BaseTexture {
		return _bumpTexture;
	}
	private inline function set_bumpTexture(val:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _bumpTexture = val;
	}

	@serializeAsColor3()
	public var diffuseColor:Color3 = new Color3(1, 1, 1);

	@serializeAsColor3()
	public var specularColor:Color3 = new Color3(0, 0, 0);

	@serialize()
	public var specularPower:Float = 64;

	@serialize("disableLighting")
	private var _disableLighting:Bool = false;
	@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var disableLighting(get, set):Bool;
	private inline function get_disableLighting():Bool {
		return _disableLighting;
	}
	private inline function set_disableLighting(val:Bool):Bool {
		_markAllSubMeshesAsLightsDirty();
		return _disableLighting = val;
	}

	@serialize("maxSimultaneousLights")
	private var _maxSimultaneousLights:Int = 4;
	@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var maxSimultaneousLights(get, set):Int;
	private inline function get_maxSimultaneousLights():Int {
		return _maxSimultaneousLights;
	}
	private inline function set_maxSimultaneousLights(val:Int):Int {
		_markAllSubMeshesAsLightsDirty();
		return _maxSimultaneousLights = val;
	}

	/**
	* @param {number}: Represents the wind force
	*/
	@serialize()
	public var windForce:Float = 6;
	/**
	* @param {Vector2}: The direction of the wind in the plane (X, Z)
	*/
	@serializeAsVector2()
	public var windDirection:Vector2 = new Vector2(0, 1);
	/**
	* @param {number}: Wave height, represents the height of the waves
	*/
	@serialize()
	public var waveHeight:Float = 0.4;
	/**
	* @param {number}: Bump height, represents the bump height related to the bump map
	*/
	@serialize()
	public var bumpHeight:Float = 0.4;
	/**
	 * @param {boolean}: Add a smaller moving bump to less steady waves.
	 */
	@serialize("bumpSuperimpose")
	private var _bumpSuperimpose:Bool = false;
	@expandToProperty("_markAllSubMeshesAsMiscDirty")
	public var bumpSuperimpose(get, set):Bool;
	private inline function get_bumpSuperimpose():Bool {
		return _bumpSuperimpose;
	}
	private inline function set_bumpSuperimpose(val:Bool):Bool {
		_markAllSubMeshesAsMiscDirty();
		return _bumpSuperimpose = val;
	}

	/**
	 * @param {boolean}: Color refraction and reflection differently with .waterColor2 and .colorBlendFactor2. Non-linear (physically correct) fresnel.
	 */
	@serialize("fresnelSeparate")
	private var _fresnelSeparate:Bool = false;
	@expandToProperty("_markAllSubMeshesAsMiscDirty")
	public var fresnelSeparate(get, set):Bool;
	private inline function get_fresnelSeparate():Bool {
		return _fresnelSeparate;
	}
	private inline function set_fresnelSeparate(val:Bool):Bool {
		_markAllSubMeshesAsMiscDirty();
		return _fresnelSeparate = val;
	}

	/**
	 * @param {boolean}: bump Waves modify the reflection.
	 */
	@serialize("bumpAffectsReflection")
	private var _bumpAffectsReflection:Bool = false;
	@expandToProperty("_markAllSubMeshesAsMiscDirty")
	public var bumpAffectsReflection(get, set):Bool;
	private inline function get_bumpAffectsReflection():Bool {
		return _bumpAffectsReflection;
	}
	private inline function set_bumpAffectsReflection(val:Bool):Bool {
		_markAllSubMeshesAsMiscDirty();
		return _bumpAffectsReflection = val;
	}

	/**
	* @param {number}: The water color blended with the refraction (near)
	*/
	@serializeAsColor3()
	public var waterColor:Color3 = new Color3(0.1, 0.1, 0.6);
	/**
	* @param {number}: The blend factor related to the water color
	*/
	@serialize()
	public var colorBlendFactor:Float = 0.2;
	/**
	 * @param {number}: The water color blended with the reflection (far)
	 */
	@serializeAsColor3()
	public var waterColor2:Color3 = new Color3(0.1, 0.1, 0.6);
	/**
	 * @param {number}: The blend factor related to the water color (reflection, far)
	 */
	@serialize()
	public var colorBlendFactor2:Float = 0.2;
	/**
	* @param {number}: Represents the maximum length of a wave
	*/
	@serialize()
	public var waveLength:Float = 0.1;

	/**
	* @param {number}: Defines the waves speed
	*/
	@serialize()
	public var waveSpeed:Float = 1.0;

	private var _renderTargets:SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(16);

	/*
	* Private members
	*/
	private var _mesh:AbstractMesh = null;

	private var _refractionRTT:RenderTargetTexture;
	private var _reflectionRTT:RenderTargetTexture;

	private var _material:ShaderMaterial;

	private var _reflectionTransform:Matrix = Matrix.Zero();
	private var _lastTime:Float = 0;
	private var _lastDeltaTime:Float = 0;

	private var _renderId:Int;

	private var _useLogarithmicDepth:Bool;
	
	public var renderTargetSize:Vector2;
	

	/**
	* Constructor
	*/
	public function new(name:String, scene:Scene, ?renderTargetSize:Vector2) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists('waterPixelShader')) {
			ShadersStore.Shaders['waterPixelShader'] = _fragmentShader;
			ShadersStore.Shaders['waterVertexShader'] = _vertexShader;
		}
		
		this.renderTargetSize = renderTargetSize != null ? renderTargetSize : new Vector2(512, 512);
		
		this._createRenderTargets(scene, this.renderTargetSize);
		
		// Create render targets
		this.getRenderTargetTextures = function():SmartArray<RenderTargetTexture> {
			this._renderTargets.reset();
			this._renderTargets.push(this._reflectionRTT);
			this._renderTargets.push(this._refractionRTT);
			
			return this._renderTargets;
		};
	}

	@serialize()
	public var useLogarithmicDepth(get, set):Bool;
	private inline function get_useLogarithmicDepth():Bool {
		return this._useLogarithmicDepth;
	}
	private inline function set_useLogarithmicDepth(value:Bool):Bool {
		this._useLogarithmicDepth = value && this.getScene().getEngine().getCaps().fragmentDepthSupported;
		this._markAllSubMeshesAsMiscDirty();
		return value;
	}

	// Get / Set
	public var refractionTexture(get, never):RenderTargetTexture;
	private inline function get_refractionTexture():RenderTargetTexture {
		return this._refractionRTT;
	}
	
	public var reflectionTexture(get, never):RenderTargetTexture;
	private inline function get_reflectionTexture():RenderTargetTexture {
		return this._reflectionRTT;
	}

	// Methods
	public inline function addToRenderList(node:Node) {
		this._refractionRTT.renderList.push(cast node);
		this._reflectionRTT.renderList.push(cast node);
	}

	public function enableRenderTargets(enable:Bool) {
		var refreshRate = enable ? 1 : 0;
		
		this._refractionRTT.refreshRate = refreshRate;
		this._reflectionRTT.refreshRate = refreshRate;
	}

	public inline function getRenderList():Array<AbstractMesh> {
		return this._refractionRTT.renderList;
	}

	public var renderTargetsEnabled(get, never):Bool;
	private inline function get_renderTargetsEnabled():Bool {
		return !(this._refractionRTT.refreshRate == 0);
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

	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {
		if (this.isFrozen) {
			if (this._wasPreviouslyReady && subMesh.effect != null) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new WaterMaterialDefines();
		}
		
		var defines:WaterMaterialDefines = cast subMesh._materialDefines;
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
				if (this.bumpTexture != null && StandardMaterial.BumpTextureEnabled) {
					if (!this.bumpTexture.isReady()) {
						return false;
					} 
					else {
						defines._needUVs = true;
						defines.BUMP = true;
					}
				}
				
				if (StandardMaterial.ReflectionTextureEnabled) {
					defines.REFLECTION = true;
				}
			}
		}
		
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances);
		
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, this._useLogarithmicDepth, this.pointsCloud, this.fogEnabled, defines);
		
		if (defines._areMiscDirty) {
			if (this._fresnelSeparate) {
				defines.FRESNELSEPARATE = true;
			}
			
			if (this._bumpSuperimpose) {
				defines.BUMPSUPERIMPOSE = true;
			}
			
			if (this._bumpAffectsReflection) {
				defines.BUMPAFFECTSREFLECTION = true;
			}
		}
		
		// Lights
		defines._needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, true, this._maxSimultaneousLights, this._disableLighting);
		
		// Attribs
		MaterialHelper.PrepareDefinesForAttributes(mesh, defines, true, true);
		
		this._mesh = mesh;
		
		// Get correct effect      
		if (defines.isDirty) {
			defines.markAsProcessed();
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();
			if (defines.FOG) {
				fallbacks.addFallback(1, "FOG");
			}
			
			if (defines.LOGARITHMICDEPTH) {
				fallbacks.addFallback(0, "LOGARITHMICDEPTH");
			}
			
			MaterialHelper.HandleFallbacksForShadows(defines, fallbacks, this.maxSimultaneousLights);
			
			if (defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs = [VertexBuffer.PositionKind];
			
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
			var shaderName:String = "water";
			var join:String = defines.toString();
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor", "vSpecularColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vNormalInfos",
				"mBones",
				"vClipPlane", "normalMatrix",
				"logarithmicDepthConstant",
				
				// Water
				"worldReflectionViewProjection", "windDirection", "waveLength", "time", "windForce",
				"cameraPosition", "bumpHeight", "waveHeight", "waterColor", "waterColor2", "colorBlendFactor", "colorBlendFactor2", "waveSpeed"
			];
			var samplers:Array<String> = ["normalSampler",
				// Water
				"refractionSampler", "reflectionSampler"
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
					indexParameters: { maxSimultaneousLights: this._maxSimultaneousLights }
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
		
		var defines:WaterMaterialDefines = cast subMesh._materialDefines;
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
		
		if (this._mustRebind(scene, effect)) {
			// Textures        
			if (this.bumpTexture != null && StandardMaterial.BumpTextureEnabled) {
				this._activeEffect.setTexture("normalSampler", this.bumpTexture);
				
				this._activeEffect.setFloat2("vNormalInfos", this.bumpTexture.coordinatesIndex, this.bumpTexture.level);
				this._activeEffect.setMatrix("normalMatrix", this.bumpTexture.getTextureMatrix());
			}
			// Clip plane
			MaterialHelper.BindClipPlane(this._activeEffect, scene);
			
			// Point size
			if (this.pointsCloud) {
				this._activeEffect.setFloat("pointSize", this.pointSize);
			}
			
			this._activeEffect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.position);
		}
		
		this._activeEffect.setColor4("vDiffuseColor", this.diffuseColor, this.alpha * mesh.visibility);
		
		if (defines.SPECULARTERM) {
			this._activeEffect.setColor4("vSpecularColor", this.specularColor, this.specularPower);
		}
		
		if (scene.lightsEnabled && !this.disableLighting) {
			MaterialHelper.BindLights(scene, mesh, this._activeEffect, defines.SPECULARTERM, this.maxSimultaneousLights);
		}
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._activeEffect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._activeEffect);
		
		// Log. depth
		MaterialHelper.BindLogDepth(defines.LOGARITHMICDEPTH, this._activeEffect, scene);
		
		// Water
		if (StandardMaterial.ReflectionTextureEnabled) {
			this._activeEffect.setTexture("refractionSampler", this._refractionRTT);
			this._activeEffect.setTexture("reflectionSampler", this._reflectionRTT);
		}
		
		var wrvp = this._mesh.getWorldMatrix().multiply(this._reflectionTransform).multiply(scene.getProjectionMatrix());
		
		// Add delta time. Prevent adding delta time if it hasn't changed.
		var deltaTime = scene.getEngine().getDeltaTime();
		if (deltaTime != this._lastDeltaTime) {
			this._lastDeltaTime = deltaTime;
			this._lastTime += this._lastDeltaTime;
		}
		
		this._activeEffect.setMatrix("worldReflectionViewProjection", wrvp);
		this._activeEffect.setVector2("windDirection", this.windDirection);
		this._activeEffect.setFloat("waveLength", this.waveLength);
		this._activeEffect.setFloat("time", this._lastTime / 100000);
		this._activeEffect.setFloat("windForce", this.windForce);
		this._activeEffect.setFloat("waveHeight", this.waveHeight);
		this._activeEffect.setFloat("bumpHeight", this.bumpHeight);
		this._activeEffect.setColor4("waterColor", this.waterColor, 1.0);
		this._activeEffect.setFloat("colorBlendFactor", this.colorBlendFactor);
		this._activeEffect.setColor4("waterColor2", this.waterColor2, 1.0);
		this._activeEffect.setFloat("colorBlendFactor2", this.colorBlendFactor2);
		this._activeEffect.setFloat("waveSpeed", this.waveSpeed);
		
		this._afterBind(mesh, this._activeEffect);
	}

	private function _createRenderTargets(scene:Scene, renderTargetSize:Vector2) {
		// Render targets
		this._refractionRTT = new RenderTargetTexture(name + "_refraction", { width: renderTargetSize.x, height: renderTargetSize.y }, scene, false, true);
		this._refractionRTT.wrapU = Texture.MIRROR_ADDRESSMODE;
		this._refractionRTT.wrapV = Texture.MIRROR_ADDRESSMODE;
		this._refractionRTT.ignoreCameraViewport = true;
		
		this._reflectionRTT = new RenderTargetTexture(name + "_reflection", { width: renderTargetSize.x, height: renderTargetSize.y }, scene, false, true);
		this._reflectionRTT.wrapU = Texture.MIRROR_ADDRESSMODE;
		this._reflectionRTT.wrapV = Texture.MIRROR_ADDRESSMODE;
		this._reflectionRTT.ignoreCameraViewport = true;
		
		var isVisible:Bool = false;
		var clipPlane:Plane = null;
		var savedViewMatrix:Matrix = null;
		var mirrorMatrix:Matrix = Matrix.Zero();
		
		this._refractionRTT.onBeforeRender = function(_, _) {
			if (this._mesh != null) {
				isVisible = this._mesh.isVisible;
				this._mesh.isVisible = false;
			}
			// Clip plane
			clipPlane = scene.clipPlane;
			
			var positiony = this._mesh != null ? this._mesh.position.y : 0.0;
			scene.clipPlane = Plane.FromPositionAndNormal(new Vector3(0, positiony + 0.05, 0), new Vector3(0, 1, 0));
		};
		
		this._refractionRTT.onAfterRender = function(_, _) {
			if (this._mesh != null) {
				this._mesh.isVisible = isVisible;
			}
			
			// Clip plane 
			scene.clipPlane = clipPlane;
		};
		
		this._reflectionRTT.onBeforeRender = function(_, _) {
			if (this._mesh != null) {
				isVisible = this._mesh.isVisible;
				this._mesh.isVisible = false;
			}
			
			// Clip plane
			clipPlane = scene.clipPlane;
			
			var positiony = this._mesh != null ? this._mesh.position.y : 0.0;
			scene.clipPlane = Plane.FromPositionAndNormal(new Vector3(0, positiony - 0.05, 0), new Vector3(0, -1, 0));
			
			// Transform
			Matrix.ReflectionToRef(scene.clipPlane, mirrorMatrix);
			savedViewMatrix = scene.getViewMatrix();
			
			mirrorMatrix.multiplyToRef(savedViewMatrix, this._reflectionTransform);
			scene.setTransformMatrix(this._reflectionTransform, scene.getProjectionMatrix());
			scene.getEngine().cullBackFaces = false;
			scene._mirroredCameraPosition = Vector3.TransformCoordinates(scene.activeCamera.position, mirrorMatrix);
		};
		
		this._reflectionRTT.onAfterRender = function(_, _) {
			if (this._mesh != null) {
				this._mesh.isVisible = isVisible;
			}
			
			// Clip plane
			scene.clipPlane = clipPlane;
			
			// Transform
			scene.setTransformMatrix(savedViewMatrix, scene.getProjectionMatrix());
			scene.getEngine().cullBackFaces = true;
			scene._mirroredCameraPosition = null;
		};
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.bumpTexture != null && this.bumpTexture.animations != null && this.bumpTexture.animations.length > 0) {
			results.push(this.bumpTexture);
		}
		if (this._reflectionRTT != null && this._reflectionRTT.animations != null && this._reflectionRTT.animations.length > 0) {
			results.push(this._reflectionRTT);
		}
		if (this._refractionRTT != null && this._refractionRTT.animations != null && this._refractionRTT.animations.length > 0) {
			results.push(this._refractionRTT);
		}
		
		return results;
	}

	override public function getActiveTextures():Array<BaseTexture> {
		var activeTextures = super.getActiveTextures();
		
		if (this._bumpTexture != null) {
			activeTextures.push(this._bumpTexture);
		}
		
		return activeTextures;
	}

	override public function hasTexture(texture:BaseTexture):Bool {
		if (super.hasTexture(texture)) {
			return true;
		}
		
		if (this._bumpTexture == texture) {
			return true;
		}
		
		return false;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		if (this.bumpTexture != null) {
			this.bumpTexture.dispose();
		}
		
		var index = this.getScene().customRenderTargets.indexOf(this._refractionRTT);
		if (index != -1) {
			this.getScene().customRenderTargets.splice(index, 1);
		}
		index = -1;
		index = this.getScene().customRenderTargets.indexOf(this._reflectionRTT);
		if (index != -1) {
			this.getScene().customRenderTargets.splice(index, 1);
		}
		
		if (this._reflectionRTT != null) {
			this._reflectionRTT.dispose();
		}
		if (this._refractionRTT != null) {
			this._refractionRTT.dispose();
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):WaterMaterial {
		return SerializationHelper.Clone(function() { return new WaterMaterial(name, this.getScene()); } , this);
	}

	override public function serialize():Dynamic {
		/*var serializationObject = SerializationHelper.Serialize(this);
		serializationObject.customType = "WaterMaterial";
		serializationObject.reflectionTexture.isRenderTarget = true;
		serializationObject.refractionTexture.isRenderTarget = true;
		return serializationObject;*/
		return null;
	}

	override public function getClassName():String {
		return "WaterMaterial";
	}

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):WaterMaterial {
		return SerializationHelper.Parse(function() { return new WaterMaterial(source.name, scene); } , source, scene, rootUrl);
	}

	public static function CreateDefaultMesh(name:String, scene:Scene):Mesh {
		var mesh = Mesh.CreateGround(name, 512, 512, 32, scene, false);
		return mesh;
	}
	
}
