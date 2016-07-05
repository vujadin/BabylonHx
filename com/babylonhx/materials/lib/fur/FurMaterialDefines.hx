package com.babylonhx.materials.lib.fur;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class FurMaterialDefines extends MaterialDefines {
	
	public static inline var DIFFUSE:Int = 0;
	public static inline var HEIGHTMAP:Int = 1;
	public static inline var CLIPPLANE:Int = 2;
	public static inline var ALPHATEST:Int = 3;
	public static inline var POINTSIZE:Int = 4;
	public static inline var FOG:Int = 5;
	public static inline var NORMAL:Int = 6;
	public static inline var UV1:Int = 7;
	public static inline var UV2:Int = 8;
	public static inline var VERTEXCOLOR:Int = 9;
	public static inline var VERTEXALPHA:Int = 10;
	public static inline var INSTANCES:Int = 11;
	public static inline var HIGHLEVEL:Int = 12;	
	public static inline var SHADOWS:Int = 13;
	public static inline var SHADOWFULLFLOAT:Int = 14;	
	
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	
	
	public function new() {
		super();
		
		this._keys = Vector.fromArrayCopy(["DIFFUSE", "HEIGHTMAP", "CLIPPLANE", "ALPHATEST", "POINTSIZE", "FOG", "NORMAL", "UV1", "UV2", "VERTEXCOLOR", "VERTEXALPHA", "INSTANCES", "HIGHLEVEL", "SHADOWS", "SHADOWFULLFLOAT"]);
		
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