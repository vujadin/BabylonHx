package com.babylonhx.materials.lib.gradient;

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
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */

class GradientMaterial extends PushMaterial {
	
	static var _fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n\nuniform vec4 topColor;\nuniform vec4 bottomColor;\nuniform float offset;\nuniform float smoothness;\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<helperFunctions>\n\n#include<__decl__lightFragment>[0]\n#include<__decl__lightFragment>[1]\n#include<__decl__lightFragment>[2]\n#include<__decl__lightFragment>[3]\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\nvoid main(void) {\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\nfloat h=normalize(vPositionW).y+offset;\nfloat mysmoothness=clamp(smoothness,0.01,max(smoothness,10.));\nvec4 baseColor=mix(bottomColor,topColor,max(pow(max(h,0.0),mysmoothness),0.0));\n\nvec3 diffuseColor=baseColor.rgb;\n\nfloat alpha=baseColor.a;\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\nfloat glossiness=0.;\n#include<lightFragment>[0]\n#include<lightFragment>[1]\n#include<lightFragment>[2]\n#include<lightFragment>[3]\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\nvec3 finalDiffuse=clamp(diffuseBase*diffuseColor,0.0,1.0)*baseColor.rgb;\n\nvec4 color=vec4(finalDiffuse,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}\n";
	
	static var _vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<__decl__lightFragment>[0..maxSimultaneousLights]\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex> \ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef DIFFUSE\nif (vDiffuseInfos.x == 0.)\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n#include<shadowsVertex>[0..maxSimultaneousLights]\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}\n";
	
	
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

	// The gradient top color, red by default
	@serializeAsColor3()
	public var topColor:Color3 = new Color3(1, 0, 0);
	
	@serialize()
	public var topColorAlpha:Float = 1.0;

	// The gradient top color, blue by default
	@serializeAsColor3()
	public var bottomColor:Color3 = new Color3(0, 0, 1);
	
	@serialize()
	public var bottomColorAlpha:Float = 1.0;

	// Gradient offset
	@serialize()
	public var offset:Float = 0;
	
	@serialize()
	public var smoothness:Float = 1.0;

	@serialize()
	public var disableLighting:Bool = false;

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists('gradientPixelShader')) {
			ShadersStore.Shaders['gradientPixelShader'] = _fragmentShader;
			ShadersStore.Shaders['gradientVertexShader'] = _vertexShader;
		}
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
	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {   
		if (this.isFrozen) {
			if (this._wasPreviouslyReady && subMesh.effect != null) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new GradientMaterialDefines();
		}
		
		var defines:GradientMaterialDefines = cast subMesh._materialDefines;
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall && subMesh.effect != null) {
			if (this._renderId == scene.getRenderId()) {
				return true;
			}
		}
		
		var engine = scene.getEngine();
		
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances);
		
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, false, this.pointsCloud, this.fogEnabled, defines);
		
		defines._needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, false, this._maxSimultaneousLights);
		
		// Attribs
		MaterialHelper.PrepareDefinesForAttributes(mesh, defines, false, true);
		
		// Get correct effect      
		if (defines.isDirty) {
			defines.markAsProcessed();
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();             
			if (defines.FOG) {
				fallbacks.addFallback(1, "FOG");
			}
			
			MaterialHelper.HandleFallbacksForShadows(defines, fallbacks);
		 
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
			var shaderName:String = "gradient";
			var join:String = defines.toString();
			
			var uniforms = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vDiffuseInfos", 
				"mBones",
				"vClipPlane", "diffuseMatrix",
				"topColor", "bottomColor", "offset", "smoothness"
			];
			var samplers:Array<String> = ["diffuseSampler"];
			var uniformBuffers:Array<String> = [];
			
			MaterialHelper.PrepareUniformsAndSamplersList({
				uniformsNames: uniforms, 
				uniformBuffersNames: uniformBuffers,
				samplers: samplers, 
				defines: defines, 
				maxSimultaneousLights: 4
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
					indexParameters: { maxSimultaneousLights: 4 }
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
		
		var defines:GradientMaterialDefines = cast subMesh._materialDefines;
		if (defines == null) {
			return;
		}
		
		var effect = subMesh.effect;
		this._activeEffect = effect;
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		this._activeEffect.setMatrix("viewProjection", scene.getTransformMatrix());
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._effect);
		
		if (this._mustRebind(scene, effect)) {
			// Clip plane
			MaterialHelper.BindClipPlane(this._effect, scene);
			
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
		
		this._activeEffect.setColor4("topColor", this.topColor, this.topColorAlpha);
		this._activeEffect.setColor4("bottomColor", this.bottomColor, this.bottomColorAlpha);
		this._activeEffect.setFloat("offset", this.offset);
		this._activeEffect.setFloat("smoothness", this.smoothness);
		
		this._afterBind(mesh, this._activeEffect);
	}

	public function getAnimatables():Array<IAnimatable> {
		return [];
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):GradientMaterial {
		return SerializationHelper.Clone(function() { return new GradientMaterial(name, this.getScene()); } , this);
	}

	override public function serialize():Dynamic {
		/*var serializationObject = SerializationHelper.Serialize(this);
		serializationObject.customType = "BABYLON.GradientMaterial";
		return serializationObject;*/
		return null;
	}

	override public function getClassName():String {
		return "GradientMaterial";
	}              

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):GradientMaterial {
		return SerializationHelper.Parse(function() { return new GradientMaterial(source.name, scene); } , source, scene, rootUrl);
	}
	
}
