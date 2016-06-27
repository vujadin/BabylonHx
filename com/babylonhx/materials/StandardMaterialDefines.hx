package com.babylonhx.materials;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StandardMaterialDefines extends MaterialDefines {
	
	static public inline var DIFFUSE:Int = 0;
	static public inline var AMBIENT:Int = 1;
	static public inline var OPACITY:Int = 2;
	static public inline var OPACITYRGB:Int = 3;
	static public inline var REFLECTION:Int = 4;
	static public inline var EMISSIVE:Int = 5;
	static public inline var SPECULAR:Int = 6;
	static public inline var BUMP:Int = 7;
	static public inline var PARALLAX:Int = 8;
	static public inline var PARALLAXOCCLUSION:Int = 9;
	static public inline var SPECULAROVERALPHA:Int = 10;
	static public inline var CLIPPLANE:Int = 11;
	static public inline var ALPHATEST:Int = 12;
	static public inline var ALPHAFROMDIFFUSE:Int = 13;
	static public inline var POINTSIZE:Int = 14;
	static public inline var FOG:Int = 15;	
	static public inline var SPECULARTERM:Int = 16;	
	static public inline var DIFFUSEFRESNEL:Int = 17;
	static public inline var OPACITYFRESNEL:Int = 18;
	static public inline var REFLECTIONFRESNEL:Int = 19;
	static public inline var REFRACTIONFRESNEL:Int = 20;
	static public inline var EMISSIVEFRESNEL:Int = 21;
	static public inline var FRESNEL:Int = 22;
	static public inline var NORMAL:Int = 23;
	static public inline var UV1:Int = 24;
	static public inline var UV2:Int = 25;
	static public inline var VERTEXCOLOR:Int = 26;
	static public inline var VERTEXALPHA:Int = 27;
	static public inline var INSTANCES:Int = 28;
	static public inline var GLOSSINESS:Int = 29;
	static public inline var ROUGHNESS:Int = 30;
	static public inline var EMISSIVEASILLUMINATION:Int = 31;
	static public inline var LINKEMISSIVEWITHDIFFUSE:Int = 32;
	static public inline var REFLECTIONFRESNELFROMSPECULAR:Int = 33;
	static public inline var LIGHTMAP:Int = 34;
	static public inline var USELIGHTMAPASSHADOWMAP:Int = 35;
	static public inline var REFLECTIONMAP_3D:Int = 36;
	static public inline var REFLECTIONMAP_SPHERICAL:Int = 37;
	static public inline var REFLECTIONMAP_PLANAR:Int = 38;
	static public inline var REFLECTIONMAP_CUBIC:Int = 39;
	static public inline var REFLECTIONMAP_PROJECTION:Int = 40;
	static public inline var REFLECTIONMAP_SKYBOX:Int = 41;
	static public inline var REFLECTIONMAP_EXPLICIT:Int = 42;
	static public inline var REFLECTIONMAP_EQUIRECTANGULAR:Int = 43;
	static public inline var REFLECTIONMAP_EQUIRECTANGULAR_FIXED:Int = 44;
	static public inline var INVERTCUBICMAP:Int = 45;
	static public inline var LOGARITHMICDEPTH:Int = 46;
	static public inline var REFRACTION:Int = 47;
	static public inline var REFRACTIONMAP_3D:Int = 48;
	static public inline var REFLECTIONOVERALPHA:Int = 49;
	static public inline var INVERTNORMALMAPX:Int = 50;
	static public inline var INVERTNORMALMAPY:Int = 51;
	static public inline var SHADOWS:Int = 52;
	
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	
	
	public function new() {
		super();
		
		this._keys = Vector.fromArrayCopy(["DIFFUSE", "AMBIENT", "OPACITY", "OPACITYRGB", "REFLECTION", "EMISSIVE", "SPECULAR", "BUMP", "PARALLAX", "PARALLAXOCCLUSION", "SPECULAROVERALPHA", "CLIPPLANE", "ALPHATEST", "ALPHAFROMDIFFUSE", "POINTSIZE", "FOG", "SPECULARTERM", "DIFFUSEFRESNEL", "OPACITYFRESNEL", "REFLECTIONFRESNEL", "REFRACTIONFRESNEL", "EMISSIVEFRESNEL", "FRESNEL", "NORMAL", "UV1", "UV2", "VERTEXCOLOR", "VERTEXALPHA", "INSTANCES", "GLOSSINESS", "ROUGHNESS", "EMISSIVEASILLUMINATION", "LINKEMISSIVEWITHDIFFUSE", "REFLECTIONFRESNELFROMSPECULAR", "LIGHTMAP", "USELIGHTMAPASSHADOWMAP", "REFLECTIONMAP_3D", "REFLECTIONMAP_SPHERICAL", "REFLECTIONMAP_PLANAR", "REFLECTIONMAP_CUBIC", "REFLECTIONMAP_PROJECTION", "REFLECTIONMAP_SKYBOX", "REFLECTIONMAP_EXPLICIT", "REFLECTIONMAP_EQUIRECTANGULAR", "REFLECTIONMAP_EQUIRECTANGULAR_FIXED", "INVERTCUBICMAP", "LOGARITHMICDEPTH", "REFRACTION", "REFRACTIONMAP_3D", "REFLECTIONOVERALPHA", "INVERTNORMALMAPX", "INVERTNORMALMAPY", "SHADOWS"]);
		
		defines = new Vector<Bool>(this._keys.length);
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
