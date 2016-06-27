package com.babylonhx.rendering;

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

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.DepthRenderer') class DepthRenderer {
	
	private var _scene:Scene;
	private var _depthMap:RenderTargetTexture;
	private var _effect:Effect;

	private var _viewMatrix = Matrix.Zero();
	private var _projectionMatrix = Matrix.Zero();
	private var _transformMatrix = Matrix.Zero();
	private var _worldViewProjection = Matrix.Zero();

	private var _cachedDefines:String;
	

	public function new(scene:Scene, type:Int = Engine.TEXTURETYPE_FLOAT) {
		this._scene = scene;
		var engine = scene.getEngine();
		
		// Render target
		this._depthMap = new RenderTargetTexture("depthMap", { width: engine.getRenderWidth(), height: engine.getRenderHeight() }, this._scene, false, true, type);
		this._depthMap.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._depthMap.wrapV = Texture.CLAMP_ADDRESSMODE;
		this._depthMap.refreshRate = 1;
		this._depthMap.renderParticles = false;
		this._depthMap.renderList = null;
		
		// set default depth value to 1.0 (far away)
		this._depthMap.onClearObservable.add(function(engine:Engine, es:EventState = null) {
			engine.clear(new Color4(1.0, 1.0, 1.0, 1.0), true, true);
		});
		
		// Custom render function
		var renderSubMesh = function(subMesh:SubMesh) {
			var mesh:Mesh = subMesh.getRenderingMesh();
			var scene = this._scene;
			//var engine = scene.getEngine();
			
			// Culling
			engine.setState(subMesh.getMaterial().backFaceCulling);
			
			// Managing instances
			var batch:_InstancesBatch = mesh._getInstancesRenderList(subMesh._id);
			
			if (batch.mustReturn) {
				return;
			}
			
			var hardwareInstancedRendering:Bool = (engine.getCaps().instancedArrays != null) && (batch.visibleInstances[subMesh._id] != null);
			
			if (this.isReady(subMesh, hardwareInstancedRendering)) {
				engine.enableEffect(this._effect);
				mesh._bind(subMesh, this._effect, Material.TriangleFillMode);
				var material = subMesh.getMaterial();
				
				this._effect.setMatrix("viewProjection", scene.getTransformMatrix());
				
				this._effect.setFloat("far", scene.activeCamera.maxZ);
				
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
				
				// Draw
				mesh._processRendering(subMesh, this._effect, Material.TriangleFillMode, batch, hardwareInstancedRendering,
					function(isInstance:Bool, world:Matrix) { this._effect.setMatrix("world", world); } );
			}
		};
		
		this._depthMap.customRenderFunction = function(opaqueSubMeshes:SmartArray<SubMesh>, alphaTestSubMeshes:SmartArray<SubMesh>) {	
			for (index in 0...opaqueSubMeshes.length) {
				renderSubMesh(opaqueSubMeshes.data[index]);
			}
			for (index in 0...alphaTestSubMeshes.length) {
				renderSubMesh(alphaTestSubMeshes.data[index]);
			}
		};
	}

	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var material:Material = subMesh.getMaterial();
		if (material.disableDepthWrite) {
			return false;
		}
		
		var defines:Array<String> = [];
		
		var attribs = [VertexBuffer.PositionKind];
		
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
				["world", "mBones", "viewProjection", "diffuseMatrix", "far"],
				["diffuseSampler"], join);
		}
		
		return this._effect.isReady();
	}

	public function getDepthMap():RenderTargetTexture {
		return this._depthMap;
	}

	// Methods
	public function dispose() {
		this._depthMap.dispose();
	}
	
}
