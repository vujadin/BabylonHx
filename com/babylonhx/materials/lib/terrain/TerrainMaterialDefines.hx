package com.babylonhx.materials.lib.terrain;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TerrainMaterialDefines extends MaterialDefines {
		
	public static inline var DIFFUSE:Int = 0;
	public static inline var BUMP:Int = 1;
	public static inline var CLIPPLANE:Int = 2;
	public static inline var ALPHATEST:Int = 3;
	public static inline var POINTSIZE:Int = 4;
	public static inline var FOG:Int = 5;
	public static inline var LIGHT0:Int = 6;
	public static inline var LIGHT1:Int = 7;
	public static inline var LIGHT2:Int = 8;
	public static inline var LIGHT3:Int = 9;
	public static inline var SPOTLIGHT0:Int = 10;
	public static inline var SPOTLIGHT1:Int = 11;
	public static inline var SPOTLIGHT2:Int = 12;
	public static inline var SPOTLIGHT3:Int = 13;
	public static inline var HEMILIGHT0:Int = 14;
	public static inline var HEMILIGHT1:Int = 15;
	public static inline var HEMILIGHT2:Int = 16;
	public static inline var HEMILIGHT3:Int = 17;
	public static inline var POINTLIGHT0:Int = 18;
	public static inline var POINTLIGHT1:Int = 19;
	public static inline var POINTLIGHT2:Int = 20;
	public static inline var POINTLIGHT3:Int = 21;
	public static inline var DIRLIGHT0:Int = 22;
	public static inline var DIRLIGHT1:Int = 23;
	public static inline var DIRLIGHT2:Int = 24;
	public static inline var DIRLIGHT3:Int = 25;
	public static inline var SHADOW0:Int = 26;
	public static inline var SHADOW1:Int = 27;
	public static inline var SHADOW2:Int = 28;
	public static inline var SHADOW3:Int = 29;
	public static inline var SHADOWS:Int = 30;
	public static inline var SHADOWVSM0:Int = 31;
	public static inline var SHADOWVSM1:Int = 32;
	public static inline var SHADOWVSM2:Int = 33;
	public static inline var SHADOWVSM3:Int = 34;
	public static inline var SHADOWPCF0:Int = 35;
	public static inline var SHADOWPCF1:Int = 36;
	public static inline var SHADOWPCF2:Int = 37;
	public static inline var SHADOWPCF3:Int = 38;
	public static inline var SPECULARTERM:Int = 39;
	public static inline var NORMAL:Int = 40;
	public static inline var UV1:Int = 41;
	public static inline var UV2:Int = 42;
	public static inline var VERTEXCOLOR:Int = 43;
	public static inline var VERTEXALPHA:Int = 44;
	public static inline var INSTANCES:Int = 45;
	
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
		
		this._keys = Vector.fromArrayCopy(["DIFFUSE", "BUMP", "CLIPPLANE", "ALPHATEST", "POINTSIZE", "FOG", "LIGHT0", "LIGHT1", "LIGHT2", "LIGHT3", "SPOTLIGHT0", "SPOTLIGHT1", "SPOTLIGHT2", "SPOTLIGHT3", "HEMILIGHT0", "HEMILIGHT1", "HEMILIGHT2", "HEMILIGHT3", "POINTLIGHT0", "POINTLIGHT1", "POINTLIGHT2", "POINTLIGHT3", "DIRLIGHT0", "DIRLIGHT1", "DIRLIGHT2", "DIRLIGHT3", "SHADOW0", "SHADOW1", "SHADOW2", "SHADOW3", "SHADOWS", "SHADOWVSM0", "SHADOWVSM1", "SHADOWVSM2", "SHADOWVSM3", "SHADOWPCF0", "SHADOWPCF1", "SHADOWPCF2", "SHADOWPCF3", "SPECULARTERM", "NORMAL", "UV1", "UV2", "VERTEXCOLOR", "VERTEXALPHA", "INSTANCES"]);
		
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
	
	public function getLight(lightType:String, lightIndex:Int):Int {
		switch (lightType) {
			case "POINTLIGHT":
				switch (lightIndex) {
					case 0:
						return POINTLIGHT0;
						
					case 1:
						return POINTLIGHT1;
						
					case 2:
						return POINTLIGHT2;
						
					case 3:
						return POINTLIGHT3;
				}
				
			case "HEMILIGHT":
				switch (lightIndex) {
					case 0:
						return HEMILIGHT0;
						
					case 1:
						return HEMILIGHT1;
						
					case 2:
						return HEMILIGHT2;
						
					case 3:
						return HEMILIGHT3;
				}
				
			case "DIRLIGHT":
				switch (lightIndex) {
					case 0:
						return DIRLIGHT0;
						
					case 1:
						return DIRLIGHT1;
						
					case 2:
						return DIRLIGHT2;
						
					case 3:
						return DIRLIGHT3;
				}
				
			case "SPOTLIGHT":
				switch (lightIndex) {
					case 0:
						return SPOTLIGHT0;
						
					case 1:
						return SPOTLIGHT1;
						
					case 2:
						return SPOTLIGHT2;
						
					case 3:
						return SPOTLIGHT3;
				}
				
		}
		
		return -1;
	}
	
}
