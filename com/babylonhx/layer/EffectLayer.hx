package com.babylonhx.layer;

import com.babylonhx.cameras.Camera;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.materials.Effect;
import com.babylonhx.engine.Engine;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.math.Tools as MathTools;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color4;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.materials.Material;
import com.babylonhx.tools.ISize;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;

import com.babylonhx.utils.typedarray.UInt32Array;

/**
 * @author Krtolica Vujadin
 */
/**
 * The effect layer Helps adding post process effect blended with the main pass.
 * 
 * This can be for instance use to generate glow or higlight effects on the scene.
 * 
 * The effect layer class can not be used directly and is intented to inherited from to be 
 * customized per effects.
 */
class EffectLayer {
	
	public var name:String;

	private var _vertexBuffers:Map<String, VertexBuffer> = new Map();
	private var _indexBuffer:WebGLBuffer;
	private var _cachedDefines:String;
	private var _effectLayerMapGenerationEffect:Effect;
	private var _effectLayerOptions:IEffectLayerOptions;
	private var _mergeEffect:Effect;

	private var _scene:Scene;
	private var _engine:Engine;
	private var _maxSize:Int = 0;
	private var _mainTextureDesiredSize:ISize = { width: 0, height: 0 };
	@:allow(com.babylonhx.Scene)
	private var _mainTexture:RenderTargetTexture;
	private var _shouldRender:Bool = true;
	private var _postProcesses:Array<PostProcess> = [];
	private var _textures:Array<BaseTexture> = [];
	private var _emissiveTextureAndColor:Dynamic = { texture: null, color: new Color4() };

	/**
	 * The clear color of the texture used to generate the glow map.
	 */
	public var neutralColor:Color4 = new Color4();

	/**
	 * Specifies wether the highlight layer is enabled or not.
	 */
	public var isEnabled:Bool = true;

	public var camera(get, never):Camera;
	/**
	 * Gets the camera attached to the layer.
	 */
	inline function get_camera():Camera {
		return this._effectLayerOptions.camera;
	}

	/**
	 * An event triggered when the effect layer has been disposed.
	 */
	public var onDisposeObservable:Observable<EffectLayer> = new Observable<EffectLayer>();

	/**
	 * An event triggered when the effect layer is about rendering the main texture with the glowy parts.
	 */
	public var onBeforeRenderMainTextureObservable:Observable<EffectLayer> = new Observable<EffectLayer>();

	/**
	 * An event triggered when the generated texture is being merged in the scene.
	 */
	public var onBeforeComposeObservable:Observable<EffectLayer> = new Observable<EffectLayer>();

	/**
	 * An event triggered when the generated texture has been merged in the scene.
	 */
	public var onAfterComposeObservable:Observable<EffectLayer> = new Observable<EffectLayer>();

	/**
	 * An event triggered when the efffect layer changes its size.
	 */
	public var onSizeChangedObservable:Observable<EffectLayer> = new Observable<EffectLayer>();

	/**
	 * Instantiates a new effect Layer and references it in the scene.
	 * @param name The name of the layer
	 * @param scene The scene to use the layer in
	 */
	public function new(
		/** The friendly name of the effect in the scene */
		name:String, 
		scene:Scene) {
		this._scene = scene != null ? scene : Engine.LastCreatedScene;
		this._engine = scene.getEngine();
		this._maxSize = this._engine.getCaps().maxTextureSize;
		this._scene.effectLayers.push(this);
		
		// Generate Buffers
		this._generateIndexBuffer();
		this._genrateVertexBuffer();
	}

	/**
	 * Get the effect name of the layer.
	 * @return The effect name
	 */ 
	public function getEffectName():String {
		// to be overriden...
		return "";
	}

	/**
	 * Checks for the readiness of the element composing the layer.
	 * @param subMesh the mesh to check for
	 * @param useInstances specify wether or not to use instances to render the mesh
	 * @return true if ready otherwise, false
	 */ 
	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		// to be overriden...
		return true;
	}

	/**
	 * Returns wether or nood the layer needs stencil enabled during the mesh rendering.
	 * @returns true if the effect requires stencil during the main canvas render pass.
	 */
	public function needStencil():Bool {
		// to be overriden...
		return true;
	}

	/**
	 * Create the merge effect. This is the shader used to blit the information back
	 * to the main canvas at the end of the scene rendering.
	 * @returns The effect containing the shader used to merge the effect on the main canvas
	 */
	public function _createMergeEffect():Effect {
		// to be overriden...
		return null;
	}
	
	/**
	 * Creates the render target textures and post processes used in the effect layer.
	 */
	public function _createTextureAndPostProcesses() {
		// to be overriden...
	}
	
	/**
	 * Implementation specific of rendering the generating effect on the main canvas.
	 * @param effect The effect used to render through
	 */
	public function _internalRender(effect:Effect) {
		// to be overriden...
	}

	/**
	 * Sets the required values for both the emissive texture and and the main color.
	 */
	public function _setEmissiveTextureAndColor(mesh:Mesh, subMesh:SubMesh, material:Material) {
		// to be overriden...
	}

	/**
	 * Free any resources and references associated to a mesh.
	 * Internal use
	 * @param mesh The mesh to free.
	 */
	public function _disposeMesh(mesh:Mesh) {
		// to be overriden...
	}

	/**
	 * Initializes the effect layer with the required options.
	 * @param options Sets of none mandatory options to use with the layer (see IEffectLayerOptions for more information)
	 */
	public function _init(?options:IEffectLayerOptions) {
		// Adapt options
		this._effectLayerOptions = {
			mainTextureRatio: 0.5,
			alphaBlendingMode: Engine.ALPHA_COMBINE,
			camera: null
		};
		
		this._effectLayerOptions = Tools.ExtendOptions(options, this._effectLayerOptions);
		
		this._setMainTextureSize();
		this._createMainTexture();
		this._createTextureAndPostProcesses();
		this._mergeEffect = this._createMergeEffect();
	}

	/**
	 * Generates the index buffer of the full screen quad blending to the main canvas.
	 */
	private function _generateIndexBuffer() {
		// Indices
		var indices:Array<Int> = [];
		indices.push(0);
		indices.push(1);
		indices.push(2);
		
		indices.push(0);
		indices.push(2);
		indices.push(3);
		
		this._indexBuffer = this._engine.createIndexBuffer(new UInt32Array(indices));
	}

	/**
	 * Generates the vertex buffer of the full screen quad blending to the main canvas.
	 */
	private function _genrateVertexBuffer() {
		// VBO
		var vertices:Array<Float> = [];
		vertices.push(1);
		vertices.push(1);
		vertices.push( -1);
		vertices.push(1);
		vertices.push( -1);
		vertices.push(-1);
		vertices.push(1);
		vertices.push(-1);
		
		var vertexBuffer = new VertexBuffer(this._engine, vertices, VertexBuffer.PositionKind, false, false, 2);
		this._vertexBuffers[VertexBuffer.PositionKind] = vertexBuffer;
	}

	/**
	 * Sets the main texture desired size which is the closest power of two
	 * of the engine canvas size.
	 */
	private function _setMainTextureSize() {
		if (this._effectLayerOptions.mainTextureFixedSize != null) {
			this._mainTextureDesiredSize.width = this._effectLayerOptions.mainTextureFixedSize;
			this._mainTextureDesiredSize.height = this._effectLayerOptions.mainTextureFixedSize;
		}
		else {
			this._mainTextureDesiredSize.width = Std.int(this._engine.getRenderWidth() * this._effectLayerOptions.mainTextureRatio);
			this._mainTextureDesiredSize.height = Std.int(this._engine.getRenderHeight() * this._effectLayerOptions.mainTextureRatio);
			
			this._mainTextureDesiredSize.width = this._engine.needPOTTextures ? MathTools.GetExponentOfTwo(this._mainTextureDesiredSize.width, this._maxSize) : this._mainTextureDesiredSize.width;
			this._mainTextureDesiredSize.height = this._engine.needPOTTextures ? MathTools.GetExponentOfTwo(this._mainTextureDesiredSize.height, this._maxSize) : this._mainTextureDesiredSize.height;
		}
		
		this._mainTextureDesiredSize.width = Math.floor(this._mainTextureDesiredSize.width);
		this._mainTextureDesiredSize.height = Math.floor(this._mainTextureDesiredSize.height);
	}

	/**
	 * Creates the main texture for the effect layer.
	 */
	public function _createMainTexture() {
		this._mainTexture = new RenderTargetTexture("HighlightLayerMainRTT",
			{
				width: this._mainTextureDesiredSize.width,
				height: this._mainTextureDesiredSize.height
			},
			this._scene,
			false,
			true,
			Engine.TEXTURETYPE_UNSIGNED_INT);
		this._mainTexture.activeCamera = this._effectLayerOptions.camera;
		this._mainTexture.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._mainTexture.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._mainTexture.anisotropicFilteringLevel = 1;
		this._mainTexture.updateSamplingMode(Texture.BILINEAR_SAMPLINGMODE);
		this._mainTexture.renderParticles = false;
		this._mainTexture.renderList = null;
		this._mainTexture.ignoreCameraViewport = true;
		
		// Custom render function
		this._mainTexture.customRenderFunction = function(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>, transparentSubMeshes:SmartArray<SubMesh>, depthOnlySubMeshes:SmartArray<SubMesh>) {
			this.onBeforeRenderMainTextureObservable.notifyObservers(this);
			
			var engine = this._scene.getEngine();
			
			if (depthOnlySubMeshes.length > 0) {
				engine.setColorWrite(false);
				for (index in 0...depthOnlySubMeshes.length) {
					this._renderSubMesh(depthOnlySubMeshes.data[index]);
				}
				engine.setColorWrite(true);
			}
			
			for (index in 0...opaqueSubMeshes.length) {
				this._renderSubMesh(opaqueSubMeshes.data[index]);
			}
			
			for (index in 0...alphaTestSubMeshes.length) {
				this._renderSubMesh(alphaTestSubMeshes.data[index]);
			}
			
			for (index in 0...transparentSubMeshes.length) {
				this._renderSubMesh(transparentSubMeshes.data[index]);
			}
		};
		
		this._mainTexture.onClearObservable.add(function(engine:Engine, _) {
			engine.clear(this.neutralColor, true, true, true);
		});
	}

	/**
	 * Checks for the readiness of the element composing the layer.
	 * @param subMesh the mesh to check for
	 * @param useInstances specify wether or not to use instances to render the mesh
	 * @param emissiveTexture the associated emissive texture used to generate the glow
	 * @return true if ready otherwise, false
	 */
	public function _isReady(subMesh:SubMesh, useInstances:Bool, emissiveTexture:BaseTexture):Bool {
		var material = subMesh.getMaterial();
		
		if (material == null) {
			return false;
		}
		
		if (!material.isReady(subMesh.getMesh(), useInstances)) {
			return false;
		}
		
		var defines:Array<String> = [];
		
		var attribs = [VertexBuffer.PositionKind];
		
		var mesh:Mesh = cast subMesh.getMesh();
		var uv1:Bool = false;
		var uv2:Bool = false;
		
		// Alpha test
		if (material != null && material.needAlphaTesting()) {
			var alphaTexture = material.getAlphaTestTexture();
			if (alphaTexture != null) {
				defines.push("#define ALPHATEST");
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind) &&
					alphaTexture.coordinatesIndex == 1) {
					defines.push("#define DIFFUSEUV2");
					uv2 = true;
				}
				else if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					defines.push("#define DIFFUSEUV1");
					uv1 = true;
				}
			}
		}
		
		// Emissive
		if (emissiveTexture != null) {
			defines.push("#define EMISSIVE");
			if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind) &&
				emissiveTexture.coordinatesIndex == 1) {
				defines.push("#define EMISSIVEUV2");
				uv2 = true;
			}
			else if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
				defines.push("#define EMISSIVEUV1");
				uv1 = true;
			}
		}
		
		if (uv1) {
			attribs.push(VertexBuffer.UVKind);
			defines.push("#define UV1");
		}
		if (uv2) {
			attribs.push(VertexBuffer.UV2Kind);
			defines.push("#define UV2");
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
			defines.push("#define BonesPerMesh " + (mesh.skeleton != null ? (mesh.skeleton.bones.length + 1) : 0));
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
		var join:String = defines.join("\n");
		if (this._cachedDefines != join) {
			this._cachedDefines = join;
			this._effectLayerMapGenerationEffect = this._scene.getEngine().createEffect("glowMapGeneration",
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix", "color", "emissiveMatrix"],
				["diffuseSampler", "emissiveSampler"], join);
		}
		
		return this._effectLayerMapGenerationEffect.isReady();
	}

	/**
	 * Renders the glowing part of the scene by blending the blurred glowing meshes on top of the rendered scene.
	 */
	public function render() {
		var currentEffect = this._mergeEffect;
		
		// Check
		if (!currentEffect.isReady()) {
			return;
		}
		
		for (i in 0...this._postProcesses.length) {
			if (!this._postProcesses[i].isReady()) {
				return;
			}
		}
		
		var engine = this._scene.getEngine();
		
		this.onBeforeComposeObservable.notifyObservers(this);
		
		// Render
		engine.enableEffect(currentEffect);
		engine.setState(false);
		
		// VBOs
		engine.bindBuffers(this._vertexBuffers, this._indexBuffer, currentEffect);
		
		// Cache
		var previousAlphaMode = engine.getAlphaMode();
		
		// Go Blend.
		engine.setAlphaMode(this._effectLayerOptions.alphaBlendingMode);
		
		// Blends the map on the main canvas.
		this._internalRender(currentEffect);
		
		// Restore Alpha
		engine.setAlphaMode(previousAlphaMode);
		
		this.onAfterComposeObservable.notifyObservers(this);
		
		// Handle size changes.
		var size = this._mainTexture.getSize();
		this._setMainTextureSize();
		if (size.width != this._mainTextureDesiredSize.width || size.height != this._mainTextureDesiredSize.height) {
			// Recreate RTT and post processes on size change.
			this.onSizeChangedObservable.notifyObservers(this);
			this._disposeTextureAndPostProcesses();
			this._createMainTexture();
			this._createTextureAndPostProcesses();
		}
	}

	/**
	 * Determine if a given mesh will be used in the current effect.
	 * @param mesh mesh to test
	 * @returns true if the mesh will be used
	 */
	public function hasMesh(mesh:AbstractMesh):Bool {
		return true;
	}

	/**
	 * Returns true if the layer contains information to display, otherwise false.
	 * @returns true if the glow layer should be rendered
	 */
	public function shouldRender():Bool {
		return this.isEnabled && this._shouldRender;
	}

	/**
	 * Returns true if the mesh should render, otherwise false.
	 * @param mesh The mesh to render
	 * @returns true if it should render otherwise false
	 */
	public function _shouldRenderMesh(mesh:Mesh):Bool {
		return true;
	}

	/**
	 * Returns true if the mesh should render, otherwise false.
	 * @param mesh The mesh to render
	 * @returns true if it should render otherwise false
	 */
	public function _shouldRenderEmissiveTextureForMesh(mesh:Mesh):Bool {
		return true;
	}

	/**
	 * Renders the submesh passed in parameter to the generation map.
	 */
	public function _renderSubMesh(subMesh:SubMesh) {
		if (!this.shouldRender()) {
			return;
		}
		
		var material = subMesh.getMaterial();
		var mesh = subMesh.getRenderingMesh();
		var scene = this._scene;
		var engine = scene.getEngine();
		
		if (material == null) {
			return;
		}
		
		// Do not block in blend mode.
		if (material.needAlphaBlendingForMesh(mesh)) {
			return;
		}
		
		// Culling
		engine.setState(material.backFaceCulling);
		
		// Managing instances
		var batch = mesh._getInstancesRenderList(subMesh._id);
		if (batch.mustReturn) {
			return;
		}
		
		// Early Exit per mesh
		if (!this._shouldRenderMesh(mesh)) {
			return;
		}
		
		var hardwareInstancedRendering = (engine.getCaps().instancedArrays) && (batch.visibleInstances[subMesh._id] != null);
		
		this._setEmissiveTextureAndColor(mesh, subMesh, material);
		
		if (this._isReady(subMesh, hardwareInstancedRendering, this._emissiveTextureAndColor.texture)) {
			engine.enableEffect(this._effectLayerMapGenerationEffect);
			mesh._bind(subMesh, this._effectLayerMapGenerationEffect, Material.TriangleFillMode);
			
			this._effectLayerMapGenerationEffect.setMatrix("viewProjection", scene.getTransformMatrix());
			
			this._effectLayerMapGenerationEffect.setFloat4("color",
				this._emissiveTextureAndColor.color.r,
				this._emissiveTextureAndColor.color.g,
				this._emissiveTextureAndColor.color.b,
				this._emissiveTextureAndColor.color.a);
				
			// Alpha test
			if (material != null && material.needAlphaTesting()) {
				var alphaTexture = material.getAlphaTestTexture();
				if (alphaTexture != null) {
					this._effectLayerMapGenerationEffect.setTexture("diffuseSampler", alphaTexture);
					var textureMatrix = alphaTexture.getTextureMatrix();
					
					if (textureMatrix != null) {
						this._effectLayerMapGenerationEffect.setMatrix("diffuseMatrix", textureMatrix);
					}
				}
			}
			
			// Glow emissive only
			if (this._emissiveTextureAndColor.texture != null) {
				this._effectLayerMapGenerationEffect.setTexture("emissiveSampler", this._emissiveTextureAndColor.texture);
				this._effectLayerMapGenerationEffect.setMatrix("emissiveMatrix", this._emissiveTextureAndColor.texture.getTextureMatrix());
			}
			
			// Bones
			if (mesh.useBones && mesh.computeBonesUsingShaders && mesh.skeleton != null) {
				this._effectLayerMapGenerationEffect.setMatrices("mBones", mesh.skeleton.getTransformMatrices(mesh));
			}
			
			// Draw
			mesh._processRendering(subMesh, this._effectLayerMapGenerationEffect, Material.TriangleFillMode, batch, hardwareInstancedRendering,
				function(_, world:Matrix, _) { this._effectLayerMapGenerationEffect.setMatrix("world", world); });
		} 
		else {
			// Need to reset refresh rate of the shadowMap
			this._mainTexture.resetRefreshCounter();
		}
	}

	/**
	 * Rebuild the required buffers.
	 * @ignore Internal use only.
	 */
	public function _rebuild() {
		var vb = this._vertexBuffers[VertexBuffer.PositionKind];
		
		if (vb != null) {
			vb._rebuild();
		}
		
		this._generateIndexBuffer();
	}

	/**
	 * Dispose only the render target textures and post process.
	 */
	private function _disposeTextureAndPostProcesses() {
		this._mainTexture.dispose();
		
		for (i in 0...this._postProcesses.length) {
			if (this._postProcesses[i] != null) {
				this._postProcesses[i].dispose();
			}
		}
		this._postProcesses = [];
		
		for (i in 0...this._textures.length) {
			if (this._textures[i] != null) {
				this._textures[i].dispose();
			}
		}
		this._textures = [];
	}

	/**
	 * Dispose the highlight layer and free resources.
	 */
	public function dispose() {
		var vertexBuffer = this._vertexBuffers[VertexBuffer.PositionKind];
		if (vertexBuffer != null) {
			vertexBuffer.dispose();
			this._vertexBuffers[VertexBuffer.PositionKind] = null;
		}
		
		if (this._indexBuffer != null) {
			this._scene.getEngine()._releaseBuffer(this._indexBuffer);
			this._indexBuffer = null;
		}
		
		// Clean textures and post processes
		this._disposeTextureAndPostProcesses();
		
		// Remove from scene
		var index = this._scene.effectLayers.indexOf(this, 0);
		if (index > -1) {
			this._scene.effectLayers.splice(index, 1);
		}
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
		
		this.onDisposeObservable.clear();
		this.onBeforeRenderMainTextureObservable.clear();
		this.onBeforeComposeObservable.clear();
		this.onAfterComposeObservable.clear();
		this.onSizeChangedObservable.clear();
	}
	
}
