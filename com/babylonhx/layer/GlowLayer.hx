package com.babylonhx.layer;

import com.babylonhx.engine.Engine;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.BlurPostProcess;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Color4;
import com.babylonhx.tools.Tools;
import com.babylonhx.math.Tools as MathTools;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * The glow layer Helps adding a glow effect around the emissive parts of a mesh.
 * 
 * Once instantiated in a scene, simply use the pushMesh or removeMesh method to add or remove
 * glowy meshes to your scene.
 * 
 * Documentation: https://doc.babylonjs.com/how_to/glow_layer
 */
class GlowLayer extends EffectLayer {

	/**
	 * Effect Name of the layer.
	 */
	public static inline var EffectName:String = "GlowLayer";

	/**
	 * The default blur kernel size used for the glow.
	 */
	public static var DefaultBlurKernelSize:Float = 32;

	/**
	 * The default texture size ratio used for the glow.
	 */
	public static var DefaultTextureRatio:Float = 0.5;

	public var blurKernelSize(get, set):Float;
	/**
	 * Sets the kernel size of the blur.
	 */
	inline function set_blurKernelSize(value:Float):Float {
		this._horizontalBlurPostprocess1.kernel = value;
		this._verticalBlurPostprocess1.kernel = value;
		this._horizontalBlurPostprocess2.kernel = value;
		this._verticalBlurPostprocess2.kernel = value;
		return value;
	}
	/**
	 * Gets the kernel size of the blur.
	 */
	inline function get_blurKernelSize():Float {
		return this._horizontalBlurPostprocess1.kernel;
	}

	public var intensity(get, set):Float;
	/**
	 * Sets the glow intensity.
	 */
	inline function set_intensity(value:Float):Float {
		return this._intensity = value;
	}
	/**
	 * Gets the glow intensity.
	 */
	inline function get_intensity():Float {
		return this._intensity;
	}

	private var _options:IGlowLayerOptions;
	private var _intensity:Float = 1.0;
	private var _horizontalBlurPostprocess1:BlurPostProcess;
	private var _verticalBlurPostprocess1:BlurPostProcess;
	private var _horizontalBlurPostprocess2:BlurPostProcess;
	private var _verticalBlurPostprocess2:BlurPostProcess;
	private var _blurTexture1:RenderTargetTexture;
	private var _blurTexture2:RenderTargetTexture;
	private var _postProcesses1:Array<PostProcess>;
	private var _postProcesses2:Array<PostProcess>;

	private var _includedOnlyMeshes:Array<Int> = [];
	private var _excludedMeshes:Array<Int> = [];
	
	/**
     * Callback used to let the user override the color selection on a per mesh basis
     */
    public var customEmissiveColorSelector:Mesh->SubMesh->Material->Color4->Void;
    /**
     * Callback used to let the user override the texture selection on a per mesh basis
     */
    public var customEmissiveTextureSelector:Mesh->SubMesh->Material->Texture;
	

	/**
	 * Instantiates a new glow Layer and references it to the scene.
	 * @param name The name of the layer
	 * @param scene The scene to use the layer in
	 * @param options Sets of none mandatory options to use with the layer (see IGlowLayerOptions for more information)
	 */
	public function new(name:String, scene:Scene, ?options:IGlowLayerOptions) {
		super(name, scene);
		this.neutralColor = new Color4(0, 0, 0, 1);
		
		// Adapt options
		this._options = {
			mainTextureRatio: GlowLayer.DefaultTextureRatio,
			blurKernelSize: 32,
			mainTextureFixedSize: null,
			camera: null,
			mainTextureSamples: 1,
		};
		
		this._options = Tools.ExtendOptions(options, this._options);
		
		// Initialize the layer
		this._init({
			alphaBlendingMode: Engine.ALPHA_ADD,
			camera: this._options.camera,
			mainTextureFixedSize: this._options.mainTextureFixedSize,
			mainTextureRatio: this._options.mainTextureRatio
		});
	}

	/**
	 * Get the effect name of the layer.
	 * @return The effect name
	 */ 
	override public function getEffectName():String {
		return GlowLayer.EffectName;
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
			["textureSampler", "textureSampler2"],
			"#define EMISSIVE \n");
	}

	/**
	 * Creates the render target textures and post processes used in the glow layer.
	 */
	override public function _createTextureAndPostProcesses() {
		var blurTextureWidth = this._mainTextureDesiredSize.width;
		var blurTextureHeight = this._mainTextureDesiredSize.height;
		blurTextureWidth = this._engine.needPOTTextures ? MathTools.GetExponentOfTwo(blurTextureWidth, this._maxSize) : blurTextureWidth;
		blurTextureHeight = this._engine.needPOTTextures ? MathTools.GetExponentOfTwo(blurTextureHeight, this._maxSize) : blurTextureHeight;
		
		this._blurTexture1 = new RenderTargetTexture("GlowLayerBlurRTT",
			{
				width: blurTextureWidth,
				height: blurTextureHeight
			},
			this._scene,
			false,
			true,
			Engine.TEXTURETYPE_HALF_FLOAT);
		this._blurTexture1.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._blurTexture1.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._blurTexture1.updateSamplingMode(Texture.BILINEAR_SAMPLINGMODE);
		this._blurTexture1.renderParticles = false;
		this._blurTexture1.ignoreCameraViewport = true;
		
		var blurTextureWidth2 = Math.floor(blurTextureWidth / 2);
		var blurTextureHeight2 = Math.floor(blurTextureHeight / 2);
		
		this._blurTexture2 = new RenderTargetTexture("GlowLayerBlurRTT2",
			{
				width: blurTextureWidth2,
				height: blurTextureHeight2
			},
			this._scene,
			false,
			true,
			Engine.TEXTURETYPE_HALF_FLOAT);
		this._blurTexture2.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._blurTexture2.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._blurTexture2.updateSamplingMode(Texture.BILINEAR_SAMPLINGMODE);
		this._blurTexture2.renderParticles = false;
		this._blurTexture2.ignoreCameraViewport = true;
		
		this._textures = [this._blurTexture1, this._blurTexture2];
		
		this._horizontalBlurPostprocess1 = new BlurPostProcess("GlowLayerHBP1", new Vector2(1.0, 0), this._options.blurKernelSize / 2, {
				width:  blurTextureWidth,
				height: blurTextureHeight
			},
			null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, Engine.TEXTURETYPE_HALF_FLOAT);
		this._horizontalBlurPostprocess1.width = blurTextureWidth;
		this._horizontalBlurPostprocess1.height = blurTextureHeight;
		this._horizontalBlurPostprocess1.onApplyObservable.add(function(effect:Effect, _) {
			effect.setTexture("textureSampler", this._mainTexture);
		});
		
		this._verticalBlurPostprocess1 = new BlurPostProcess("GlowLayerVBP1", new Vector2(0, 1.0), this._options.blurKernelSize / 2, {
				width:  blurTextureWidth,
				height: blurTextureHeight
			},
			null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, Engine.TEXTURETYPE_HALF_FLOAT);
			
		this._horizontalBlurPostprocess2 = new BlurPostProcess("GlowLayerHBP2", new Vector2(1.0, 0), this._options.blurKernelSize / 2, {
				width:  blurTextureWidth2,
				height: blurTextureHeight2
			},
			null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, Engine.TEXTURETYPE_HALF_FLOAT);
		this._horizontalBlurPostprocess2.width = blurTextureWidth2;
		this._horizontalBlurPostprocess2.height = blurTextureHeight2;
		this._horizontalBlurPostprocess2.onApplyObservable.add(function(effect:Effect, _) {
			effect.setTexture("textureSampler", this._blurTexture1);
		});
		
		this._verticalBlurPostprocess2 = new BlurPostProcess("GlowLayerVBP2", new Vector2(0, 1.0), this._options.blurKernelSize / 2, {
				width:  blurTextureWidth2,
				height: blurTextureHeight2
			},
			null, Texture.BILINEAR_SAMPLINGMODE, this._scene.getEngine(), false, Engine.TEXTURETYPE_HALF_FLOAT);
			
		this._postProcesses = [this._horizontalBlurPostprocess1, this._verticalBlurPostprocess1, this._horizontalBlurPostprocess2, this._verticalBlurPostprocess2];
		this._postProcesses1 = [this._horizontalBlurPostprocess1, this._verticalBlurPostprocess1];
		this._postProcesses2 = [this._horizontalBlurPostprocess2, this._verticalBlurPostprocess2];
		
		this._mainTexture.samples = this._options.mainTextureSamples;
		this._mainTexture.onAfterUnbindObservable.add(function(_, _) {
			var internalTexture = this._blurTexture1.getInternalTexture();
			if (internalTexture != null) {
				this._scene.postProcessManager.directRender(
					this._postProcesses1,
					internalTexture, 
					true);
					
					internalTexture = this._blurTexture2.getInternalTexture();
					if (internalTexture != null) {
						this._scene.postProcessManager.directRender(
							this._postProcesses2,
							internalTexture, 
							true);
					}
			}
		});
		
		// Prevent autoClear.
		this._postProcesses.map(function(pp) { pp.autoClear = false; });
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
		
		if (material == null || mesh == null) {
			return false;
		}
		
		var emissiveTexture = untyped material.emissiveTexture;
		return super._isReady(subMesh, useInstances, emissiveTexture);
	}

	/**
	 * Returns wether or nood the layer needs stencil enabled during the mesh rendering.
	 */
	override public function needStencil():Bool {
		return false;
	}

	/**
	 * Implementation specific of rendering the generating effect on the main canvas.
	 * @param effect The effect used to render through
	 */
	override public function _internalRender(effect:Effect) {
		// Texture
		effect.setTexture("textureSampler", this._blurTexture1);
		effect.setTexture("textureSampler2", this._blurTexture2);
		effect.setFloat("offset", this._intensity);
		
		// Cache
		var engine = this._engine;
		var previousStencilBuffer = engine.getStencilBuffer();
		
		// Draw order
		engine.setStencilBuffer(false);
		
		engine.drawElementsType(Material.TriangleFillMode, 0, 6);
		
		// Draw order
		engine.setStencilBuffer(previousStencilBuffer);
	}

	/**
	 * Sets the required values for both the emissive texture and and the main color.
	 */
	override public function _setEmissiveTextureAndColor(mesh:Mesh, subMesh:SubMesh, material:Material) {
		var textureLevel = 1.0;
		
		if (this.customEmissiveTextureSelector != null) {
			this._emissiveTextureAndColor.texture = this.customEmissiveTextureSelector(mesh, subMesh, material);
		} 
		else {
			if (material != null) {
				this._emissiveTextureAndColor.texture = untyped material.emissiveTexture;
				if (this._emissiveTextureAndColor.texture != null) {
					textureLevel = this._emissiveTextureAndColor.texture.level;
				}
			}
			else {
				this._emissiveTextureAndColor.texture = null;
			}
		}
		
		if (this.customEmissiveColorSelector != null) {
			this.customEmissiveColorSelector(mesh, subMesh, material, this._emissiveTextureAndColor.color);
		} 
		else {
			if (untyped material.emissiveColor != null) {
				this._emissiveTextureAndColor.color.set(
					untyped material.emissiveColor.r * textureLevel,
					untyped material.emissiveColor.g * textureLevel,
					untyped material.emissiveColor .b * textureLevel,
					1.0);
			}
			else {
				this._emissiveTextureAndColor.color.set(
					this.neutralColor.r,
					this.neutralColor.g,
					this.neutralColor.b,
					this.neutralColor.a);
			}
		}
	}

	/**
	 * Returns true if the mesh should render, otherwise false.
	 * @param mesh The mesh to render
	 * @returns true if it should render otherwise false
	 */
	override public function _shouldRenderMesh(mesh:Mesh):Bool {
		return this.hasMesh(mesh);
	}

	/**
	 * Add a mesh in the exclusion list to prevent it to impact or being impacted by the glow layer.
	 * @param mesh The mesh to exclude from the glow layer
	 */
	public function addExcludedMesh(mesh:Mesh) {
		if (this._excludedMeshes.indexOf(mesh.uniqueId) == -1) {
			this._excludedMeshes.push(mesh.uniqueId);
		}
	}

	/**
	  * Remove a mesh from the exclusion list to let it impact or being impacted by the glow layer.
	  * @param mesh The mesh to remove
	  */
	public function removeExcludedMesh(mesh:Mesh) {
		var index = this._excludedMeshes.indexOf(mesh.uniqueId);
		if (index != -1) {
			this._excludedMeshes.splice(index, 1);
		} 
	}

	/**
	 * Add a mesh in the inclusion list to impact or being impacted by the glow layer.
	 * @param mesh The mesh to include in the glow layer
	 */
	public function addIncludedOnlyMesh(mesh:Mesh) {
		if (this._includedOnlyMeshes.indexOf(mesh.uniqueId) == -1) {
			this._includedOnlyMeshes.push(mesh.uniqueId);
		}
	}

	/**
	  * Remove a mesh from the Inclusion list to prevent it to impact or being impacted by the glow layer.
	  * @param mesh The mesh to remove
	  */
	public function removeIncludedOnlyMesh(mesh:Mesh) {
		var index = this._includedOnlyMeshes.indexOf(mesh.uniqueId);
		if (index != -1) {
			this._includedOnlyMeshes.splice(index, 1);
		} 
	}

	/**
	 * Determine if a given mesh will be used in the glow layer
	 * @param mesh The mesh to test
	 * @returns true if the mesh will be highlighted by the current glow layer
	 */
	override public function hasMesh(mesh:AbstractMesh):Bool {
		// Included Mesh
		if (this._includedOnlyMeshes.length > 0) {
			return this._includedOnlyMeshes.indexOf(mesh.uniqueId) != -1;
		}
		
		// Excluded Mesh
		if (this._excludedMeshes.length > 0) {
			return this._excludedMeshes.indexOf(mesh.uniqueId) == -1;
		}
		
		return true;
	}

	/**
	 * Free any resources and references associated to a mesh.
	 * Internal use
	 * @param mesh The mesh to free.
	 */
	override public function _disposeMesh(mesh:Mesh) {
		this.removeIncludedOnlyMesh(mesh);
		this.removeExcludedMesh(mesh);
	}
	
}
