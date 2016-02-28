package com.babylonhx.materials.lib.pbr;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialDefines extends MaterialDefines {
		
	static public inline var ALBEDO:Int = 0;
	static public inline var AMBIENT:Int = 1;
	static public inline var OPACITY:Int = 2;
	static public inline var OPACITYRGB:Int = 3;
	static public inline var REFLECTION:Int = 4;
	static public inline var EMISSIVE:Int = 5;
	static public inline var REFLECTIVITY:Int = 6;
	static public inline var BUMP:Int = 7;
	static public inline var SPECULAROVERALPHA:Int = 8;
	static public inline var CLIPPLANE:Int = 9;
	static public inline var ALPHATEST:Int = 10;
	static public inline var ALPHAFROMALBEDO:Int = 11;
	static public inline var POINTSIZE:Int = 12;
	static public inline var FOG:Int = 13;
	static public inline var LIGHT0:Int = 14;
	static public inline var LIGHT1:Int = 15;
	static public inline var LIGHT2:Int = 16;
	static public inline var LIGHT3:Int = 17;
	static public inline var SPOTLIGHT0:Int = 18;
	static public inline var SPOTLIGHT1:Int = 19;
	static public inline var SPOTLIGHT2:Int = 20;
	static public inline var SPOTLIGHT3:Int = 21;
	static public inline var HEMILIGHT0:Int = 22;
	static public inline var HEMILIGHT1:Int = 23;
	static public inline var HEMILIGHT2:Int = 24;
	static public inline var HEMILIGHT3:Int = 25;
	static public inline var POINTLIGHT0:Int = 26;
	static public inline var POINTLIGHT1:Int = 27;
	static public inline var POINTLIGHT2:Int = 28;
	static public inline var POINTLIGHT3:Int = 29;
	static public inline var DIRLIGHT0:Int = 30;
	static public inline var DIRLIGHT1:Int = 31;
	static public inline var DIRLIGHT2:Int = 32;
	static public inline var DIRLIGHT3:Int = 33;
	static public inline var SPECULARTERM:Int = 34;
	static public inline var SHADOW0:Int = 35;
	static public inline var SHADOW1:Int = 36;
	static public inline var SHADOW2:Int = 37;
	static public inline var SHADOW3:Int = 38;
	static public inline var SHADOWS:Int = 39;
	static public inline var SHADOWVSM0:Int = 40;
	static public inline var SHADOWVSM1:Int = 41;
	static public inline var SHADOWVSM2:Int = 42;
	static public inline var SHADOWVSM3:Int = 43;
	static public inline var SHADOWPCF0:Int = 44;
	static public inline var SHADOWPCF1:Int = 45;
	static public inline var SHADOWPCF2:Int = 46;
	static public inline var SHADOWPCF3:Int = 47;
	static public inline var OPACITYFRESNEL:Int = 48;
	static public inline var EMISSIVEFRESNEL:Int = 49;
	static public inline var FRESNEL:Int = 50;
	static public inline var NORMAL:Int = 51;
	static public inline var UV1:Int = 52;
	static public inline var UV2:Int = 53;
	static public inline var VERTEXCOLOR:Int = 54;
	static public inline var VERTEXALPHA:Int = 55;
	static public inline var INSTANCES:Int = 56;
	static public inline var MICROSURFACEFROMREFLECTIVITYMAP:Int = 57;
	static public inline var MICROSURFACEAUTOMATIC:Int = 58;
	static public inline var EMISSIVEASILLUMINATION:Int = 59;
	static public inline var LINKEMISSIVEWITHALBEDO:Int = 60;
	static public inline var LIGHTMAP:Int = 61;
	static public inline var USELIGHTMAPASSHADOWMAP:Int = 62;
	static public inline var REFLECTIONMAP_3D:Int = 63;
	static public inline var REFLECTIONMAP_SPHERICAL:Int = 64;
	static public inline var REFLECTIONMAP_PLANAR:Int = 65;
	static public inline var REFLECTIONMAP_CUBIC:Int = 66;
	static public inline var REFLECTIONMAP_PROJECTION:Int = 67;
	static public inline var REFLECTIONMAP_SKYBOX:Int = 68;
	static public inline var REFLECTIONMAP_EXPLICIT:Int = 69;
	static public inline var REFLECTIONMAP_EQUIRECTANGULAR:Int = 70;
	static public inline var INVERTCUBICMAP:Int = 71;
	static public inline var LOGARITHMICDEPTH:Int = 72;
	static public inline var CAMERATONEMAP:Int = 73;
	static public inline var CAMERACONTRAST:Int = 74;
	static public inline var OVERLOADEDVALUES:Int = 75;
	static public inline var OVERLOADEDSHADOWVALUES:Int = 76;
	static public inline var USESPHERICALFROMREFLECTIONMAP:Int = 77;
	static public inline var REFRACTION:Int = 78;
	static public inline var REFRACTIONMAP_3D:Int = 79;
	static public inline var LINKREFRACTIONTOTRANSPARENCY:Int = 80;
	static public inline var REFRACTIONMAPINLINEARSPACE:Int = 81;
	static public inline var LODBASEDMICROSFURACE:Int = 82;
	static public inline var USEPHYSICALLIGHTFALLOFF:Int = 83;
	static public inline var RADIANCEOVERALPHA:Int = 84;
	static public inline var PARALLAX:Int = 85;
	static public inline var PARALLAXOCCLUSION:Int = 86;
	static public inline var USEPMREMREFLECTION:Int = 87;
	static public inline var USEPMREMREFRACTION:Int = 88;
	
	public static var LIGHTS:Map<String, Array<Int>> = [
		"POINTLIGHT" => [POINTLIGHT0, POINTLIGHT1, POINTLIGHT2, POINTLIGHT3],
		"HEMILIGHT" => [HEMILIGHT0, HEMILIGHT1, HEMILIGHT2, HEMILIGHT3],
		"DIRLIGHT" => [DIRLIGHT0, DIRLIGHT1, DIRLIGHT2, DIRLIGHT3],
		"SPOTLIGHT" => [SPOTLIGHT0, SPOTLIGHT1, SPOTLIGHT2, SPOTLIGHT3]
	];
	
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	

	public function new() {
		super();
		
		this._keys = Vector.fromArrayCopy(["ALBEDO", "AMBIENT", "OPACITY", "OPACITYRGB", "REFLECTION", "EMISSIVE", "REFLECTIVITY", "BUMP", "SPECULAROVERALPHA", "CLIPPLANE", "ALPHATEST", "ALPHAFROMALBEDO", "POINTSIZE", "FOG", "LIGHT0", "LIGHT1", "LIGHT2", "LIGHT3", "SPOTLIGHT0", "SPOTLIGHT1", "SPOTLIGHT2", "SPOTLIGHT3", "HEMILIGHT0", "HEMILIGHT1", "HEMILIGHT2", "HEMILIGHT3", "POINTLIGHT0", "POINTLIGHT1", "POINTLIGHT2", "POINTLIGHT3", "DIRLIGHT0", "DIRLIGHT1", "DIRLIGHT2", "DIRLIGHT3", "SPECULARTERM", "SHADOW0", "SHADOW1", "SHADOW2", "SHADOW3", "SHADOWS", "SHADOWVSM0", "SHADOWVSM1", "SHADOWVSM2", "SHADOWVSM3", "SHADOWPCF0", "SHADOWPCF1", "SHADOWPCF2", "SHADOWPCF3", "OPACITYFRESNEL", "EMISSIVEFRESNEL", "FRESNEL", "NORMAL", "UV1", "UV2", "VERTEXCOLOR", "VERTEXALPHA", "INSTANCES", "MICROSURFACEFROMREFLECTIVITYMAP", "MICROSURFACEAUTOMATIC", "EMISSIVEASILLUMINATION", "LINKEMISSIVEWITHALBEDO", "LIGHTMAP", "USELIGHTMAPASSHADOWMAP", "REFLECTIONMAP_3D", "REFLECTIONMAP_SPHERICAL", "REFLECTIONMAP_PLANAR", "REFLECTIONMAP_CUBIC", "REFLECTIONMAP_PROJECTION", "REFLECTIONMAP_SKYBOX", "REFLECTIONMAP_EXPLICIT", "REFLECTIONMAP_EQUIRECTANGULAR", "INVERTCUBICMAP", "LOGARITHMICDEPTH", "CAMERATONEMAP", "CAMERACONTRAST", "OVERLOADEDVALUES", "OVERLOADEDSHADOWVALUES", "USESPHERICALFROMREFLECTIONMAP", "REFRACTION", "REFRACTIONMAP_3D", "LINKREFRACTIONTOTRANSPARENCY", "REFRACTIONMAPINLINEARSPACE", "LODBASEDMICROSFURACE", "USEPHYSICALLIGHTFALLOFF", "RADIANCEOVERALPHA", "PARALLAX", "PARALLAXOCCLUSION", "USEPMREMREFLECTION", "USEPMREMREFRACTION"]);
		
		defines = new Vector(this._keys.length);
		for (i in 0...this._keys.length) {
			defines[i] = false;
		}
		
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
