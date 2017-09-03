package com.babylonhx.lights.shadows;

import com.babylonhx.Engine;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.MaterialDefines;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.BlurPostProcess;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ShadowGenerator') class ShadowGenerator implements IShadowGenerator {
	
	public static inline var FILTER_NONE:Int = 0;
	public static inline var FILTER_EXPONENTIALSHADOWMAP:Int = 1;
	public static inline var FILTER_POISSONSAMPLING:Int = 2;
	public static inline var FILTER_BLUREXPONENTIALSHADOWMAP:Int = 3;
	public static inline var FILTER_CLOSEEXPONENTIALSHADOWMAP:Int = 4;
    public static inline var FILTER_BLURCLOSEEXPONENTIALSHADOWMAP:Int = 5;

	// Members
	private var _bias:Float = 0.00005;
	public var bias(get, set):Float;
	inline private function get_bias():Float {
		return this._bias;
	}
	inline private function set_bias(bias:Float):Float {
		return this._bias = bias;
	}

	private var _blurBoxOffset:Float = 1;
	public var blurBoxOffset(get, set):Float;
	inline private function get_blurBoxOffset():Float {
		return this._blurBoxOffset;
	}
	private function set_blurBoxOffset(value:Float):Float {
		if (this._blurBoxOffset == value) {
			return value;
		}
		
		this._blurBoxOffset = value;
		this._disposeBlurPostProcesses();
		return value;
	}

	private var _blurScale:Float = 2;
	public var blurScale(get, set):Float;
	inline private function get_blurScale():Float {
		return this._blurScale;
	}
	private function set_blurScale(value:Float):Float {
		if (this._blurScale == value) {
			return value;
		}
		
		this._blurScale = value;
		this._disposeBlurPostProcesses();
		return value;
	}

	private var _blurKernel:Float = 1;
	public var blurKernel(get, set):Float;
	inline private function get_blurKernel():Float {
		return this._blurKernel;
	}
	private function set_blurKernel(value:Float):Float {
		if (this._blurKernel == value) {
			return value;
		}
		
		this._blurKernel = value;
		this._disposeBlurPostProcesses();
		return value;
	}

	private var _useKernelBlur:Bool = false;
	public var useKernelBlur(get, set):Bool;
	inline private function get_useKernelBlur():Bool {
		return this._useKernelBlur;
	}
	private function set_useKernelBlur(value:Bool):Bool {
		if (this._useKernelBlur == value) {
			return value;
		}
		
		this._useKernelBlur = value;
		this._disposeBlurPostProcesses();
		return value;
	}

	private var _depthScale:Null<Float> = null;
	public var depthScale(get, set):Float;
	inline private function get_depthScale():Float {
		return this._depthScale != null ? this._depthScale : this._light.getDepthScale();
	}
	inline private function set_depthScale(value:Float):Float {
		return this._depthScale = value;
	}

	private var _filter:Int = ShadowGenerator.FILTER_NONE;
	public var filter(get, set):Int;
	inline private function get_filter():Int {
		return this._filter;
	}
	private function set_filter(value:Int):Int {
		// Blurring the cubemap is going to be too expensive. Reverting to unblurred version
		if (this._light.needCube()) {
			if (value == ShadowGenerator.FILTER_BLUREXPONENTIALSHADOWMAP) {
				this.useExponentialShadowMap = true;
				return value;
			}
			else if (value == ShadowGenerator.FILTER_BLURCLOSEEXPONENTIALSHADOWMAP) {
				this.useCloseExponentialShadowMap = true;
				return value;
			}
		}
		
		if (this._filter == value) {
			return value;
		}
		
		this._filter = value;
		this._disposeBlurPostProcesses();
		this._applyFilterValues();
		this._light._markMeshesAsLightDirty();
		return value;
	}

	public var usePoissonSampling(get, set):Bool;
	inline private function get_usePoissonSampling():Bool {
		return this.filter == ShadowGenerator.FILTER_POISSONSAMPLING;
	}
	inline private function set_usePoissonSampling(value:Bool):Bool {
		if (!value && this.filter != ShadowGenerator.FILTER_POISSONSAMPLING) {
            return value;
        } 
		this.filter = (value ? ShadowGenerator.FILTER_POISSONSAMPLING : ShadowGenerator.FILTER_NONE);
		return value;
	}

	public var useExponentialShadowMap(get, set):Bool;
	inline private function get_useExponentialShadowMap():Bool {
		return this.filter == ShadowGenerator.FILTER_EXPONENTIALSHADOWMAP;
	}
	inline private function set_useExponentialShadowMap(value:Bool):Bool {
		this.filter = (value ? ShadowGenerator.FILTER_EXPONENTIALSHADOWMAP : ShadowGenerator.FILTER_NONE);
		return value;
	}

	public var useBlurExponentialShadowMap(get, set):Bool;
	inline private function get_useBlurExponentialShadowMap():Bool {
		return this.filter == ShadowGenerator.FILTER_BLUREXPONENTIALSHADOWMAP;
	}
	inline private function set_useBlurExponentialShadowMap(value:Bool):Bool {
		if (!value && this.filter != ShadowGenerator.FILTER_BLUREXPONENTIALSHADOWMAP) {
            return value;
        }   
		this.filter = (value ? ShadowGenerator.FILTER_BLUREXPONENTIALSHADOWMAP : ShadowGenerator.FILTER_NONE);
		return value;
	}

	public var useCloseExponentialShadowMap(get, set):Bool;
	inline private function get_useCloseExponentialShadowMap():Bool {
		return this.filter == ShadowGenerator.FILTER_CLOSEEXPONENTIALSHADOWMAP;
	}
	inline private function set_useCloseExponentialShadowMap(value:Bool):Bool {
		if (!value && this.filter != ShadowGenerator.FILTER_CLOSEEXPONENTIALSHADOWMAP) {
            return value;
        }
		this.filter = (value ? ShadowGenerator.FILTER_CLOSEEXPONENTIALSHADOWMAP : ShadowGenerator.FILTER_NONE);
		return value;
	}

	public var useBlurCloseExponentialShadowMap(get, set):Bool;
	inline private function get_useBlurCloseExponentialShadowMap():Bool {
		return this.filter == ShadowGenerator.FILTER_BLURCLOSEEXPONENTIALSHADOWMAP;
	}
	inline private function set_useBlurCloseExponentialShadowMap(value:Bool):Bool {
		if (!value && this.filter != ShadowGenerator.FILTER_BLURCLOSEEXPONENTIALSHADOWMAP) {
            return value;
        } 
		this.filter = (value ? ShadowGenerator.FILTER_BLURCLOSEEXPONENTIALSHADOWMAP : ShadowGenerator.FILTER_NONE);
		return value;
	}

	private var _darkness:Float = 0;
	/**
	 * Returns the darkness value (float).  
	 */
	inline public function getDarkness():Float {
		return this._darkness;
	}
	/**
	 * Sets the ShadowGenerator darkness value (float <= 1.0).  
	 * Returns the ShadowGenerator.  
	 */
	public function setDarkness(darkness:Float):ShadowGenerator {
		if (darkness >= 1.0) {
			this._darkness = 1.0;
		}
		else if (darkness <= 0.0) {
			this._darkness = 0.0;
		}
		else {
			this._darkness = darkness;
		}
		return this;
	}
	
	private var _transparencyShadow:Bool = false;
	/**
	 * Sets the ability to have transparent shadow (boolean).  
	 * Returns the ShadowGenerator.  
	 */
	inline public function setTransparencyShadow(hasShadow:Bool):ShadowGenerator {
		this._transparencyShadow = hasShadow;
		return this;
	}

	private var _shadowMap:RenderTargetTexture;
	private var _shadowMap2:RenderTargetTexture;
	/**
	 * Returns a RenderTargetTexture object : the shadow map texture.  
	 */
	inline public function getShadowMap():RenderTargetTexture {
		return this._shadowMap;
	}
	/**
	 * Returns the most ready computed shadow map as a RenderTargetTexture object.  
	 */
	public function getShadowMapForRendering():RenderTargetTexture {
		if (this._shadowMap2 != null) {
			return this._shadowMap2;
		}
		
		return this._shadowMap;
	}
	
	/**
	 * Controls the extent to which the shadows fade out at the edge of the frustum
     * Used only by directionals and spots
	*/
    public var frustumEdgeFalloff:Float = 0; 

	private var _light:IShadowLight;
	/**
	 * Returns the associated light object.  
	 */
	inline public function getLight():IShadowLight {
		return this._light;
	}

	public var forceBackFacesOnly:Bool = false;

	private var _scene:Scene;
	private var _lightDirection:Vector3 = Vector3.Zero();

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
	private var _kernelBlurXPostprocess:PostProcess;
	private var _kernelBlurYPostprocess:PostProcess;
	private var _blurPostProcesses:Array<PostProcess>;
	private var _mapSize:Int;
	private var _currentFaceIndex:Int = 0;
	private var _currentFaceIndexCache:Int = 0;
	private var _textureType:Int;
	private var _isCube:Bool = false;
	private var _defaultTextureMatrix:Matrix = Matrix.Identity();


	/**
	 * Creates a ShadowGenerator object.  
	 * A ShadowGenerator is the required tool to use the shadows.  
	 * Each light casting shadows needs to use its own ShadowGenerator.  
	 * Required parameters : 
	 * -  `mapSize` (integer), the size of the texture what stores the shadows. Example : 1024.    
	 * - `light` : the light object generating the shadows.
	 * - `useFullFloatFirst`: by default the generator will try to use half float textures but if you need precision (for self shadowing for instance), you can use this option to enforce full float texture.
	 * Documentation : http://doc.babylonjs.com/tutorials/shadows  
	 */
	public function new(mapSize:Int, light:IShadowLight, useFullFloatFirst:Bool = false) {
		this._mapSize = mapSize;
		this._light = light;
		this._scene = light.getScene();
		light._shadowGenerator = this;
		
		// Texture type fallback from float to int if not supported.
		var caps = this._scene.getEngine().getCaps();
		
		if (!useFullFloatFirst) {
			if (caps.textureHalfFloatRender && caps.textureHalfFloatLinearFiltering) {
				this._textureType = Engine.TEXTURETYPE_HALF_FLOAT;
			}
			else if (caps.textureFloatRender && caps.textureFloatLinearFiltering) {
				this._textureType = Engine.TEXTURETYPE_FLOAT;
			}
			else {
				this._textureType = Engine.TEXTURETYPE_UNSIGNED_INT;
			}
		} 
		else {
			if (caps.textureFloatRender && caps.textureFloatLinearFiltering) {
				this._textureType = Engine.TEXTURETYPE_FLOAT;
			}
			else if (caps.textureHalfFloatRender && caps.textureHalfFloatLinearFiltering) {
				this._textureType = Engine.TEXTURETYPE_HALF_FLOAT;
			}
			else {
				this._textureType = Engine.TEXTURETYPE_UNSIGNED_INT;
			}
		}
		
		this._initializeGenerator();
	}

	private function _initializeGenerator() {
		this._light._markMeshesAsLightDirty();
		this._initializeShadowMap();
	}

	private function _initializeShadowMap() {
		// Render target
		this._shadowMap = new RenderTargetTexture(this._light.name + "_shadowMap", this._mapSize, this._scene, false, true, this._textureType, this._light.needCube());
		this._shadowMap.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._shadowMap.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._shadowMap.anisotropicFilteringLevel = 1;
		this._shadowMap.updateSamplingMode(Texture.BILINEAR_SAMPLINGMODE);
		this._shadowMap.renderParticles = false;
		
		// Record Face Index before render.
		this._shadowMap.onBeforeRenderObservable.add(function(faceIndex:Int, _) {
			this._currentFaceIndex = faceIndex;
		});
		
		// Custom render function.
		this._shadowMap.customRenderFunction = this._renderForShadowMap;
		
		// Blur if required afer render.
		this._shadowMap.onAfterUnbindObservable.add(function(_, _) {
			if (!this.useBlurExponentialShadowMap && !this.useBlurCloseExponentialShadowMap) {
				return;
			}
			
			if (this._blurPostProcesses == null) {
				this._initializeBlurRTTAndPostProcesses();
			}
			
			this._scene.postProcessManager.directRender(this._blurPostProcesses, this.getShadowMapForRendering().getInternalTexture());
		});
		
		// Clear according to the chosen filter.
		this._shadowMap.onClearObservable.add(function(engine:Engine, _) {
			if (this.useExponentialShadowMap || this.useBlurExponentialShadowMap) {
				engine.clear(new Color4(0, 0, 0, 0), true, true, true);
			}
			else {
				engine.clear(new Color4(1.0, 1.0, 1.0, 1.0), true, true, true);
			}
		});
	}

	private function _initializeBlurRTTAndPostProcesses() {
		var engine = this._scene.getEngine();
		var targetSize = Std.int(this._mapSize / this.blurScale);
		
		if (!this.useKernelBlur || this.blurScale != 1.0) {
			this._shadowMap2 = new RenderTargetTexture(this._light.name + "_shadowMap2", targetSize, this._scene, false, true, this._textureType);
			this._shadowMap2.wrapU = Texture.CLAMP_ADDRESSMODE;
			this._shadowMap2.wrapV = Texture.CLAMP_ADDRESSMODE;
			this._shadowMap2.updateSamplingMode(Texture.BILINEAR_SAMPLINGMODE);
		}
		
		if (this.useKernelBlur) {
			this._kernelBlurXPostprocess = new BlurPostProcess(this._light.name + "KernelBlurX", new Vector2(1, 0), this.blurKernel, 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._textureType);
			this._kernelBlurXPostprocess.width = targetSize;
			this._kernelBlurXPostprocess.height = targetSize;
			this._kernelBlurXPostprocess.onApplyObservable.add(function(effect:Effect, _) {
				effect.setTexture("textureSampler", this._shadowMap);
			});
			
			this._kernelBlurYPostprocess = new BlurPostProcess(this._light.name + "KernelBlurY", new Vector2(0, 1), this.blurKernel, 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, this._textureType);
			
			this._kernelBlurXPostprocess.autoClear = false;
			this._kernelBlurYPostprocess.autoClear = false;
			
			this._blurPostProcesses = [this._kernelBlurXPostprocess, this._kernelBlurYPostprocess];
		}
		else {
			this._boxBlurPostprocess = new PostProcess(this._light.name + "DepthBoxBlur", "depthBoxBlur", ["screenSize", "boxOffset"], [], 1.0, null, Texture.BILINEAR_SAMPLINGMODE, engine, false, "#define OFFSET " + this._blurBoxOffset, this._textureType);
			this._boxBlurPostprocess.onApplyObservable.add(function(effect:Effect, _) {
				effect.setFloat2("screenSize", targetSize, targetSize);
				effect.setTexture("textureSampler", this._shadowMap);
			});
			
			this._boxBlurPostprocess.autoClear = false;
			
			this._blurPostProcesses = [this._boxBlurPostprocess];
		}
	}

	private function _renderForShadowMap(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>, transparentSubMeshes:SmartArray<SubMesh>) {
		for (index in 0...opaqueSubMeshes.length) {
			this._renderSubMeshForShadowMap(opaqueSubMeshes.data[index]);
		}
		
		for (index in 0...alphaTestSubMeshes.length) {
			this._renderSubMeshForShadowMap(alphaTestSubMeshes.data[index]);
		}
		
		if (this._transparencyShadow) {
			for (index in 0...transparentSubMeshes.length) {
				this._renderSubMeshForShadowMap(transparentSubMeshes.data[index]);
			}
		}
	}

	private function _renderSubMeshForShadowMap(subMesh:SubMesh) {
		var mesh = subMesh.getRenderingMesh();
		var scene = this._scene;
		var engine = scene.getEngine();
		
		// Culling
		engine.setState(subMesh.getMaterial().backFaceCulling);
		
		// Managing instances
		var batch = mesh._getInstancesRenderList(subMesh._id);
		if (batch.mustReturn) {
			return;
		}
		
		var hardwareInstancedRendering = (engine.getCaps().instancedArrays) && (batch.visibleInstances[subMesh._id] != null) && (batch.visibleInstances[subMesh._id] != null);
		if (this.isReady(subMesh, hardwareInstancedRendering)) {
			engine.enableEffect(this._effect);
			mesh._bind(subMesh, this._effect, Material.TriangleFillMode);
			var material = subMesh.getMaterial();
			
			this._effect.setFloat2("biasAndScale", this.bias, this.depthScale);
			
			this._effect.setMatrix("viewProjection", this.getTransformMatrix());
			this._effect.setVector3("lightPosition", this.getLight().position);
			
			this._effect.setFloat2("depthValues", this.getLight().getDepthMinZ(scene.activeCamera), this.getLight().getDepthMinZ(scene.activeCamera) + this.getLight().getDepthMaxZ(scene.activeCamera));
			
			// Alpha test
			if (material != null && material.needAlphaTesting()) {
				var alphaTexture = material.getAlphaTestTexture();
				if (alphaTexture != null) {
					this._effect.setTexture("diffuseSampler", alphaTexture);
					this._effect.setMatrix("diffuseMatrix", alphaTexture.getTextureMatrix() != null ? alphaTexture.getTextureMatrix() : this._defaultTextureMatrix);
				}
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
				function(_, world:Matrix, _) { this._effect.setMatrix("world", world); });
				
			if (this.forceBackFacesOnly) {
				engine.setState(true, 0, false, false);
			}
		} 
		else {
			// Need to reset refresh rate of the shadowMap
			this._shadowMap.resetRefreshCounter();
		}
	}

	private function _applyFilterValues() {
		if (this.filter == ShadowGenerator.FILTER_NONE) {
			this._shadowMap.updateSamplingMode(Texture.NEAREST_SAMPLINGMODE);
		} 
		else {
			this._shadowMap.updateSamplingMode(Texture.BILINEAR_SAMPLINGMODE);
		}
	}
	
	/**
	 * Force shader compilation including textures ready check
	 */
	var checkReady:Void->Void;
	public function forceCompilation(onCompiled:ShadowGenerator->Void, useInstances:Bool = false) {
		var scene = this._scene;
		var engine = scene.getEngine();
		var subMeshes:Array<SubMesh> = [];
		var currentIndex:Int = 0;
		
		for (mesh in this.getShadowMap().renderList) {
			for (m in mesh.subMeshes) {
				subMeshes.push(m);
			}
		}
		
		checkReady = function() {
			if (this._scene == null || this._scene.getEngine() == null) {
                return;
            }
			
			var subMesh = subMeshes[currentIndex];
			
			if (this.isReady(subMesh, useInstances)) {
				currentIndex++;
				if (currentIndex >= subMeshes.length) {
					if (onCompiled != null) {
						onCompiled(this);
					}
					return;
				}
			}
			Timer.delay(checkReady, 16);
		};
		
		if (subMeshes.length > 0) {
			checkReady();
		}
	}

	/**
	 * Boolean : true when the ShadowGenerator is finally computed.  
	 */
	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var defines:Array<String> = [];
		
		if (this._textureType != Engine.TEXTURETYPE_UNSIGNED_INT) {
			defines.push("#define FLOAT");
		}
		
		if (this.useExponentialShadowMap || this.useBlurExponentialShadowMap) {
			defines.push("#define ESM");
		}
		
		var attribs = [VertexBuffer.PositionKind];
		
		var mesh = subMesh.getMesh();
		var material = subMesh.getMaterial();
		
		// Alpha test
		if (material != null && material.needAlphaTesting()) {
			var alphaTexture = material.getAlphaTestTexture();
			if (alphaTexture != null) {
				defines.push("#define ALPHATEST");
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					attribs.push(VertexBuffer.UVKind);
					defines.push("#define UV1");
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					if (alphaTexture.coordinatesIndex == 1) {
						attribs.push(VertexBuffer.UV2Kind);
						defines.push("#define UV2");
					}
				}
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
				["world", "mBones", "viewProjection", "diffuseMatrix", "lightPosition", "depthValues", "biasAndScale"],
				["diffuseSampler"], join);
		}
		
		return this._effect.isReady();
	}

	/**
	 * This creates the defines related to the standard BJS materials.
	 */
	public function prepareDefines(defines:MaterialDefines, lightIndex:Int) {
		var scene = this._scene;
		var light = this._light;
		
		if (!scene.shadowsEnabled || !light.shadowEnabled) {
			return;
		}
		
		defines.shadows[lightIndex] = true;
		
		if (this.usePoissonSampling) {
			defines.shadowpcf[lightIndex] = true;
		} 
		else if (this.useExponentialShadowMap || this.useBlurExponentialShadowMap) {
			defines.shadowesm[lightIndex] = true;
		}
		else if (this.useCloseExponentialShadowMap || this.useBlurCloseExponentialShadowMap) {
			defines.shadowcloseesm[lightIndex] = true;
		}
		
		if (light.needCube()) {
			defines.shadowqube[lightIndex] = true;
		}
		
		//trace(defines);
	}

	/**
	 * This binds shadow lights related to the standard BJS materials.
	 * It implies the unifroms available on the materials are the standard BJS ones.
	 */
	public function bindShadowLight(lightIndex:String, effect:Effect) {
		var light = this._light;
		var scene = this._scene;
		
		if (!scene.shadowsEnabled || !light.shadowEnabled) {
			return;
		}
		
		if (!light.needCube()) {
			effect.setMatrix("lightMatrix" + lightIndex, this.getTransformMatrix());
		} 
		effect.setTexture("shadowSampler" + lightIndex, this.getShadowMapForRendering());
		light._uniformBuffer.updateFloat4("shadowsInfo", this.getDarkness(), this.blurScale / this.getShadowMap().getSize().width, this.depthScale, this.frustumEdgeFalloff, lightIndex);
		light._uniformBuffer.updateFloat2("depthValues", this.getLight().getDepthMinZ(scene.activeCamera), this.getLight().getDepthMinZ(scene.activeCamera) + this.getLight().getDepthMaxZ(scene.activeCamera), lightIndex);
	}

	// Methods
	/**
	 * Returns a Matrix object : the updated transformation matrix.  
	 */
	public function getTransformMatrix():Matrix {
		var scene = this._scene;
		if (this._currentRenderID == scene.getRenderId() && this._currentFaceIndexCache == this._currentFaceIndex) {
			return this._transformMatrix;
		}
		
		this._currentRenderID = scene.getRenderId();
		this._currentFaceIndexCache = this._currentFaceIndex;
		
		var lightPosition = this._light.position;
		if (this._light.computeTransformedInformation()) {
			lightPosition = this._light.transformedPosition;
		}
		
		Vector3.NormalizeToRef(this._light.getShadowDirection(this._currentFaceIndex), this._lightDirection);
		if (Math.abs(Vector3.Dot(this._lightDirection, Vector3.Up())) == 1.0) {
			this._lightDirection.z = 0.0000000000001; // Required to avoid perfectly perpendicular light
		}
		
		if (this._light.needProjectionMatrixCompute() || this._cachedPosition == null || this._cachedDirection == null || !lightPosition.equals(this._cachedPosition) || !this._lightDirection.equals(this._cachedDirection)) {
			
			this._cachedPosition = lightPosition.clone();
			this._cachedDirection = this._lightDirection.clone();
			
			Matrix.LookAtLHToRef(lightPosition, lightPosition.add(this._lightDirection), Vector3.Up(), this._viewMatrix);
			
			this._light.setShadowProjectionMatrix(this._projectionMatrix, this._viewMatrix, this.getShadowMap().renderList);
			
			this._viewMatrix.multiplyToRef(this._projectionMatrix, this._transformMatrix);
		}
		
		return this._transformMatrix;
	}

	public function recreateShadowMap() {
		// Track render list.
		var renderList = this._shadowMap.renderList;
		// Clean up existing data.
		this._disposeRTTandPostProcesses();
		// Reinitializes.
		this._initializeGenerator();
		// Reaffect the filter to ensure a correct fallback if necessary.
		this.filter = this.filter;
		// Reaffect the filter.
		this._applyFilterValues();
		// Reaffect Render List.
		this._shadowMap.renderList = renderList;
	}

	private function _disposeBlurPostProcesses() {
		if (this._shadowMap2 != null) {
			this._shadowMap2.dispose();
			this._shadowMap2 = null;
		}
		
		if (this._downSamplePostprocess != null) {
			this._downSamplePostprocess.dispose();
			this._downSamplePostprocess = null;
		}
		
		if (this._boxBlurPostprocess != null) {
			this._boxBlurPostprocess.dispose();
			this._boxBlurPostprocess = null;
		}
		
		if (this._kernelBlurXPostprocess != null) {
			this._kernelBlurXPostprocess.dispose();
			this._kernelBlurXPostprocess = null;
		}
		
		if (this._kernelBlurYPostprocess != null) {
			this._kernelBlurYPostprocess.dispose();
			this._kernelBlurYPostprocess = null;
		}
		
		this._blurPostProcesses = null;
	}

	private function _disposeRTTandPostProcesses() {
		if (this._shadowMap != null) {
			this._shadowMap.dispose();
			this._shadowMap = null;
		}
		
		this._disposeBlurPostProcesses();
	}

	/**
	 * Disposes the ShadowGenerator.  
	 * Returns nothing.  
	 */
	public function dispose() {
		this._disposeRTTandPostProcesses();
		
		this._light._shadowGenerator = null;
		this._light._markMeshesAsLightDirty();
	}
	
	/**
	 * Serializes the ShadowGenerator and returns a serializationObject.  
	 */
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		var shadowMap = this.getShadowMap();
		
		serializationObject.lightId = this._light.id;
		serializationObject.mapSize = shadowMap.getRenderSize();
		serializationObject.useExponentialShadowMap = this.useExponentialShadowMap;
		serializationObject.useBlurExponentialShadowMap = this.useBlurExponentialShadowMap;
		serializationObject.useCloseExponentialShadowMap = this.useBlurExponentialShadowMap;
		serializationObject.useBlurCloseExponentialShadowMap = this.useBlurExponentialShadowMap;
		serializationObject.usePoissonSampling = this.usePoissonSampling;
		serializationObject.forceBackFacesOnly = this.forceBackFacesOnly;
		serializationObject.depthScale = this.depthScale;
		serializationObject.darkness = this.getDarkness();
		serializationObject.blurBoxOffset = this.blurBoxOffset;
		serializationObject.blurKernel = this.blurKernel;
		serializationObject.blurScale = this.blurScale;
		serializationObject.useKernelBlur = this.useKernelBlur;
		serializationObject.transparencyShadow = this._transparencyShadow;
		
		serializationObject.renderList = [];
		for (meshIndex in 0...shadowMap.renderList.length) {
			var mesh = shadowMap.renderList[meshIndex];
			
			serializationObject.renderList.push(mesh.id);
		}
		
		return serializationObject;
	}
	/**
	 * Parses a serialized ShadowGenerator and returns a new ShadowGenerator.  
	 */
	public static function Parse(parsedShadowGenerator:Dynamic, scene:Scene):ShadowGenerator {
		//casting to point light, as light is missing the position attr and typescript complains.
		var light = scene.getLightByID(parsedShadowGenerator.lightId);
		var shadowGenerator = new ShadowGenerator(parsedShadowGenerator.mapSize, cast light);
		var shadowMap = shadowGenerator.getShadowMap();
		
		for (meshIndex in 0...parsedShadowGenerator.renderList.length) {
			var meshes = scene.getMeshesByID(parsedShadowGenerator.renderList[meshIndex]);
			for (mesh in meshes) {
				shadowMap.renderList.push(mesh);
			}
		}
		
		if (parsedShadowGenerator.usePoissonSampling == true) {
			shadowGenerator.usePoissonSampling = true;
		}
		else if (parsedShadowGenerator.useExponentialShadowMap == true) {
			shadowGenerator.useExponentialShadowMap = true;
		}
		else if (parsedShadowGenerator.useBlurExponentialShadowMap == true) {
			shadowGenerator.useBlurExponentialShadowMap = true;
		}
		else if (parsedShadowGenerator.useCloseExponentialShadowMap == true) {
			shadowGenerator.useCloseExponentialShadowMap = true;
		}
		else if (parsedShadowGenerator.useBlurExponentialShadowMap == true) {
			shadowGenerator.useBlurCloseExponentialShadowMap = true;
		}		
		// Backward compat
		else if (parsedShadowGenerator.useVarianceShadowMap == true) {
			shadowGenerator.useExponentialShadowMap = true;
		}
		else if (parsedShadowGenerator.useBlurVarianceShadowMap == true) {
			shadowGenerator.useBlurExponentialShadowMap = true;
		}
		
		if (parsedShadowGenerator.depthScale != null) {
			shadowGenerator.depthScale = parsedShadowGenerator.depthScale;
		}
		
		if (parsedShadowGenerator.blurScale != null) {
			shadowGenerator.blurScale = parsedShadowGenerator.blurScale;
		}
		
		if (parsedShadowGenerator.blurBoxOffset != null) {
			shadowGenerator.blurBoxOffset = parsedShadowGenerator.blurBoxOffset;
		}
		
		if (parsedShadowGenerator.useKernelBlur != null) {
			shadowGenerator.useKernelBlur = parsedShadowGenerator.useKernelBlur;
		}
		
		if (parsedShadowGenerator.blurKernel != null) {
			shadowGenerator.blurKernel = parsedShadowGenerator.blurKernel;
		}
		
		if (parsedShadowGenerator.bias != null) {
			shadowGenerator.bias = parsedShadowGenerator.bias;
		}
		
		if (parsedShadowGenerator.darkness != null) {
			shadowGenerator.setDarkness(parsedShadowGenerator.darkness);
		}
		
		if (parsedShadowGenerator.transparencyShadow != null) {
			shadowGenerator.setTransparencyShadow(true);
		}
		
		shadowGenerator.forceBackFacesOnly = parsedShadowGenerator.forceBackFacesOnly;
		
		return shadowGenerator;
	}
	
}
