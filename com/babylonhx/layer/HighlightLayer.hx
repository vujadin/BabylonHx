package com.babylonhx.layer;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Tools;
import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.postprocess.GlowBlurPostProcess;
import com.babylonhx.postprocess.BlurPostProcess;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.WebGLTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.cameras.Camera;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.ISize;

import lime.utils.Float32Array;
import lime.utils.Int32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The highlight layer Helps adding a glow effect around a mesh.
 * 
 * Once instantiated in a scene, simply use the pushMesh or removeMesh method to add or remove
 * glowy meshes to your scene.
 * 
 * !!! THIS REQUIRES AN ACTIVE STENCIL BUFFER ON THE CANVAS !!!
 */
class HighlightLayer {

	/**
	 * The neutral color used during the preparation of the glow effect.
	 * This is black by default as the blend operation is a blend operation. 
	 */
	public static var neutralColor:Color4 = new Color4(0, 0, 0, 0);

	/**
	 * Stencil value used for glowing meshes.
	 */
	public static var glowingMeshStencilReference:Int = 0x02;

	/**
	 * Stencil value used for the other meshes in the scene.
	 */
	public static var normalMeshStencilReference:Int = 0x01;

	private var _scene:Scene;
	private var _engine:Engine;
	private var _options:IHighlightLayerOptions;
	private var _vertexBuffers:Map<String, VertexBuffer> = new Map();
	private var _indexBuffer:WebGLBuffer;
	private var _downSamplePostprocess:PassPostProcess;
	private var _horizontalBlurPostprocess:PostProcess;
	private var _verticalBlurPostprocess:PostProcess;
	private var _cachedDefines:String;
	private var _glowMapGenerationEffect:Effect;
	private var _glowMapMergeEffect:Effect;      
	private var _blurTexture:RenderTargetTexture;
	@:allow(com.babylonhx.Scene)
	private var _mainTexture:RenderTargetTexture;
	private var _mainTextureDesiredSize = { width: 0, height: 0 };
	private var _meshes:Map<Int, IHighlightLayerMesh> = new Map();
	private var _maxSize:Int = 0;
	private var _shouldRender:Bool = false;
	private var _instanceGlowingMeshStencilReference:Int = HighlightLayer.glowingMeshStencilReference++;
	private var _excludedMeshes:Map<Int, IHighlightLayerExcludedMesh> = new Map();

	/**
	 * Specifies whether or not the inner glow is ACTIVE in the layer.
	 */
	public var innerGlow:Bool = true;
	
	/**
	 * Specifies whether or not the outer glow is ACTIVE in the layer.
	 */
	public var outerGlow:Bool = true;
	
	/**
     * Specifies wether the highlight layer is enabled or not.
     */
    public var isEnabled:Bool = true;
	
	public var camera(get, never):Camera;
	private function get_camera():Camera {
		return this._options.camera;
	}
	
	/**
	 * Specifies the horizontal size of the blur.
	 */
	public var blurHorizontalSize(get, set):Float;
	private function set_blurHorizontalSize(value:Float):Float {
		untyped return this._horizontalBlurPostprocess.kernel = value;
	}
	private function get_blurHorizontalSize():Float {
		untyped return this._horizontalBlurPostprocess.kernel;
	}

	/**
	 * Specifies the vertical size of the blur.
	 */
	public var blurVerticalSize(get, set):Float;
	private function set_blurVerticalSize(value:Float):Float {
		untyped return this._verticalBlurPostprocess.kernel = value;
	}
	private function get_blurVerticalSize():Float {
		untyped return this._verticalBlurPostprocess.kernel;
	}

	/**
	 * An event triggered when the highlight layer has been disposed.
	 * @type {Observable}
	 */
	public var onDisposeObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();

	/**
	 * An event triggered when the highlight layer is about rendering the main texture with the glowy parts.
	 * @type {Observable}
	 */
	public var onBeforeRenderMainTextureObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();

	/**
	 * An event triggered when the highlight layer is being blurred.
	 * @type {Observable}
	 */
	public var onBeforeBlurObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();
	
	/**
	 * An event triggered when the highlight layer has been blurred.
	 * @type {Observable}
	 */
	public var onAfterBlurObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();

	/**
	 * An event triggered when the glowing blurred texture is being merged in the scene.
	 * @type {Observable}
	 */
	public var onBeforeComposeObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();

	/**
	 * An event triggered when the glowing blurred texture has been merged in the scene.
	 * @type {Observable}
	 */
	public var onAfterComposeObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();

	/**
	 * An event triggered when the highlight layer changes its size.
	 * @type {Observable}
	 */
	public var onSizeChangedObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();
	

	/**
	 * Instantiates a new highlight Layer and references it to the scene..
	 * @param name The name of the layer
	 * @param scene The scene to use the layer in
	 * @param options Sets of none mandatory options to use with the layer (see IHighlightLayerOptions for more information)
	 */
	public function new(name:String, scene:Scene, ?options:Dynamic/*IHighlightLayerOptions*/) {
		this._scene = scene;
		var engine = scene.getEngine();
		this._engine = engine;
		this._maxSize = this._engine.getCaps().maxTextureSize;
		this._scene.highlightLayers.push(this);
		
		// Warn on stencil.
		if (!this._engine.isStencilEnable) {
			trace("Rendering the Highlight Layer requires the stencil to be active on the canvas. var engine = new Engine(canvas, antialias, { stencil: true }");
		}
		
		// Adapt options
		this._options = options != null ? options : {
			//camera: null,
			mainTextureRatio: 0.5,
			//mainTextureFixedSize: 512,
			blurTextureSizeRatio: 0.5,
			blurHorizontalSize: 1.0,
			blurVerticalSize: 1.0,
			alphaBlendingMode: Engine.ALPHA_COMBINE
		};
		if (this._options.mainTextureRatio == null) {
			this._options.mainTextureRatio = 0.5; 
		}
		if (this._options.blurTextureSizeRatio == null) {
			this._options.blurTextureSizeRatio = 1.0;
		}
		if (this._options.blurHorizontalSize == null) {
			this._options.blurHorizontalSize = 1;
		}
		if (this._options.blurVerticalSize == null) {
			this._options.blurVerticalSize = 1;
		}
		if (this._options.alphaBlendingMode == null) {
			this._options.alphaBlendingMode = Engine.ALPHA_COMBINE;
		}
		/*if (this._options.mainTextureFixedSize == null) {
			this._options.mainTextureFixedSize = 512;
		}*/
		
		// VBO
		var vertices:Float32Array = new Float32Array([
			 1,  1,
			-1,  1,
			-1, -1,
			 1, -1
		]);
		
		var vertexBuffer = new VertexBuffer(engine, vertices, VertexBuffer.PositionKind, false, false, 2);
		this._vertexBuffers[VertexBuffer.PositionKind] = vertexBuffer;
		
		// Indices
		var indices:Array<Int> = [];
		indices.push(0);
		indices.push(1);
		indices.push(2);
		indices.push(0);
		indices.push(2);
		indices.push(3);
		
		this._indexBuffer = engine.createIndexBuffer(new Int32Array(indices));
		
		// Effect
		this._glowMapMergeEffect = engine.createEffect("glowMapMerge",
			[VertexBuffer.PositionKind],
			["offset"],
			["textureSampler"], "");
		
		// Render target
		this.setMainTextureSize();
		
		// Create Textures and post processes
		this.createTextureAndPostProcesses();
	}

	/**
	 * Creates the render target textures and post processes used in the highlight layer.
	 */
	private function createTextureAndPostProcesses() {
		var blurTextureWidth:Int = Std.int(this._mainTextureDesiredSize.width * this._options.blurTextureSizeRatio);
		var blurTextureHeight:Int = Std.int(this._mainTextureDesiredSize.height * this._options.blurTextureSizeRatio);
		blurTextureWidth = this._engine.needPOTTextures ? Tools.GetExponentOfTwo(blurTextureWidth, this._maxSize) : blurTextureWidth;
		blurTextureHeight = this._engine.needPOTTextures ? Tools.GetExponentOfTwo(blurTextureHeight, this._maxSize) : blurTextureHeight;
		
		this._mainTexture = new RenderTargetTexture("HighlightLayerMainRTT", 
			{
				width: this._mainTextureDesiredSize.width,
				height: this._mainTextureDesiredSize.height
			}, 
			this._scene, 
			false, 
			true,
			Engine.TEXTURETYPE_UNSIGNED_INT);
		this._mainTexture.activeCamera = this._options.camera;
		this._mainTexture.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._mainTexture.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._mainTexture.anisotropicFilteringLevel = 1;
		this._mainTexture.updateSamplingMode(Texture.BILINEAR_SAMPLINGMODE);
		this._mainTexture.renderParticles = false;
		this._mainTexture.renderList = null;
		this._mainTexture.ignoreCameraViewport = true;
		
		this._blurTexture = new RenderTargetTexture("HighlightLayerBlurRTT",
			{
				width: blurTextureWidth,
				height: blurTextureHeight
			}, 
			this._scene, 
			false, 
			true,
			Engine.TEXTURETYPE_UNSIGNED_INT);
		this._blurTexture.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._blurTexture.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._blurTexture.anisotropicFilteringLevel = 16;
		this._blurTexture.updateSamplingMode(Texture.TRILINEAR_SAMPLINGMODE);
		this._blurTexture.renderParticles = false;
		this._blurTexture.ignoreCameraViewport = true;
		
		this._downSamplePostprocess = new PassPostProcess("HighlightLayerPPP", this._options.blurTextureSizeRatio, 
			null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine());
		this._downSamplePostprocess.onApplyObservable.add(function(effect:Effect, _) {
			effect.setTexture("textureSampler", this._mainTexture);
		});
		
		if (this._options.alphaBlendingMode == Engine.ALPHA_COMBINE) {
			this._horizontalBlurPostprocess = new GlowBlurPostProcess("HighlightLayerHBP", new Vector2(1.0, 0), this._options.blurHorizontalSize, 1,
				null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine());
			this._horizontalBlurPostprocess.onApplyObservable.add(function(effect:Effect, _) {
				effect.setFloat2("screenSize", blurTextureWidth, blurTextureHeight);
			});
			
			this._verticalBlurPostprocess = new GlowBlurPostProcess("HighlightLayerVBP", new Vector2(0, 1.0), this._options.blurVerticalSize, 1,
				null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine());
			this._verticalBlurPostprocess.onApplyObservable.add(function(effect:Effect, _) {
				effect.setFloat2("screenSize", blurTextureWidth, blurTextureHeight);
			});
		}
		else {
			this._horizontalBlurPostprocess = new BlurPostProcess("HighlightLayerHBP", new Vector2(1.0, 0), this._options.blurHorizontalSize, 1,
			null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine());
			this._horizontalBlurPostprocess.onApplyObservable.add(function(effect:Effect, _) {
				effect.setFloat2("screenSize", blurTextureWidth, blurTextureHeight);
			});
			
			this._verticalBlurPostprocess = new BlurPostProcess("HighlightLayerVBP", new Vector2(0, 1.0), this._options.blurVerticalSize, 1,
				null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine());
			this._verticalBlurPostprocess.onApplyObservable.add(function(effect:Effect, _) {
				effect.setFloat2("screenSize", blurTextureWidth, blurTextureHeight);
			});
		}
		
		this._mainTexture.onAfterUnbindObservable.add(function(_, _) {
			this.onBeforeBlurObservable.notifyObservers(this);
			
			this._scene.postProcessManager.directRender(
				[this._downSamplePostprocess, this._horizontalBlurPostprocess, this._verticalBlurPostprocess], 
				this._blurTexture.getInternalTexture(), true
			);
			
			this.onAfterBlurObservable.notifyObservers(this);
		});
		
		// Custom render function
		var renderSubMesh = function(subMesh:SubMesh) {
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
			
			// Excluded Mesh
            if (this._excludedMeshes[mesh.uniqueId] != null) {
                return;
            }
			
			var hardwareInstancedRendering = (engine.getCaps().instancedArrays) && (batch.visibleInstances[subMesh._id] != null) && (batch.visibleInstances[subMesh._id] != null);
			
			var highlightLayerMesh:IHighlightLayerMesh = this._meshes[mesh.uniqueId];
			var material = subMesh.getMaterial();
			var emissiveTexture:Texture = null;
			if (highlightLayerMesh != null && highlightLayerMesh.glowEmissiveOnly && material != null) {
				emissiveTexture = untyped material.emissiveTexture;
			}
			
			if (this.isReady(subMesh, hardwareInstancedRendering, emissiveTexture)) {
				engine.enableEffect(this._glowMapGenerationEffect);
				mesh._bind(subMesh, this._glowMapGenerationEffect, Material.TriangleFillMode);
				
				this._glowMapGenerationEffect.setMatrix("viewProjection", scene.getTransformMatrix());
				if (highlightLayerMesh != null) {
					this._glowMapGenerationEffect.setFloat4("color", 
						highlightLayerMesh.color.r,
						highlightLayerMesh.color.g,
						highlightLayerMesh.color.b,
						1.0);
				}
				else {
					this._glowMapGenerationEffect.setFloat4("color", 
						HighlightLayer.neutralColor.r,
						HighlightLayer.neutralColor.g,
						HighlightLayer.neutralColor.b,
						HighlightLayer.neutralColor.a);
				}
				
				// Alpha test
				if (material != null && material.needAlphaTesting()) {
					var alphaTexture = material.getAlphaTestTexture();
					
					if (alphaTexture != null) {
						this._glowMapGenerationEffect.setTexture("diffuseSampler", alphaTexture);
						this._glowMapGenerationEffect.setMatrix("diffuseMatrix", alphaTexture.getTextureMatrix());
					}
				}
				
				// Glow emissive only
				if (emissiveTexture != null) {
					this._glowMapGenerationEffect.setTexture("emissiveSampler", emissiveTexture);
					this._glowMapGenerationEffect.setMatrix("emissiveMatrix", emissiveTexture.getTextureMatrix());
				}
				
				// Bones
				if (mesh.useBones && mesh.computeBonesUsingShaders) {
					this._glowMapGenerationEffect.setMatrices("mBones", mesh.skeleton.getTransformMatrices(mesh));
				}
				
				// Draw
				mesh._processRendering(subMesh, this._glowMapGenerationEffect, Material.TriangleFillMode, batch, hardwareInstancedRendering,
					function(_, world:Matrix, _) { this._glowMapGenerationEffect.setMatrix("world", world); } );
			} 
			else {
				// Need to reset refresh rate of the shadowMap
				this._mainTexture.resetRefreshCounter();
			}
		};
		
		this._mainTexture.customRenderFunction = function(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>, transparentSubMeshes:SmartArray<SubMesh>) {
			this.onBeforeRenderMainTextureObservable.notifyObservers(this);
			
			for (index in 0...opaqueSubMeshes.length) {
				renderSubMesh(opaqueSubMeshes.data[index]);
			}
			
			for (index in 0...alphaTestSubMeshes.length) {
				renderSubMesh(alphaTestSubMeshes.data[index]);
			}
			
			for (index in 0...transparentSubMeshes.length) {
				renderSubMesh(transparentSubMeshes.data[index]);
			}
		};
		
		this._mainTexture.onClearObservable.add(function(engine:Engine, _) {
			engine.clear(HighlightLayer.neutralColor, true, true, true);
		});
	}

	/**
	 * Checks for the readiness of the element composing the layer.
	 * @param subMesh the mesh to check for
	 * @param useInstances specify wether or not to use instances to render the mesh
	 * @param emissiveTexture the associated emissive texture used to generate the glow
	 * @return true if ready otherwise, false
	 */
	private function isReady(subMesh:SubMesh, useInstances:Bool, emissiveTexture:Texture):Bool {
		if (!subMesh.getMaterial().isReady(subMesh.getMesh(), useInstances)) {
			return false;
		}
		
		var defines:Array<String> = [];
		
		var attribs:Array<String> = [VertexBuffer.PositionKind];
		
		var mesh = subMesh.getMesh();
		var material = subMesh.getMaterial();
		var uv1 = false;
		var uv2 = false;
		
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
			this._glowMapGenerationEffect = this._scene.getEngine().createEffect("glowMapGeneration",
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix", "color", "emissiveMatrix"],
				["diffuseSampler", "emissiveSampler"], join);
		}
		
		return this._glowMapGenerationEffect.isReady();
	}

	/**
	 * Renders the glowing part of the scene by blending the blurred glowing meshes on top of the rendered scene.
	 */
	public function render() {
		var currentEffect = this._glowMapMergeEffect;
		
		// Check
		if (!currentEffect.isReady() || !this._blurTexture.isReady()) {
			return;
		}
		
		var engine = this._scene.getEngine();
		
		this.onBeforeComposeObservable.notifyObservers(this);
		
		// Render
		engine.enableEffect(currentEffect);
		engine.setState(false);
		
		// Cache
		var previousStencilBuffer = engine.getStencilBuffer();
		var previousStencilFunction = engine.getStencilFunction();
		var previousStencilMask = engine.getStencilMask();
		var previousStencilOperationPass = engine.getStencilOperationPass();
		var previousStencilOperationFail = engine.getStencilOperationFail();
		var previousStencilOperationDepthFail = engine.getStencilOperationDepthFail(); 
		var previousAlphaMode = engine.getAlphaMode();
		
		// Texture
		currentEffect.setTexture("textureSampler", this._blurTexture);
		
		// VBOs
		engine.bindBuffers(this._vertexBuffers, this._indexBuffer, currentEffect);
		
		// Stencil operations
		engine.setStencilOperationPass(Engine.REPLACE);
		engine.setStencilOperationFail(Engine.KEEP);
		engine.setStencilOperationDepthFail(Engine.KEEP);
		
		// Draw order
		engine.setAlphaMode(this._options.alphaBlendingMode);
		engine.setStencilMask(0x00);
		engine.setStencilBuffer(true);
		engine.setStencilFunctionReference(this._instanceGlowingMeshStencilReference);
		
		if (this.outerGlow) {
			currentEffect.setFloat("offset", 0);
			engine.setStencilFunction(Engine.NOTEQUAL);
			engine.draw(true, 0, 6);
		}
		if (this.innerGlow) {
			currentEffect.setFloat("offset", 1);
			engine.setStencilFunction(Engine.EQUAL);
			engine.draw(true, 0, 6);
		}
		
		// Restore Cache
		engine.setStencilFunction(previousStencilFunction);
		engine.setStencilMask(previousStencilMask);
		engine.setAlphaMode(previousAlphaMode);
		engine.setStencilBuffer(previousStencilBuffer);
		engine.setStencilOperationPass(previousStencilOperationPass);
		engine.setStencilOperationFail(previousStencilOperationFail);
		engine.setStencilOperationDepthFail(previousStencilOperationDepthFail);
		
		engine._stencilState.reset();
		
		this.onAfterComposeObservable.notifyObservers(this);
		
		// Handle size changes.
		var size = this._mainTexture.getSize();
		this.setMainTextureSize();
		if (size.width != this._mainTextureDesiredSize.width || size.height != this._mainTextureDesiredSize.height) {
			// Recreate RTT and post processes on size change.
			this.onSizeChangedObservable.notifyObservers(this);
			this.disposeTextureAndPostProcesses();
			this.createTextureAndPostProcesses();
		}
	}
	
	/**
	 * Add a mesh in the exclusion list to prevent it to impact or being impacted by the highlight layer.
	 * @param mesh The mesh to exclude from the highlight layer
	 */
	public function addExcludedMesh(mesh:Mesh) {
		var meshExcluded = this._excludedMeshes[mesh.uniqueId];
		if (meshExcluded == null) {
			this._excludedMeshes[mesh.uniqueId] = {
				mesh: mesh,
				beforeRender: mesh.onBeforeRenderObservable.add(function(mesh:Mesh, _) {
					mesh.getEngine().setStencilBuffer(false);
				}),
				afterRender: mesh.onAfterRenderObservable.add(function(mesh:Mesh, _) {
					mesh.getEngine().setStencilBuffer(true);
				})
			}
		}
	}

	/**
	  * Remove a mesh from the exclusion list to let it impact or being impacted by the highlight layer.
	  * @param mesh The mesh to highlight
	  */
	public function removeExcludedMesh(mesh:Mesh) {
		var meshExcluded = this._excludedMeshes[mesh.uniqueId];
		if (meshExcluded != null) {
			mesh.onBeforeRenderObservable.remove(meshExcluded.beforeRender);
			mesh.onAfterRenderObservable.remove(meshExcluded.afterRender);
		}
		
		this._excludedMeshes[mesh.uniqueId] = null;
	}

	/**
	 * Add a mesh in the highlight layer in order to make it glow with the chosen color.
	 * @param mesh The mesh to highlight
	 * @param color The color of the highlight
	 * @param glowEmissiveOnly Extract the glow from the emissive texture
	 */
	public function addMesh(mesh:Mesh, color:Color3, glowEmissiveOnly:Bool = false) {
		var meshHighlight = this._meshes[mesh.uniqueId];
		if (meshHighlight != null) {
			meshHighlight.color = color;
		}
		else {
			this._meshes.set(mesh.uniqueId, {
				mesh: mesh,
				color: color,
				// Lambda required for capture due to Observable this context
				observerHighlight: mesh.onBeforeRenderObservable.add(function(mesh:Mesh, _) {
					if (this._excludedMeshes[mesh.uniqueId] != null) {
						this.defaultStencilReference(mesh, null);
					}
					else {
						mesh.getScene().getEngine().setStencilFunctionReference(this._instanceGlowingMeshStencilReference);
					}
				}),
				observerDefault: mesh.onAfterRenderObservable.add(this.defaultStencilReference),
				glowEmissiveOnly: glowEmissiveOnly
			});
		}

		this._shouldRender = true;
	}

	/**
	 * Remove a mesh from the highlight layer in order to make it stop glowing.
	 * @param mesh The mesh to highlight
	 */
	public function removeMesh(mesh:Mesh) {
		var meshHighlight = this._meshes[mesh.uniqueId];
		if (meshHighlight != null) {
			mesh.onBeforeRenderObservable.remove(meshHighlight.observerHighlight);
			mesh.onAfterRenderObservable.remove(meshHighlight.observerDefault);
		}
		
		this._meshes[mesh.uniqueId] = null;
		
		this._shouldRender = false;
		for (key in this._meshes.keys()) {
			if (this._meshes[key] != null) {
				this._shouldRender = true;
				break;
			}
		}
	}

	/**
	 * Returns true if the layer contains information to display, otherwise false.
	 */
	public function shouldRender():Bool {
		return this.isEnabled && this._shouldRender;
	}

	/**
	 * Sets the main texture desired size which is the closest power of two
	 * of the engine canvas size.
	 */
	private function setMainTextureSize() {
		if (this._options.mainTextureFixedSize != null) {
			this._mainTextureDesiredSize.width = this._options.mainTextureFixedSize;
			this._mainTextureDesiredSize.height = this._options.mainTextureFixedSize;
		}
		else {
			this._mainTextureDesiredSize.width = Std.int(this._engine.width * this._options.mainTextureRatio);
			this._mainTextureDesiredSize.height = Std.int(this._engine.height * this._options.mainTextureRatio);
			
			this._mainTextureDesiredSize.width = this._engine.needPOTTextures ? Tools.GetExponentOfTwo(this._mainTextureDesiredSize.width, this._maxSize) : this._mainTextureDesiredSize.width;
			this._mainTextureDesiredSize.height = this._engine.needPOTTextures ? Tools.GetExponentOfTwo(this._mainTextureDesiredSize.height, this._maxSize) : this._mainTextureDesiredSize.height;
		}
	}

	/**
	 * Force the stencil to the normal expected value for none glowing parts
	 */
	private function defaultStencilReference(mesh:Mesh, _) {
		mesh.getScene().getEngine().setStencilFunctionReference(HighlightLayer.normalMeshStencilReference);
	}

	/**
	 * Dispose only the render target textures and post process.
	 */
	private function disposeTextureAndPostProcesses() {
		this._blurTexture.dispose();
		this._mainTexture.dispose();
		
		this._downSamplePostprocess.dispose();
		this._horizontalBlurPostprocess.dispose();
		this._verticalBlurPostprocess.dispose();
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
		this.disposeTextureAndPostProcesses();
		
		// Clean mesh references 
		for (id in this._meshes.keys()) {
			var meshHighlight = this._meshes[id];
			if (meshHighlight != null && meshHighlight.mesh != null) {
				meshHighlight.mesh.onBeforeRenderObservable.remove(meshHighlight.observerHighlight);
				meshHighlight.mesh.onAfterRenderObservable.remove(meshHighlight.observerDefault);
			} 
		}
		this._meshes = null;
		
		for (id in this._excludedMeshes.keys()) {
			var meshHighlight = this._excludedMeshes[id];
			if (meshHighlight != null) {
				meshHighlight.mesh.onBeforeRenderObservable.remove(meshHighlight.beforeRender);
				meshHighlight.mesh.onAfterRenderObservable.remove(meshHighlight.afterRender);
			}
		}
		this._excludedMeshes = null;
		
		// Remove from scene
		var index = this._scene.highlightLayers.indexOf(this);
		if (index > -1) {
			this._scene.highlightLayers.splice(index, 1);
		}
		
		// Callback
		this.onDisposeObservable.notifyObservers(this);
		
		this.onDisposeObservable.clear();
		this.onBeforeRenderMainTextureObservable.clear();
		this.onBeforeBlurObservable.clear();
		this.onBeforeComposeObservable.clear();
		this.onAfterComposeObservable.clear();
		this.onSizeChangedObservable.clear();
	}
	
}
