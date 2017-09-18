package com.babylonhx.materials.lib.shadowonly;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShadowOnlyMaterial extends PushMaterial {
	
	static var _vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<__decl__lightFragment>[0..maxSimultaneousLights]\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n#include<shadowsVertex>[0..maxSimultaneousLights]\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}\n";
	
	static var _fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform float alpha;\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n\n#include<helperFunctions>\n\n#include<__decl__lightFragment>[0..maxSimultaneousLights]\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\nvoid main(void) {\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\nfloat glossiness=0.;\n#include<lightFragment>[0..1]\n\nvec4 color=vec4(0.,0.,0.,1.0-clamp(shadow,0.,1.)*alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}";

	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Int;
	private var _activeLight:IShadowLight;

	
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("shadowOnlyPixelShader")) {
			ShadersStore.Shaders["shadowOnlyPixelShader"] = _fragmentShader;
			ShadersStore.Shaders["shadowOnlyVertexShader"] = _vertexShader;
		}
	}

	override public function needAlphaBlending():Bool {
		return true;
	}

	override public function needAlphaTesting():Bool {
		return false;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return null;
	}

	public var activeLight(get, set):IShadowLight;
	inline private function get_activeLight():IShadowLight {
		return this._activeLight;
	}
	inline private function set_activeLight(light:IShadowLight):IShadowLight {
		return this._activeLight = light;
	}        

	// Methods   
	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {   
		if (this.isFrozen) {
			if (this._wasPreviouslyReady && subMesh.effect != null) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new ShadowOnlyMaterialDefines();
		}
		
		var defines:ShadowOnlyMaterialDefines = cast subMesh._materialDefines;
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall && subMesh.effect != null) {
			if (this._renderId == scene.getRenderId()) {
				return true;
			}
		}
		
		var engine = scene.getEngine();
		
		// Ensure that active light is the first shadow light
		if (this._activeLight != null) {
			for (light in mesh._lightSources) {
				if (light.shadowEnabled) {
					if (untyped this._activeLight == light) {
						break; // We are good
					}
					
					var lightPosition = mesh._lightSources.indexOf(cast this._activeLight);
					
					if (lightPosition != -1) {
						mesh._lightSources.splice(lightPosition, 1);
						mesh._lightSources.insert(0, cast this._activeLight);
					}
					break;
				}
			}
		}
		
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances);
		
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, false, this.pointsCloud, this.fogEnabled, defines);
		
		defines._needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, false, 1);
		
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
			
			MaterialHelper.HandleFallbacksForShadows(defines, fallbacks, 1);
			
			if (defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (defines.NORMAL) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, defines.NUM_BONE_INFLUENCERS, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, defines);
			
			var shaderName:String = "shadowOnly";
			var join:String = defines.toString();
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType",
							"vFogInfos", "vFogColor", "pointSize", "alpha",
							"mBones",
							"vClipPlane"
			];
			var samplers:Array<String> = [];
			
			var uniformBuffers:Array<String> = [];
			
			MaterialHelper.PrepareUniformsAndSamplersList({
				uniformsNames: uniforms, 
				uniformBuffersNames: uniformBuffers,
				samplers: samplers, 
				defines: defines, 
				maxSimultaneousLights: 1
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
					indexParameters: { maxSimultaneousLights: 1 }
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
		
		var defines:ShadowOnlyMaterialDefines = cast subMesh._materialDefines;
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
			// Clip plane
			MaterialHelper.BindClipPlane(this._activeEffect, scene);
			
			// Point size
			if (this.pointsCloud) {
				this._activeEffect.setFloat("pointSize", this.pointSize);
			}
			
			this._activeEffect.setFloat("alpha", this.alpha);
			
			this._activeEffect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.position);     
		}
		
		// Lights
		if (scene.lightsEnabled) {
			MaterialHelper.BindLights(scene, mesh, this._activeEffect, false, 1);          
		}
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._activeEffect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._activeEffect);
		
		this._afterBind(mesh, this._activeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):ShadowOnlyMaterial {
		return SerializationHelper.Clone(function() { return new ShadowOnlyMaterial(name, this.getScene()); } , this);
	}
	
	override public function serialize():Dynamic {
		/*var serializationObject = SerializationHelper.Serialize(this);
		serializationObject.customType = "BABYLON.ShadowOnlyMaterial";
		return serializationObject;*/
		return null;
	}

	override public function getClassName():String {
		return "ShadowOnlyMaterial";
	}               

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):ShadowOnlyMaterial {
		return SerializationHelper.Parse(function() { return new ShadowOnlyMaterial(source.name, scene); }, source, scene, rootUrl);
	}
	
}
