package com.babylonhx.materials.lib.cell;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CellMaterialDefines extends MaterialDefines {
	
	public var DIFFUSE:Bool = false;
	public var CLIPPLANE:Bool = false;
	public var ALPHATEST:Bool = false;
	public var DEPTHPREPASS:Bool = false;
	public var POINTSIZE:Bool = false;
	public var FOG:Bool = false;
	public var NORMAL:Bool = false;
	public var UV1:Bool = false;
	public var UV2:Bool = false;
	public var VERTEXCOLOR:Bool = false;
	public var VERTEXALPHA:Bool = false;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	public var BonesPerMesh:Int = 0;
	public var INSTANCES:Bool = false;
	public var NDOTL:Bool = true;
	public var CUSTOMUSERLIGHTING:Bool = true;
	public var CELLBASIC:Bool = true;

	
	public function new() {
		super();
	}
	
	override public function isEqual(other:MaterialDefines):Bool {
		if (super.isEqual(other)) {
			if (untyped this.DIFFUSE != other.DIFFUSE) return false;
			if (untyped this.CLIPPLANE != other.CLIPPLANE) return false;
			if (untyped this.ALPHATEST != other.ALPHATEST) return false;
			if (untyped this.DEPTHPREPASS != other.DEPTHPREPASS) return false;
			if (untyped this.POINTSIZE != other.POINTSIZE) return false; 
			if (untyped this.FOG != other.FOG) return false;
			if (untyped this.NORMAL != other.NORMAL) return false;
			if (untyped this.UV1 != other.UV1) return false;
			if (untyped this.UV2 != other.UV2) return false;
			if (untyped this.VERTEXCOLOR != other.VERTEXCOLOR) return false;
			if (untyped this.VERTEXALPHA != other.VERTEXALPHA) return false; 
			if (untyped this.BonesPerMesh != other.BonesPerMesh) return false;
			if (untyped this.NUM_BONE_INFLUENCERS != other.NUM_BONE_INFLUENCERS) return false;
			if (untyped this.INSTANCES != other.INSTANCES) return false; 
			if (untyped this.NDOTL != other.NDOTL) return false;
			if (untyped this.CUSTOMUSERLIGHTING != other.CUSTOMUSERLIGHTING) return false;
			if (untyped this.CELLBASIC != other.CELLBASIC) return false;
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.DIFFUSE = this.DIFFUSE;
		untyped other.CLIPPLANE = this.CLIPPLANE;
		untyped other.ALPHATEST = this.ALPHATEST;
		untyped other.DEPTHPREPASS = this.DEPTHPREPASS;
		untyped other.POINTSIZE = this.POINTSIZE;
		untyped other.FOG = this.FOG;
		untyped other.NORMAL = this.NORMAL;
		untyped other.UV1 = this.UV1;
		untyped other.UV2 = this.UV2;
		untyped other.VERTEXCOLOR = this.VERTEXCOLOR;
		untyped other.VERTEXALPHA = this.VERTEXALPHA;		
		untyped other.BonesPerMesh = this.BonesPerMesh;
		untyped other.NUM_BONE_INFLUENCERS = this.NUM_BONE_INFLUENCERS;
		untyped other.INSTANCES = this.INSTANCES;
		untyped other.NDOTL = this.NDOTL;
		untyped other.CUSTOMUSERLIGHTING = this.CUSTOMUSERLIGHTING;
		untyped other.CELLBASIC = this.CELLBASIC;
	}
	
	override public function reset() {
		super.reset();
		
		this.DIFFUSE = false;
		this.CLIPPLANE = false;
		this.ALPHATEST = false;
		this.DEPTHPREPASS = false;
		this.POINTSIZE = false;
		this.FOG = false;
		this.NORMAL = false;
		this.UV1 = false;
		this.UV2 = false;
		this.VERTEXCOLOR = false;
		this.VERTEXALPHA = false;
		this.BonesPerMesh = 0;
		this.NUM_BONE_INFLUENCERS = 0;
		this.INSTANCES = false;
		this.NDOTL = false;
		this.CUSTOMUSERLIGHTING = false;
		this.CELLBASIC = false;
	}
	
	override public function toString():String {
		var result = super.toString();
		
		if (this.DIFFUSE) {
			result += "#define DIFFUSE \n";
		}
		if (this.CLIPPLANE) {
			result += "#define CLIPPLANE \n";
		}
		if (this.ALPHATEST) {
			result += "#define ALPHATEST \n";
		}
		if (this.DEPTHPREPASS) {
			result += "#define DEPTHPREPASS \n";
		}
		if (this.POINTSIZE) {
			result += "#define POINTSIZE \n";
		}
		if (this.FOG) {
			result += "#define FOG \n";
		}
		if (this.NORMAL) {
			result += "#define NORMAL \n";
		}
		if (this.UV1) {
			result += "#define UV1 \n";
		}
		if (this.UV2) {
			result += "#define UV2 \n";
		}
		if (this.VERTEXCOLOR) {
			result += "#define VERTEXCOLOR \n";
		}
		if (this.VERTEXALPHA) {
			result += "#define VERTEXALPHA \n";
		}
		if (this.INSTANCES) {
			result += "#define INSTANCES \n";
		}
		if (this.NDOTL) {
			result += "#define NDOTL \n";
		}
		if (this.CUSTOMUSERLIGHTING) {
			result += "#define CUSTOMUSERLIGHTING \n";
		}
		if (this.CELLBASIC) {
			result += "#define CELLBASIC \n";
		}
		
		result += "#define BonesPerMesh " + this.BonesPerMesh + "\n";
		result += "#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + "\n";
		
		return result;
	}
	
}
