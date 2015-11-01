package com.babylonhx.materials;

/**
 * ...
 * @author ...
 */
class MaterialDefines {
	
	public var defines:Map<String, Bool>;
	public var _keys:Array<String>;
	

	public function new() {
		defines = new Map<String, Bool>();
		_keys = [];
	}
	
	var ret:Bool = true;
	inline public function isEqual(other:MaterialDefines):Bool {
		ret = true;
		for (prop in this._keys) {
			if (this.defines[prop] != other.defines[prop]) {
				ret = false;
				break;
			}
		}
		
		return ret;
	}

	public function cloneTo(other:MaterialDefines) {
		for (prop in this._keys) {
			other.defines[prop] = this.defines[prop];
		}		
	}

	public function reset() {
		for (prop in this._keys) {
			this.defines[prop] = false;
		}
	}

	var result:String = "";
	public function toString():String {
		result = "";
		for (prop in this._keys) {
			if (this.defines[prop] == true) {
				result += "#define " + prop + "\n";
			}
		}
		
		return result;
	}
	
}
