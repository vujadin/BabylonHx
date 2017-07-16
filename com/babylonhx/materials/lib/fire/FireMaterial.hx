package com.babylonhx.materials.lib.fire;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef FMD = FireMaterialDefines
 
class FireMaterial extends Material {

	static var fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\n\nvarying vec3 vPositionW;\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n\nuniform sampler2D distortionSampler;\nuniform sampler2D opacitySampler;\nvarying vec2 vDistortionCoords1;\nvarying vec2 vDistortionCoords2;\nvarying vec2 vDistortionCoords3;\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\nvec4 bx2(vec4 x)\n{\nreturn vec4(2.0)*x-vec4(1.0);\n}\nvoid main(void) {\n\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(1.,1.,1.,1.);\n\nfloat alpha=1.0;\n#ifdef DIFFUSE\n\nconst float distortionAmount0=0.092;\nconst float distortionAmount1=0.092;\nconst float distortionAmount2=0.092;\nvec2 heightAttenuation=vec2(0.3,0.39);\nvec4 noise0=texture2D(distortionSampler,vDistortionCoords1);\nvec4 noise1=texture2D(distortionSampler,vDistortionCoords2);\nvec4 noise2=texture2D(distortionSampler,vDistortionCoords3);\nvec4 noiseSum=bx2(noise0)*distortionAmount0+bx2(noise1)*distortionAmount1+bx2(noise2)*distortionAmount2;\nvec4 perturbedBaseCoords=vec4(vDiffuseUV,0.0,1.0)+noiseSum*(vDiffuseUV.y*heightAttenuation.x+heightAttenuation.y);\nvec4 opacityColor=texture2D(opacitySampler,perturbedBaseCoords.xy);\n#ifdef ALPHATEST\nif (opacityColor.r<0.1)\ndiscard;\n#endif\nbaseColor=texture2D(diffuseSampler,perturbedBaseCoords.xy)*2.0;\nbaseColor*=opacityColor;\nbaseColor.rgb*=vDiffuseInfos.y;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\nvec3 diffuseBase=vec3(1.0,1.0,1.0);\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n\nvec4 color=vec4(baseColor.rgb,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}";
	
	static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<shadowsVertexDeclaration>\n\nuniform float time;\nuniform float speed;\nvarying vec2 vDistortionCoords1;\nvarying vec2 vDistortionCoords2;\nvarying vec2 vDistortionCoords3;\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n\n#ifdef DIFFUSE\nvDiffuseUV=uv;\nvDiffuseUV.y-=0.2;\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n\nvec3 layerSpeed=vec3(-0.2,-0.52,-0.1)*speed;\nvDistortionCoords1.x=uv.x;\nvDistortionCoords1.y=uv.y+layerSpeed.x*time/1000.0;\nvDistortionCoords2.x=uv.x;\nvDistortionCoords2.y=uv.y+layerSpeed.y*time/1000.0;\nvDistortionCoords3.x=uv.x;\nvDistortionCoords3.y=uv.y+layerSpeed.z*time/1000.0;\n}\n";

	
	@serializeAsTexture()
	public var diffuseTexture:BaseTexture;
	
	@serializeAsTexture()
	public var distortionTexture:BaseTexture;
	
	@serializeAsTexture()
	public var opacityTexture:BaseTexture;

	@serialize("diffuseColor")
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	
	@serialize()
	public var speed:Float = 1.0;
	
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:FireMaterialDefines = new FireMaterialDefines();
	private var _cachedDefines:FireMaterialDefines = new FireMaterialDefines();
	
	private var _lastTime:Float = 0;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("firemat.fragment")) {
			ShadersStore.Shaders.set("firemat.fragment", fragmentShader);
			ShadersStore.Shaders.set("firemat.vertex", vertexShader);
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

	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (this.checkReadyOnlyOnce) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		var scene:Scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall) {
			if (this._renderId == scene.getRenderId()) {
				if (this._checkCache(scene, mesh, useInstances)) {
					return true;
				}
			}
		}
		
		var engine = scene.getEngine();
		var needNormals:Bool = false;
		var needUVs:Bool = false;
		
		this._defines.reset();
		
		// Textures
		if (scene.texturesEnabled) {
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				if (!this.diffuseTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this._defines.defines["DIFFUSE"] = true;
				}
			}                
		}
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.defines["CLIPPLANE"] = true;
		}
		
		this._defines.defines["ALPHATEST"] = true;
		
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
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this._defines.defines["UV1"] = true;
				}
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this._defines.defines["VERTEXCOLOR"] = true;
				
				if (mesh.hasVertexAlpha) {
					this._defines.defines["VERTEXALPHA"] = true;
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				this._defines.BonesPerMesh = mesh.skeleton.bones.length + 1;
			}
			
			// Instances
			if (useInstances) {
				this._defines.defines["INSTANCES"] = true;
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
		 
			if (this._defines.NUM_BONE_INFLUENCERS > 0){
                fallbacks.addCPUSkinningFallback(0, mesh);    
            }
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this._defines.defines["UV1"]) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this._defines.defines["VERTEXCOLOR"]) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, this._defines, fallbacks);
		    MaterialHelper.PrepareAttributesForInstances(attribs, this._defines);
			
			// Legacy browser patch
			var shaderName:String = "firemat";
			
			var join:String = this._defines.toString();
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs,
				["world", "view", "viewProjection", "vEyePosition",
					"vFogInfos", "vFogColor", "pointSize",
					"vDiffuseInfos", 
					"mBones",
					"vClipPlane", "diffuseMatrix",
					// Fire
					"time", "speed"
				],
				["diffuseSampler",
					// Fire
					"distortionSampler", "opacitySampler"
				],
				join, fallbacks, this.onCompiled, this.onError);
		}
		
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		if (mesh != null) {
			if (mesh._materialDefines == null) {
				mesh._materialDefines = new FireMaterialDefines();
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
		if (mesh != null && mesh.useBones && mesh.computeBonesUsingShaders) {
			this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices(mesh));
		}
		
		if (scene.getCachedMaterial() != this) {
			// Textures        
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				this._effect.setTexture("diffuseSampler", this.diffuseTexture);
				
				this._effect.setFloat2("vDiffuseInfos", this.diffuseTexture.coordinatesIndex, this.diffuseTexture.level);
				this._effect.setMatrix("diffuseMatrix", this.diffuseTexture.getTextureMatrix());
				
				this._effect.setTexture("distortionSampler", this.distortionTexture);
				this._effect.setTexture("opacitySampler", this.opacityTexture);
			}
			
			// Clip plane
			if (scene.clipPlane != null) {
				var clipPlane = scene.clipPlane;
				this._effect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
			}
			
			// Point size
			if (this.pointsCloud) {
				this._effect.setFloat("pointSize", this.pointSize);
			}
			
			this._effect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.position);    
		}
		
		this._effect.setColor4("vDiffuseColor", this._scaledDiffuse, this.alpha * mesh.visibility);
		
		// View and Fog
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._effect);
		
		// Time
		this._lastTime += scene.getEngine().getDeltaTime();
		this._effect.setFloat("time", this._lastTime);
		
		// Speed
		this._effect.setFloat("speed", this.speed);
		
		super.bind(world, mesh);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.diffuseTexture != null && this.diffuseTexture.animations != null && this.diffuseTexture.animations.length > 0) {
			results.push(this.diffuseTexture);
		}
		if (this.distortionTexture != null && this.distortionTexture.animations != null && this.distortionTexture.animations.length > 0) {
			results.push(this.distortionTexture);
		}
		if (this.opacityTexture != null && this.opacityTexture.animations != null && this.opacityTexture.animations.length > 0) {
			results.push(this.opacityTexture);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (forceDisposeTextures) {
			if (this.diffuseTexture != null) {
				this.diffuseTexture.dispose();
			}
			if (this.distortionTexture != null) {
				this.distortionTexture.dispose();
			}
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):FireMaterial {
		var newMaterial = new FireMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		// Fire material
		if (this.diffuseTexture != null) {
			newMaterial.diffuseTexture = this.diffuseTexture.clone();
		}
		if (this.distortionTexture != null) {
			newMaterial.distortionTexture = this.distortionTexture.clone();
		}
		if (this.opacityTexture != null) {
			newMaterial.opacityTexture = this.opacityTexture.clone();
		}
		
		newMaterial.diffuseColor = this.diffuseColor.clone();
		return newMaterial;
	}
	
	override public function serialize():Dynamic {		
		return SerializationHelper.Serialize(FireMaterial, this, super.serialize());
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):FireMaterial {
		var material = new FireMaterial(source.name, scene);
		
		material.diffuseColor   	= Color3.FromArray(source.diffuseColor);
		material.speed          	= source.speed;
		
		material.alpha = source.alpha;
		
		material.id = source.id;
		
		Tags.AddTagsTo(material, source.tags);
		material.backFaceCulling = source.backFaceCulling;
		material.wireframe = source.wireframe;
		
		if (source.diffuseTexture != null) {
			material.diffuseTexture = Texture.Parse(source.diffuseTexture, scene, rootUrl);
		}
		
		if (source.distortionTexture != null) {
			material.distortionTexture = Texture.Parse(source.distortionTexture, scene, rootUrl);
		}
				
		if (source.opacityTexture != null) {
			material.opacityTexture = Texture.Parse(source.opacityTexture, scene, rootUrl);
		}
		
		if (source.checkReadyOnlyOnce) {
			material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
		}
		
		return material;
	}
	
}
