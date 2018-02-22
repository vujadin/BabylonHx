package com.babylonhx.layer;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Tools as MathTools;
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
import com.babylonhx.tools.Tools;

import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt32Array;

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
class HighlightLayer extends EffectLayer {
	
	/**
	 * Effect Name of the highlight layer.
	 */
	public static inline var EffectName:String = "HighlightLayer";

	/**
	 * The neutral color used during the preparation of the glow effect.
	 * This is black by default as the blend operation is a blend operation. 
	 */
	public static var NeutralColor:Color4 = new Color4(0, 0, 0, 0);

	/**
	 * Stencil value used for glowing meshes.
	 */
	public static var GlowingMeshStencilReference:Int = 0x02;

	/**
	 * Stencil value used for the other meshes in the scene.
	 */
	public static var NormalMeshStencilReference:Int = 0x01;

	/**
	 * Specifies whether or not the inner glow is ACTIVE in the layer.
	 */
	public var innerGlow:Bool = true;
	
	/**
	 * Specifies whether or not the outer glow is ACTIVE in the layer.
	 */
	public var outerGlow:Bool = true;
	
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
	 * An event triggered when the highlight layer is being blurred.
	 * @type {Observable}
	 */
	public var onBeforeBlurObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();
	
	/**
	 * An event triggered when the highlight layer has been blurred.
	 * @type {Observable}
	 */
	public var onAfterBlurObservable:Observable<HighlightLayer> = new Observable<HighlightLayer>();

	private var _instanceGlowingMeshStencilReference = HighlightLayer.GlowingMeshStencilReference++;
	
	private var _options:IHighlightLayerOptions;
	private var _downSamplePostprocess:PassPostProcess;
	private var _horizontalBlurPostprocess:PostProcess;
	private var _verticalBlurPostprocess:PostProcess;
	private var _blurTexture:RenderTargetTexture;

	private var _meshes:Map<Int, IHighlightLayerMesh> = new Map();
	private var _excludedMeshes:Map<Int, IHighlightLayerExcludedMesh> = new Map();
	

	/**
	 * Instantiates a new highlight Layer and references it to the scene..
	 * @param name The name of the layer
	 * @param scene The scene to use the layer in
	 * @param options Sets of none mandatory options to use with the layer (see IHighlightLayerOptions for more information)
	 */
	public function new(name:String, scene:Scene, ?options:IHighlightLayerOptions) {
		super(name, scene);
		this.neutralColor = HighlightLayer.NeutralColor;
		
		// Warn on stencil
		if (!this._engine.isStencilEnable) {
			Tools.Warn("Rendering the Highlight Layer requires the stencil to be active on the canvas. var engine = new BABYLON.Engine(canvas, antialias, { stencil: true }");
		}
		
		// Adapt options
		this._options = {
			mainTextureRatio: 0.5,
			blurTextureSizeRatio: 0.5,
			blurHorizontalSize: 1.0,
			blurVerticalSize: 1.0,
			alphaBlendingMode: Engine.ALPHA_COMBINE,
			camera: null
		};
		
		Tools.ExtendOptions(options, this._options);
		
		// Initialize the layer
		this._init({
			alphaBlendingMode: this._options.alphaBlendingMode,
			camera: this._options.camera,
			mainTextureFixedSize: this._options.mainTextureFixedSize,
			mainTextureRatio: this._options.mainTextureRatio
		});
		
		// Do not render as long as no meshes have been added
        this._shouldRender = false;
	}
	
	/**
	 * Get the effect name of the layer.
	 * @return The effect name
	 */ 
	override public function getEffectName():String {
		return HighlightLayer.EffectName;
	}

	/**
	 * Create the merge effect. This is the shader use to blit the information back
	 * to the main canvas at the end of the scene rendering.
	 */
	override public function _createMergeEffect():Effect {
		 // Effect
		 return this._engine.createEffect("glowMapMerge",
			[VertexBuffer.PositionKind],
			["offset"],
			["textureSampler"],
			this._options.isStroke ? "#define STROKE \n" : null);
	}

	/**
	 * Creates the render target textures and post processes used in the highlight layer.
	 */
	override public function _createTextureAndPostProcesses() {
		var blurTextureWidth:Int = Std.int(this._mainTextureDesiredSize.width * this._options.blurTextureSizeRatio);
		var blurTextureHeight:Int = Std.int(this._mainTextureDesiredSize.height * this._options.blurTextureSizeRatio);
		blurTextureWidth = this._engine.needPOTTextures ? MathTools.GetExponentOfTwo(blurTextureWidth, this._maxSize) : blurTextureWidth;
		blurTextureHeight = this._engine.needPOTTextures ? MathTools.GetExponentOfTwo(blurTextureHeight, this._maxSize) : blurTextureHeight;
		
		this._blurTexture = new RenderTargetTexture("HighlightLayerMainRTT", 
			{
				width: this._mainTextureDesiredSize.width,
				height: this._mainTextureDesiredSize.height
			}, 
			this._scene, 
			false, 
			true,
			Engine.TEXTURETYPE_UNSIGNED_INT);
		this._blurTexture.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._blurTexture.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._blurTexture.anisotropicFilteringLevel = 16;
		this._blurTexture.updateSamplingMode(Texture.BILINEAR_SAMPLINGMODE);
		this._blurTexture.renderParticles = false;
		this._blurTexture.ignoreCameraViewport = true;
		
		this._textures = [this._blurTexture];
		
		if (this._options.alphaBlendingMode == Engine.ALPHA_COMBINE) {
			this._downSamplePostprocess = new PassPostProcess("HighlightLayerPPP", this._options.blurTextureSizeRatio,
				null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine());
			this._downSamplePostprocess.onApplyObservable.add(function(effect:Effect, _) {
				effect.setTexture("textureSampler", this._mainTexture);
			});
			
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
			
			this._postProcesses = [this._downSamplePostprocess, this._horizontalBlurPostprocess, this._verticalBlurPostprocess];
		}
		else {
			this._horizontalBlurPostprocess = new BlurPostProcess("HighlightLayerHBP", new Vector2(1.0, 0), this._options.blurHorizontalSize / 2, {
					width:  blurTextureWidth,
					height: blurTextureHeight
				},
				null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, Engine.TEXTURETYPE_HALF_FLOAT);
			this._horizontalBlurPostprocess.width = blurTextureWidth;
			this._horizontalBlurPostprocess.height = blurTextureHeight;
			this._horizontalBlurPostprocess.onApplyObservable.add(function(effect:Effect, _) {
				effect.setTexture("textureSampler", this._mainTexture);
			});
			
			this._verticalBlurPostprocess = new BlurPostProcess("HighlightLayerVBP", new Vector2(0, 1.0), this._options.blurVerticalSize / 2, {
					width:  blurTextureWidth,
					height: blurTextureHeight
				},
				null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, Engine.TEXTURETYPE_HALF_FLOAT);
				
			this._postProcesses = [this._horizontalBlurPostprocess, this._verticalBlurPostprocess];
		}
		
		this._mainTexture.onAfterUnbindObservable.add(function(_, _) {
			this.onBeforeBlurObservable.notifyObservers(this);
			
			var internalTexture = this._blurTexture.getInternalTexture();
			if (internalTexture != null) {
				this._scene.postProcessManager.directRender(
					this._postProcesses,
					internalTexture, 
					true);
			}
			
			this.onAfterBlurObservable.notifyObservers(this);
		});
		
		// Prevent autoClear.
		this._postProcesses.map(function(pp) { pp.autoClear = false; });
	}

	/**
	 * Returns wether or nood the layer needs stencil enabled during the mesh rendering.
	 */
	override public function needStencil():Bool {
		return true;
	}

	/**
	 * Checks for the readiness of the element composing the layer.
	 * @param subMesh the mesh to check for
	 * @param useInstances specify wether or not to use instances to render the mesh
	 * @param emissiveTexture the associated emissive texture used to generate the glow
	 * @return true if ready otherwise, false
	 */
	override public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var material = subMesh.getMaterial();
		var mesh = subMesh.getRenderingMesh();
		
		if (material == null || mesh == null || this._meshes == null) {
			return false;
		}
		
		var emissiveTexture:Texture = null;
		var highlightLayerMesh = this._meshes[mesh.uniqueId];
		
		if (highlightLayerMesh != null && highlightLayerMesh.glowEmissiveOnly && material != null) {
			emissiveTexture = untyped material.emissiveTexture;
		}
		return this._isReady(subMesh, useInstances, emissiveTexture);
	}

	/**
	 * Implementation specific of rendering the generating effect on the main canvas.
	 * @param effect The effect used to render through
	 */
	override public function _internalRender(effect:Effect) {
		// Texture
		effect.setTexture("textureSampler", this._blurTexture);
		
		// Cache
		var engine = this._engine;
		var previousStencilBuffer = engine.getStencilBuffer();
		var previousStencilFunction = engine.getStencilFunction();
		var previousStencilMask = engine.getStencilMask();
		var previousStencilOperationPass = engine.getStencilOperationPass();
		var previousStencilOperationFail = engine.getStencilOperationFail();
		var previousStencilOperationDepthFail = engine.getStencilOperationDepthFail();
		var previousStencilReference = engine.getStencilFunctionReference();
		
		// Stencil operations
		engine.setStencilOperationPass(Engine.REPLACE);
		engine.setStencilOperationFail(Engine.KEEP);
		engine.setStencilOperationDepthFail(Engine.KEEP);
		
		// Draw order
		engine.setStencilMask(0x00);
		engine.setStencilBuffer(true);
		engine.setStencilFunctionReference(this._instanceGlowingMeshStencilReference);
		
		// 2 passes inner outer
		if (this.outerGlow) {
			effect.setFloat("offset", 0);
			engine.setStencilFunction(Engine.NOTEQUAL);
			engine.drawElementsType(Material.TriangleFillMode, 0, 6);
		}
		if (this.innerGlow) {
			effect.setFloat("offset", 1);
			engine.setStencilFunction(Engine.EQUAL);
			engine.drawElementsType(Material.TriangleFillMode, 0, 6);
		}
		
		// Restore Cache
		engine.setStencilFunction(previousStencilFunction);
		engine.setStencilMask(previousStencilMask);
		engine.setStencilBuffer(previousStencilBuffer);
		engine.setStencilOperationPass(previousStencilOperationPass);
		engine.setStencilOperationFail(previousStencilOperationFail);
		engine.setStencilOperationDepthFail(previousStencilOperationDepthFail);
		engine.setStencilFunctionReference(previousStencilReference);
	}
	
	/**
	 * Returns true if the layer contains information to display, otherwise false.
	 */
	override public function shouldRender():Bool {
		if (super.shouldRender()) {
			return this._meshes != null ? true : false;
		}
		
		return false;
	}

	/**
	 * Returns true if the mesh should render, otherwise false.
	 * @param mesh The mesh to render
	 * @returns true if it should render otherwise false
	 */
	override public function _shouldRenderMesh(mesh:Mesh):Bool {
		// Excluded Mesh
		if (this._excludedMeshes != null && this._excludedMeshes[mesh.uniqueId] != null) {
			return false;
		}
		
		return true;
	}

	/**
	 * Sets the required values for both the emissive texture and and the main color.
	 */
	override public function _setEmissiveTextureAndColor(mesh:Mesh, subMesh:SubMesh, material:Material) {
		var highlightLayerMesh = this._meshes[mesh.uniqueId];
		if (highlightLayerMesh != null) {
			this._emissiveTextureAndColor.color.set(
				highlightLayerMesh.color.r,
				highlightLayerMesh.color.g,
				highlightLayerMesh.color.b,
				1.0);
		}
		else {
			this._emissiveTextureAndColor.color.set(
				this.neutralColor.r,
				this.neutralColor.g,
				this.neutralColor.b,
				this.neutralColor.a);
		}
		
		if (highlightLayerMesh != null && highlightLayerMesh.glowEmissiveOnly && material != null) {
			this._emissiveTextureAndColor.texture = untyped material.emissiveTexture;
			this._emissiveTextureAndColor.color.set(
				1.0,
				1.0,
				1.0,
				1.0);
		}
		else {
			this._emissiveTextureAndColor.texture = null;
		}
	}
	
	/**
	 * Add a mesh in the exclusion list to prevent it to impact or being impacted by the highlight layer.
	 * @param mesh The mesh to exclude from the highlight layer
	 */
	public function addExcludedMesh(mesh:Mesh) {
		if (this._excludedMeshes == null) {
			return;
		}
		
		var meshExcluded = this._excludedMeshes[mesh.uniqueId];
		if (meshExcluded == null) {
			this._excludedMeshes[mesh.uniqueId] = {
				mesh: cast mesh,
				beforeRender: mesh.onBeforeRenderObservable.add(function(mesh:AbstractMesh, _) {
					mesh.getEngine().setStencilBuffer(false);
				}),
				afterRender: mesh.onAfterRenderObservable.add(function(mesh:AbstractMesh, _) {
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
		if (this._excludedMeshes == null) {
			return;
		}
		
		var meshExcluded = this._excludedMeshes[mesh.uniqueId];
		if (meshExcluded != null) {
			if (meshExcluded.beforeRender != null) {
				mesh.onBeforeRenderObservable.remove(meshExcluded.beforeRender);
			}
			
			if (meshExcluded.afterRender != null) {
				mesh.onAfterRenderObservable.remove(meshExcluded.afterRender);
			}
		}
		
		this._excludedMeshes[mesh.uniqueId] = null;
	}
	
	/**
	 * Determine if a given mesh will be highlighted by the current HighlightLayer
	 * @param mesh mesh to test
	 * @returns true if the mesh will be highlighted by the current HighlightLayer
	 */
	override public function hasMesh(mesh:AbstractMesh):Bool {
		if (this._meshes == null) {
			return false;
		}
		
		return this._meshes[mesh.uniqueId] != null;
	}

	/**
	 * Add a mesh in the highlight layer in order to make it glow with the chosen color.
	 * @param mesh The mesh to highlight
	 * @param color The color of the highlight
	 * @param glowEmissiveOnly Extract the glow from the emissive texture
	 */
	public function addMesh(mesh:Mesh, color:Color3, glowEmissiveOnly:Bool = false) {
		if (this._meshes == null) {
			return;
		}
		
		var meshHighlight = this._meshes[mesh.uniqueId];
		if (meshHighlight != null) {
			meshHighlight.color = color;
		}
		else {
			this._meshes.set(mesh.uniqueId, {
				mesh: cast mesh,
				color: color,
				// Lambda required for capture due to Observable this context
				observerHighlight: mesh.onBeforeRenderObservable.add(function(mesh:AbstractMesh, _) {
					if (this._excludedMeshes[mesh.uniqueId] != null) {
						this.defaultStencilReference(cast mesh, null);
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
		if (this._meshes == null) {
			return;
		}
		
		var meshHighlight = this._meshes[mesh.uniqueId];
		if (meshHighlight != null) {
			if (meshHighlight.observerHighlight != null) {
				mesh.onBeforeRenderObservable.remove(meshHighlight.observerHighlight);
			}
			
			if (meshHighlight.observerDefault != null) {
				mesh.onAfterRenderObservable.remove(meshHighlight.observerDefault);
			}
			
			this._meshes.remove(mesh.uniqueId);
		}
		
		this._shouldRender = false;
		for (key in this._meshes.keys()) {
			if (this._meshes[key] != null) {
				this._shouldRender = true;
				break;
			}
		}
	}
	
	/**
	 * Force the stencil to the normal expected value for none glowing parts
	 */
	private function defaultStencilReference(mesh:AbstractMesh, _) {
		mesh.getScene().getEngine().setStencilFunctionReference(HighlightLayer.NormalMeshStencilReference);
	}

	/**
	 * Free any resources and references associated to a mesh.
	 * Internal use
	 * @param mesh The mesh to free.
	 */
	override public function _disposeMesh(mesh:Mesh) {
		this.removeMesh(mesh);
		this.removeExcludedMesh(mesh);
	}

	/**
	 * Dispose the highlight layer and free resources.
	 */
	override public function dispose() {		
		if (this._meshes != null) {
			// Clean mesh references 
			for (id in this._meshes.keys()) {
				var meshHighlight = this._meshes[id];
				if (meshHighlight != null && meshHighlight.mesh != null) {
					if (meshHighlight.observerHighlight != null) {
						meshHighlight.mesh.onBeforeRenderObservable.remove(meshHighlight.observerHighlight);
					}
					
					if (meshHighlight.observerDefault != null) {
						meshHighlight.mesh.onAfterRenderObservable.remove(meshHighlight.observerDefault);
					}
				}
			}
			this._meshes = null;
		}
		
		if (this._excludedMeshes != null) {
			for (id in this._excludedMeshes.keys()) {
				var meshHighlight = this._excludedMeshes[id];
				if (meshHighlight != null) {
					if (meshHighlight.beforeRender != null) {
						meshHighlight.mesh.onBeforeRenderObservable.remove(meshHighlight.beforeRender);
					}
					
					if (meshHighlight.afterRender != null) {
						meshHighlight.mesh.onAfterRenderObservable.remove(meshHighlight.afterRender);
					}
				}
			}
			this._excludedMeshes = null;
		}
		
		super.dispose();		
	}
	
}
