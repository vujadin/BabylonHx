package com.babylonhx.materials.lib.fire;

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
 
class FireMaterial extends PushMaterial {

	static var _fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\n\nvarying vec3 vPositionW;\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\nuniform sampler2D diffuseSampler;\nuniform vec2 vDiffuseInfos;\n#endif\n\nuniform sampler2D distortionSampler;\nuniform sampler2D opacitySampler;\n#ifdef DIFFUSE\nvarying vec2 vDistortionCoords1;\nvarying vec2 vDistortionCoords2;\nvarying vec2 vDistortionCoords3;\n#endif\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\nvec4 bx2(vec4 x)\n{\nreturn vec4(2.0)*x-vec4(1.0);\n}\nvoid main(void) {\n\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(1.,1.,1.,1.);\n\nfloat alpha=1.0;\n#ifdef DIFFUSE\n\nconst float distortionAmount0=0.092;\nconst float distortionAmount1=0.092;\nconst float distortionAmount2=0.092;\nvec2 heightAttenuation=vec2(0.3,0.39);\nvec4 noise0=texture2D(distortionSampler,vDistortionCoords1);\nvec4 noise1=texture2D(distortionSampler,vDistortionCoords2);\nvec4 noise2=texture2D(distortionSampler,vDistortionCoords3);\nvec4 noiseSum=bx2(noise0)*distortionAmount0+bx2(noise1)*distortionAmount1+bx2(noise2)*distortionAmount2;\nvec4 perturbedBaseCoords=vec4(vDiffuseUV,0.0,1.0)+noiseSum*(vDiffuseUV.y*heightAttenuation.x+heightAttenuation.y);\nvec4 opacityColor=texture2D(opacitySampler,perturbedBaseCoords.xy);\n#ifdef ALPHATEST\nif (opacityColor.r<0.1)\ndiscard;\n#endif\nbaseColor=texture2D(diffuseSampler,perturbedBaseCoords.xy)*2.0;\nbaseColor*=opacityColor;\nbaseColor.rgb*=vDiffuseInfos.y;\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\nvec3 diffuseBase=vec3(1.0,1.0,1.0);\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n\nvec4 color=vec4(baseColor.rgb,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}";
	
	static var _vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef DIFFUSE\nvarying vec2 vDiffuseUV;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n\nuniform float time;\nuniform float speed;\n#ifdef DIFFUSE\nvarying vec2 vDistortionCoords1;\nvarying vec2 vDistortionCoords2;\nvarying vec2 vDistortionCoords3;\n#endif\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\ngl_Position=viewProjection*finalWorld*vec4(position,1.0);\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n\n#ifdef DIFFUSE\nvDiffuseUV=uv;\nvDiffuseUV.y-=0.2;\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\n#ifdef DIFFUSE\n\nvec3 layerSpeed=vec3(-0.2,-0.52,-0.1)*speed;\nvDistortionCoords1.x=uv.x;\nvDistortionCoords1.y=uv.y+layerSpeed.x*time/1000.0;\nvDistortionCoords2.x=uv.x;\nvDistortionCoords2.y=uv.y+layerSpeed.y*time/1000.0;\nvDistortionCoords3.x=uv.x;\nvDistortionCoords3.y=uv.y+layerSpeed.z*time/1000.0;\n#endif\n}\n";

	
	@serializeAsTexture("diffuseTexture")
	private var _diffuseTexture:BaseTexture;
	@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var diffuseTexture(get, set):BaseTexture;        
	private inline function get_diffuseTexture():BaseTexture {
		return _diffuseTexture;
	}
	private inline function set_diffuseTexture(val:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _diffuseTexture = val;
	}
	
	@serializeAsTexture("distortionTexture")
	private var _distortionTexture:BaseTexture;
	@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var distortionTexture(get, set):BaseTexture;       
	private inline function get_distortionTexture():BaseTexture {
		return _distortionTexture;
	}
	private inline function set_distortionTexture(val:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _distortionTexture = val;
	}
	
	@serializeAsTexture("opacityTexture")
	private var _opacityTexture:BaseTexture;
	@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var opacityTexture(get, set):BaseTexture;
	private inline function get_opacityTexture():BaseTexture {
		return _opacityTexture;
	}
	private inline function set_opacityTexture(val:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _opacityTexture = val;
	}
	
	@serialize("diffuseColor")
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	
	@serialize()
	public var speed:Float = 1.0;
	
	private var _scaledDiffuse:Color3 = new Color3();
	private var _renderId:Float;
	private var _lastTime:Float = 0;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists('firePixelShader')) {
			ShadersStore.Shaders['firePixelShader'] = _fragmentShader;
			ShadersStore.Shaders['fireVertexShader'] = _vertexShader;
		}
	}

	override public function needAlphaBlending():Bool {
		return false;
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
			subMesh._materialDefines = new FireMaterialDefines();
		}
		
		var defines:FireMaterialDefines = cast subMesh._materialDefines;
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
		
		// Misc.
		if (defines._areMiscDirty) {
			defines.POINTSIZE = (this.pointsCloud || scene.forcePointsCloud);
			defines.FOG = (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled);
		}
		
		// Values that need to be evaluated on every frame
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances);
		
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
			
			if (defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs = [VertexBuffer.PositionKind];
			
			if (defines.UV1) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (defines.VERTEXCOLOR) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, defines.NUM_BONE_INFLUENCERS, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, defines);
			
			// Legacy browser patch
			var shaderName:String = "fire";
			
			var join:String = defines.toString();
			subMesh.setEffect(scene.getEngine().createEffect(shaderName,
				{
					attributes: attribs,
					uniformsNames: ["world", "view", "viewProjection", "vEyePosition",
							"vFogInfos", "vFogColor", "pointSize",
							"vDiffuseInfos", 
							"mBones",
							"vClipPlane", "diffuseMatrix",
							// Fire
							"time", "speed"
						],
					uniformBuffersNames: [],
					samplers: ["diffuseSampler",
							// Fire
							"distortionSampler", "opacitySampler"
						],
					defines: join,
					fallbacks: fallbacks,
					onCompiled: this.onCompiled,
					onError: this.onError
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
		
		var defines:FireMaterialDefines = cast subMesh._materialDefines;
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
				
				this._activeEffect.setTexture("distortionSampler", this._distortionTexture);
				this._activeEffect.setTexture("opacitySampler", this._opacityTexture);
			}
			
			// Clip plane
			if (scene.clipPlane != null) {
				var clipPlane = scene.clipPlane;
				this._activeEffect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
			}
			
			// Point size
			if (this.pointsCloud) {
				this._activeEffect.setFloat("pointSize", this.pointSize);
			}
			
			this._activeEffect.setVector3("vEyePosition", scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.position);
		}
		
		this._activeEffect.setColor4("vDiffuseColor", this._scaledDiffuse, this.alpha * mesh.visibility);
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._activeEffect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._activeEffect);
		
		// Time
		this._lastTime += scene.getEngine().getDeltaTime();
		this._activeEffect.setFloat("time", this._lastTime);
		
		// Speed
		this._activeEffect.setFloat("speed", this.speed);
		
		this._afterBind(mesh, this._activeEffect);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this._diffuseTexture != null && this._diffuseTexture.animations != null && this._diffuseTexture.animations.length > 0) {
			results.push(this._diffuseTexture);
		}
		if (this._distortionTexture != null && this._distortionTexture.animations != null && this._distortionTexture.animations.length > 0) {
			results.push(this._distortionTexture);
		}
		if (this._opacityTexture != null && this._opacityTexture.animations != null && this._opacityTexture.animations.length > 0) {
			results.push(this._opacityTexture);
		}
		
		return results;
	}

	override public function getActiveTextures():Array<BaseTexture> {
		var activeTextures = super.getActiveTextures();
		
		if (this._diffuseTexture != null) {
			activeTextures.push(this._diffuseTexture);
		}
		
		if (this._distortionTexture != null) {
			activeTextures.push(this._distortionTexture);
		}
		
		if (this._opacityTexture != null) {
			activeTextures.push(this._opacityTexture);
		}
		
		return activeTextures;
	}

	override public function hasTexture(texture:BaseTexture):Bool {
		if (super.hasTexture(texture)) {
			return true;
		}
		
		if (this._diffuseTexture == texture) {
			return true;
		}
		
		if (this._distortionTexture == texture) {
			return true;
		}
		
		if (this._opacityTexture == texture) {
			return true;
		}
		
		return false;    
	}         

	override public function getClassName():String {
		return "FireMaterial";
	}        

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		if (this._diffuseTexture != null) {
			this._diffuseTexture.dispose();
		}
		if (this._distortionTexture != null) {
			this._distortionTexture.dispose();
		}
		if (this._opacityTexture != null) {
			this._opacityTexture.dispose();
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):FireMaterial {
		return SerializationHelper.Clone(function() { return new FireMaterial(name, this.getScene()); } , this);
	}
	
	override public function serialize():Dynamic {	
		var serializationObject = super.serialize();
		serializationObject.customType      = "BABYLON.FireMaterial";
		serializationObject.diffuseColor    = this.diffuseColor.asArray();
		serializationObject.speed           = this.speed;
		
		if (this._diffuseTexture != null) {
			serializationObject._diffuseTexture = this._diffuseTexture.serialize();
		}
		
		if (this._distortionTexture != null) {
			serializationObject._distortionTexture = this._distortionTexture.serialize();
		}
		
		if (this._opacityTexture != null) {
			serializationObject._opacityTexture = this._opacityTexture.serialize();
		}
		
		return serializationObject;
	}

	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):FireMaterial {
		var material = new FireMaterial(source.name, scene);
		
		material.diffuseColor   = Color3.FromArray(source.diffuseColor);
		material.speed          = source.speed;
		
		material.alpha          = source.alpha;
		
		material.id             = source.id;
		
		Tags.AddTagsTo(material, source.tags);
		material.backFaceCulling = source.backFaceCulling;
		material.wireframe = source.wireframe;
		
		if (source._diffuseTexture != null) {
			material._diffuseTexture = Texture.Parse(source._diffuseTexture, scene, rootUrl);
		}
		
		if (source._distortionTexture != null) {
			material._distortionTexture = Texture.Parse(source._distortionTexture, scene, rootUrl);
		}
		
		if (source._opacityTexture != null) {
			material._opacityTexture = Texture.Parse(source._opacityTexture, scene, rootUrl);
		}
		
		if (source.checkReadyOnlyOnce != null) {
			material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
		}
		
		return material;
	}
	
}
