package com.babylonhx.materials;
import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MaterialDefines {
	
	public var defines:Vector<Bool>;
	public var _keys:Vector<String>;
	

	public function new() {
		//defines = [];
		//_keys = [];
	}
	
	var ret:Bool = true;
	inline public function isEqual(other:MaterialDefines):Bool {
		ret = true;
		for (i in 0...this.defines.length) {
			if (this.defines[i] != other.defines[i]) {
				ret = false;
				break;
			}
		}
		
		return ret;
	}

	public function cloneTo(other:MaterialDefines) {
		for (i in 0...this.defines.length) {
			other.defines[i] = other.defines[i];
		}		
	}

	public function reset() {
		for (i in 0...this.defines.length) {
			this.defines[i] = false;
		}
	}

	var result:String = "";
	public function toString():String {
		result = "";
		for (i in 0...this.defines.length) {
			if (this.defines[i] == true) {
				result += "#define " + this._keys[i] + "\n";
			}
		}
		
		return result;
	}
	
}
