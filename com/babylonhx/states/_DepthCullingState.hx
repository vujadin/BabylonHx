package com.babylonhx.states;

import com.babylonhx.utils.GL;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON._DepthCullingState') class _DepthCullingState {
	
	private var _isDepthTestDirty = false;
	private var _isDepthMaskDirty = false;
	private var _isDepthFuncDirty = false;
	private var _isCullFaceDirty = false;
	private var _isCullDirty = false;
	private var _isZOffsetDirty = false;

	private var _depthTest:Bool;
	private var _depthMask:Bool;
	private var _depthFunc:Null<Int>;
	private var _cull:Null<Bool>;
	private var _cullFace:Null<Int>;
	private var _zOffset:Float = 0.0;


	public var isDirty(get, never):Bool;
	private function get_isDirty():Bool {
		return this._isDepthFuncDirty || this._isDepthTestDirty || this._isDepthMaskDirty || this._isCullFaceDirty || this._isCullDirty || this._isZOffsetDirty;
	}
	
	public var zOffset(get, set):Float;
	private function get_zOffset():Float {
		return this._zOffset;
	}
	private function set_zOffset(value:Float):Float {
		if (this._zOffset == value) {
			return value;
		}
		
		this._zOffset = value;
		this._isZOffsetDirty = true;
		
		return value;
	}

	public var cullFace(get, set):Null<Int>;
	private function get_cullFace():Null<Int> {
		return this._cullFace;
	}
	private function set_cullFace(?value:Int):Null<Int> {
		if (this._cullFace == value) {
			return value;
		}
		
		this._cullFace = value;
		this._isCullFaceDirty = true;
		return value;
	}

	public var cull(get, set):Null<Bool>;
	private function get_cull():Null<Bool> {
		return this._cull;
	}
	private function set_cull(?value:Bool):Null<Bool> {
		if (this._cull == value) {
			return value;
		}
		
		this._cull = value;
		this._isCullDirty = true;
		return value;
	}

	public var depthFunc(get, set):Null<Int>;
	private function get_depthFunc():Null<Int> {
		return this._depthFunc;
	}
	private function set_depthFunc(?value:Int):Null<Int> {
		if (this._depthFunc == value) {
			return value;
		}
		
		this._depthFunc = value;
		this._isDepthFuncDirty = true;
		return value;
	}

	public var depthMask(get, set):Bool;
	private function get_depthMask():Bool {
		return this._depthMask;
	}
	private function set_depthMask(value:Bool):Bool {
		if (this._depthMask == value) {
			return value;
		}
		
		this._depthMask = value;
		this._isDepthMaskDirty = true;
		return value;
	}

	public var depthTest(get, set):Bool;
	private function get_depthTest():Bool {
		return this._depthTest;
	}
	private function set_depthTest(value:Bool):Bool {
		if (this._depthTest == value) {
			return value;
		}
		
		this._depthTest = value;
		this._isDepthTestDirty = true;
		return value;
	}
	
	public function new() {
		//
	}

	public function reset() {
		this._depthMask = true;
		this._depthTest = true;
		this._depthFunc = null;
		this._cull = null;
		this._cullFace = null;
		this._zOffset = 0;
		
		this._isDepthTestDirty = true;
		this._isDepthMaskDirty = true;
		this._isDepthFuncDirty = false;
		this._isCullFaceDirty = false;
		this._isCullDirty = false;
		this._isZOffsetDirty = false;
	}

	public function apply() {
		if (this.isDirty) {
			// Cull
			if (this._isCullDirty) {
				if (this.cull != null && this.cull) {
					GL.enable(GL.CULL_FACE);
				} 
				else {
					GL.disable(GL.CULL_FACE);
				}
				
				this._isCullDirty = false;
			}
			
			// Cull face
			if (this._isCullFaceDirty) {
				GL.cullFace(this.cullFace);
				this._isCullFaceDirty = false;
			}
			
			// Depth mask
			if (this._isDepthMaskDirty) {
				GL.depthMask(this.depthMask);
				this._isDepthMaskDirty = false;
			}
			
			// Depth test
			if (this._isDepthTestDirty) {
				if (this.depthTest) {
					GL.enable(GL.DEPTH_TEST);
				} 
				else {
					GL.disable(GL.DEPTH_TEST);
				}
				this._isDepthTestDirty = false;
			}
			
			// Depth func
			if (this._isDepthFuncDirty) {
				GL.depthFunc(this.depthFunc);
				this._isDepthFuncDirty = false;
			}
			
			// zOffset
			if (this._isZOffsetDirty) {
				if (this.zOffset != 0) {
					GL.enable(GL.POLYGON_OFFSET_FILL);
					GL.polygonOffset(this.zOffset, 0);
				} 
				else {
					GL.disable(GL.POLYGON_OFFSET_FILL);
				}
				
				this._isZOffsetDirty = false;
			}
		}	
	}
	
}
