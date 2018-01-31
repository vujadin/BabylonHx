package com.babylonhx.loading.gltf.two;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GLTFLoaderTracker {

	private var _pendingCount:Int = 0;
	private var _callback:Void->Void;
	

	public function new(onComplete:Void->Void) {
		this._callback = onComplete;
	}

	public function _addPendingData(data:Dynamic) {
		this._pendingCount++;
	}

	public function _removePendingData(data:Dynamic) {
		if (--this._pendingCount == 0) {
			this._callback();
		}
	}
	
}
