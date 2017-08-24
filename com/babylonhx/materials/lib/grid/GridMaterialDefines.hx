package com.babylonhx.materials.lib.grid;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GridMaterialDefines extends MaterialDefines {
	
	public var TRANSPARENT:Bool = false;
	public var FOG:Bool = false;
	public var PREMULTIPLYALPHA:Bool = false;
	

	public function new() {
		super();
	}
	
	override public function isEqual(other:MaterialDefines):Bool {
		if (super.isEqual(other)) {
			if (untyped this.TRANSPARENT != other.TRANSPARENT) return false;
			if (untyped this.FOG != other.FOG) return false;
			if (untyped this.PREMULTIPLYALPHA != other.PREMULTIPLYALPHA) return false;
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.TRANSPARENT = this.TRANSPARENT;
		untyped other.FOG = this.FOG;
		untyped other.PREMULTIPLYALPHA = this.PREMULTIPLYALPHA;
	}
	
	override public function reset() {
		super.reset();
		
		this.TRANSPARENT = false;
		this.FOG = false;
		this.PREMULTIPLYALPHA = false;
	}
	
	override public function toString():String {
		var result = super.toString();
		
		if (this.TRANSPARENT) {
			result += "#define TRANSPARENT \n";
		}
		if (this.FOG) {
			result += "#define FOG \n";
		}
		if (this.PREMULTIPLYALPHA) {
			result += "#define PREMULTIPLYALPHA \n";
		}
		
		return result;
	}
	
}
