package com.gamestudiohx.babylonhx.rendering;

import com.gamestudiohx.babylonhx.materials.Material;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.mesh.SubMesh;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.tools.SmartArray;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class RenderingGroup {
	
	public var index:Int;
	public var _scene:Scene;
	
	private var _opaqueSubMeshes:SmartArray;
	public var _transparentSubMeshes:SmartArray;
	public var _alphaTestSubMeshes:SmartArray;
	
	public var _activeVertices:Int;

	public function new(index:Int, scene:Scene) {
		this.index = index;
        this._scene = scene;
		
		this._activeVertices = 0;

        this._opaqueSubMeshes = new SmartArray();
        this._transparentSubMeshes = new SmartArray();
        this._alphaTestSubMeshes = new SmartArray();
	}
	
	public function render(customRenderFunction:SmartArray->SmartArray->SmartArray->Dynamic->Void = null, beforeTransparents:Dynamic = null):Bool {
        if (customRenderFunction != null) {
            customRenderFunction(this._opaqueSubMeshes, this._alphaTestSubMeshes, this._transparentSubMeshes, beforeTransparents);
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
			
            this._activeVertices += submesh.verticesCount;

            submesh.render();
        }

        // Alpha test
        engine.setAlphaTesting(true);
        for (subIndex in 0...this._alphaTestSubMeshes.length) {
            submesh = this._alphaTestSubMeshes.data[subIndex];
			
            this._activeVertices += submesh.verticesCount;

            submesh.render();
        }
        engine.setAlphaTesting(false);

        if (beforeTransparents != null) {
            beforeTransparents();
        }

        // Transparent
        if (this._transparentSubMeshes.length > 0) {
            // Sorting			
            for (subIndex in 0...this._transparentSubMeshes.length) {
                submesh = this._transparentSubMeshes.data[subIndex];
                submesh._distanceToCamera = submesh.getBoundingInfo().boundingSphere.centerWorld.subtract(this._scene.activeCamera.position).length();
            }

            var sortedArray = this._transparentSubMeshes.data.slice(0, this._transparentSubMeshes.length);

            sortedArray.sort(function (a:SubMesh, b:SubMesh):Int {
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
                this._activeVertices += submesh.verticesCount;

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
        var mesh:Mesh = subMesh.getMesh();
        if (Std.is(material, Material) && material.needAlphaBlending() || mesh.visibility < 1.0) { // Transparent
            if (material.alpha > 0 || mesh.visibility < 1.0) {
                this._transparentSubMeshes.push(subMesh);
            }
        } else if (Std.is(material, Material) && material.needAlphaTesting()) { // Alpha test
            this._alphaTestSubMeshes.push(subMesh);
        } else {
            this._opaqueSubMeshes.push(subMesh); // Opaque
        }
    }
	
}
