package com.babylonhx.rendering;

import com.babylonhx.engine.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.MultiRenderTarget;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color4;
import com.babylonhx.tools.SmartArray;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GeometryBufferRenderer {

	private var _scene:Scene;
	private var _multiRenderTarget:MultiRenderTarget;
	private var _enablePosition:Bool = false;
	private var _ratio:Float;
	
	private var _effect:Effect;
	private var _cachedDefines:String;
	
	public var renderList(never, set):Array<Mesh>;
	/**
	 * Set the render list (meshes to be rendered) used in the G buffer.
	 */
	private function set_renderList(meshes:Array<Mesh>):Array<Mesh> {
		this._multiRenderTarget.renderList = cast meshes;
		return cast meshes;
	}

	public var isSupported(get, never):Bool;
	/**
	 * Gets wether or not G buffer are supported by the running hardware.
	 * This requires draw buffer supports
	 */
	private function get_isSupported():Bool {
		return this._multiRenderTarget.isSupported;
	}
	
	public var enablePosition(get, set):Bool;
	/**
	 * Gets wether or not position are enabled for the G buffer.
	 */
	inline private function get_enablePosition():Bool {
		return this._enablePosition;
	}
	/**
	 * Sets wether or not position are enabled for the G buffer.
	 */
	private function set_enablePosition(enable:Bool):Bool {
		this._enablePosition = enable;
		this.dispose();
		this._createRenderTargets();
		return enable;
	}

	/**
	 * Gets the scene associated with the buffer.
	 */
	public var scene(get, never):Scene;
	inline function get_scene():Scene {
		return this._scene;
	}

	/**
	 * Gets the ratio used by the buffer during its creation.
	 * How big is the buffer related to the main canvas.
	 */
	public var ratio(get, never):Float;
	inline function get_ratio():Float {
		return this._ratio;
	}


	/**
	 * Creates a new G Buffer for the scene. @see GeometryBufferRenderer
	 * @param scene The scene the buffer belongs to
	 * @param ratio How big is the buffer related to the main canvas.
	 */		
	public function new(scene:Scene, ratio:Float = 1) {
		this._scene = scene;
		this._ratio = ratio;
		
		// Render target
		this._createRenderTargets();
	}

	/**
	 * Checks wether everything is ready to render a submesh to the G buffer.
	 * @param subMesh the submesh to check readiness for
	 * @param useInstances is the mesh drawn using instance or not
	 * @returns true if ready otherwise false
	 */
	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var material:Material = subMesh.getMaterial();
		
		if (material != null && material.disableDepthWrite) {
			return false;
		}
		
		var defines:Array<String> = [];
		
		var attribs = [VertexBuffer.PositionKind, VertexBuffer.NormalKind];
		
		var mesh = subMesh.getMesh();
		var scene = mesh.getScene();
		
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
		
		// Buffers
		if (this._enablePosition) {
			defines.push("#define POSITION");
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
			defines.push("#define BonesPerMesh " + (mesh.skeleton != null ? mesh.skeleton.bones.length + 1 : 0));
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
			this._effect = this._scene.getEngine().createEffect("geometry",
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix", "view"],
				["diffuseSampler"], join,
				null, null, null,
                { buffersCount: this._enablePosition ? 3 : 2 });
		}
		
		return this._effect.isReady();
	}

	/**
	 * Gets the current underlying G Buffer.
	 * @returns the buffer
	 */
	inline public function getGBuffer():MultiRenderTarget {
		return this._multiRenderTarget;
	}
	
	public var samples(get, set):Int;
	/**
	 * Gets the number of samples used to render the buffer (anti aliasing).
	 */
	inline function get_samples():Int {
        return this._multiRenderTarget.samples;
    }
	/**
	 * Sets the number of samples used to render the buffer (anti aliasing).
	 */
    inline function set_samples(value:Int):Int {
        return this._multiRenderTarget.samples = value;
    }

	/**
	 * Disposes the renderer and frees up associated resources.
	 */
	public function dispose() {
		this.getGBuffer().dispose();
	}
	
	private function _createRenderTargets() {
		var engine = this._scene.getEngine();
		var count = this._enablePosition ? 3 : 2;
		
		// Render target
		this._multiRenderTarget = new MultiRenderTarget("gBuffer", { width: engine.getRenderWidth() * this._ratio, height: engine.getRenderHeight() * this._ratio }, count, this._scene, { generateMipMaps: false, generateDepthTexture: true, defaultType: Engine.TEXTURETYPE_FLOAT });
		if (!this.isSupported) {
			return;
		}
		this._multiRenderTarget.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._multiRenderTarget.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._multiRenderTarget.refreshRate = 1;
		this._multiRenderTarget.renderParticles = false;
		this._multiRenderTarget.renderList = null;
		
		// set default depth value to 1.0 (far away)
		this._multiRenderTarget.onClearObservable.add(function(engine:Engine, _) {
			engine.clear(new Color4(0.0, 0.0, 0.0, 1.0), true, true, true);
		});
		
		// Custom render function
		var renderSubMesh = function(subMesh:SubMesh) {
			var mesh = subMesh.getRenderingMesh();
			var scene = this._scene;
			var engine = scene.getEngine();
			var material = subMesh.getMaterial();
			
			if (material == null) {
				return;
			}
			
			// Culling
			engine.setState(material.backFaceCulling, 0, false, scene.useRightHandedSystem);
			
			// Managing instances
			var batch = mesh._getInstancesRenderList(subMesh._id);
			
			if (batch.mustReturn) {
				return;
			}
			
			var hardwareInstancedRendering = (engine.getCaps().instancedArrays) && (batch.visibleInstances[subMesh._id] != null);
			
			if (this.isReady(subMesh, hardwareInstancedRendering)) {
				engine.enableEffect(this._effect);
				mesh._bind(subMesh, this._effect, Material.TriangleFillMode);
				var material = subMesh.getMaterial();
				
				this._effect.setMatrix("viewProjection", scene.getTransformMatrix());
				this._effect.setMatrix("view", scene.getViewMatrix());
				
				// Alpha test
				if (material != null && material.needAlphaTesting()) {
					var alphaTexture = material.getAlphaTestTexture();
					
					if (alphaTexture != null) {
						this._effect.setTexture("diffuseSampler", alphaTexture);
						this._effect.setMatrix("diffuseMatrix", alphaTexture.getTextureMatrix());
					}
				}
				
				// Bones
				if (mesh.useBones && mesh.computeBonesUsingShaders && mesh.skeleton != null) {
					this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices(mesh));
				}
				
				// Draw
				mesh._processRendering(subMesh, this._effect, Material.TriangleFillMode, batch, hardwareInstancedRendering,
					function(_, world:Matrix, _) this._effect.setMatrix("world", world));
			}
		};
		
		this._multiRenderTarget.customRenderFunction = function(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>, transparentSubMeshes:SmartArray<SubMesh>, depthOnlySubMeshes:SmartArray<SubMesh>) {
			if (depthOnlySubMeshes.length > 0) {
                engine.setColorWrite(false);            
                for (index in 0...depthOnlySubMeshes.length) {
                    renderSubMesh(depthOnlySubMeshes.data[index]);
                }
                engine.setColorWrite(true);
            } 
			
			for (index in 0...opaqueSubMeshes.length) {
				renderSubMesh(opaqueSubMeshes.data[index]);
			}
			
			for (index in 0...alphaTestSubMeshes.length) {
				renderSubMesh(alphaTestSubMeshes.data[index]);
			}
		};
	}
	
}
