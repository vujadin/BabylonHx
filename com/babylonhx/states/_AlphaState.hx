package com.babylonhx.states;

import lime.graphics.opengl.GL;

#if (!js && !purejs)
import lime.graphics.opengl.GL in Gl;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON._AlphaState') class _AlphaState {
	
	private var _isAlphaBlendDirty:Bool = false;
	private var _isBlendFunctionParametersDirty:Bool = false;
	private var _isBlendEquationParametersDirty:Bool = false;
	private var _isBlendConstantsDirty = false;
	private var _alphaBlend:Bool = false;
	private var _blendFunctionParameters:Array<Null<Int>> = [];
	private var _blendEquationParameters:Array<Null<Int>> = [];
	private var _blendConstants:Array<Null<Float>> = [];
	
	
	public function new() {
		this.reset();
	}

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
	
	public function setAlphaBlendConstants(r:Float, g:Float, b:Float, a:Float) {
		if (
			this._blendConstants[0] == r &&
			this._blendConstants[1] == g &&
			this._blendConstants[2] == b &&
			this._blendConstants[3] == a
		) {
			return;
		}
		
		this._blendConstants[0] = r;
		this._blendConstants[1] = g;
		this._blendConstants[2] = b;
		this._blendConstants[3] = a;
		
		this._isBlendConstantsDirty = true;
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
	
	public function setAlphaEquationParameters(rgb:Int, alpha:Int) {
		if (
			this._blendEquationParameters[0] == rgb &&
			this._blendEquationParameters[1] == alpha
		) {
			return;
		}
		
		this._blendEquationParameters[0] = rgb;
		this._blendEquationParameters[1] = alpha;
		
		this._isBlendEquationParametersDirty = true;
	}

	public function reset() {
		this._alphaBlend = false;
		this._blendFunctionParameters[0] = null;
		this._blendFunctionParameters[1] = null;
		this._blendFunctionParameters[2] = null;
		this._blendFunctionParameters[3] = null;
		
		this._blendEquationParameters[0] = null;
		this._blendEquationParameters[1] = null; 
		
		this._blendConstants[0] = null;
		this._blendConstants[1] = null;
		this._blendConstants[2] = null;
		this._blendConstants[3] = null;
		
		this._isAlphaBlendDirty = true;
		this._isBlendFunctionParametersDirty = false;
		this._isBlendEquationParametersDirty = false;
		this._isBlendConstantsDirty = false;
	}

	public function apply(#if (js || purejs) Gl:js.html.webgl.RenderingContext #end) {
		
		if (!this.isDirty) {
			return;
		}
		
		// Alpha blend
		if (this._isAlphaBlendDirty) {
			if (this._alphaBlend) {
				Gl.enable(GL.BLEND);
			} 
			else {
				Gl.disable(GL.BLEND);
			}
			
			this._isAlphaBlendDirty = false;
		}
		
		// Alpha function
		if (this._isBlendFunctionParametersDirty) {
			Gl.blendFuncSeparate(this._blendFunctionParameters[0], this._blendFunctionParameters[1], this._blendFunctionParameters[2], this._blendFunctionParameters[3]);
			this._isBlendFunctionParametersDirty = false;
		}
		
		// Alpha equation
		if (this._isBlendEquationParametersDirty) {
			Gl.blendEquationSeparate(this._blendEquationParameters[0], this._blendEquationParameters[1]);
			this._isBlendEquationParametersDirty = false;
		}
		
		// Constants
		if (this._isBlendConstantsDirty) {
			Gl.blendColor(this._blendConstants[0], this._blendConstants[1], this._blendConstants[2], this._blendConstants[3]);
			this._isBlendConstantsDirty = false;
		} 
	}
	
}
