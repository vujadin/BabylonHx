package com.babylonhx.materials.lib.water;

import com.babylonhx.tools.serialization.SerializationHelper;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class WaterMaterialDefines extends MaterialDefines {
	
	public static inline var BUMP:Int = 0;
	public static inline var REFLECTION:Int = 1;
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
	public static inline var SPECULARTERM:Int = 12;	
	public static inline var SHADOWS:Int = 13;
	public static inline var LOGARITHMICDEPTH:Int = 14;
    public static inline var FRESNELSEPARATE:Int = 15;
    public static inline var BUMPSUPERIMPOSE:Int = 16;
    public static inline var BUMPAFFECTSREFLECTION:Int = 17;
	
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	
	
	public function new() {
		super();
		
		this._keys = Vector.fromArrayCopy(["BUMP", "REFLECTION", "CLIPPLANE", "ALPHATEST", "POINTSIZE", "FOG", "NORMAL", "UV1", "UV2", "VERTEXCOLOR", "VERTEXALPHA", "INSTANCES", "SPECULARTERM", "SHADOWS", "LOGARITHMICDEPTH", "FRESNELSEPARATE", "BUMPSUPERIMPOSE", "BUMPAFFECTSREFLECTION"]);
		
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
