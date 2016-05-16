package com.babylonhx.materials.lib.fur;

import com.babylonhx.Engine;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.lights.Light;
import com.babylonhx.materials.EffectFallbacks;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.DynamicTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Tags;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef FURMD = FurMaterialDefines
 
class FurMaterial extends Material {
	
	public static var fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n\nuniform vec4 furColor;\nvarying vec3 vPositionW;\nvarying float vfur_length;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<lightFragmentDeclaration>[0..maxSimultaneousLights]\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n\n#ifdef HIGHLEVEL\nuniform float furOffset;\nuniform sampler2D furTexture;\nvarying vec2 vFurUV;\n#endif\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n#include<fogFragmentDeclaration>\n#include<clipPlaneFragmentDeclaration>\nfloat Rand(vec3 rv) {\nfloat x=dot(rv,vec3(12.9898,78.233,24.65487));\nreturn fract(sin(x)*43758.5453);\n}\nvoid main(void) {\n\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=furColor;\nvec3 diffuseColor=vDiffuseColor.rgb;\n\nfloat alpha=vDiffuseColor.a;\n#ifdef DIFFUSE\nbaseColor*=texture2D(diffuseSampler,vDiffuseUV);\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\nbaseColor.rgb*=vDiffuseInfos.y;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\n#ifdef HIGHLEVEL\n\nvec4 furTextureColor=texture2D(furTexture,vec2(vFurUV.x,vFurUV.y));\nif (furTextureColor.a<=0.0 || furTextureColor.g<furOffset) {\ndiscard;\n}\nfloat occlusion=mix(0.0,furTextureColor.b*1.2,furOffset);\nbaseColor=vec4(baseColor.xyz*occlusion,1.1-furOffset);\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\nfloat glossiness=0.;\n#include<lightFragment>[0..maxSimultaneousLights]\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\nvec3 finalDiffuse=clamp(diffuseBase.rgb*baseColor.rgb,0.0,1.0);\n\n#ifdef HIGHLEVEL\nvec4 color=vec4(finalDiffuse,alpha);\n#else\nfloat r=vfur_length*0.5;\nvec4 color=vec4(finalDiffuse*(0.5+r),alpha);\n#endif\n#include<fogFragment>\ngl_FragColor=color;\n}";

	public static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\nattribute vec3 normal;\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\nuniform float furLength;\nuniform float furAngle;\n#ifdef HIGHLEVEL\nuniform float furOffset;\nuniform vec3 furGravity;\nuniform float furTime;\nuniform float furSpacing;\nuniform float furDensity;\n#endif\n#ifdef HEIGHTMAP\nuniform sampler2D heightTexture;\n#endif\n#ifdef HIGHLEVEL\nvarying vec2 vFurUV;\n#endif\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\nvarying float vfur_length;\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<shadowsVertexDeclaration>\nfloat Rand(vec3 rv) {\nfloat x=dot(rv,vec3(12.9898,78.233,24.65487));\nreturn fract(sin(x)*43758.5453);\n}\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\n\nfloat r=Rand(position);\n#ifdef HEIGHTMAP \nvfur_length=furLength*texture2D(heightTexture,uv).rgb.x;\n#else \nvfur_length=(furLength*r);\n#endif\nvec3 tangent1=vec3(normal.y,-normal.x,0);\nvec3 tangent2=vec3(-normal.z,0,normal.x);\nr=Rand(tangent1*r);\nfloat J=(2.0+4.0*r);\nr=Rand(tangent2*r);\nfloat K=(2.0+2.0*r);\ntangent1=tangent1*J+tangent2*K;\ntangent1=normalize(tangent1);\nvec3 newPosition=position+normal*vfur_length*cos(furAngle)+tangent1*vfur_length*sin(furAngle);\n#ifdef HIGHLEVEL\n\nvec3 forceDirection=vec3(0.0,0.0,0.0);\nforceDirection.x=sin(furTime+position.x*0.05)*0.2;\nforceDirection.y=cos(furTime*0.7+position.y*0.04)*0.2;\nforceDirection.z=sin(furTime*0.7+position.z*0.04)*0.2;\nvec3 displacement=vec3(0.0,0.0,0.0);\ndisplacement=furGravity+forceDirection;\nfloat displacementFactor=pow(furOffset,3.0);\nvec3 aNormal=normal;\naNormal.xyz+=displacement*displacementFactor;\nnewPosition=vec3(newPosition.x,newPosition.y,newPosition.z)+(normalize(aNormal)*furOffset*furSpacing);\n#endif\n#ifdef NORMAL\n#ifdef HIGHLEVEL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0))*aNormal);\n#else\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n#endif\n\ngl_Position=viewProjection*finalWorld*vec4(newPosition,1.0);\nvec4 worldPos=finalWorld*vec4(newPosition,1.0);\nvPositionW=vec3(worldPos);\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef DIFFUSE\nif (vDiffuseInfos.x == 0.)\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv2,1.0,0.0));\n}\n#ifdef HIGHLEVEL\nvFurUV=vDiffuseUV*furDensity;\n#endif\n#else\n#ifdef HIGHLEVEL\nvFurUV=uv*furDensity;\n#endif\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n\n#include<shadowsVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}\n";
	
	
	@serializeAsTexture()
	public var diffuseTexture:BaseTexture;
	
	@serializeAsTexture()
	public var heightTexture:BaseTexture;
	
	@serializeAsColor3()
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	
	@serialize()
	public var furLength:Float = 1;
	
	@serialize()
	public var furAngle:Float = 0;
	
	@serializeAsColor3()
	public var furColor:Color3 = new Color3(0.44,0.21,0.02);
	
	@serialize()
	public var furOffset:Float = 0.0;
	
	@serialize()
	public var furSpacing:Float = 12;
	
	@serializeAsVector3()
	public var furGravity:Vector3 = new Vector3(0, 0, 0);
	
	@serialize()
	public var furSpeed:Float = 100;
	
	@serialize()
	public var furDensity:Int = 20;
	
	public var furTexture:DynamicTexture;
	
	@serialize()
	public var disableLighting:Bool = false;
	
	@serialize()
	public var highLevelFur:Bool = true;
	
	@serialize()
	public var maxSimultaneousLights:Int = 4;
	
	public var _meshes:Array<AbstractMesh>;

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _renderId:Int;
	
	private var _furTime:Float = 0;
	public var furTime(get, set):Float;

	private var _defines:FurMaterialDefines = new FurMaterialDefines();
	private var _cachedDefines:FurMaterialDefines = new FurMaterialDefines();
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("furmat.fragment")) {
			ShadersStore.Shaders.set("furmat.fragment", fragmentShader);
			ShadersStore.Shaders.set("furmat.vertex", vertexShader);
		}
		
        this._cachedDefines.BonesPerMesh = -1;
	}
	
	private function get_furTime():Float {
		return this._furTime;
	}
	private function set_furTime(val:Float):Float {
		return this._furTime = val;
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
	
	public function updateFur() {
		for (i in 1...this._meshes.length) {
			var offsetFur:FurMaterial = cast this._meshes[i].material;
			
			offsetFur.furLength = this.furLength;
			offsetFur.furAngle = this.furAngle;
			offsetFur.furGravity = this.furGravity;
			offsetFur.furSpacing = this.furSpacing;
			offsetFur.furSpeed = this.furSpeed;
			offsetFur.furColor = this.furColor;
			offsetFur.diffuseTexture = this.diffuseTexture;
			offsetFur.furTexture = this.furTexture;
			offsetFur.highLevelFur = this.highLevelFur;
			offsetFur.furTime = this.furTime;
			offsetFur.furDensity = this.furDensity;
		}
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
		var needUVs = false;
		
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
			
			if (this.heightTexture != null) {
				if (!this.heightTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this._defines.defines["HEIGHTMAP"] = true;
				}
			}               
		}
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.defines["CLIPPLANE"] = true;
		}
		
		if (engine.getAlphaTesting()) {
			this._defines.defines["ALPHATEST"] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.defines["POINTSIZE"] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.defines["FOG"] = true;
		}
		
		// High level
        if (this.highLevelFur) {
            this._defines.defines["HIGHLEVEL"] = true;
        }
		
		// Lights
		if (scene.lightsEnabled && !this.disableLighting) {
			needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, this._defines, this.maxSimultaneousLights);
		}
		
		// Attribs
		if (mesh != null) {
			if (needNormals && mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
				this._defines.defines["NORMAL"] = true;
			}
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this._defines.defines["UV1"] = true;
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					this._defines.defines["UV2"] = true;
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
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
			}
			
			// Instances
			if (useInstances) {
				this._defines.defines["INSTANCES"] = true;
			}
		}
		
		// Get correct effect      
		if (!this._defines.isEqual(this._cachedDefines)) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();             
			if (this._defines.defines["FOG"]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			MaterialHelper.HandleFallbacksForShadows(this._defines, fallbacks, this.maxSimultaneousLights);
		 
			if (this._defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this._defines.defines["NORMAL"]) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this._defines.defines["UV1"]) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this._defines.defines["UV2"]) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (this._defines.defines["VERTEXCOLOR"]) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, this._defines, fallbacks);
            MaterialHelper.PrepareAttributesForInstances(attribs, this._defines);
			
			// Legacy browser patch
			var shaderName:String = "furmat";
			var join:String = this._defines.toString();
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vDiffuseInfos", 
				"mBones",
				"vClipPlane", "diffuseMatrix",
				"furLength", "furAngle", "furColor", "furOffset", "furGravity", "furTime", "furSpacing", "furDensity"
			];
			
			var samplers:Array<String> = ["diffuseSampler", "heightTexture", "furTexture"];
			
			MaterialHelper.PrepareUniformsAndSamplersList(uniforms, samplers, this._defines, this.maxSimultaneousLights);
			
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
				mesh._materialDefines = new FurMaterialDefines();
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
		
		if (scene.getCachedMaterial() != this) {
			// Textures        
			if (this.diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				this._effect.setTexture("diffuseSampler", this.diffuseTexture);
				
				this._effect.setFloat2("vDiffuseInfos", this.diffuseTexture.coordinatesIndex, this.diffuseTexture.level);
				this._effect.setMatrix("diffuseMatrix", this.diffuseTexture.getTextureMatrix());
			}
			
			if (this.heightTexture != null) {
				this._effect.setTexture("heightTexture", this.heightTexture);
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
		
		this._effect.setColor4("vDiffuseColor", this.diffuseColor, this.alpha * mesh.visibility);
		
		if (scene.lightsEnabled && !this.disableLighting) {
			MaterialHelper.BindLights(scene, mesh, this._effect, this._defines, this.maxSimultaneousLights);
		}
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._effect);
		
		this._effect.setFloat("furLength", this.furLength);
		this._effect.setFloat("furAngle", this.furAngle);
		this._effect.setColor4("furColor", this.furColor, 1.0);
		
		if (this.highLevelFur) {
            this._effect.setVector3("furGravity", this.furGravity);
            this._effect.setFloat("furOffset", this.furOffset);
            this._effect.setFloat("furSpacing", this.furSpacing);
			this._effect.setFloat("furDensity", this.furDensity);
            
            this._furTime += this.getScene().getEngine().getDeltaTime() / this.furSpeed;
            this._effect.setFloat("furTime", this._furTime);
            
            this._effect.setTexture("furTexture", this.furTexture);
        }
		
		super.bind(world, mesh);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.diffuseTexture != null && this.diffuseTexture.animations != null && this.diffuseTexture.animations.length > 0) {
			results.push(this.diffuseTexture);
		}
		
		if (this.heightTexture != null && this.heightTexture.animations != null && this.heightTexture.animations.length > 0) {
			results.push(this.heightTexture);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (forceDisposeTextures) {
			if (this.diffuseTexture != null) {
				this.diffuseTexture.dispose();
			}
			
			if (this.heightTexture != null) {
				this.heightTexture.dispose();
			}
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):Material {
		var newMaterial = new FurMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		// Fur material
		if (this.diffuseTexture != null) {
			newMaterial.diffuseTexture = this.diffuseTexture.clone();
		}
		if (this.heightTexture != null) {
			newMaterial.heightTexture = this.heightTexture.clone();
		}
		if (this.diffuseColor != null) {
			newMaterial.diffuseColor = this.diffuseColor.clone();
		}
		
		return newMaterial;
	}
	
	override public function serialize():Dynamic {		
		return SerializationHelper.Serialize(FurMaterial, this, super.serialize());
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):FurMaterial {
		var material = new FurMaterial(source.name, scene);
		
		material.diffuseColor       = Color3.FromArray(source.diffuseColor);
		material.furLength          = source.furLength;
		material.furAngle           = source.furAngle;
		material.furColor           = Color3.FromArray(source.furColor);
		material.furGravity         = Vector3.FromArray(source.furGravity);
		material.furSpacing         = source.furSpacing;
		material.furSpeed           = source.furSpeed;
		material.furDensity         = source.furDensity;
		material.disableLighting    = source.disableLighting;
		
		material.alpha          	= source.alpha;
		
		material.id             	= source.id;
		
		Tags.AddTagsTo(material, source.tags);
		material.backFaceCulling = source.backFaceCulling;
		material.wireframe = source.wireframe;
		
		if (source.diffuseTexture != null) {
			material.diffuseTexture = Texture.Parse(source.diffuseTexture, scene, rootUrl);
		}
		
		if (source.heightTexture != null) {
			material.heightTexture = Texture.Parse(source.heightTexture, scene, rootUrl);
		}
		
		if (source.checkReadyOnlyOnce) {
			material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
		}
		
		return material;
	}
	
	public static function GenerateTexture(name:String, scene:Scene):DynamicTexture {
		// Generate fur textures
		var size:Int = 256;
		var texture = new DynamicTexture("FurTexture " + name, size, scene, true);
		var context = texture.getContext();
		
		var totalPixelsCount = size * size * 4;
		var i:Int = 0;
		while (i < totalPixelsCount) {
			context[i] = 255;
			context[i + 1] = Math.floor(Math.random() * 255);
			context[i + 2] = Math.floor(Math.random() * 255);
			context[i + 3] = 255;
			
			i += 4;
		}
		
		texture.update(false);
		texture.wrapU = Texture.WRAP_ADDRESSMODE;
		texture.wrapV = Texture.WRAP_ADDRESSMODE;
		
		return texture;
	}
	
	// Creates and returns an array of meshes used as shells for the Fur Material
	// that can be disposed later in your code
	// The quality is in interval [0, 100]
	public static function FurifyMesh(sourceMesh:Mesh, quality:Int):Array<Mesh> {
		var meshes:Array<Mesh> = [sourceMesh];
		var mat:FurMaterial = cast sourceMesh.material;
		
		if (!Std.is(mat, FurMaterial)) {
			throw "The material of the source mesh must be a Fur Material";
		}
		
		for (i in 1...quality) {
			var offsetFur:FurMaterial = new FurMaterial(mat.name + i, sourceMesh.getScene());
			sourceMesh.getScene().materials.pop();
			//Tags.EnableFor(offsetFur);
			//Tags.AddTagsTo(offsetFur, "furShellMaterial");
			
			offsetFur.furLength = mat.furLength;
			offsetFur.furAngle = mat.furAngle;
			offsetFur.furGravity = mat.furGravity;
			offsetFur.furSpacing = mat.furSpacing;
			offsetFur.furSpeed = mat.furSpeed;
			offsetFur.furColor = mat.furColor;
			offsetFur.diffuseTexture = mat.diffuseTexture;
			offsetFur.furOffset = i / quality;
			offsetFur.furTexture = mat.furTexture;
			offsetFur.highLevelFur = mat.highLevelFur;
			offsetFur.furTime = mat.furTime;
			offsetFur.furDensity = mat.furDensity;
			
			var offsetMesh = sourceMesh.clone(sourceMesh.name + i);
			
			offsetMesh.material = offsetFur;
			offsetMesh.skeleton = sourceMesh.skeleton;
			offsetMesh.position = Vector3.Zero();
			meshes.push(offsetMesh);
		}
		
		cast(sourceMesh.material, FurMaterial)._meshes = cast meshes;
		
		return meshes;
	}
	
}
