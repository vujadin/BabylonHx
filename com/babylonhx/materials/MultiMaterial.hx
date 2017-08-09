package com.babylonhx.materials;

import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.tools.Tags;
import com.babylonhx.materials.textures.BaseTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.MultiMaterial') class MultiMaterial extends Material {
	
	private var _subMaterials:Array<Material>;
	public var subMaterials(get, set):Array<Material>;
	private inline function get_subMaterials():Array<Material> {
		return this._subMaterials;
	}
	private inline function set_subMaterials(value:Array<Material>):Array<Material> {
		this._subMaterials = value;
		this._hookArray(value);
		return value;
	}
	

	public function new(name:String, scene:Scene) {
		super(name, scene, true);
		
		scene.multiMaterials.push(this);
		
		this.subMaterials = [];
		
		this.storeEffectOnSubMeshes = true; // multimaterial is considered like a push material
	}
	
	private function _hookArray(array:Array<Material>) {
		// VK TODO:
		/*var oldPush = array.push;
		array.push = (...items: Material[]) => {
			var result = oldPush.apply(array, items);
			
			this._markAllSubMeshesAsTexturesDirty();
			
			return result;
		}
		
		var oldSplice = array.splice;
		array.splice = (index: number, deleteCount?: number) => {
			var deleted = oldSplice.apply(array, [index, deleteCount]);
			
			this._markAllSubMeshesAsTexturesDirty();
			
			return deleted;
		}*/
	}

	// Properties
	public function getSubMaterial(index:Int):Material {
		if (index < 0 || index >= this.subMaterials.length) {
			return this.getScene().defaultMaterial;
		}
		
		return this.subMaterials[index];
	}
	
	override public function getActiveTextures():Array<BaseTexture> {
		for (sm in this.subMaterials) {
			super.getActiveTextures().concat(sm.getActiveTextures());
		}
		//var _st:Array<BaseTexture> = this.subMaterials.map(function(subMaterial:Material):Array<BaseTexture> { return subMaterial.getActiveTextures(); });
		return super.getActiveTextures();
	}

	// Methods
	override public function getClassName():String {
		return "MultiMaterial";
	}

	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {
		for (index in 0...this.subMaterials.length) {
			var subMaterial = this.subMaterials[index];
			if (subMaterial != null) {
				if (this.subMaterials[index].storeEffectOnSubMeshes) {
					if (!this.subMaterials[index].isReadyForSubMesh(mesh, subMesh, useInstances)) {
						return false;
					}
					continue;
				}
				
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
	
	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		var scene = this.getScene();
		if (scene == null) {
			return;
		}
		
		var index = scene.multiMaterials.indexOf(this);
		if (index >= 0) {
			scene.multiMaterials.splice(index, 1);
		}
		
		super.dispose(forceDisposeEffect, forceDisposeTextures);
	}
	
}
