package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StandardMaterialDefines {

	public var defines:Map<String, Bool> = new Map<String, Bool>();
	public var BonesPerMesh:Int = 0;
	
	
	public function new() {
		defines["DIFFUSE"] = false;
		defines["AMBIENT"] = false;
		defines["OPACITY"] = false;
		defines["OPACITYRGB"] = false;
		defines["REFLECTION"] = false;
		defines["EMISSIVE"] = false;
		defines["SPECULAR"] = false;
		defines["BUMP"] = false;
		defines["SPECULAROVERALPHA"] = false;
		defines["CLIPPLANE"] = false;
		defines["ALPHATEST"] = false;
		defines["ALPHAFROMDIFFUSE"] = false;
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
		defines["POINTDIRLIGHT0"] = false;
		defines["POINTDIRLIGHT1"] = false;
		defines["POINTDIRLIGHT2"] = false;
		defines["POINTDIRLIGHT3"] = false;
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
		defines["DIFFUSEFRESNEL"] = false;
		defines["OPACITYFRESNEL"] = false;
		defines["REFLECTIONFRESNEL"] = false;
		defines["EMISSIVEFRESNEL"] = false;
		defines["FRESNEL"] = false;
		defines["NORMAL"] = false;
		defines["UV1"] = false;
		defines["UV2"] = false;
		defines["VERTEXCOLOR"] = false;
		defines["VERTEXALPHA"] = false;
		defines["BONES"] = false;
		defines["BONES4"] = false;
		defines["INSTANCES"] = false;
		
		BonesPerMesh = 0;
	}

	public function isEqual(other:StandardMaterialDefines):Bool {
		for (prop in this.defines.keys()) {
			if (this.defines[prop] != other.defines[prop]) {
				return false;
			}
		}
		
		return true;
	}

	public function cloneTo(other:StandardMaterialDefines) {
		for (prop in this.defines.keys()) {
			other.defines[prop] = this.defines[prop];
		}
	}

	public function reset() {
		for (prop in this.defines.keys()) {
			this.defines[prop] = false;
		}
		
		this.BonesPerMesh = 0;
	}

	public function toString():String {
		var result = "";
		for (prop in this.defines.keys()) {
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
