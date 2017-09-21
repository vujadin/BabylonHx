package com.babylonhx.materials.lib.gradient;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GradientMaterialDefines extends MaterialDefines {
	
	public var DIFFUSE:Bool = false;
	public var CLIPPLANE:Bool = false;
	public var ALPHATEST:Bool = false;
	public var DEPTHPREPASS:Bool = false;
	public var POINTSIZE:Bool = false;
	public var FOG:Bool = false;
	public var LIGHT0:Bool = false;
	public var LIGHT1:Bool = false;
	public var LIGHT2:Bool = false;
	public var LIGHT3:Bool = false;
	public var SPOTLIGHT0:Bool = false;
	public var SPOTLIGHT1:Bool = false;
	public var SPOTLIGHT2:Bool = false;
	public var SPOTLIGHT3:Bool = false;
	public var HEMILIGHT0:Bool = false;
	public var HEMILIGHT1:Bool = false;
	public var HEMILIGHT2:Bool = false;
	public var HEMILIGHT3:Bool = false;
	public var DIRLIGHT0:Bool = false;
	public var DIRLIGHT1:Bool = false;
	public var DIRLIGHT2:Bool = false;
	public var DIRLIGHT3:Bool = false;
	public var POINTLIGHT0:Bool = false;
	public var POINTLIGHT1:Bool = false;
	public var POINTLIGHT2:Bool = false;
	public var POINTLIGHT3:Bool = false;        
	public var SHADOW0:Bool = false;
	public var SHADOW1:Bool = false;
	public var SHADOW2:Bool = false;
	public var SHADOW3:Bool = false;
	public var SHADOWS:Bool = false;
	public var SHADOWESM0:Bool = false;
	public var SHADOWESM1:Bool = false;
	public var SHADOWESM2:Bool = false;
	public var SHADOWESM3:Bool = false;
	public var SHADOWPCF0:Bool = false;
	public var SHADOWPCF1:Bool = false;
	public var SHADOWPCF2:Bool = false;
	public var SHADOWPCF3:Bool = false;
	public var NORMAL:Bool = false;
	public var UV1:Bool = false;
	public var UV2:Bool = false;
	public var VERTEXCOLOR:Bool = false;
	public var VERTEXALPHA:Bool = false;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	public var BonesPerMesh:Int = 0;
	public var INSTANCES:Bool = false;
	

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
			if (untyped this.LIGHT0 != other.LIGHT0) return false;
			if (untyped this.LIGHT1 != other.LIGHT1) return false;
			if (untyped this.LIGHT2 != other.LIGHT2) return false;
			if (untyped this.LIGHT3 != other.LIGHT3) return false;
			if (untyped this.SPOTLIGHT0 != other.SPOTLIGHT0) return false; 
			if (untyped this.SPOTLIGHT1 != other.SPOTLIGHT1) return false; 
			if (untyped this.SPOTLIGHT2 != other.SPOTLIGHT2) return false; 
			if (untyped this.SPOTLIGHT3 != other.SPOTLIGHT3) return false;
			if (untyped this.HEMILIGHT0 != other.HEMILIGHT0) return false;
			if (untyped this.HEMILIGHT1 != other.HEMILIGHT1) return false;
			if (untyped this.HEMILIGHT2 != other.HEMILIGHT2) return false;
			if (untyped this.HEMILIGHT3 != other.HEMILIGHT3) return false;
			if (untyped this.DIRLIGHT0 != other.DIRLIGHT0) return false;
			if (untyped this.DIRLIGHT1 != other.DIRLIGHT1) return false;			
			if (untyped this.DIRLIGHT2 != other.DIRLIGHT2) return false;
			if (untyped this.DIRLIGHT3 != other.DIRLIGHT3) return false;
			if (untyped this.POINTLIGHT0 != other.POINTLIGHT0) return false;
			if (untyped this.POINTLIGHT1 != other.POINTLIGHT1) return false;
			if (untyped this.POINTLIGHT2 != other.POINTLIGHT2) return false;
			if (untyped this.POINTLIGHT3 != other.POINTLIGHT3) return false;
			if (untyped this.SHADOW0 != other.SHADOW0) return false;
			if (untyped this.SHADOW1 != other.SHADOW1) return false;
			if (untyped this.SHADOW2 != other.SHADOW2) return false;
			if (untyped this.SHADOW3 != other.SHADOW3) return false;
			if (untyped this.SHADOWS != other.SHADOWS) return false;
			if (untyped this.SHADOWESM0 != other.SHADOWESM0) return false;
			if (untyped this.SHADOWESM1 != other.SHADOWESM1) return false;
			if (untyped this.SHADOWESM2 != other.SHADOWESM2) return false;
			if (untyped this.SHADOWESM3 != other.SHADOWESM3) return false;
			if (untyped this.SHADOWPCF0 != other.SHADOWPCF0) return false;
			if (untyped this.SHADOWPCF1 != other.SHADOWPCF1) return false;
			if (untyped this.SHADOWPCF2 != other.SHADOWPCF2) return false;
			if (untyped this.SHADOWPCF3 != other.SHADOWPCF3) return false;
			if (untyped this.NORMAL != other.NORMAL) return false;
			if (untyped this.UV1 != other.UV1) return false;
			if (untyped this.UV2 != other.UV2) return false;
			if (untyped this.VERTEXCOLOR != other.VERTEXCOLOR) return false;
			if (untyped this.VERTEXALPHA != other.VERTEXALPHA) return false;
			
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
		untyped other.LIGHT0 = this.LIGHT0;
		untyped other.LIGHT1 = this.LIGHT1;
		untyped other.LIGHT2 = this.LIGHT2;
		untyped other.LIGHT3 = this.LIGHT3;
		untyped other.SPOTLIGHT0 = this.SPOTLIGHT0;
		untyped other.SPOTLIGHT1 = this.SPOTLIGHT1;
		untyped other.SPOTLIGHT2 = this.SPOTLIGHT2;
		untyped other.SPOTLIGHT3 = this.SPOTLIGHT3;
		untyped other.HEMILIGHT0 = this.HEMILIGHT0;
		untyped other.HEMILIGHT1 = this.HEMILIGHT1;
		untyped other.HEMILIGHT2 = this.HEMILIGHT2;
		untyped other.HEMILIGHT3 = this.HEMILIGHT3;
		untyped other.DIRLIGHT0 = this.DIRLIGHT0;
		untyped other.DIRLIGHT1 = this.DIRLIGHT1;
		untyped other.DIRLIGHT2 = this.DIRLIGHT2;
		untyped other.DIRLIGHT3 = this.DIRLIGHT3;
		untyped other.POINTLIGHT0 = this.POINTLIGHT0;
		untyped other.POINTLIGHT1 = this.POINTLIGHT1;
		untyped other.POINTLIGHT2 = this.POINTLIGHT2;
		untyped other.POINTLIGHT3 = this.POINTLIGHT3;        
		untyped other.SHADOW0 = this.SHADOW0;
		untyped other.SHADOW1 = this.SHADOW1;
		untyped other.SHADOW2 = this.SHADOW2;
		untyped other.SHADOW3 = this.SHADOW3;
		untyped other.SHADOWS = this.SHADOWS;
		untyped other.SHADOWESM0 = this.SHADOWESM0;
		untyped other.SHADOWESM1 = this.SHADOWESM1;
		untyped other.SHADOWESM2 = this.SHADOWESM2;
		untyped other.SHADOWESM3 = this.SHADOWESM3;
		untyped other.SHADOWPCF0 = this.SHADOWPCF0;
		untyped other.SHADOWPCF1 = this.SHADOWPCF1;
		untyped other.SHADOWPCF2 = this.SHADOWPCF2;
		untyped other.SHADOWPCF3 = this.SHADOWPCF3;
		untyped other.NORMAL = this.NORMAL;
		untyped other.UV1 = this.UV1;
		untyped other.UV2 = this.UV2;
		untyped other.VERTEXCOLOR = this.VERTEXCOLOR;
		untyped other.VERTEXALPHA = this.VERTEXALPHA;
		untyped other.NUM_BONE_INFLUENCERS = this.NUM_BONE_INFLUENCERS;
		untyped other.BonesPerMesh = this.BonesPerMesh;
		untyped other.INSTANCES = this.INSTANCES;
	}
	
	override public function reset() {
		super.reset();
		
		this.DIFFUSE = false;
		this.CLIPPLANE = false;
		this.ALPHATEST = false;
		this.DEPTHPREPASS = false;
		this.POINTSIZE = false;
		this.FOG = false;
		this.LIGHT0 = false;
		this.LIGHT1 = false;
		this.LIGHT2 = false;
		this.LIGHT3 = false;
		this.SPOTLIGHT0 = false;
		this.SPOTLIGHT1 = false;
		this.SPOTLIGHT2 = false;
		this.SPOTLIGHT3 = false;
		this.HEMILIGHT0 = false;
		this.HEMILIGHT1 = false;
		this.HEMILIGHT2 = false;
		this.HEMILIGHT3 = false;
		this.DIRLIGHT0 = false;
		this.DIRLIGHT1 = false;
		this.DIRLIGHT2 = false;
		this.DIRLIGHT3 = false;
		this.POINTLIGHT0 = false;
		this.POINTLIGHT1 = false;
		this.POINTLIGHT2 = false;
		this.POINTLIGHT3 = false;        
		this.SHADOW0 = false;
		this.SHADOW1 = false;
		this.SHADOW2 = false;
		this.SHADOW3 = false;
		this.SHADOWS = false;
		this.SHADOWESM0 = false;
		this.SHADOWESM1 = false;
		this.SHADOWESM2 = false;
		this.SHADOWESM3 = false;
		this.SHADOWPCF0 = false;
		this.SHADOWPCF1 = false;
		this.SHADOWPCF2 = false;
		this.SHADOWPCF3 = false;
		this.NORMAL = false;
		this.UV1 = false;
		this.UV2 = false;
		this.VERTEXCOLOR = false;
		this.VERTEXALPHA = false;
		this.NUM_BONE_INFLUENCERS = 0;
		this.BonesPerMesh = 0;
		this.INSTANCES = false;
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
		if (this.LIGHT0) {
			result += "#define LIGHT0 \n";
		}
		if (this.LIGHT1) {
			result += "#define LIGHT1 \n";
		}
		if (this.LIGHT2) {
			result += "#define LIGHT2 \n";
		}
		if (this.LIGHT3) {
			result += "#define LIGHT3 \n";
		}
		if (this.SPOTLIGHT0) {
			result += "#define SPOTLIGHT0 \n";
		}
		if (this.SPOTLIGHT1) {
			result += "#define SPOTLIGHT1 \n";
		}
		if (this.SPOTLIGHT2) {
			result += "#define SPOTLIGHT2 \n";
		}
		if (this.SPOTLIGHT3) {
			result += "#define SPOTLIGHT3 \n";
		}
		if (this.HEMILIGHT0) {
			result += "#define HEMILIGHT0 \n";
		}
		if (this.HEMILIGHT1) {
			result += "#define HEMILIGHT1 \n";
		}
		if (this.HEMILIGHT2) {
			result += "#define HEMILIGHT2 \n";
		}
		if (this.HEMILIGHT3) {
			result += "#define HEMILIGHT3 \n";
		}
		if (this.DIRLIGHT0) {
			result += "#define DIRLIGHT0 \n";
		}
		if (this.DIRLIGHT1) {
			result += "#define DIRLIGHT1 \n";
		}
		if (this.DIRLIGHT2) {
			result += "#define DIRLIGHT2 \n";
		}
		if (this.DIRLIGHT3) {
			result += "#define DIRLIGHT3 \n";
		}
		if (this.POINTLIGHT0) {
			result += "#define POINTLIGHT0 \n";
		}
		if (this.POINTLIGHT1) {
			result += "#define POINTLIGHT1 \n";
		}
		if (this.POINTLIGHT2) {
			result += "#define POINTLIGHT2 \n";
		}
		if (this.POINTLIGHT3) {
			result += "#define POINTLIGHT3 \n";
		}
		if (this.SHADOW0) {
			result += "#define SHADOW0 \n";
		}
		if (this.SHADOW1) {
			result += "#define SHADOW1 \n";
		}
		if (this.SHADOW2) {
			result += "#define SHADOW2 \n";
		}
		if (this.SHADOW3) {
			result += "#define SHADOW3 \n";
		}
		if (this.SHADOWS) {
			result += "#define SHADOWS \n";
		}
		if (this.SHADOWESM0) {
			result += "#define SHADOWESM0 \n";
		}
		if (this.SHADOWESM1) {
			result += "#define SHADOWESM1 \n";
		}
		if (this.SHADOWESM2) {
			result += "#define SHADOWESM2 \n";
		}
		if (this.SHADOWESM3) {
			result += "#define SHADOWESM3 \n";
		}
		if (this.SHADOWPCF0) {
			result += "#define SHADOWPCF0 \n";
		}
		if (this.SHADOWPCF1) {
			result += "#define SHADOWPCF1 \n";
		}
		if (this.SHADOWPCF2) {
			result += "#define SHADOWPCF2 \n";
		}
		if (this.SHADOWPCF3) {
			result += "#define SHADOWPCF3 \n";
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
		
		result += "#define BonesPerMesh " + this.BonesPerMesh + "\n";
		result += "#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + "\n";
		
		return result;
	}
	
}
