package com.babylonhx.materials.lib.water;

/**
 * ...
 * @author Krtolica Vujadin
 */
class WaterMaterialDefines extends MaterialDefines {

	public var BonesPerMesh:Int = 0;
	
	
	public function new() {
		super();
		
		defines["BUMP"] = false;
		defines["REFLECTION"] = false;
		defines["CLIPPLANE"] = false;
		defines["ALPHATEST"] = false;
		defines["POINTSIZE"] = false;
		defines["FOG"] = false;
		defines["LIGHT0"] = false;
		defines["LIGHT1"] = false;
		defines["LIGHT2"] = false;
		defines["LIGHT3"] = false;
		defines["SPOTLIGHT0"] = false;
		defines["SPOTLIGHT1"] = false;
		defines["SPOTLIGHT2"] = false;
		defines["SPOTLIGHT3"] = false;
		defines["HEMILIGHT0"] = false;
		defines["HEMILIGHT1"] = false;
		defines["HEMILIGHT2"] = false;
		defines["HEMILIGHT3"] = false;
		defines["POINTLIGHT0"] = false;
		defines["POINTLIGHT1"] = false;
		defines["POINTLIGHT2"] = false;
		defines["POINTLIGHT3"] = false;
		defines["DIRLIGHT0"] = false;
		defines["DIRLIGHT1"] = false;
		defines["DIRLIGHT2"] = false;
		defines["DIRLIGHT3"] = false;
		defines["SPECULARTERM"] = false;
		defines["SHADOW0"] = false;
		defines["SHADOW1"] = false;
		defines["SHADOW2"] = false;
		defines["SHADOW3"] = false;
		defines["SHADOWS"] = false;
		defines["SHADOWVSM0"] = false;
		defines["SHADOWVSM1"] = false;
		defines["SHADOWVSM2"] = false;
		defines["SHADOWVSM3"] = false;
		defines["SHADOWPCF0"] = false;
		defines["SHADOWPCF1"] = false;
		defines["SHADOWPCF2"] = false;
		defines["SHADOWPCF3"] = false;
		defines["NORMAL"] = false;
		defines["UV1"] = false;
		defines["UV2"] = false;
		defines["VERTEXCOLOR"] = false;
		defines["VERTEXALPHA"] = false;
		defines["BONES"] = false;
		defines["BONES4"] = false;
		defines["INSTANCES"] = false;
		defines["SPECULARTERM"] = false;
				
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
