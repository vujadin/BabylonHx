package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialDefines {
	
	public var defines:Map<String, Bool> = new Map<String, Bool>();
	public var BonesPerMesh:Int = 0;
	
	private var _keys:Array<String> = [];
	

	public function new() {
		defines["ALBEDO"] = false;
		defines["CLIPPLANE"] = false;
		defines["ALPHATEST"] = false;
		defines["FOG"] = false;
		defines["NORMAL"] = false;
		defines["UV1"] = false;
		defines["UV2"] = false;
		defines["VERTEXCOLOR"] = false;
		defines["VERTEXALPHA"] = false;
		defines["BONES"] = false;
		defines["BONES4"] = false;
		defines["INSTANCES"] = false;
		defines["POINTSIZE"] = false;
		
		BonesPerMesh = 0;
		
		for (key in defines.keys()) {
			_keys.push(key);
		}
	}
	
	var ret:Bool = true;
	inline public function isEqual(other:PBRMaterialDefines):Bool {
		ret = true;
		for (prop in this._keys) {
			if (this.defines[prop] != other.defines[prop]) {
				ret = false;
				break;
			}
		}
		
		return ret;
	}

	public function cloneTo(other:PBRMaterialDefines) {
		for (prop in this._keys) {
			other.defines[prop] = this.defines[prop];
		}
		other.BonesPerMesh = this.BonesPerMesh;
	}

	public function reset() {
		for (prop in this._keys) {
			this.defines[prop] = false;
		}
		
		this.BonesPerMesh = 0;
	}

	public function toString():String {
		var result = "";
		for (prop in this._keys) {
			if (this.defines[prop] == true) {
				result += "#define " + prop + "\n";
			}
		}
		
		if (this.BonesPerMesh > 0) {
			result += "#define BonesPerMesh " + this.BonesPerMesh + "\n";
		}
		
		return result;
	}
	
}
