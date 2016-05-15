package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MaterialDefines {
	
	public var defines:Map<String, Bool>;
	
	var finalString:String = "";
	

	public function new() {	}
	
	var ret:Bool = true;
	inline public function isEqual(other:MaterialDefines):Bool {
		ret = true;
		for (key in this.defines.keys()) {
			if (this.defines[key] != other.defines[key]) {
				ret = false;
				break;
			}
		}
		
		return ret;
	}

	public function cloneTo(other:MaterialDefines) {
		for (key in this.defines.keys()) {
			other.defines[key] = other.defines[key];
		}		
	}

	public function reset() {
		for (key in this.defines.keys()) {
			this.defines[key] = false;
		}
	}

	public function toString():String {
		finalString = "";
		for (key in this.defines.keys()) {
			if (this.defines[key] == true) {
				finalString += "#define " + key + "\n";
			}
		}
		
		return finalString;
	}
	
}
