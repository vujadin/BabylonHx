package com.babylonhx.materials.lib.fire;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class FireMaterialDefines extends MaterialDefines {
		
	public static inline var DIFFUSE:Int = 0;
	public static inline var CLIPPLANE:Int = 1;
	public static inline var ALPHATEST:Int = 2;
	public static inline var POINTSIZE:Int = 3;
	public static inline var FOG:Int = 4;
	public static inline var UV1:Int = 5;
	public static inline var NORMAL:Int = 6;
	public static inline var VERTEXCOLOR:Int = 7;
	public static inline var VERTEXALPHA:Int = 8;
	public static inline var INSTANCES:Int = 9;
	
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	

	public function new() {
		super();
		
		this._keys = Vector.fromData(["DIFFUSE", "CLIPPLANE", "ALPHATEST", "POINTSIZE", "FOG", "UV1", "NORMAL", "VERTEXCOLOR", "VERTEXALPHA", "BONES", "BONES4", "INSTANCES"]);		
		
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
