package com.babylonhx.rendering;

import com.babylonhx.engine.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh._InstancesBatch;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.EventState;
import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * This represents a depth renderer in Babylon.
 * A depth renderer will render to it's depth map every frame which can be displayed or used in post processing
 */
@:expose('BABYLON.DepthRenderer') class DepthRenderer {
	
	private var _scene:Scene;
	private var _depthMap:RenderTargetTexture;
	private var _effect:Effect;

	private var _cachedDefines:String;
	private var _camera:Camera;
	

	/**
	 * Instantiates a depth renderer
	 * @param scene The scene the renderer belongs to
	 * @param type The texture type of the depth map (default: Engine.TEXTURETYPE_FLOAT)
	 * @param camera The camera to be used to render the depth map (default: scene's active camera)
	 */
	public function new(scene:Scene, type:Int = Engine.TEXTURETYPE_FLOAT, camera:Camera = null) {
		this._scene = scene;
		this._camera = camera;
		var engine = scene.getEngine();
		
		// Render target
		this._depthMap = new RenderTargetTexture("depthMap", { width: engine.getRenderWidth(), height: engine.getRenderHeight() }, this._scene, false, true, type);
		this._depthMap.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._depthMap.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._depthMap.refreshRate = 1;
		this._depthMap.renderParticles = false;
		this._depthMap.renderList = null;
		
		// Camera to get depth map from to support multiple concurrent cameras
		this._depthMap.activeCamera = this._camera;
		this._depthMap.ignoreCameraViewport = true;
		this._depthMap.useCameraPostProcesses = false;
		
		// set default depth value to 1.0 (far away)
		this._depthMap.onClearObservable.add(function(engine:Engine, _) {
			engine.clear(new Color4(1.0, 1.0, 1.0, 1.0), true, true, true);
		});
		
		// Custom render function
		var renderSubMesh = function(subMesh:SubMesh) {
			var mesh:Mesh = subMesh.getRenderingMesh();
			var scene = this._scene;
			var engine = scene.getEngine();
			var material = subMesh.getMaterial();
			
            if (material == null) {
                return;
            }
		 
			// Culling and reverse (right handed system)
			engine.setState(material.backFaceCulling, 0, false, scene.useRightHandedSystem);
			
			// Managing instances
			var batch:_InstancesBatch = mesh._getInstancesRenderList(subMesh._id);
			
			if (batch.mustReturn) {
				return;
			}
			
			var hardwareInstancedRendering:Bool = (engine.getCaps().instancedArrays) && (batch.visibleInstances[subMesh._id] != null);
			
			var camera = this._camera != null ? this._camera : scene.activeCamera;
			if (this.isReady(subMesh, hardwareInstancedRendering) && camera != null) {
				engine.enableEffect(this._effect);
				mesh._bind(subMesh, this._effect, Material.TriangleFillMode);
				
				this._effect.setMatrix("viewProjection", scene.getTransformMatrix());
				
				this._effect.setFloat2("depthValues", scene.activeCamera.minZ, scene.activeCamera.minZ + scene.activeCamera.maxZ);
				
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
					function(_, world:Matrix, _) { this._effect.setMatrix("world", world); } );
			}
		};
		
		this._depthMap.customRenderFunction = function(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>, transparentSubMeshes:SmartArray<SubMesh>, depthOnlySubMeshes:SmartArray<SubMesh>) {
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

	/**
	 * Creates the depth rendering effect and checks if the effect is ready.
	 * @param subMesh The submesh to be used to render the depth map of
	 * @param useInstances If multiple world instances should be used
	 * @returns if the depth renderer is ready to render the depth map
	 */
	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var material:Material = subMesh.getMaterial();
		if (material.disableDepthWrite) {
			return false;
		}
		
		var defines:Array<String> = [];
		
		var attribs = [VertexBuffer.PositionKind];
		
		var mesh = subMesh.getMesh();
		
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
		var join:String = defines.join("\n");
		if (this._cachedDefines != join) {
			this._cachedDefines = join;
			this._effect = this._scene.getEngine().createEffect("depth",
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix", "depthValues"],
				["diffuseSampler"], join);
		}
		
		return this._effect.isReady();
	}

	/**
	 * Gets the texture which the depth map will be written to.
	 * @returns The depth map texture
	 */
	public function getDepthMap():RenderTargetTexture {
		return this._depthMap;
	}

	/**
	 * Disposes of the depth renderer.
	 */
	public function dispose() {
		this._depthMap.dispose();
	}
	
}
