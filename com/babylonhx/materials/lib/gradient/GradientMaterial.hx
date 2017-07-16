package com.babylonhx.materials.lib.gradient;

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


/**
 * ...
 * @author Krtolica Vujadin
 */

typedef GMD = GradientMaterialDefines 

class GradientMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n\nuniform vec4 topColor;\nuniform vec4 bottomColor;\nuniform float offset;\nuniform float smoothness;\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<lightFragmentDeclaration>[0]\n#include<lightFragmentDeclaration>[1]\n#include<lightFragmentDeclaration>[2]\n#include<lightFragmentDeclaration>[3]\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\nvoid main(void) {\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\nfloat h=normalize(vPositionW).y+offset;\nfloat mysmoothness=clamp(smoothness,0.01,max(smoothness,10.));\nvec4 baseColor=mix(bottomColor,topColor,max(pow(max(h,0.0),mysmoothness),0.0));\n\nvec3 diffuseColor=baseColor.rgb;\n\nfloat alpha=baseColor.a;\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\nfloat glossiness=0.;\n#include<lightFragment>[0]\n#include<lightFragment>[1]\n#include<lightFragment>[2]\n#include<lightFragment>[3]\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\nvec3 finalDiffuse=clamp(diffuseBase*diffuseColor,0.0,1.0)*baseColor.rgb;\n\nvec4 color=vec4(finalDiffuse,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}\n";
	
	static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<shadowsVertexDeclaration>\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex> \ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef DIFFUSE\nif (vDiffuseInfos.x == 0.)\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n#include<shadowsVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}\n";
	
	
	// The gradient top color, red by default
	public var topColor:Color3 = new Color3(1, 0, 0);
	public var topColorAlpha:Float = 1.0;

	// The gradient top color, blue by default
	public var bottomColor:Color3 = new Color3(0, 0, 1);
	public var bottomColorAlpha:Float = 1.0;

	// Gradient offset
	public var offset:Float = 0;
	public var smoothness:Float = 1.0;

	public var disableLighting:Bool = false;

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:GradientMaterialDefines = new GradientMaterialDefines();
	private var _cachedDefines:GradientMaterialDefines = new GradientMaterialDefines();
		

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("gradientmat.fragment")) {
			ShadersStore.Shaders.set("gradientmat.fragment", fragmentShader);
			ShadersStore.Shaders.set("gradientmat.vertex", vertexShader);
		}
		
		this._cachedDefines.BonesPerMesh = -1;
	}
	
	override public function needAlphaBlending():Bool {
		return (this.alpha < 1.0 || this.topColorAlpha < 1.0 || this.bottomColorAlpha < 1.0);
	}

	override public function needAlphaTesting():Bool {
		return true;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return null;
	}

	// Methods   
	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this._defines.defines[GMD.INSTANCES] != useInstances) {
			return false;
		}
		
		if (mesh._materialDefines != null && mesh._materialDefines.isEqual(this._defines)) {
			return true;
		}
		
		return false;
	}

	override public function isReady(?mesh: AbstractMesh, useInstances:Bool = false):Bool {
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
		
		// No textures
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.defines[GMD.CLIPPLANE] = true;
		}
		
		if (engine.getAlphaTesting()) {
			this._defines.defines[GMD.ALPHATEST] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.defines[GMD.POINTSIZE] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.defines[GMD.FOG] = true;
		}
		
		var lightIndex:Int = 0;
		if (scene.lightsEnabled && !this.disableLighting) {
			needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, this._defines, GMD.LIGHT0, -1, GMD.SHADOW0, GMD.SHADOWS, GMD.SHADOWVSM0, GMD.SHADOWPCF0, GMD.LIGHTS);
		}
		
		// Attribs
		if (mesh != null) {
			if (needNormals && mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
				this._defines.defines[GMD.NORMAL] = true;
			}
			
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this._defines.defines[GMD.UV1] = true;
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					this._defines.defines[GMD.UV2] = true;
				}
			}
			
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this._defines.defines[GMD.VERTEXCOLOR] = true;
				
				if (mesh.hasVertexAlpha) {
					this._defines.defines[GMD.VERTEXALPHA] = true;
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;                    
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
			}
			
			// Instances
			if (useInstances) {
				this._defines.defines[GMD.INSTANCES] = true;
			}
		}
		
		// Get correct effect      
		if (!this._defines.isEqual(this._cachedDefines)) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks:EffectFallbacks = new EffectFallbacks();             
			if (this._defines.defines[GMD.FOG]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			MaterialHelper.HandleFallbacksForShadows(this._defines, fallbacks, GMD.LIGHT0, GMD.SHADOW0, GMD.SHADOWPCF0, GMD.SHADOWVSM0);
             
			if (this._defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this._defines.defines[GMD.NORMAL]) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this._defines.defines[GMD.UV1]) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this._defines.defines[GMD.UV2]) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (this._defines.defines[GMD.VERTEXCOLOR]) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, this._defines, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, this._defines, GMD.INSTANCES);
			
			// Legacy browser patch
			var shaderName:String = "gradientmat";
			var join:String = this._defines.toString();
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs,
				["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor",
					"vLightData0", "vLightDiffuse0", "vLightSpecular0", "vLightDirection0", "vLightGround0", "lightMatrix0",
					"vLightData1", "vLightDiffuse1", "vLightSpecular1", "vLightDirection1", "vLightGround1", "lightMatrix1",
					"vLightData2", "vLightDiffuse2", "vLightSpecular2", "vLightDirection2", "vLightGround2", "lightMatrix2",
					"vLightData3", "vLightDiffuse3", "vLightSpecular3", "vLightDirection3", "vLightGround3", "lightMatrix3",
					"vFogInfos", "vFogColor", "pointSize",
					"vDiffuseInfos", 
					"mBones",
					"vClipPlane", "diffuseMatrix",
					"shadowsInfo0", "shadowsInfo1", "shadowsInfo2", "shadowsInfo3", "depthValues", "topColor", "bottomColor", "offset", "smoothness"
				],
				["diffuseSampler",
					"shadowSampler0", "shadowSampler1", "shadowSampler2", "shadowSampler3"
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
				mesh._materialDefines = new GradientMaterialDefines();
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
			// Clip plane
			MaterialHelper.BindClipPlane(this._effect, scene);
			
			// Point size
			if (this.pointsCloud) {
				this._effect.setFloat("pointSize", this.pointSize);
			}
			
			this._effect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.position);                
		}
		
		this._effect.setColor4("vDiffuseColor", this._scaledDiffuse, this.alpha * mesh.visibility);
		
		if (scene.lightsEnabled && !this.disableLighting) {
			MaterialHelper.BindLights(scene, mesh, this._effect, this._defines, -1);
		}
		
		// View 
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._effect);
		
		this._effect.setColor4("topColor", this.topColor, this.topColorAlpha);
		this._effect.setColor4("bottomColor", this.bottomColor, this.bottomColorAlpha);
		this._effect.setFloat("offset", this.offset);
		this._effect.setFloat("smoothness", this.smoothness);
		
		super.bind(world, mesh);
	}

	public function getAnimatables():Array<IAnimatable> {
		return [];
	}

	override public function dispose(forceDisposeEffect:Bool = false) {
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):GradientMaterial {
		var newMaterial = new GradientMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newMaterial);
		
		// Gradient material
		newMaterial.topColor = this.topColor.clone();
		newMaterial.bottomColor = this.bottomColor.clone();
		newMaterial.offset = this.offset;
		
		return newMaterial;
	}
	
	override public function serialize():Dynamic {		
		var serializationObject = super.serialize();
		serializationObject.customType      = "GradientMaterial";
		serializationObject.topColor        = this.topColor.asArray();
		serializationObject.bottomColor     = this.bottomColor.asArray();
		serializationObject.offset          = this.offset;
		serializationObject.disableLighting = this.disableLighting;
		
		return serializationObject;
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):GradientMaterial {
		var material = new GradientMaterial(source.name, scene);
		
		material.topColor               = Color3.FromArray(source.topColor);
		material.bottomColor            = Color3.FromArray(source.bottomColor);
		material.offset                 = source.offset;
		material.disableLighting        = source.disableLighting;
		
		material.alpha = source.alpha;
		
		material.id = source.id;
		
		Tags.AddTagsTo(material, source.tags);
		material.backFaceCulling = source.backFaceCulling;
		material.wireframe = source.wireframe;
		
		if (source.checkReadyOnlyOnce) {
			material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
		}
		
		return material;
	}
	
}
