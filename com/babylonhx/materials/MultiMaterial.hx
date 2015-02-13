package com.babylonhx.materials;

import com.babylonhx.mesh.AbstractMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.MultiMaterial') class MultiMaterial extends Material {
	
	public var subMaterials:Array<Material> = [];
	

	public function new(name:String, scene:Scene) {
		super(name, scene, true);
		
		scene.multiMaterials.push(this);
	}

	// Properties
	public function getSubMaterial(index:Int):Material {
		if (index < 0 || index >= this.subMaterials.length) {
			return this.getScene().defaultMaterial;
		}
		
		return this.subMaterials[index];
	}

	// Methods
	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false/*?useInstances:Bool*/):Bool {
		for (index in 0...this.subMaterials.length) {
			var subMaterial = this.subMaterials[index];
			if (subMaterial != null) {
				if (!this.subMaterials[index].isReady(mesh)) {
					return false;
				}
			}
		}
		
		return true;
	}
	
}
