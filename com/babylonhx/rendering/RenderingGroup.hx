package com.babylonhx.rendering;

import com.babylonhx.tools.SmartArray;
import com.babylonhx.mesh.SubMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RenderingGroup') class RenderingGroup {
	
	public var index:Int;
	
	private var _scene:Scene;
	private var _opaqueSubMeshes:SmartArray = new SmartArray();
	private var _transparentSubMeshes:SmartArray = new SmartArray();
	private var _alphaTestSubMeshes:SmartArray = new SmartArray();
	private var _activeVertices:Int = 0;
	

	public function new(index:Int, scene:Scene) {
		this._scene = scene;
		this.index = index;
	}

	public function render(customRenderFunction:SmartArray->SmartArray->SmartArray->Void):Bool {
		if (customRenderFunction != null) {
			customRenderFunction(this._opaqueSubMeshes, this._alphaTestSubMeshes, this._transparentSubMeshes);
			return true;
		}
		
		if (this._opaqueSubMeshes.length == 0 && this._alphaTestSubMeshes.length == 0 && this._transparentSubMeshes.length == 0) {
			return false;
		}
		
		var engine = this._scene.getEngine();
		// Opaque
		var submesh:SubMesh = null;
		for (subIndex in 0...this._opaqueSubMeshes.length) {
			submesh = this._opaqueSubMeshes.data[subIndex];
			submesh.render();
		}
		
		// Alpha test
		engine.setAlphaTesting(true);
		for (subIndex in 0...this._alphaTestSubMeshes.length) {
			submesh = this._alphaTestSubMeshes.data[subIndex];
			submesh.render();
		}
		engine.setAlphaTesting(false);
		
		// Transparent
		if (this._transparentSubMeshes.length > 0) {
			// Sorting
			for (subIndex in 0...this._transparentSubMeshes.length) {
				submesh = this._transparentSubMeshes.data[subIndex];
				submesh._alphaIndex = submesh.getMesh().alphaIndex;
				submesh._distanceToCamera = submesh.getBoundingInfo().boundingSphere.centerWorld.subtract(this._scene.activeCamera.position).length();
			}
			
			var sortedArray = this._transparentSubMeshes.data.slice(0, this._transparentSubMeshes.length);
			
			sortedArray.sort(function(a:SubMesh, b:SubMesh):Int {
				// Alpha index first
				if (a._alphaIndex > b._alphaIndex) {
					return 1;
				}
				if (a._alphaIndex < b._alphaIndex) {
					return -1;
				}
					
				// Then distance to camera
				if (a._distanceToCamera < b._distanceToCamera) {
					return 1;
				}
				if (a._distanceToCamera > b._distanceToCamera) {
					return -1;
				}
				
				return 0;
			});
			
			// Rendering
			engine.setAlphaMode(Engine.ALPHA_COMBINE);
			for (subIndex in 0...sortedArray.length) {
				submesh = sortedArray[subIndex];
				submesh.render();
			}
			engine.setAlphaMode(Engine.ALPHA_DISABLE);
		}
		
		return true;
	}
	
	public function prepare() {
		this._opaqueSubMeshes.reset();
		this._transparentSubMeshes.reset();
		this._alphaTestSubMeshes.reset();
	}

	public function dispatch(subMesh:SubMesh) {
		var material = subMesh.getMaterial();
		var mesh = subMesh.getMesh();
		
		if (material.needAlphaBlending() || mesh.visibility < 1.0 || mesh.hasVertexAlpha) { // Transparent
			this._transparentSubMeshes.push(subMesh);
		} else if (material.needAlphaTesting()) { // Alpha test
			this._alphaTestSubMeshes.push(subMesh);
		} else {
			this._opaqueSubMeshes.push(subMesh); // Opaque
		}
	}
	
}
