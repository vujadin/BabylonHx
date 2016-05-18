package com.babylonhx.lights.shadows;

import com.babylonhx.Engine;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.EventState;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ShadowGenerator') class ShadowGenerator {
	
	public static var FILTER_NONE:Int = 0;
	public static var FILTER_VARIANCESHADOWMAP:Int = 1;
	public static var FILTER_POISSONSAMPLING:Int = 2;
	public static var FILTER_BLURVARIANCESHADOWMAP:Int = 3;

	// Members
	private var _filter:Int = ShadowGenerator.FILTER_NONE;
	public var blurScale:Int = 2;
	private var _blurBoxOffset:Float = 0.0;
	private var _bias:Float = 0.00005;
	private var _lightDirection:Vector3 = Vector3.Zero();
	
	public var forceBackFacesOnly:Bool = false;

	public var bias(get, set):Float;
	private function get_bias():Float {
		return this._bias;
	}
	private function set_bias(bias:Float):Float {
		this._bias = bias;
		return bias;
	}
	
	public var blurBoxOffset(get, set):Float;
	private function get_blurBoxOffset():Float {
		return this._blurBoxOffset;
	}
	private function set_blurBoxOffset(value:Float):Float {
		if (this._blurBoxOffset == value) {
			return value;
		}
		
		this._blurBoxOffset = value;
		
		if (this._boxBlurPostprocess != null) {
			this._boxBlurPostprocess.dispose();
		}
		
		this._boxBlurPostprocess = new PostProcess("DepthBoxBlur", "depthBoxBlur", ["screenSize", "boxOffset"], [], 1.0 / this.blurScale, null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, "#define OFFSET " + value);
		this._boxBlurPostprocess.onApplyObservable.add(function(effect:Effect, eventState:EventState = null) {
			effect.setFloat2("screenSize", this._mapSize / this.blurScale, this._mapSize / this.blurScale);
		});
		
		return value;
	}

	public var filter(get, set):Int;
	private function get_filter():Int {
		return this._filter;
	}
	private function set_filter(value:Int):Int {
		if (this._filter == value) {
			return value;
		}
		
		this._filter = value;
		
		if (this.useVarianceShadowMap || this.useBlurVarianceShadowMap || this.usePoissonSampling) {
			this._shadowMap.anisotropicFilteringLevel = 16;
			this._shadowMap.updateSamplingMode(Texture.TRILINEAR_SAMPLINGMODE);
		} 
		else {
			this._shadowMap.anisotropicFilteringLevel = 1;
			this._shadowMap.updateSamplingMode(Texture.NEAREST_SAMPLINGMODE);
		}
		
		return value;
	}

	public var useVarianceShadowMap(get, set):Bool;
	private function get_useVarianceShadowMap():Bool {
		return this.filter == ShadowGenerator.FILTER_VARIANCESHADOWMAP && this._light.supportsVSM();
	}
	private function set_useVarianceShadowMap(value:Bool):Bool {
		this.filter = (value ? ShadowGenerator.FILTER_VARIANCESHADOWMAP : ShadowGenerator.FILTER_NONE);
		return value;
	}

	public var usePoissonSampling(get, set):Bool;
	private function get_usePoissonSampling():Bool {
		return this.filter == ShadowGenerator.FILTER_POISSONSAMPLING ||
			(!this._light.supportsVSM() && (
				this.filter == ShadowGenerator.FILTER_VARIANCESHADOWMAP ||
				this.filter == ShadowGenerator.FILTER_BLURVARIANCESHADOWMAP
				));
	}
	private function set_usePoissonSampling(value:Bool):Bool {
		this.filter = (value ? ShadowGenerator.FILTER_POISSONSAMPLING : ShadowGenerator.FILTER_NONE);
		return value;
	}

	public var useBlurVarianceShadowMap(get, set):Bool;
	private function get_useBlurVarianceShadowMap():Bool {
		return this.filter == ShadowGenerator.FILTER_BLURVARIANCESHADOWMAP && this._light.supportsVSM();
	}
	private function set_useBlurVarianceShadowMap(value:Bool):Bool {
		this.filter = (value ? ShadowGenerator.FILTER_BLURVARIANCESHADOWMAP : ShadowGenerator.FILTER_NONE);
		return value;
	}

	private var _light:IShadowLight;
	private var _scene:Scene;
	private var _shadowMap:RenderTargetTexture;
	private var _shadowMap2:RenderTargetTexture;
	private var _darkness:Float = 0;
	private var _transparencyShadow:Bool = false;
	private var _effect:Effect;

	private var _viewMatrix:Matrix = Matrix.Zero();
	private var _projectionMatrix:Matrix = Matrix.Zero();
	private var _transformMatrix:Matrix = Matrix.Zero();
	private var _worldViewProjection:Matrix = Matrix.Zero();
	private var _cachedPosition:Vector3;
	private var _cachedDirection:Vector3;
	private var _cachedDefines:String;
	private var _currentRenderID:Int;
	private var _downSamplePostprocess:PassPostProcess;
	private var _boxBlurPostprocess:PostProcess;
	private var _mapSize:Int;
	private var _currentFaceIndex:Int = 0;
    private var _currentFaceIndexCache:Int = 0;

	
	public function new(mapSize:Int, light:IShadowLight) {
		this._light = light;
		this._scene = light.getScene();
		this._mapSize = mapSize;
		
		light._shadowGenerator = this;
		
		// Render target
		this._shadowMap = new RenderTargetTexture(light.name + "_shadowMap", mapSize, this._scene, false, true, Engine.TEXTURETYPE_UNSIGNED_INT, light.needCube());
		this._shadowMap.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._shadowMap.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._shadowMap.anisotropicFilteringLevel = 1;
		this._shadowMap.updateSamplingMode(Texture.NEAREST_SAMPLINGMODE);
		this._shadowMap.renderParticles = false;
		
		this._shadowMap.onBeforeRenderObservable.add(function(faceIndex:Int, eventState:EventState = null) {
			this._currentFaceIndex = faceIndex;
		});
		
		this._shadowMap.onAfterUnbindObservable.add(function(rtt:RenderTargetTexture, eventState:EventState = null) {
			if (!this.useBlurVarianceShadowMap) {
				return;
			}
			
			if (this._shadowMap2 == null) {
				this._shadowMap2 = new RenderTargetTexture(light.name + "_shadowMap", mapSize, this._scene, false);
				this._shadowMap2.wrapU = Texture.CLAMP_ADDRESSMODE;
				this._shadowMap2.wrapV = Texture.CLAMP_ADDRESSMODE;
				this._shadowMap2.updateSamplingMode(Texture.TRILINEAR_SAMPLINGMODE);
				
				this._downSamplePostprocess = new PassPostProcess("downScale", 1.0 / this.blurScale, null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine());
				this._downSamplePostprocess.onApplyObservable.add(function(effect:Effect, eventState:EventState = null) {
					effect.setTexture("textureSampler", this._shadowMap);
				});
				
				this.blurBoxOffset = 1;				
			}
			
			this._scene.postProcessManager.directRender([this._downSamplePostprocess, this._boxBlurPostprocess], this._shadowMap2.getInternalTexture());
		});
		
		// Custom render function
		var renderSubMesh = function(subMesh:SubMesh) {
			var mesh:Mesh = subMesh.getRenderingMesh();
			var scene:Scene = this._scene;
			var engine:Engine = scene.getEngine();
			
			// Culling
			engine.setState(subMesh.getMaterial().backFaceCulling);
			
			// Managing instances
			var batch = mesh._getInstancesRenderList(subMesh._id);
			
			if (batch.mustReturn) {
				return;
			}
			
			var hardwareInstancedRendering = (engine.getCaps().instancedArrays != null) && (batch.visibleInstances[subMesh._id] != null);
			
			if (this.isReady(subMesh, hardwareInstancedRendering)) {
				engine.enableEffect(this._effect);
				mesh._bind(subMesh, this._effect, Material.TriangleFillMode);
				var material = subMesh.getMaterial();
				
				this._effect.setMatrix("viewProjection", this.getTransformMatrix());
				this._effect.setVector3("lightPosition", this.getLight().position);
				
				if (this.getLight().needCube()) {
					this._effect.setFloat2("depthValues", scene.activeCamera.minZ, scene.activeCamera.maxZ);
				}
				
				// Alpha test
				if (material != null && material.needAlphaTesting()) {
					var alphaTexture = material.getAlphaTestTexture();
					this._effect.setTexture("diffuseSampler", alphaTexture);
					this._effect.setMatrix("diffuseMatrix", alphaTexture.getTextureMatrix());
				}
				
				// Bones
				if (mesh.useBones && mesh.computeBonesUsingShaders) {
					this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices(mesh));
				}
				
				if (this.forceBackFacesOnly) {
					engine.setState(true, 0, false, true);
				}
				
				// Draw
				mesh._processRendering(subMesh, this._effect, Material.TriangleFillMode, batch, hardwareInstancedRendering,
					function(isInstance:Bool, world:Matrix) { this._effect.setMatrix("world", world); } );
					
				if (this.forceBackFacesOnly) {
					engine.setState(true, 0, false, false);
				}
			} 
			else {
				// Need to reset refresh rate of the shadowMap
				this._shadowMap.resetRefreshCounter();
			}
		};
		
		this._shadowMap.customRenderFunction = function(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>, transparentSubMeshes:SmartArray<SubMesh>) {
			for (index in 0...opaqueSubMeshes.length) {
				renderSubMesh(opaqueSubMeshes.data[index]);
			}
			
			for (index in 0...alphaTestSubMeshes.length) {
				renderSubMesh(alphaTestSubMeshes.data[index]);
			}
			
			if (this._transparencyShadow) {
				for (index in 0...transparentSubMeshes.length) {
					renderSubMesh(transparentSubMeshes.data[index]);
				}
			}
		};
		
		this._shadowMap.onClearObservable.add(function(engine:Engine, eventState:EventState = null) {
			if (this.useBlurVarianceShadowMap || this.useVarianceShadowMap) {
				engine.clear(new Color4(0, 0, 0, 0), true, true);
			} 
			else {
				engine.clear(new Color4(1.0, 1.0, 1.0, 1.0), true, true);
			}
		});
	}

	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var defines:Array<String> = [];
		
		if (this.useVarianceShadowMap || this.useBlurVarianceShadowMap) {
			defines.push("#define VSM");
		}
		
		if (this.getLight().needCube()) {
			defines.push("#define CUBEMAP");
		}
		
		var attribs:Array<String> = [VertexBuffer.PositionKind];
		
		var mesh = subMesh.getMesh();
		var material = subMesh.getMaterial();
		
		// Alpha test
		if (material != null && material.needAlphaTesting()) {
			defines.push("#define ALPHATEST");
			if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
				attribs.push(VertexBuffer.UVKind);
				defines.push("#define UV1");
			}
			if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
				attribs.push(VertexBuffer.UV2Kind);
				defines.push("#define UV2");
			}
		}
		
		// Bones
		if (mesh.useBones && mesh.computeBonesUsingShaders) {
			attribs.push(VertexBuffer.MatricesIndicesKind);
			attribs.push(VertexBuffer.MatricesWeightsKind);
			if (mesh.numBoneInfluencers > 4) {
                attribs.push(VertexBuffer.MatricesIndicesExtraKind);
                attribs.push(VertexBuffer.MatricesWeightsExtraKind);
            }
            defines.push("#define NUM_BONE_INFLUENCERS " + mesh.numBoneInfluencers);
			defines.push("#define BonesPerMesh " + (mesh.skeleton.bones.length + 1));
		} 
		else {
			defines.push("#define NUM_BONE_INFLUENCERS 0");
		}
		
		// Instances
		if (useInstances) {
			defines.push("#define INSTANCES");
			attribs.push("world0");
			attribs.push("world1");
			attribs.push("world2");
			attribs.push("world3");
		}
		
		// Get correct effect      
		var join = defines.join("\n");
		if (this._cachedDefines != join) {
			this._cachedDefines = join;
			this._effect = this._scene.getEngine().createEffect("shadowMap",
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix", "lightPosition", "depthValues"],
				["diffuseSampler"], join);
		}
		
		return this._effect.isReady();
	}

	public function getShadowMap():RenderTargetTexture {
		return this._shadowMap;
	}

	public function getShadowMapForRendering():RenderTargetTexture {
		if (this._shadowMap2 != null) {
			return this._shadowMap2;
		}
		
		return this._shadowMap;
	}

	public function getLight():IShadowLight {
		return this._light;
	}

	// Methods
	public function getTransformMatrix():Matrix {
		var scene = this._scene;
		if (this._currentRenderID == scene.getRenderId() && this._currentFaceIndexCache == this._currentFaceIndex) {
			return this._transformMatrix;
		}
		
		this._currentRenderID = scene.getRenderId();
		this._currentFaceIndexCache = this._currentFaceIndex;
		
		var lightPosition = this._light.position;
		Vector3.NormalizeToRef(this._light.getShadowDirection(this._currentFaceIndex), this._lightDirection);
		
		if (Math.abs(Vector3.Dot(this._lightDirection, Vector3.Up())) == 1.0) {
            this._lightDirection.z = 0.0000000000001; // Required to avoid perfectly perpendicular light
        }
		
		if (this._light.computeTransformedPosition()) {
			lightPosition = this._light.transformedPosition;
		}
		
		if (this._light.needRefreshPerFrame() || this._cachedPosition == null || this._cachedDirection == null || !lightPosition.equals(this._cachedPosition) || !this._lightDirection.equals(this._cachedDirection)) {
			
			this._cachedPosition = lightPosition.clone();
			this._cachedDirection = this._lightDirection.clone();
			
			Matrix.LookAtLHToRef(lightPosition, lightPosition.add(_lightDirection), Vector3.Up(), this._viewMatrix);
			
			this._light.setShadowProjectionMatrix(this._projectionMatrix, this._viewMatrix, this.getShadowMap().renderList);
			
			this._viewMatrix.multiplyToRef(this._projectionMatrix, this._transformMatrix);
		}
		
		return this._transformMatrix;
	}

	public function getDarkness():Float {
		return this._darkness;
	}

	public function setDarkness(darkness:Float) {
		if (darkness >= 1.0) {
			this._darkness = 1.0;
		}
		else if (darkness <= 0.0) {
			this._darkness = 0.0;
		}
		else {
			this._darkness = darkness;
		}
	}

	public function setTransparencyShadow(hasShadow:Bool) {
		this._transparencyShadow = hasShadow;
	}

	private function _packHalf(depth:Float):Vector2 {
		var scale = depth * 255.0;
		var fract = scale - Math.floor(scale);
		
		return new Vector2(depth - fract / 255.0, fract);
	}

	public function dispose() {
		this._shadowMap.dispose();
		
		if (this._shadowMap2 != null) {
			this._shadowMap2.dispose();
		}
		
		if (this._downSamplePostprocess != null) {
			this._downSamplePostprocess.dispose();
		}
		
		if (this._boxBlurPostprocess != null) {
			this._boxBlurPostprocess.dispose();
		}
	}
	
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.lightId = untyped this._light.id;
		serializationObject.mapSize = this.getShadowMap().getRenderSize();
		serializationObject.useVarianceShadowMap = this.useVarianceShadowMap;
		serializationObject.usePoissonSampling = this.usePoissonSampling;
		serializationObject.forceBackFacesOnly = this.forceBackFacesOnly;
		
		serializationObject.renderList = [];
		for (meshIndex in 0...this.getShadowMap().renderList.length) {
			var mesh = this.getShadowMap().renderList[meshIndex];
			
			serializationObject.renderList.push(mesh.id);
		}
		
		return serializationObject;
	}

	public static function Parse(parsedShadowGenerator:Dynamic, scene:Scene):ShadowGenerator {
		var light = scene.getLightByID(parsedShadowGenerator.lightId);
		var shadowGenerator:ShadowGenerator = new ShadowGenerator(parsedShadowGenerator.mapSize, cast light);
		
		for (meshIndex in 0...parsedShadowGenerator.renderList.length) {
			var meshes = scene.getMeshesByID(parsedShadowGenerator.renderList[meshIndex]);
			for (mesh in meshes) {
				shadowGenerator.getShadowMap().renderList.push(mesh);
			}
		}
		
		if (parsedShadowGenerator.usePoissonSampling == true) {
			shadowGenerator.usePoissonSampling = true;
		} 
		else if (parsedShadowGenerator.useVarianceShadowMap == true) {
			shadowGenerator.useVarianceShadowMap = true;
		} 
		else if (parsedShadowGenerator.useBlurVarianceShadowMap == true) {
			shadowGenerator.useBlurVarianceShadowMap = true;
			
			if (parsedShadowGenerator.blurScale != null) {
				shadowGenerator.blurScale = parsedShadowGenerator.blurScale;
			}
			
			if (parsedShadowGenerator.blurBoxOffset != null) {
				shadowGenerator.blurBoxOffset = parsedShadowGenerator.blurBoxOffset;
			}
		}
		
		if (parsedShadowGenerator.bias != null) {
			shadowGenerator.bias = parsedShadowGenerator.bias;
		}
		
		shadowGenerator.forceBackFacesOnly = parsedShadowGenerator.forceBackFacesOnly;
		
		return shadowGenerator;
	}
	
}
