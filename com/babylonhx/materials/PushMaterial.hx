package com.babylonhx.materials;

import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PushMaterial extends Material {

	private var _activeEffect:Effect;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		this.storeEffectOnSubMeshes = true;
	}

	override public function getEffect():Effect {
		return this._activeEffect;
	}

	override public function isReady(mesh:AbstractMesh = null, useInstances:Bool = false):Bool {
		if (mesh == null) {
			return false;
		}
		
		if (mesh.subMeshes == null || mesh.subMeshes.length == 0) {
			return true;
		}
		
		return this.isReadyForSubMesh(mesh, mesh.subMeshes[0], useInstances);
	}

	override public function bindOnlyWorldMatrix(world:Matrix) {
		this._activeEffect.setMatrix("world", world);
	}

	override public function bind(world:Matrix, mesh:Mesh = null) {
		if (mesh == null) {
			return;
		}
		
		this.bindForSubMesh(world, mesh, mesh.subMeshes[0]);
	}

	override public function _afterBind(mesh:Mesh, ?effect:Effect) {
		super._afterBind(mesh);
		this.getScene()._cachedEffect = effect;
	}

	public function _mustRebind(scene:Scene, effect:Effect, visibility:Float = 0) {
		return scene.isCachedMaterialInvalid(this, effect, visibility);
	}

}
