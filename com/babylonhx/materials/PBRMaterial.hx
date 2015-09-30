package com.babylonhx.materials;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.animations.IAnimatable;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterial extends Material {
	
	public var albedoColor = new Color3(1, 1, 1);

	private var _worldViewProjectionMatrix = Matrix.Zero();
	private var _globalAmbientColor = new Color3(0, 0, 0);
	private var _scaledDiffuse = new Color3();
	private var _scaledSpecular = new Color3();
	private var _renderId:Int;

	private var _defines:PBRMaterialDefines = new PBRMaterialDefines();
	private var _cachedDefines:PBRMaterialDefines = new PBRMaterialDefines();
		

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this._cachedDefines.BonesPerMesh = -1;
	}
	
	override public function needAlphaBlending():Bool {
		return this.alpha < 1.0;
	}

	override public function needAlphaTesting():Bool {
		return false;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return null;
	}

	// Methods   
	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (this.checkReadyOnlyOnce) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall) {
			if (this._renderId == scene.getRenderId()) {
				return true;
			}
		}
		
		var engine = scene.getEngine();
		var needNormals = false;
		var needUVs = false;
		
		this._defines.reset();
		
		// Textures
		if (scene.texturesEnabled) {  
			
		}
		
		// Effect
		if (scene.clipPlane) {
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
					this._defines.defines["VERTEXALPHA"] = true
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.defines["BONES"] = true;
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
				this._defines.defines["BONES4"] = true;
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
			var fallbacks:EffectFallbacks = new EffectFallbacks();              
			if (this._defines.defines["FOG"]) {
				fallbacks.addFallback(1, "FOG");
			}  
			
			if (this._defines.defines["BONES4"]) {
				fallbacks.addFallback(0, "BONES4");
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
			
			if (this._defines.defines["BONES"]) {
				attribs.push(VertexBuffer.MatricesIndicesKind);
				attribs.push(VertexBuffer.MatricesWeightsKind);
			}
			
			if (this._defines.defines["INSTANCES"]) {
				attribs.push("world0");
				attribs.push("world1");
				attribs.push("world2");
				attribs.push("world3");
			}
			
			// Legacy browser patch
			var join:String = this._defines.toString();
			this._effect = scene.getEngine().createEffect("pbr",
				attribs,
				["world", "view", "viewProjection", "vEyePosition", "vAlbedoColor",                        
					"vFogInfos", "vFogColor", "pointSize",
					"mBones",
					"vClipPlane",
				],
				[],
				join, fallbacks, this.onCompiled, this.onError);
		}
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		return true;
	}

	public function bindOnlyWorldMatrix(world:Matrix) {
		this._effect.setMatrix("world", world);
	}

	public function bind(world:Matrix, ?mesh:Mesh) {
		var scene = this.getScene();
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		this._effect.setMatrix("viewProjection", scene.getTransformMatrix());
		
		// Bones
		if (mesh != null && mesh.useBones && mesh.computeBonesUsingShaders) {
			this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices());
		}
		
		if (scene.getCachedMaterial() != this) {
			// Clip plane
			if (scene.clipPlane) {
				var clipPlane = scene.clipPlane;
				this._effect.setFloat4("vClipPlane", clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.d);
			}
			
			this._effect.setVector3("vEyePosition", scene.activeCamera.position);              
		}
		
		// Point size
		if (this.pointsCloud) {
			this._effect.setFloat("pointSize", this.pointSize);
		}
		
		// Colors
		this._effect.setColor4("vAlbedoColor", this.albedoColor, this.alpha * mesh.visibility);
		
		// View
		if (scene.fogEnabled && mesh.applyFog &&scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setMatrix("view", scene.getViewMatrix());
		}
		
		// Fog
		if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE) {
			this._effect.setFloat4("vFogInfos", scene.fogMode, scene.fogStart, scene.fogEnd, scene.fogDensity);
			this._effect.setColor3("vFogColor", scene.fogColor);
		}
		
		super.bind(world, mesh);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];  
		
		return results;
	}

	public function dispose(forceDisposeEffect:Bool = false) {        
		super.dispose(forceDisposeEffect);
	}

	public function clone(name:String):PBRMaterial {
		var newPBRMaterial = new PBRMaterial(name, this.getScene());
		
		// Base material
		this.copyTo(newPBRMaterial);
		
		// PBRMaterial material
		newPBRMaterial.albedoColor = this.albedoColor.clone();
		
		return newPBRMaterial;
	}

	// Statics
	// Flags used to enable or disable a type of texture for all PBR Materials
	
}
