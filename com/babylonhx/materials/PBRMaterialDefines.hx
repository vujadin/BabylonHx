package com.babylonhx.materials;

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
	static public inline var PARALLAX:Int = 8; 
	static public inline var PARALLAXOCCLUSION:Int = 9; 
	static public inline var SPECULAROVERALPHA:Int = 10; 
	static public inline var CLIPPLANE:Int = 11; 
	static public inline var ALPHATEST:Int = 12; 
	static public inline var ALPHAFROMALBEDO:Int = 13; 
	static public inline var POINTSIZE:Int = 14; 
	static public inline var FOG:Int = 15; 
	static public inline var SPECULARTERM:Int = 16; 
	static public inline var OPACITYFRESNEL:Int = 17; 
	static public inline var EMISSIVEFRESNEL:Int = 18; 
	static public inline var FRESNEL:Int = 19; 
	static public inline var NORMAL:Int = 20; 
	static public inline var UV1:Int = 21; 
	static public inline var UV2:Int = 22; 
	static public inline var VERTEXCOLOR:Int = 23; 
	static public inline var VERTEXALPHA:Int = 24; 
	static public inline var INSTANCES:Int = 25; 
	static public inline var MICROSURFACEFROMREFLECTIVITYMAP:Int = 26; 
	static public inline var MICROSURFACEAUTOMATIC:Int = 27; 
	static public inline var EMISSIVEASILLUMINATION:Int = 28; 
	static public inline var LINKEMISSIVEWITHALBEDO:Int = 29; 
	static public inline var LIGHTMAP:Int = 30; 
	static public inline var USELIGHTMAPASSHADOWMAP:Int = 31; 
	static public inline var REFLECTIONMAP_3D:Int = 32; 
	static public inline var REFLECTIONMAP_SPHERICAL:Int = 33; 
	static public inline var REFLECTIONMAP_PLANAR:Int = 34; 
	static public inline var REFLECTIONMAP_CUBIC:Int = 35; 
	static public inline var REFLECTIONMAP_PROJECTION:Int = 36; 
	static public inline var REFLECTIONMAP_SKYBOX:Int = 37; 
	static public inline var REFLECTIONMAP_EXPLICIT:Int = 38; 
	static public inline var REFLECTIONMAP_EQUIRECTANGULAR:Int = 39; 
	static public inline var INVERTCUBICMAP:Int = 40; 
	static public inline var LOGARITHMICDEPTH:Int = 41; 
	static public inline var CAMERATONEMAP:Int = 42; 
	static public inline var CAMERACONTRAST:Int = 43; 
	static public inline var CAMERACOLORGRADING:Int = 44; 
	static public inline var OVERLOADEDVALUES:Int = 45; 
	static public inline var OVERLOADEDSHADOWVALUES:Int = 46; 
	static public inline var USESPHERICALFROMREFLECTIONMAP:Int = 47; 
	static public inline var REFRACTION:Int = 48; 
	static public inline var REFRACTIONMAP_3D:Int = 49; 
	static public inline var LINKREFRACTIONTOTRANSPARENCY:Int = 50; 
	static public inline var REFRACTIONMAPINLINEARSPACE:Int = 51; 
	static public inline var LODBASEDMICROSFURACE:Int = 52; 
	static public inline var USEPHYSICALLIGHTFALLOFF:Int = 53; 
	static public inline var RADIANCEOVERALPHA:Int = 54; 
	static public inline var USEPMREMREFLECTION:Int = 55; 
	static public inline var USEPMREMREFRACTION:Int = 56;
	static public inline var INVERTNORMALMAPX:Int = 57;
	static public inline var INVERTNORMALMAPY:Int = 58;	
	static public inline var METALLICWORKFLOW:Int = 59;
	static public inline var METALLICROUGHNESSMAP:Int = 60;
	static public inline var METALLICROUGHNESSGSTOREINALPHA:Int = 61;
	static public inline var METALLICROUGHNESSGSTOREINGREEN:Int = 62;
	
	static public inline var SHADOWS:Int = 63;
	
	static public inline var CAMERACOLORCURVES:Int = 64;
	
	static public inline var SHADOWFULLFLOAT:Int = 65;
	
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	

	public function new() {
		super();
		
		this._keys = Vector.fromArrayCopy(["ALBEDO", "AMBIENT", "OPACITY", "OPACITYRGB", "REFLECTION", "EMISSIVE", "REFLECTIVITY", "BUMP", "PARALLAX", "PARALLAXOCCLUSION", "SPECULAROVERALPHA", "CLIPPLANE", "ALPHATEST", "ALPHAFROMALBEDO", "POINTSIZE", "FOG", "SPECULARTERM", "OPACITYFRESNEL", "EMISSIVEFRESNEL", "FRESNEL", "NORMAL", "UV1", "UV2", "VERTEXCOLOR", "VERTEXALPHA", "INSTANCES", "MICROSURFACEFROMREFLECTIVITYMAP", "MICROSURFACEAUTOMATIC", "EMISSIVEASILLUMINATION", "LINKEMISSIVEWITHALBEDO", "LIGHTMAP", "USELIGHTMAPASSHADOWMAP", "REFLECTIONMAP_3D", "REFLECTIONMAP_SPHERICAL", "REFLECTIONMAP_PLANAR", "REFLECTIONMAP_CUBIC", "REFLECTIONMAP_PROJECTION", "REFLECTIONMAP_SKYBOX", "REFLECTIONMAP_EXPLICIT", "REFLECTIONMAP_EQUIRECTANGULAR", "INVERTCUBICMAP", "LOGARITHMICDEPTH", "CAMERATONEMAP", "CAMERACONTRAST", "CAMERACOLORGRADING", "OVERLOADEDVALUES", "OVERLOADEDSHADOWVALUES", "USESPHERICALFROMREFLECTIONMAP", "REFRACTION", "REFRACTIONMAP_3D", "LINKREFRACTIONTOTRANSPARENCY", "REFRACTIONMAPINLINEARSPACE", "LODBASEDMICROSFURACE", "USEPHYSICALLIGHTFALLOFF", "RADIANCEOVERALPHA", "USEPMREMREFLECTION", "USEPMREMREFRACTION", "INVERTNORMALMAPX", "INVERTNORMALMAPY", "METALLICWORKFLOW", "METALLICROUGHNESSMAP", "METALLICROUGHNESSGSTOREINALPHA", "METALLICROUGHNESSGSTOREINGREEN", "SHADOWS", "CAMERACOLORCURVES", "SHADOWFULLFLOAT"]);
		
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
