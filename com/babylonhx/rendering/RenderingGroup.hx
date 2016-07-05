package com.babylonhx.rendering;

import com.babylonhx.tools.SmartArray;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.Material;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RenderingGroup') class RenderingGroup {
	
	public var index:Int;
	
	private var _scene:Scene;
	private var _opaqueSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>();
	private var _transparentSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>();
	private var _alphaTestSubMeshes:SmartArray<SubMesh> = new SmartArray<SubMesh>();
	private var _activeVertices:Int = 0;
	
	public var onBeforeTransparentRendering:Void->Void;
	

	public function new(index:Int, scene:Scene) {
		this._scene = scene;
		this.index = index;
	}

	public function render(?customRenderFunction:SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void):Bool {
		if (customRenderFunction != null) {
			customRenderFunction(this._opaqueSubMeshes, this._alphaTestSubMeshes, this._transparentSubMeshes);
			return true;
		}
		
		if (this._opaqueSubMeshes.length == 0 && this._alphaTestSubMeshes.length == 0 && this._transparentSubMeshes.length == 0) {
			if (this.onBeforeTransparentRendering != null) {
                this.onBeforeTransparentRendering();
            }
			return false;
		}
		
		var engine = this._scene.getEngine();
		
		var submesh:SubMesh = null;
		
		// Opaque		
		for (subIndex in 0...this._opaqueSubMeshes.length) {
			this._opaqueSubMeshes.data[subIndex].render(false);
		}
		
		// Alpha test
		engine.setAlphaTesting(true);
		for (subIndex in 0...this._alphaTestSubMeshes.length) {
			this._alphaTestSubMeshes.data[subIndex].render(false);
		}
		engine.setAlphaTesting(false);
		
		if (this.onBeforeTransparentRendering != null) {
            this.onBeforeTransparentRendering();
        }
		
		// Transparent
		if (this._transparentSubMeshes.length > 0) {
			// Sorting
			for (subIndex in 0...this._transparentSubMeshes.length) {
				submesh = this._transparentSubMeshes.data[subIndex];
				submesh._alphaIndex = submesh.getMesh().alphaIndex;
				submesh._distanceToCamera = submesh.getBoundingInfo().boundingSphere.centerWorld.subtract(this._scene.activeCamera.globalPosition).length();
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
			for (subIndex in 0...sortedArray.length) {
				submesh = sortedArray[subIndex];
				submesh.render(true);
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

	var material:Material;
	var mesh:AbstractMesh;
	inline public function dispatch(subMesh:SubMesh) {
		material = subMesh.getMaterial();
		mesh = subMesh.getMesh();
		
		if (material.needAlphaBlending() || mesh.visibility < 1.0 || mesh.hasVertexAlpha) { // Transparent
			this._transparentSubMeshes.push(subMesh);
		} 
		else if (material.needAlphaTesting()) { // Alpha test
			this._alphaTestSubMeshes.push(subMesh);
		} 
		else {
			this._opaqueSubMeshes.push(subMesh); // Opaque
		}
	}
	
}
