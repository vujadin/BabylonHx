package com.babylonhx.materials.lib.triplanar;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.Tags;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.tools.serialization.SerializationHelper;
import haxe.ds.Vector;


/**
 * ...
 * @author Krtolica Vujadin
 */

typedef TPMD = TriPlanarMaterialDefines
 
class TriPlanarMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n#ifdef SPECULARTERM\nuniform vec4 vSpecularColor;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<lightFragmentDeclaration>[0..maxSimultaneousLights]\n\n#ifdef DIFFUSEX\nvarying vec2 vTextureUVX;\nuniform sampler2D diffuseSamplerX;\n#ifdef BUMPX\nuniform sampler2D normalSamplerX;\n#endif\n#endif\n#ifdef DIFFUSEY\nvarying vec2 vTextureUVY;\nuniform sampler2D diffuseSamplerY;\n#ifdef BUMPY\nuniform sampler2D normalSamplerY;\n#endif\n#endif\n#ifdef DIFFUSEZ\nvarying vec2 vTextureUVZ;\nuniform sampler2D diffuseSamplerZ;\n#ifdef BUMPZ\nuniform sampler2D normalSamplerZ;\n#endif\n#endif\n#ifdef NORMAL\nvarying mat3 tangentSpace;\n#endif\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n#include<clipPlaneFragmentDeclaration>\n#include<fogFragmentDeclaration>\nvoid main(void) {\n\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(0.,0.,0.,1.);\nvec3 diffuseColor=vDiffuseColor.rgb;\n\nfloat alpha=vDiffuseColor.a;\n\n#ifdef NORMAL\nvec3 normalW=tangentSpace[2];\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\nvec4 baseNormal=vec4(0.0,0.0,0.0,1.0);\nnormalW*=normalW;\n#ifdef DIFFUSEX\nbaseColor+=texture2D(diffuseSamplerX,vTextureUVX)*normalW.x;\n#ifdef BUMPX\nbaseNormal+=texture2D(normalSamplerX,vTextureUVX)*normalW.x;\n#endif\n#endif\n#ifdef DIFFUSEY\nbaseColor+=texture2D(diffuseSamplerY,vTextureUVY)*normalW.y;\n#ifdef BUMPY\nbaseNormal+=texture2D(normalSamplerY,vTextureUVY)*normalW.y;\n#endif\n#endif\n#ifdef DIFFUSEZ\nbaseColor+=texture2D(diffuseSamplerZ,vTextureUVZ)*normalW.z;\n#ifdef BUMPZ\nbaseNormal+=texture2D(normalSamplerZ,vTextureUVZ)*normalW.z;\n#endif\n#endif\n#ifdef NORMAL\nnormalW=normalize((2.0*baseNormal.xyz-1.0)*tangentSpace);\n#endif\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\n#ifdef SPECULARTERM\nfloat glossiness=vSpecularColor.a;\nvec3 specularBase=vec3(0.,0.,0.);\nvec3 specularColor=vSpecularColor.rgb;\n#else\nfloat glossiness=0.;\n#endif\n#include<lightFragment>[0..maxSimultaneousLights]\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n#ifdef SPECULARTERM\nvec3 finalSpecular=specularBase*specularColor;\n#else\nvec3 finalSpecular=vec3(0.0);\n#endif\nvec3 finalDiffuse=clamp(diffuseBase*diffuseColor,0.0,1.0)*baseColor.rgb;\n\nvec4 color=vec4(finalDiffuse+finalSpecular,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}\n";
	
	static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSEX\nvarying vec2 vTextureUVX;\n#endif\n#ifdef DIFFUSEY\nvarying vec2 vTextureUVY;\n#endif\n#ifdef DIFFUSEZ\nvarying vec2 vTextureUVZ;\n#endif\nuniform float tileSize;\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying mat3 tangentSpace;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<shadowsVertexDeclaration>\nvoid main(void)\n{\n#include<instancesVertex>\n#include<bonesVertex>\ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef DIFFUSEX\nvTextureUVX=worldPos.zy/tileSize;\n#endif\n#ifdef DIFFUSEY\nvTextureUVY=worldPos.xz/tileSize;\n#endif\n#ifdef DIFFUSEZ\nvTextureUVZ=worldPos.xy/tileSize;\n#endif\n#ifdef NORMAL\n\nvec3 xtan=vec3(0,0,1);\nvec3 xbin=vec3(0,1,0);\nvec3 ytan=vec3(1,0,0);\nvec3 ybin=vec3(0,0,1);\nvec3 ztan=vec3(1,0,0);\nvec3 zbin=vec3(0,1,0);\nvec3 normalizedNormal=normalize(normal);\nnormalizedNormal*=normalizedNormal;\nvec3 worldBinormal=normalize(xbin*normalizedNormal.x+ybin*normalizedNormal.y+zbin*normalizedNormal.z);\nvec3 worldTangent=normalize(xtan*normalizedNormal.x+ytan*normalizedNormal.y+ztan*normalizedNormal.z);\nworldTangent=(world*vec4(worldTangent,1.0)).xyz;\nworldBinormal=(world*vec4(worldBinormal,1.0)).xyz;\nvec3 worldNormal=normalize(cross(worldTangent,worldBinormal));\ntangentSpace[0]=worldTangent;\ntangentSpace[1]=worldBinormal;\ntangentSpace[2]=worldNormal;\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n\n#include<shadowsVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}\n";
	
	
	@serializeAsTexture()
	public var mixTexture:BaseTexture;
	
	@serializeAsTexture()
	public var diffuseTextureX:Texture;
	
	@serializeAsTexture()
	public var diffuseTextureY:Texture;
	
	@serializeAsTexture()
	public var diffuseTextureZ:Texture;
	
	@serializeAsTexture()
	public var normalTextureX:Texture;
	
	@serializeAsTexture()
	public var normalTextureY:Texture;
	
	@serializeAsTexture()
	public var normalTextureZ:Texture;
	
	@serialize()
	public var tileSize:Float = 1;
	
	@serializeAsColor3()
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	
	@serializeAsColor3()
	public var specularColor:Color3 = new Color3(0.2, 0.2, 0.2);
	
	@serialize()
	public var specularPower:Float = 64;
	
	@serialize()
	public var disableLighting:Bool = false;
	
	@serialize()
	public var maxSimultaneousLights:Int = 4;

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _renderId:Int;

	private var _defines:TriPlanarMaterialDefines = new TriPlanarMaterialDefines();
	private var _cachedDefines:TriPlanarMaterialDefines = new TriPlanarMaterialDefines();
	
	private var defs:Vector<Bool>;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("triplanarmat.fragment")) {
			ShadersStore.Shaders.set("triplanarmat.fragment", fragmentShader);
			ShadersStore.Shaders.set("triplanarmat.vertex", vertexShader);
		}
		
		this._cachedDefines.BonesPerMesh = -1;
		
		this.defs = this._defines.defines;
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
		
		if (this.defs[TPMD.INSTANCES] != useInstances) {
			return false;
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
		
		var engine = scene.getEngine();
		var needNormals = false;
		
		this._defines.reset();
		
		// Textures
		if (scene.texturesEnabled) {
			if (StandardMaterial.DiffuseTextureEnabled) {
				var textures:Array<Texture> = [this.diffuseTextureX, this.diffuseTextureY, this.diffuseTextureZ];
				var textureDefines:Array<Int> = [TPMD.DIFFUSEX, TPMD.DIFFUSEY, TPMD.DIFFUSEZ];
				
				for (i in 0...textures.length) {
					if (textures[i] != null) {
						if (!textures[i].isReady()) {
							return false;
						} 
						else {
							this.defs[textureDefines[i]] = true;
						}
					}
				}
			}
			
			if (StandardMaterial.BumpTextureEnabled) {
				var textures:Array<Texture> = [this.normalTextureX, this.normalTextureY, this.normalTextureZ];
				var textureDefines:Array<Int> = [TPMD.BUMPX, TPMD.BUMPY, TPMD.BUMPZ];
				
				for (i in 0...textures.length) {
					if (textures[i] != null) {
						if (!textures[i].isReady()) {
							return false;
						} 
						else {
							this.defs[textureDefines[i]] = true;
						}
					}
				}
			}
		}
		
		// Effect
		if (scene.clipPlane != null) {
			this.defs[TPMD.CLIPPLANE] = true;
		}
		
		if (engine.getAlphaTesting()) {
			this.defs[TPMD.ALPHATEST] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this.defs[TPMD.POINTSIZE] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this.defs[TPMD.FOG] = true;
		}
		
		// Lights
		if (scene.lightsEnabled && !this.disableLighting) {
			needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, this.defs, this.maxSimultaneousLights, TPMD.LIGHT0, TPMD.SPECULARTERM, TPMD.SHADOW0, TPMD.SHADOWS, TPMD.SHADOWVSM0, TPMD.SHADOWPCF0, TPMD.LIGHTS);
		}
		
		// Attribs
		if (mesh != null) {
			if (needNormals && mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
				this.defs[TPMD.NORMAL] = true;
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this.defs[TPMD.VERTEXCOLOR] = true;
				
				if (mesh.hasVertexAlpha) {
					this.defs[TPMD.VERTEXALPHA] = true;
				}
			}
			
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
			}
			
			// Instances
			if (useInstances) {
				this.defs[TPMD.INSTANCES] = true;
			}
		}
		
		// Get correct effect      
		if (!this._defines.isEqual(this._cachedDefines)) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();             
			if (this.defs[TPMD.FOG]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			MaterialHelper.HandleFallbacksForShadows(this.defs, fallbacks, TPMD.LIGHT0, TPMD.SHADOW0, TPMD.SHADOWPCF0, TPMD.SHADOWVSM0, this.maxSimultaneousLights);
		 
			if (this._defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this.defs[TPMD.NORMAL]) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this.defs[TPMD.VERTEXCOLOR]) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, this._defines, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, this.defs, TPMD.INSTANCES);
			
			// Legacy browser patch
			var shaderName:String = "triplanarmat";
			var join = this._defines.toString();
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor", "vSpecularColor",
				"vFogInfos", "vFogColor", "pointSize",
				"mBones",
				"vClipPlane",
				"tileSize"
			];
			
			var samplers:Array<String> = ["diffuseSamplerX", "diffuseSamplerY", "diffuseSamplerZ",
				"normalSamplerX", "normalSamplerY", "normalSamplerZ"
			];
			
			MaterialHelper.PrepareUniformsAndSamplersList(uniforms, samplers, this.defs, this.maxSimultaneousLights);
			
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs, uniforms, samplers,
				join, fallbacks, this.onCompiled, this.onError, { maxSimultaneousLights: this.maxSimultaneousLights });
		}
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		if (mesh != null) {
			if (mesh._materialDefines == null) {
				mesh._materialDefines = new TriPlanarMaterialDefines();
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
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._effect);
		
		this._effect.setFloat("tileSize", this.tileSize);
		
		if (scene.getCachedMaterial() != this) {
			// Textures        
			if (this.diffuseTextureX != null) {
				this._effect.setTexture("diffuseSamplerX", this.diffuseTextureX);
			}
			if (this.diffuseTextureY != null) {
				this._effect.setTexture("diffuseSamplerY", this.diffuseTextureY);
			}
			if (this.diffuseTextureZ != null) {
				this._effect.setTexture("diffuseSamplerZ", this.diffuseTextureZ);
			}
			if (this.normalTextureX != null) {
				this._effect.setTexture("normalSamplerX", this.normalTextureX);
			}
			if (this.normalTextureY != null) {
				this._effect.setTexture("normalSamplerY", this.normalTextureY);
			}
			if (this.normalTextureZ != null) {
				this._effect.setTexture("normalSamplerZ", this.normalTextureZ);
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
		
		if (this.defs[TPMD.SPECULARTERM]) {
			this._effect.setColor4("vSpecularColor", this.specularColor, this.specularPower);
		}
		
		if (scene.lightsEnabled && !this.disableLighting) {
			MaterialHelper.BindLights(scene, mesh, this._effect, this.defs, this.maxSimultaneousLights);
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
		
		if (this.mixTexture != null && this.mixTexture.animations != null && this.mixTexture.animations.length > 0) {
			results.push(this.mixTexture);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (forceDisposeTextures) {
			if (this.mixTexture != null) {
				this.mixTexture.dispose();
			}
		}
		
		super.dispose(forceDisposeEffect);
	}
	
	override public function clone(name:String, cloneChildren:Bool = false):Material {
		//return SerializationHelper.Clone(() => new TriPlanarMaterial(name, this.getScene()), this);
		return null;
	}

	override public function serialize():Dynamic {
		return SerializationHelper.Serialize(TriPlanarMaterial, this, super.serialize());
	}

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):TriPlanarMaterial {
		//return SerializationHelper.Parse(() => new TriPlanarMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
