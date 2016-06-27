package com.babylonhx.materials.lib.triplanar;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TriPlanarMaterialDefines extends MaterialDefines {
		
	public var BonesPerMesh:Int = 0;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	

	public function new() {
		super();
		
		this.defines = [
			"DIFFUSEX" => false,
			"DIFFUSEY" => false,
			"DIFFUSEZ" => false,
			"BUMPX" => false,
			"BUMPY" => false,
			"BUMPZ" => false,
			"CLIPPLANE" => false,
			"ALPHATEST" => false,
			"POINTSIZE" => false,
			"FOG" => false,
			"SPECULARTERM" => false,
			"NORMAL" => false,
			"VERTEXCOLOR" => false,
			"VERTEXALPHA" => false,
			"INSTANCES" => false
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
