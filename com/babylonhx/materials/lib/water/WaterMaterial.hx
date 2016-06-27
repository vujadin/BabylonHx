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
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef WMD = WaterMaterialDefines
 
class WaterMaterial extends Material {
	
	static var fragmentShader:String = "precision highp float;\n\nuniform vec3 vEyePosition;\nuniform vec4 vDiffuseColor;\n#ifdef SPECULARTERM\nuniform vec4 vSpecularColor;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n\n#include<lightFragmentDeclaration>[0..maxSimultaneousLights]\n#include<lightsFragmentFunctions>\n#include<shadowsFragmentFunctions>\n\n#ifdef BUMP\nvarying vec2 vNormalUV;\nuniform sampler2D normalSampler;\nuniform vec2 vNormalInfos;\n#endif\nuniform sampler2D refractionSampler;\nuniform sampler2D reflectionSampler;\n\nconst float LOG2=1.442695;\nuniform vec3 cameraPosition;\nuniform vec4 waterColor;\nuniform float colorBlendFactor;\nuniform float bumpHeight;\n\nvarying vec3 vRefractionMapTexCoord;\nvarying vec3 vReflectionMapTexCoord;\nvarying vec3 vPosition;\n#include<clipPlaneFragmentDeclaration>\n\n#include<fogFragmentDeclaration>\nvoid main(void) {\n\n#include<clipPlaneFragment>\nvec3 viewDirectionW=normalize(vEyePosition-vPositionW);\n\nvec4 baseColor=vec4(1.,1.,1.,1.);\nvec3 diffuseColor=vDiffuseColor.rgb;\n\nfloat alpha=vDiffuseColor.a;\n#ifdef BUMP\nbaseColor=texture2D(normalSampler,vNormalUV);\nvec3 bumpColor=baseColor.rgb;\n#ifdef ALPHATEST\nif (baseColor.a<0.4)\ndiscard;\n#endif\nbaseColor.rgb*=vNormalInfos.y;\n#else\nvec3 bumpColor=vec3(1.0);\n#endif\n#ifdef VERTEXCOLOR\nbaseColor.rgb*=vColor.rgb;\n#endif\n\n#ifdef NORMAL\nvec3 normalW=normalize(vNormalW);\nvec2 perturbation=bumpHeight*(baseColor.rg-0.5);\n#else\nvec3 normalW=vec3(1.0,1.0,1.0);\nvec2 perturbation=bumpHeight*(vec2(1.0,1.0)-0.5);\n#endif\n#ifdef REFLECTION\n\nvec3 eyeVector=normalize(vEyePosition-vPosition);\nvec2 projectedRefractionTexCoords=clamp(vRefractionMapTexCoord.xy/vRefractionMapTexCoord.z+perturbation,0.0,1.0);\nvec4 refractiveColor=texture2D(refractionSampler,projectedRefractionTexCoords);\nvec2 projectedReflectionTexCoords=clamp(vReflectionMapTexCoord.xy/vReflectionMapTexCoord.z+perturbation,0.0,1.0);\nvec4 reflectiveColor=texture2D(reflectionSampler,projectedReflectionTexCoords);\nvec3 upVector=vec3(0.0,1.0,0.0);\nfloat fresnelTerm=max(dot(eyeVector,upVector),0.0);\nvec4 combinedColor=refractiveColor*fresnelTerm+reflectiveColor*(1.0-fresnelTerm);\nbaseColor=colorBlendFactor*waterColor+(1.0-colorBlendFactor)*combinedColor;\n#endif\n\nvec3 diffuseBase=vec3(0.,0.,0.);\nlightingInfo info;\nfloat shadow=1.;\n#ifdef SPECULARTERM\nfloat glossiness=vSpecularColor.a;\nvec3 specularBase=vec3(0.,0.,0.);\nvec3 specularColor=vSpecularColor.rgb;\n#else\nfloat glossiness=0.;\n#endif\n#include<lightFragment>[0..maxSimultaneousLights]\n#ifdef VERTEXALPHA\nalpha*=vColor.a;\n#endif\n#ifdef SPECULARTERM\nvec3 finalSpecular=specularBase*specularColor;\n#else\nvec3 finalSpecular=vec3(0.0);\n#endif\nvec3 finalDiffuse=clamp(diffuseBase*diffuseColor,0.0,1.0)*baseColor.rgb;\n\nvec4 color=vec4(finalDiffuse+finalSpecular,alpha);\n#include<fogFragment>\ngl_FragColor=color;\n}";
	
	static var vertexShader:String = "precision highp float;\n\nattribute vec3 position;\n#ifdef NORMAL\nattribute vec3 normal;\n#endif\n#ifdef UV1\nattribute vec2 uv;\n#endif\n#ifdef UV2\nattribute vec2 uv2;\n#endif\n#ifdef VERTEXCOLOR\nattribute vec4 color;\n#endif\n#include<bonesDeclaration>\n\n#include<instancesDeclaration>\nuniform mat4 view;\nuniform mat4 viewProjection;\n#ifdef BUMP\nvarying vec2 vNormalUV;\nuniform mat4 normalMatrix;\nuniform vec2 vNormalInfos;\n#endif\n#ifdef POINTSIZE\nuniform float pointSize;\n#endif\n\nvarying vec3 vPositionW;\n#ifdef NORMAL\nvarying vec3 vNormalW;\n#endif\n#ifdef VERTEXCOLOR\nvarying vec4 vColor;\n#endif\n#include<clipPlaneVertexDeclaration>\n#include<fogVertexDeclaration>\n#include<shadowsVertexDeclaration>\n\nuniform mat4 worldReflectionViewProjection;\nuniform vec2 windDirection;\nuniform float waveLength;\nuniform float time;\nuniform float windForce;\nuniform float waveHeight;\nuniform float waveSpeed;\n\nvarying vec3 vPosition;\nvarying vec3 vRefractionMapTexCoord;\nvarying vec3 vReflectionMapTexCoord;\nvoid main(void) {\n#include<instancesVertex>\n#include<bonesVertex>\nvec4 worldPos=finalWorld*vec4(position,1.0);\nvPositionW=vec3(worldPos);\n#ifdef NORMAL\nvNormalW=normalize(vec3(finalWorld*vec4(normal,0.0)));\n#endif\n\n#ifndef UV1\nvec2 uv=vec2(0.,0.);\n#endif\n#ifndef UV2\nvec2 uv2=vec2(0.,0.);\n#endif\n#ifdef BUMP\nif (vNormalInfos.x == 0.)\n{\nvNormalUV=vec2(normalMatrix*vec4((uv*1.0)/waveLength+time*windForce*windDirection,1.0,0.0));\n}\nelse\n{\nvNormalUV=vec2(normalMatrix*vec4((uv2*1.0)/waveLength+time*windForce*windDirection,1.0,0.0));\n}\n#endif\n\n#include<clipPlaneVertex>\n\n#include<fogVertex>\n\n#include<shadowsVertex>\n\n#ifdef VERTEXCOLOR\nvColor=color;\n#endif\n\n#ifdef POINTSIZE\ngl_PointSize=pointSize;\n#endif\nvec3 p=position;\nfloat newY=(sin(((p.x/0.05)+time*waveSpeed))*waveHeight*windDirection.x*5.0)\n+(cos(((p.z/0.05)+time*waveSpeed))*waveHeight*windDirection.y*5.0);\np.y+=abs(newY);\ngl_Position=viewProjection*finalWorld*vec4(p,1.0);\n#ifdef REFLECTION\nworldPos=viewProjection*finalWorld*vec4(p,1.0);\n\nvPosition=position;\nvRefractionMapTexCoord.x=0.5*(worldPos.w+worldPos.x);\nvRefractionMapTexCoord.y=0.5*(worldPos.w+worldPos.y);\nvRefractionMapTexCoord.z=worldPos.w;\nworldPos=worldReflectionViewProjection*vec4(position,1.0);\nvReflectionMapTexCoord.x=0.5*(worldPos.w+worldPos.x);\nvReflectionMapTexCoord.y=0.5*(worldPos.w+worldPos.y);\nvReflectionMapTexCoord.z=worldPos.w;\n#endif\n}\n";
	
	/*
	* Public members
	*/
	@serializeAsTexture()
	public var bumpTexture:BaseTexture;
	
	@serializeAsColor3()
	public var diffuseColor:Color3 = new Color3(1, 1, 1);
	
	@serializeAsColor3()
	public var specularColor:Color3 = new Color3(0, 0, 0);
	
	@serialize()
	public var specularPower:Float = 64;
	
	@serialize()
	public var disableLighting:Bool = false;
	
	@serialize()
	public var maxSimultaneousLights:Int = 4;
	
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
	* @param {number}: The water color blended with the reflection and refraction samplers
	*/
	@serializeAsColor3()
	public var waterColor:Color3 = new Color3(0.1, 0.1, 0.6);
	/**
	* @param {number}: The blend factor related to the water color
	*/
	@serialize()
	public var colorBlendFactor:Float = 0.2;
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
	
	public var renderTargetSize:Vector2 = new Vector2(512, 512);
	
	public var reflectionTexture(get, never):RenderTargetTexture;
	
	/*
	* Private members
	*/
	private var _mesh:AbstractMesh = null;
	
	private var _refractionRTT:RenderTargetTexture;
	private var _reflectionRTT:RenderTargetTexture;
	
	private var _material:ShaderMaterial;
	
	private var _reflectionTransform:Matrix = Matrix.Zero();
	private var _lastTime:Float = 0;
	
	private var _renderId:Int;

	private var _defines:WaterMaterialDefines = new WaterMaterialDefines();
	private var _cachedDefines:WaterMaterialDefines = new WaterMaterialDefines();
	
	
	/**
	* Constructor
	*/
	public function new(name:String, scene:Scene, renderTargetSize:Vector2 = null) {
		super(name, scene);
		
		if (!ShadersStore.Shaders.exists("watermat.fragment")) {
			ShadersStore.Shaders.set("watermat.fragment", fragmentShader);
			ShadersStore.Shaders.set("watermat.vertex", vertexShader);
		}
		
		if (renderTargetSize != null) {
			this.renderTargetSize = renderTargetSize;
		}
		
		this._cachedDefines.BonesPerMesh = -1;
		
		// Create render targets
		this._createRenderTargets(scene, this.renderTargetSize);
	}
	
	// Get / Set
	private function get_refractionTexture():RenderTargetTexture {
		return this._refractionRTT;
	}
	
	private function get_reflectionTexture():RenderTargetTexture {
		return this._reflectionRTT;
	}
	
	// Methods
	public function addToRenderList(node:AbstractMesh) {
		this._refractionRTT.renderList.push(node);
		this._reflectionRTT.renderList.push(node);
	}
	
	public function enableRenderTargets(enable:Bool) {
		var refreshRate = enable ? 1 : 0;
		
		this._refractionRTT.refreshRate = refreshRate;
		this._reflectionRTT.refreshRate = refreshRate;
	}
	
	public function getRenderList():Array<AbstractMesh> {
		return this._refractionRTT.renderList;
	}
	
	private function get_renderTargetsEnabled():Bool {
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
			if (this.bumpTexture != null && StandardMaterial.BumpTextureEnabled) {
				if (!this.bumpTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this._defines.defines["BUMP"] = true;
				}
			}
			
			if (StandardMaterial.ReflectionTextureEnabled) {
				this._defines.defines["REFLECTION"] = true;
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
		
		this._mesh = mesh;
		
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
			var shaderName:String = "watermat";
			var join:String = this._defines.toString();
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vDiffuseColor", "vSpecularColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vNormalInfos", 
				"mBones",
				"vClipPlane", "normalMatrix",
				// Water
				"worldReflectionViewProjection", "windDirection", "waveLength", "time", "windForce",
				"cameraPosition", "bumpHeight", "waveHeight", "waterColor", "colorBlendFactor", "waveSpeed"
			];
			var samplers:Array<String> = ["normalSampler",
				// Water
				"refractionSampler", "reflectionSampler"
			];
			
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
				mesh._materialDefines = new WaterMaterialDefines();
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
			if (this.bumpTexture != null && StandardMaterial.BumpTextureEnabled) {
				this._effect.setTexture("normalSampler", this.bumpTexture);
				
				this._effect.setFloat2("vNormalInfos", this.bumpTexture.coordinatesIndex, this.bumpTexture.level);
				this._effect.setMatrix("normalMatrix", this.bumpTexture.getTextureMatrix());
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
		
		if (this._defines.defines["SPECULARTERM"]) {
			this._effect.setColor4("vSpecularColor", this.specularColor, this.specularPower);
		}
		
		if (scene.lightsEnabled && !this.disableLighting) {
			MaterialHelper.BindLights(scene, mesh, this._effect, this._defines, this.maxSimultaneousLights);
		}
		
		// View
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		MaterialHelper.BindFogParameters(scene, mesh, this._effect);
		
		// Water
		if (StandardMaterial.ReflectionTextureEnabled) {
			this._effect.setTexture("refractionSampler", this._refractionRTT);
			this._effect.setTexture("reflectionSampler", this._reflectionRTT);
		}
		
		var wrvp = this._mesh.getWorldMatrix().multiply(this._reflectionTransform).multiply(scene.getProjectionMatrix());
		this._lastTime += scene.getEngine().getDeltaTime();
		
		this._effect.setMatrix("worldReflectionViewProjection", wrvp);
		this._effect.setVector2("windDirection", this.windDirection);
		this._effect.setFloat("waveLength", this.waveLength);
		this._effect.setFloat("time", this._lastTime / 100000);
		this._effect.setFloat("windForce", this.windForce);
		this._effect.setFloat("waveHeight", this.waveHeight);
		this._effect.setFloat("bumpHeight", this.bumpHeight);
		this._effect.setColor4("waterColor", this.waterColor, 1.0);
		this._effect.setFloat("colorBlendFactor", this.colorBlendFactor);
		this._effect.setFloat("waveSpeed", this.waveSpeed);
		
		super.bind(world, mesh);
	}
	
	private function _createRenderTargets(scene:Scene, renderTargetSize:Vector2) {
		// Render targets
		this._refractionRTT = new RenderTargetTexture(name + "_refraction", {width: renderTargetSize.x, height: renderTargetSize.y}, scene, false, true);
		this._reflectionRTT = new RenderTargetTexture(name + "_reflection", {width: renderTargetSize.x, height: renderTargetSize.y}, scene, false, true);
		
		scene.customRenderTargets.push(this._refractionRTT);
		scene.customRenderTargets.push(this._reflectionRTT);
		
		var isVisible:Bool = true;
		var clipPlane:Plane = new Plane(0, 0, 0, 0);
		var savedViewMatrix:Matrix = null;
		var mirrorMatrix:Matrix = Matrix.Zero();
		
		this._refractionRTT.onBeforeRenderObservable.add(function(index:Int, es:EventState = null) {
			if (this._mesh != null) {
				isVisible = this._mesh.isVisible;
				this._mesh.isVisible = false;
			}
			// Clip plane
			clipPlane = scene.clipPlane;
			
			var positiony = this._mesh != null ? this._mesh.position.y : 0.0;
			scene.clipPlane = Plane.FromPositionAndNormal(new Vector3(0, positiony + 0.05, 0), new Vector3(0, 1, 0));
		});
		
		this._refractionRTT.onAfterRenderObservable.add(function(i:Int, es:EventState = null) {
			if (this._mesh != null) {
				this._mesh.isVisible = isVisible;
			}
			
			// Clip plane
			scene.clipPlane = clipPlane;
		});
		
		this._reflectionRTT.onBeforeRenderObservable.add(function(i:Int, es:EventState = null) {
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
		});
		
		this._reflectionRTT.onAfterRenderObservable.add(function(i:Int, es:EventState = null) {
			if (this._mesh != null) {
				this._mesh.isVisible = isVisible;
			}
			
			// Clip plane
			scene.clipPlane = clipPlane;
			
			// Transform
			scene.setTransformMatrix(savedViewMatrix, scene.getProjectionMatrix());
			scene.getEngine().cullBackFaces = true;
			scene._mirroredCameraPosition = null;
		});
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

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (forceDisposeTextures) {
			if (this.bumpTexture != null) {
				this.bumpTexture.dispose();
			}
		}
		
		var index:Int = this.getScene().customRenderTargets.indexOf(this._refractionRTT);
		if (index != -1){
			this.getScene().customRenderTargets.splice(index, 1);
		}
		index = -1;
		index = this.getScene().customRenderTargets.indexOf(this._reflectionRTT);
		if (index != -1){
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
		//return SerializationHelper.Clone(() => new WaterMaterial(name, this.getScene()), this);
		return null;
	}

	override public function serialize():Dynamic {
		return SerializationHelper.Serialize(WaterMaterial, this, super.serialize());
	}

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):WaterMaterial {
		//return SerializationHelper.Parse(() => new WaterMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
	public static function CreateDefaultMesh(name:String, scene:Scene):Mesh {
		var mesh = Mesh.CreateGround(name, 512, 512, 32, scene, false);
		
		return mesh;
	}
	
}
