package com.babylonhx.canvas2d;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Canvas2DEngineBoundData {
	
	private _modelCache:Map<String, ModelRenderCache> = new Map<String, ModelRenderCache>();
	

	public function new() { }
	
	public function GetOrAddModelCache(key:String, factory:String->ModelRenderCache):ModelRenderCache {
		return this._modelCache.getOrAddWithFactory(key, factory);
	}

	public function DisposeModelRenderCache(modelRenderCache:ModelRenderCache):Bool {
		if (!modelRenderCache.isDisposed) {
			return false;
		}
		
		this._modelCache.remove(modelRenderCache.modelKey);
		
		return true;
	}
	
}
