package com.babylonhx.materials.lib.fire;

/**
 * ...
 * @author Krtolica Vujadin
 */
class FireMaterialDefines extends MaterialDefines {
	
	public var BonesPerMesh:Int = 0;
	

	public function new() {
		super();
		
		defines["DIFFUSE"] = false;
		defines["CLIPPLANE"] = false;
		defines["ALPHATEST"] = false;
		defines["POINTSIZE"] = false;
		defines["FOG"] = false;
		defines["UV1"] = false;
		defines["NORMAL"] = false;
		defines["VERTEXCOLOR"] = false;
		defines["VERTEXALPHA"] = false;
		defines["BONES"] = false;
		defines["BONES4"] = false;
		defines["INSTANCES"] = false;		
		
		BonesPerMesh = 0;
		
		for (key in defines.keys()) {
			_keys.push(key);
		}
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.BonesPerMesh = this.BonesPerMesh;
	}
	
	override public function reset() {
		super.reset();
		
		this.BonesPerMesh = 0;
	}

	override public function toString():String {
		var result = super.toString();
		
		if (this.BonesPerMesh > 0) {
			result += "#define BonesPerMesh " + this.BonesPerMesh + "\n";
		}
		
		return result;
	}
	
}
