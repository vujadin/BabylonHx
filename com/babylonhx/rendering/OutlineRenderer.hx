package com.babylonhx.rendering;

import com.babylonhx.materials.Effect;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh._InstancesBatch;
import com.babylonhx.materials.Material;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.OutlineRenderer') class OutlineRenderer {
	
	private var _scene:Scene;
	private var _effect:Effect;
	private var _cachedDefines:String;
	

	public function new(scene:Scene) {
		this._scene = scene;
	}

	public function render(subMesh:SubMesh, batch:_InstancesBatch, useOverlay:Bool = false) {
		var scene = this._scene;
		var engine = this._scene.getEngine();
		
		var hardwareInstancedRendering = (engine.getCaps().instancedArrays != null) && (batch.visibleInstances[subMesh._id] != null);
		
		if (!this.isReady(subMesh, hardwareInstancedRendering)) {
			return;
		}
		
		var mesh = subMesh.getRenderingMesh();
		var material = subMesh.getMaterial();
		
		engine.enableEffect(this._effect);
		this._effect.setFloat("offset", mesh.outlineWidth);
		this._effect.setFloat("offset", useOverlay ? 0 : mesh.outlineWidth);
		this._effect.setColor4("color", useOverlay ? mesh.overlayColor : mesh.outlineColor, useOverlay ? mesh.overlayAlpha : 1.0);
		this._effect.setMatrix("viewProjection", scene.getTransformMatrix());
		
		// Bones
		var useBones = mesh.skeleton != null && scene.skeletonsEnabled && mesh.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && mesh.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind);
		if (useBones) {
			this._effect.setMatrices("mBones", mesh.skeleton.getTransformMatrices());
		}
		
		mesh._bind(subMesh, this._effect, Material.TriangleFillMode);
		
		// Alpha test
		if (material != null && material.needAlphaTesting()) {
			var alphaTexture = material.getAlphaTestTexture();
			this._effect.setTexture("diffuseSampler", alphaTexture);
			this._effect.setMatrix("diffuseMatrix", alphaTexture.getTextureMatrix());
		}
		
		if (hardwareInstancedRendering) {
			mesh._renderWithInstances(subMesh, Material.TriangleFillMode, batch, this._effect, engine);
		} else {
			if (batch.renderSelf.length > subMesh._id) {
				this._effect.setMatrix("world", mesh.getWorldMatrix());
				
				// Draw
				mesh._draw(subMesh, Material.TriangleFillMode);
			}
			
			if (batch.visibleInstances[subMesh._id] != null) {
				for (instanceIndex in 0...batch.visibleInstances[subMesh._id].length) {
					var instance = batch.visibleInstances[subMesh._id][instanceIndex];
					
					this._effect.setMatrix("world", instance.getWorldMatrix());
					
					// Draw
					mesh._draw(subMesh, Material.TriangleFillMode);
				}
			}
		}
	}

	public function isReady(subMesh:SubMesh, useInstances:Bool):Bool {
		var defines:Array<String> = [];
		var attribs = [VertexBuffer.PositionKind, VertexBuffer.NormalKind];
		
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
		if (mesh.skeleton != null && mesh.isVerticesDataPresent(VertexBuffer.MatricesIndicesKind) && mesh.isVerticesDataPresent(VertexBuffer.MatricesWeightsKind)) {
			attribs.push(VertexBuffer.MatricesIndicesKind);
			attribs.push(VertexBuffer.MatricesWeightsKind);
			defines.push("#define BONES");
			defines.push("#define BonesPerMesh " + (mesh.skeleton.bones.length + 1));
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
			this._effect = this._scene.getEngine().createEffect("outline",
				attribs,
				["world", "mBones", "viewProjection", "diffuseMatrix", "offset", "color"],
				["diffuseSampler"], join);
		}
		
		return this._effect.isReady();
	}
	
}
