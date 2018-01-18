package com.babylonhx.materials.lib.simple;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.tools.serialization.SerializationHelper;


/**
 * ...
 * @author Krtolica Vujadin
 */ 
class SimpleMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<lightFragmentDeclaration>[0..maxSimultaneousLights]\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\nvoid main(void) {\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(1.,1.,1.,1.);\nvec3 diffuseColor=vDiffuseColor.rgb;\n\nfloat alpha=vDiffuseColor.a;\n#ifdef DIFFUSE\nbaseColor=texture2D(diffuseSampler,vDiffuseUV);\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\nbaseColor.rgb*=vDiffuseInfos.y;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\nfloat glossiness=0.;\n#include<lightFragment>[0..maxSimultaneousLights]\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\nvec3 finalDiffuse=clamp(diffuseBase*diffuseColor,0.0,1.0)*baseColor.rgb;\n\nvec4 color=vec4(finalDiffuse,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}";
	
	static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<shadowsVertexDeclaration>\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef DIFFUSE\nif (vDiffuseInfos.x == 0.)\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n#include<shadowsVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}\n";

	
	@serializeAsTexture()
	public var diffuseTexture:BaseTexture;

	@serializeAsColor3("diffuseColor")
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	
	@serialize()
	public var disableLighting:Bool = false;        
	
	@serialize()
	public var maxSimultaneousLights:Int = 4;

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:SimpleMaterialDefines = new SimpleMaterialDefines();
	private var _cachedDefines:SimpleMaterialDefines = new SimpleMaterialDefines();
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("simplemat.fragment")) {
			ShadersStore.Shaders.set("simplemat.fragment", fragmentShader);
			ShadersStore.Shaders.set("simplemat.vertex", vertexShader);
		}
		
		this._cachedDefines.BonesPerMesh = -1;
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
		
		if (this._defines.defines["INSTANCES"] != useInstances) {
			return false;
		}
		
		if (mesh._materialDefines != null && mesh._materialDefines.isEqual(this._defines)) {
			return true;
		}
		
		return false;
	}

	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {
		if (this.isFrozen) {
			if (this._wasPreviouslyReady && subMesh.effect != null) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new SimpleMaterialDefines();
		}
		
		var defines:SimpleMaterialDefines = cast subMesh._materialDefines;
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
		defines._needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, false, this._maxSimultaneousLights, this._disableLighting);
		
		// Values that need to be evaluated on every frame
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances ? true : false, this._shouldTurnAlphaTestOn(mesh));
		
		// Attribs
		MaterialHelper.PrepareDefinesForAttributes(mesh, defines, true, true);
		
		// Get correct effect      
		if (defines.isDirty) {
			defines.markAsProcessed();
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();
			if (defines.FOG) {
				fallbacks.addFallback(1, "FOG");
			}
			
			MaterialHelper.HandleFallbacksForShadows(defines, fallbacks, this.maxSimultaneousLights);
			
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
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, defines, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, defines);
			
			var shaderName:String = "simple";
			var join:String = defines.toString();
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vDiffuseInfos",
				"mBones",
				"vClipPlane", "diffuseMatrix"
			];
			var samplers:Array<String> = ["diffuseSampler"];
			var uniformBuffers:Array<String> = [];
			
			MaterialHelper.PrepareUniformsAndSamplersList({
				uniformsNames: uniforms,
				uniformBuffersNames: uniformBuffers,
				samplers: samplers,
				defines: defines,
				maxSimultaneousLights: this.maxSimultaneousLights
			});
			subMesh.setEffect(scene.getEngine().createEffect(shaderName, {
					attributes: attribs,
					uniformsNames: uniforms,
					uniformBuffersNames: uniformBuffers,
					samplers: samplers,
					defines: join,
					fallbacks: fallbacks,
					onCompiled: this.onCompiled,
					onError: this.onError,
					indexParameters: { maxSimultaneousLights: this._maxSimultaneousLights - 1 }
				}, engine), defines);
		}
		if (subMesh.effect == null || !subMesh.effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
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
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._effect);
		
		if (scene.getCachedMaterial() != this) {
			// Textures        
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				this._effect.setTexture("diffuseSampler", this.diffuseTexture);
				
				this._effect.setFloat2("vDiffuseInfos", this.diffuseTexture.coordinatesIndex, this.diffuseTexture.level);
				this._effect.setMatrix("diffuseMatrix", this.diffuseTexture.getTextureMatrix());
			}
			
			// Clip plane
			MaterialHelper.BindClipPlane(this._effect, scene);
			
			// Point size
			if (this.pointsCloud) {
				this._effect.setFloat("pointSize", this.pointSize);
			}
			
			this._effect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.position);    
		}
		
		this._effect.setColor4("vDiffuseColor", this.diffuseColor, this.alpha * mesh.visibility);
		
		// Lights
		if (scene.lightsEnabled && !this.disableLighting) {
			MaterialHelper.BindLights(scene, mesh, this._effect, this._defines, this.maxSimultaneousLights);          
		}
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._effect);
		
		super.bind(world, mesh);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.diffuseTexture != null && this.diffuseTexture.animations != null && this.diffuseTexture.animations.length > 0) {
			results.push(this.diffuseTexture);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (forceDisposeTextures) {
			if (this.diffuseTexture != null) {
				this.diffuseTexture.dispose();
			}
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):Material {
		//return SerializationHelper.Clone<SimpleMaterial>(() => new SimpleMaterial(name, this.getScene()), this);
		return null;
	}
	
	override public function serialize():Dynamic {
		return SerializationHelper.Serialize(SimpleMaterial, this, super.serialize());
	}

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):SimpleMaterial {
		//return SerializationHelper.Parse(() => new SimpleMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
