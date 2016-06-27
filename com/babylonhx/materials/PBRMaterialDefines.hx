package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialDefines extends MaterialDefines {
	
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	

	public function new() {
		super();
		
		this.defines = [
			"ALBEDO" => false, 
			"AMBIENT" => false, 
			"OPACITY" => false, 
			"OPACITYRGB" => false, 
			"REFLECTION" => false, 
			"EMISSIVE" => false, 
			"REFLECTIVITY" => false, 
			"BUMP" => false, 
			"PARALLAX" => false, 
			"PARALLAXOCCLUSION" => false, 
			"SPECULAROVERALPHA" => false, 
			"CLIPPLANE" => false, 
			"ALPHATEST" => false, 
			"ALPHAFROMALBEDO" => false, 
			"POINTSIZE" => false, 
			"FOG" => false, 
			"SPECULARTERM" => false, 
			"OPACITYFRESNEL" => false, 
			"EMISSIVEFRESNEL" => false, 
			"FRESNEL" => false, 
			"NORMAL" => false, 
			"UV1" => false, 
			"UV2" => false, 
			"VERTEXCOLOR" => false, 
			"VERTEXALPHA" => false, 
			"INSTANCES" => false, 
			"MICROSURFACEFROMREFLECTIVITYMAP" => false, 
			"MICROSURFACEAUTOMATIC" => false, 
			"EMISSIVEASILLUMINATION" => false, 
			"LINKEMISSIVEWITHALBEDO" => false, 
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
			"INVERTCUBICMAP" => false, 
			"LOGARITHMICDEPTH" => false, 
			"CAMERATONEMAP" => false, 
			"CAMERACONTRAST" => false, 
			"CAMERACOLORGRADING" => false, 
			"OVERLOADEDVALUES" => false, 
			"OVERLOADEDSHADOWVALUES" => false, 
			"USESPHERICALFROMREFLECTIONMAP" => false, 
			"REFRACTION" => false, 
			"REFRACTIONMAP_3D" => false, 
			"LINKREFRACTIONTOTRANSPARENCY" => false, 
			"REFRACTIONMAPINLINEARSPACE" => false, 
			"LODBASEDMICROSFURACE" => false, 
			"USEPHYSICALLIGHTFALLOFF" => false, 
			"RADIANCEOVERALPHA" => false, 
			"USEPMREMREFLECTION" => false, 
			"USEPMREMREFRACTION" => false,
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
