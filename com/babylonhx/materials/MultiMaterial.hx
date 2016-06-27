package com.babylonhx.materials;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.tools.Tags;

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
	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
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
	
	override public function clone(name:String, cloneChildren:Bool = false):MultiMaterial {
		var newMultiMaterial = new MultiMaterial(name, this.getScene());
		
		for (index in 0...this.subMaterials.length) {
			var subMaterial:Material = null;
			
			if (cloneChildren) {
				subMaterial = this.subMaterials[index].clone(name + "-" + this.subMaterials[index].name);
			}
			else {
				subMaterial = this.subMaterials[index];
			}	
			newMultiMaterial.subMaterials.push(subMaterial);
		}
		
		return newMultiMaterial;
	}
	
	override public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		
		serializationObject.name = this.name;
		serializationObject.id = this.id;
		serializationObject.tags = Tags.GetTags(this);
		
		serializationObject.materials = [];
		
		for (matIndex in 0...this.subMaterials.length) {
			var subMat = this.subMaterials[matIndex];
			
			if (subMat != null) {
				serializationObject.materials.push(subMat.id);
			} 
			else {
				serializationObject.materials.push(null);
			}
		}
		
		return serializationObject;
	}
	
	static public function Parse(parsedMaterial:Dynamic, scene:Scene, rootUrl:String):MultiMaterial {
		var mm = new MultiMaterial(parsedMaterial.name, scene);
		
		var subMats:Array<Dynamic> = cast parsedMaterial.materials;
		for (m in subMats) {
			var sm = scene.getMaterialByID(m);
			if (sm != null) {
				mm.subMaterials.push(sm);
			}
			else {
				scene.getMaterialByName(m);
				if (sm != null) {
					mm.subMaterials.push(sm);
				}
			}
		}
		
		return mm;
	}
	
}
