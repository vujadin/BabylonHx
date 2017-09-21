package com.babylonhx.materials.lib.sky;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SkyMaterialDefines extends MaterialDefines {
	
	public var CLIPPLANE:Bool = false;
	public var POINTSIZE:Bool = false;
	public var FOG:Bool = false;
	public var VERTEXCOLOR:Bool = false;
	public var VERTEXALPHA:Bool = false;


	public function new() {
		super();
	}
	
	override public function isEqual(other:MaterialDefines):Bool {
		if (super.isEqual(other)) {
			if (untyped this.CLIPPLANE != other.CLIPPLANE) return false; 
			if (untyped this.POINTSIZE != other.POINTSIZE) return false; 
			if (untyped this.FOG != other.FOG) return false;
			if (untyped this.VERTEXCOLOR != other.VERTEXCOLOR) return false; 
			if (untyped this.VERTEXALPHA != other.VERTEXALPHA) return false; 
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.CLIPPLANE = this.CLIPPLANE;
		untyped other.POINTSIZE = this.POINTSIZE;
		untyped other.FOG = this.FOG;
		untyped other.VERTEXCOLOR = this.VERTEXCOLOR;
		untyped other.VERTEXALPHA = this.VERTEXALPHA;
	}
	
	override public function reset() {
		super.reset();
		
		this.CLIPPLANE = false;
		this.POINTSIZE = false;
		this.FOG = false;
		this.VERTEXCOLOR = false;
		this.VERTEXALPHA = false;
	}
	
	override public function toString():String {
		var result = super.toString();
		
		if (this.CLIPPLANE) {
			result += "#define CLIPPLANE \n";
		}
		if (this.POINTSIZE) {
			result += "#define POINTSIZE \n";
		}
		if (this.FOG) {
			result += "#define FOG \n";
		}
		if (this.VERTEXCOLOR) {
			result += "#define VERTEXCOLOR \n";
		}
		if (this.VERTEXALPHA) {
			result += "#define VERTEXALPHA \n";
		}
		
		return result;
	}
	
}
