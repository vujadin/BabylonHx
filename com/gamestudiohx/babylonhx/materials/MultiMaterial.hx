package com.gamestudiohx.babylonhx.materials;

import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.Scene;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class MultiMaterial {
	
	public var name:String;
	public var id:String;
	
	private var _scene:Scene;
	
	public var subMaterials:Array<Material>;

	public function new(name:String, scene:Scene) {
		this.name = name;
        this.id = name;
        
        this._scene = scene;
        scene.multiMaterials.push(this);

        this.subMaterials = [];
	}
	
	public function getSubMaterial(index:Int):Material {
        if (index < 0 || index >= this.subMaterials.length) {
            return this._scene.defaultMaterial;
        }

        return this.subMaterials[index];
    }
	
	public function isReady(mesh:Mesh):Bool {
        var result:Bool = true;
        for (index in 0...this.subMaterials.length) {
            var subMaterial = this.subMaterials[index];
            //if (subMaterial != null) {
                result = result && this.subMaterials[index].isReady(mesh);
            //}
        }

        return result;
    }
	
}
