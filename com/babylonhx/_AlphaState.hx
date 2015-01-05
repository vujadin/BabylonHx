package com.babylonhx;

#if openfl
import openfl.gl.GL;
#elseif snow
import snow.render.opengl.GL;
#elseif kha

#end

/**
 * ...
 * @author Krtolica Vujadin
 */

class _AlphaState {
	
	private var _isAlphaBlendDirty:Bool = false;
	private var _isBlendFunctionParametersDirty:Bool = false;
	private var _alphaBlend:Bool = false;
	private var _blendFunctionParameters:Array<Int> = [];

	public var isDirty(get, never):Bool;
	private function get_isDirty():Bool {
		return this._isAlphaBlendDirty || this._isBlendFunctionParametersDirty;
	}

	public var alphaBlend(get, set):Bool;
	private function get_alphaBlend():Bool {
		return this._alphaBlend;
	}
	private function set_alphaBlend(value:Bool):Bool {
		if (this._alphaBlend == value) {
			return value;
		}
		
		this._alphaBlend = value;
		this._isAlphaBlendDirty = true;
		return value;
	}

	public function setAlphaBlendFunctionParameters(value0:Int, value1:Int, value2:Int, value3:Int) {
		if (
			this._blendFunctionParameters[0] == value0 &&
			this._blendFunctionParameters[1] == value1 &&
			this._blendFunctionParameters[2] == value2 &&
			this._blendFunctionParameters[3] == value3
			) {
			return;
		}
		
		this._blendFunctionParameters[0] = value0;
		this._blendFunctionParameters[1] = value1;
		this._blendFunctionParameters[2] = value2;
		this._blendFunctionParameters[3] = value3;
		
		this._isBlendFunctionParametersDirty = true;
	}

	public function reset() {
		this._alphaBlend = false;
		this._blendFunctionParameters[0] = -1;
		this._blendFunctionParameters[1] = -1;
		this._blendFunctionParameters[2] = -1;
		this._blendFunctionParameters[3] = -1;
		
		this._isAlphaBlendDirty = true;
		this._isBlendFunctionParametersDirty = false;
	}

	public function apply() {
		
		if (!this.isDirty) {
			return;
		}
		
		// Alpha blend
		if (this._isAlphaBlendDirty) {
			if (this._alphaBlend == true) {
				GL.enable(GL.BLEND);
			} else if (this._alphaBlend == false) {
				GL.disable(GL.BLEND);
			}
			
			this._isAlphaBlendDirty = false;
		}
		
		// Alpha function
		if (this._isBlendFunctionParametersDirty) {
			GL.blendFuncSeparate(this._blendFunctionParameters[0], this._blendFunctionParameters[1], this._blendFunctionParameters[2], this._blendFunctionParameters[3]);
			this._isBlendFunctionParametersDirty = false;
		}
	}
	
}
