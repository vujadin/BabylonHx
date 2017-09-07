package com.babylonhx.materials.lib.cell;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.serialization.SerializationHelper;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CellMaterial extends PushMaterial {
	
	static var _fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<__decl__lightFragment>[0..maxSimultaneousLights]\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\n\nvec3 computeCustomDiffuseLighting(lightingInfo info,vec3 diffuseBase,float shadow)\n{\ndiffuseBase=info.diffuse*shadow;\n#ifdef CELLBASIC\nfloat level=1.0;\nif (info.ndl<0.5)\nlevel=0.5;\ndiffuseBase.rgb*vec3(level,level,level);\n#else\nfloat ToonThresholds[4];\nToonThresholds[0]=0.95;\nToonThresholds[1]=0.5;\nToonThresholds[2]=0.2;\nToonThresholds[3]=0.03;\nfloat ToonBrightnessLevels[5];\nToonBrightnessLevels[0]=1.0;\nToonBrightnessLevels[1]=0.8;\nToonBrightnessLevels[2]=0.6;\nToonBrightnessLevels[3]=0.35;\nToonBrightnessLevels[4]=0.2;\nif (info.ndl>ToonThresholds[0])\n{\ndiffuseBase.rgb*=ToonBrightnessLevels[0];\n}\nelse if (info.ndl>ToonThresholds[1])\n{\ndiffuseBase.rgb*=ToonBrightnessLevels[1];\n}\nelse if (info.ndl>ToonThresholds[2])\n{\ndiffuseBase.rgb*=ToonBrightnessLevels[2];\n}\nelse if (info.ndl>ToonThresholds[3])\n{\ndiffuseBase.rgb*=ToonBrightnessLevels[3];\n}\nelse\n{\ndiffuseBase.rgb*=ToonBrightnessLevels[4];\n}\n#endif\nreturn max(diffuseBase,vec3(0.2));\n}\nvoid main(void)\n{\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(1.,1.,1.,1.);\nvec3 diffuseColor=vDiffuseColor.rgb;\n\nfloat alpha=vDiffuseColor.a;\n#ifdef DIFFUSE\nbaseColor=texture2D(diffuseSampler,vDiffuseUV);\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\nbaseColor.rgb*=vDiffuseInfos.y;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\n#endif\n\nlightingInfo info;\nvec3 diffuseBase=vec3(0.,0.,0.);\nfloat shadow=1.;\nfloat glossiness=0.;\n#ifdef SPECULARTERM\nvec3 specularBase=vec3(0.,0.,0.);\n#endif \n#include<lightFragment>[0..maxSimultaneousLights]\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\nvec3 finalDiffuse=clamp(diffuseBase*diffuseColor,0.0,1.0)*baseColor.rgb;;\n\nvec4 color=vec4(finalDiffuse,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}";
	
	static var _vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform mat4 diffuseMatrix;\nuniform vec2 vDiffuseInfos;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<__decl__lightFragment>[0..maxSimultaneousLights]\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef DIFFUSE\nif (vDiffuseInfos.x == 0.)\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv,1.0,0.0));\n}\nelse\n{\nvDiffuseUV=vec2(diffuseMatrix*vec4(uv2,1.0,0.0));\n}\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n#include<shadowsVertex>[0..maxSimultaneousLights]\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n}\n";
	
	
	@serializeAsTexture("diffuseTexture")
	private var _diffuseTexture: BaseTexture;
	@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var diffuseTexture(get, set):BaseTexture;
	inline private function get_diffuseTexture():BaseTexture {
		return _diffuseTexture;
	}
	inline private function set_diffuseTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _diffuseTexture = value;
	}

	@serializeAsColor3("diffuseColor")
	public var diffuseColor:Color3 = new Color3(1, 1, 1);

	@serialize("computeHighLevel")
	public var _computeHighLevel:Bool = false;
	@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var computeHighLevel(get, set):Bool;
	inline private function get_computeHighLevel():Bool {
		return _computeHighLevel;
	}
	inline private function set_computeHighLevel(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _computeHighLevel = value;
	}
	
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
		
		if (!ShadersStore.Shaders.exists('cellPixelShader')) {
			ShadersStore.Shaders['cellPixelShader'] = _fragmentShader;
			ShadersStore.Shaders['cellVertexShader'] = _vertexShader;
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
			subMesh._materialDefines = new CellMaterialDefines();
		}
		
		var defines:CellMaterialDefines = cast subMesh._materialDefines;
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
		
		// High level
		defines.CELLBASIC = !this.computeHighLevel;
		
		// Misc.
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, false, this.pointsCloud, this.fogEnabled, defines);
		
		// Lights
		defines._needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, false, this._maxSimultaneousLights, this._disableLighting);
		
		// Values that need to be evaluated on every frame
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances);
		
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
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, defines.NUM_BONE_INFLUENCERS, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, defines);
			
			var shaderName:String = "cell";
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
					indexParameters: { maxSimultaneousLights: this.maxSimultaneousLights - 1 }
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
		
		var defines:CellMaterialDefines = cast subMesh._materialDefines;
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
			if (this._diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				this._activeEffect.setTexture("diffuseSampler", this._diffuseTexture);
				
				this._activeEffect.setFloat2("vDiffuseInfos", this._diffuseTexture.coordinatesIndex, this._diffuseTexture.level);
				this._activeEffect.setMatrix("diffuseMatrix", this._diffuseTexture.getTextureMatrix());
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
		
		// Lights
		if (scene.lightsEnabled && !this.disableLighting) {
			MaterialHelper.BindLights(scene, mesh, this._activeEffect, false, this._maxSimultaneousLights);          
		}
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._activeEffect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._activeEffect);
		
		this._afterBind(mesh, this._activeEffect);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this._diffuseTexture != null && this._diffuseTexture.animations != null && this._diffuseTexture.animations.length > 0) {
			results.push(this._diffuseTexture);
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
		
		return this._diffuseTexture == texture;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		if (this._diffuseTexture != null) {
			this._diffuseTexture.dispose();
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function getClassName():String {
		return "CellMaterial";
	}

	override public function clone(name:String, cloneChildren:Bool = false):CellMaterial {
		//return SerializationHelper.Clone<CellMaterial>(() => new CellMaterial(name, this.getScene()), this);
		return null;
	}
	
	override public function serialize():Dynamic {
		/*var serializationObject = SerializationHelper.Serialize(this);
		serializationObject.customType = "BABYLON.CellMaterial";
		return serializationObject;*/
		return null;
	}

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):CellMaterial {
		//return SerializationHelper.Parse(function() { return new CellMaterial(source.name, scene); , source, scene, rootUrl); });
		return null;
	}
	
}
