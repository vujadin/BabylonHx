package com.babylonhx.states;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.WebGL2Context;

/**
 * ...
 * @author Krtolica Vujadin
 */
class _StencilState {

	private var _isStencilTestDirty:Bool = false;
	private var _isStencilMaskDirty:Bool = false;
	private var _isStencilFuncDirty:Bool = false;
	private var _isStencilOpDirty:Bool = false;

	private var _stencilTest:Bool;

	private var _stencilMask:Int;

	private var _stencilFunc:Int;
	private var _stencilFuncRef:Int;
	private var _stencilFuncMask:Int;

	private var _stencilOpStencilFail:Int;
	private var _stencilOpDepthFail:Int;
	private var _stencilOpStencilDepthPass:Int;
	
	public var isDirty(get, never):Bool;
	inline private function get_isDirty():Bool {
		return this._isStencilTestDirty || this._isStencilMaskDirty || this._isStencilFuncDirty || this._isStencilOpDirty;
	}

	public var stencilFunc(get, set):Int;
	inline private function get_stencilFunc():Int {
		return this._stencilFunc;
	}
	private function set_stencilFunc(value:Int):Int {
		if (this._stencilFunc == value) {
			return value;
		}
		
		this._stencilFunc = value;
		this._isStencilFuncDirty = true;
		
		return value;
	}

	public var stencilFuncRef(get, set):Int;
	inline private function get_stencilFuncRef():Int {
		return this._stencilFuncRef;
	}
	private function set_stencilFuncRef(value:Int):Int {
		if (this._stencilFuncRef == value) {
			return value;
		}
		
		this._stencilFuncRef = value;
		this._isStencilFuncDirty = true;
		
		return value;
	}

	public var stencilFuncMask(get, set):Int;
	inline private function get_stencilFuncMask():Int {
		return this._stencilFuncMask;
	}
	private function set_stencilFuncMask(value:Int):Int {
		if (this._stencilFuncMask == value) {
			return value;
		}
		
		this._stencilFuncMask = value;
		this._isStencilFuncDirty = true;
		
		return value;
	}

	public var stencilOpStencilFail(get, set):Int;
	inline private function get_stencilOpStencilFail():Int {
		return this._stencilOpStencilFail;
	}
	private function set_stencilOpStencilFail(value:Int):Int {
		if (this._stencilOpStencilFail == value) {
			return value;
		}
		
		this._stencilOpStencilFail = value;
		this._isStencilOpDirty = true;
		
		return value;
	}

	public var stencilOpDepthFail(get, set):Int;
	inline private function get_stencilOpDepthFail():Int {
		return this._stencilOpDepthFail;
	}
	private function set_stencilOpDepthFail(value:Int):Int {
		if (this._stencilOpDepthFail == value) {
			return value;
		}
		
		this._stencilOpDepthFail = value;
		this._isStencilOpDirty = true;
		
		return value;
	}

	public var stencilOpStencilDepthPass(get, set):Int;
	inline private function get_stencilOpStencilDepthPass():Int {
		return this._stencilOpStencilDepthPass;
	}
	private function set_stencilOpStencilDepthPass(value:Int):Int {
		if (this._stencilOpStencilDepthPass == value) {
			return value;
		}
		
		this._stencilOpStencilDepthPass = value;
		this._isStencilOpDirty = true;
		
		return value;
	}
	
	public var stencilMask(get, set):Int;
	inline private function get_stencilMask():Int {
		return this._stencilMask;
	}
	private function set_stencilMask(value:Int):Int {
		if (this._stencilMask == value) {
			return value;
		}
		
		this._stencilMask = value;
		this._isStencilMaskDirty = true;
		
		return value;
	}

	public var stencilTest(get, set):Bool;
	inline private function get_stencilTest():Bool {
		return this._stencilTest;
	}
	private function set_stencilTest(value:Bool):Bool {
		if (this._stencilTest == value) {
			return value;
		}
		
		this._stencilTest = value;
		this._isStencilTestDirty = true;
		
		return value;
	}

	public function new() {
		this.reset();
	}

	inline public function reset() {
		this._stencilTest = false;
		this._stencilMask = 0xFF;
		
		this._stencilFunc = GL.ALWAYS;
		this._stencilFuncRef = 1;
		this._stencilFuncMask = 0xFF;
		
		this._stencilOpStencilFail = GL.KEEP;
		this._stencilOpDepthFail = GL.KEEP;
		this._stencilOpStencilDepthPass = GL.REPLACE;
		
		this._isStencilTestDirty = true;
		this._isStencilMaskDirty = true;
		this._isStencilFuncDirty = true;
		this._isStencilOpDirty = true;
	}

	public function apply(gl:WebGL2Context) {
		if (!this.isDirty) {
			return;
		}
		
		// Stencil test
		if (this._isStencilTestDirty) {
			if (this.stencilTest) {
				gl.enable(gl.STENCIL_TEST);
			} 
			else {
				gl.disable(gl.STENCIL_TEST);
			}
			this._isStencilTestDirty = false;
		}
		
		// Stencil mask
		if (this._isStencilMaskDirty) {
			gl.stencilMask(this.stencilMask);
			this._isStencilMaskDirty = false;
		}
		
		// Stencil func
		if (this._isStencilFuncDirty) {
			gl.stencilFunc(this.stencilFunc, this.stencilFuncRef, this.stencilFuncMask);
			this._isStencilFuncDirty = false;
		}
		
		// Stencil op
		if (this._isStencilOpDirty) {
			gl.stencilOp(this.stencilOpStencilFail, this.stencilOpDepthFail, this.stencilOpStencilDepthPass);
			this._isStencilOpDirty = false;
		}
	}
	
}
