package com.babylonhx.canvas2d.engine;

import com.babylonhx.mesh.WebGLBuffer;
import com.babylonhx.tools.DynamicFloatArray;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GroupInfoPartData {

	private var _partData:DynamicFloatArray = null;
	private var _partBuffer:WebGLBuffer = null;
	private var _partBufferSize:Int = 0;
	private var _isDisposed:Bool;
	

	public function new(stride:Int) {
		this._partData = new DynamicFloatArray(stride / 4, 50);
		this._isDisposed = false;
	}

	public function dispose(engine:Engine):Bool {
		if (this._isDisposed) {
			return false;
		}
		
		if (this._partBuffer != null) {
			engine._releaseBuffer(this._partBuffer);
			this._partBuffer = null;
		}
		
		this._partData = null;
		
		this._isDisposed = true;
	}
	
}
