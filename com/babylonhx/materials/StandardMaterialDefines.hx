package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StandardMaterialDefines extends MaterialDefines {
	
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	
	
	public function new() {
		super();
		
		this.defines = [
			"DIFFUSE" => false, 
			"AMBIENT" => false, 
			"OPACITY" => false, 
			"OPACITYRGB" => false, 
			"REFLECTION" => false, 
			"EMISSIVE" => false, 
			"SPECULAR" => false, 
			"BUMP" => false, 
			"PARALLAX" => false, 
			"PARALLAXOCCLUSION" => false, 
			"SPECULAROVERALPHA" => false, 
			"CLIPPLANE" => false, 
			"ALPHATEST" => false, 
			"ALPHAFROMDIFFUSE" => false, 
			"POINTSIZE" => false, 
			"FOG" => false, 
			"SPECULARTERM" => false, 
			"DIFFUSEFRESNEL" => false, 
			"OPACITYFRESNEL" => false, 
			"REFLECTIONFRESNEL" => false, 
			"REFRACTIONFRESNEL" => false, 
			"EMISSIVEFRESNEL" => false, 
			"FRESNEL" => false, 
			"NORMAL" => false, 
			"UV1" => false, 
			"UV2" => false, 
			"VERTEXCOLOR" => false, 
			"VERTEXALPHA" => false, 
			"INSTANCES" => false, 
			"GLOSSINESS" => false, 
			"ROUGHNESS" => false, 
			"EMISSIVEASILLUMINATION" => false, 
			"LINKEMISSIVEWITHDIFFUSE" => false, 
			"REFLECTIONFRESNELFROMSPECULAR" => false, 
			"LIGHTMAP" => false, 
			"USELIGHTMAPASSHADOWMAP" => false, 
			"REFLECTIONMAP_3D" => false, 
			"REFLECTIONMAP_SPHERICAL" => false, 
			"REFLECTIONMAP_PLANAR" => false, 
			"REFLECTIONMAP_CUBIC" => false, 
			"REFLECTIONMAP_PROJECTION" => false, 
			"REFLECTIONMAP_SKYBOX" => false, 
			"REFLECTIONMAP_EXPLICIT" => false, 
			"REFLECTIONMAP_EQUIRECTANGULAR" => false, 
			"REFLECTIONMAP_EQUIRECTANGULAR_FIXED" => false, 
			"INVERTCUBICMAP" => false, 
			"LOGARITHMICDEPTH" => false, 
			"REFRACTION" => false, 
			"REFRACTIONMAP_3D" => false, 
			"REFLECTIONOVERALPHA" => false,
			"INVERTNORMALMAPX" => false,
			"INVERTNORMALMAPY" => false
		];
		
		BonesPerMesh = 0;
		NUM_BONE_INFLUENCERS = 0;		
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.BonesPerMesh = this.BonesPerMesh;
		untyped other.NUM_BONE_INFLUENCERS = this.NUM_BONE_INFLUENCERS;
	}
	
	override public function reset() {
		super.reset();
		
		this.BonesPerMesh = 0;
		this.NUM_BONE_INFLUENCERS = 0;
	}

	override public function toString():String {
		var result = super.toString();
		
		result += "#define BonesPerMesh " + this.BonesPerMesh + "\n";
		result += "#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + "\n";
		
		return result;
	}
	
}
