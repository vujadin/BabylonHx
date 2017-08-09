package com.babylonhx.mesh;

import com.babylonhx.materials.Effect;
import com.babylonhx.materials.MaterialDefines;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BaseSubMesh {

	public var _materialDefines:MaterialDefines;
	public var _materialEffect:Effect;

	public var effect(get, never):Effect;
	inline private function get_effect():Effect {
		return this._materialEffect;
	}      

	public function setEffect(effect:Effect, ?defines:MaterialDefines) {
		if (this._materialEffect == effect) {
			if (effect == null) {
				this._materialDefines = null;
			}
			return;
		}
		this._materialDefines = defines;
		this._materialEffect = effect;
	}
	
	public function new() { }
	
}
