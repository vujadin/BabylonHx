package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StandardMaterialDefines extends MaterialDefines {	
	
	public var BonesPerMesh:Int = 0;
	
	
	public function new() {
		super();
		
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
		defines["GLOSSINESS"] = false;
		defines["ROUGHNESS"] = false;
		defines["EMISSIVEASILLUMINATION"] = false;
		defines["LINKEMISSIVEWITHDIFFUSE"] = false;
		defines["REFLECTIONFRESNELFROMSPECULAR"] = false;
		defines["LIGHTMAP"] = false;
		defines["USELIGHTMAPASSHADOWMAP"] = false;
		defines["REFLECTIONMAP_3D"] = false;
        defines["REFLECTIONMAP_SPHERICAL"] = false;
        defines["REFLECTIONMAP_PLANAR"] = false;
        defines["REFLECTIONMAP_CUBIC"] = false;
        defines["REFLECTIONMAP_PROJECTION"] = false;
        defines["REFLECTIONMAP_SKYBOX"] = false;
        defines["REFLECTIONMAP_EXPLICIT"] = false;
		defines["REFLECTIONMAP_EQUIRECTANGULAR"] = false;
		defines["INVERTCUBICMAP"] = false;
		
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
