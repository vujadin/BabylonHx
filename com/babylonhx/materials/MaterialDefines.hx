package com.babylonhx.materials;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MaterialDefines {
	
	public var defines:Vector<Bool>;
	public var _keys:Vector<String>;
	
	public var lights:Array<Bool> = [];
	public var pointlights:Array<Bool> = [];
	public var dirlights:Array<Bool> = [];
	public var hemilights:Array<Bool> = [];
	public var spotlights:Array<Bool> = [];
	public var shadows:Array<Bool> = [];
	public var shadowvsms:Array<Bool> = [];
	public var shadowpcfs:Array<Bool> = [];
	
	var finalString:String = "";
	

	public function new() {	}
	
	var ret:Bool = true;
	public function isEqual(other:MaterialDefines):Bool {
		for (i in 0...this.defines.length) {
			if (this.defines[i] != other.defines[i]) {
				return false;
			}
		}
		
		for (i in 0...this.lights.length) {
			if (this.lights[i] != other.lights[i]) {
				return false;
			}
		}
		
		for (i in 0...this.pointlights.length) {
			if (this.pointlights[i] != other.pointlights[i]) {
				return false;
			}
		}
		
		for (i in 0...this.dirlights.length) {
			if (this.dirlights[i] != other.dirlights[i]) {
				return false;
			}
		}
		
		for (i in 0...this.hemilights.length) {
			if (this.hemilights[i] != other.hemilights[i]) {
				return false;
			}
		}
		
		for (i in 0...this.spotlights.length) {
			if (this.spotlights[i] != other.spotlights[i]) {
				return false;
			}
		}
		
		for (i in 0...this.shadows.length) {
			if (this.shadows[i] != other.shadows[i]) {
				return false;
			}
		}
		
		for (i in 0...this.shadowvsms.length) {
			if (this.shadowvsms[i] != other.shadowvsms[i]) {
				return false;
			}
		}
		
		for (i in 0...this.shadowpcfs.length) {
			if (this.shadowpcfs[i] != other.shadowpcfs[i]) {
				return false;
			}
		}
		
		return true;
	}

	public function cloneTo(other:MaterialDefines) {
		if (this._keys.length != other._keys.length) {
			for (i in 0...this._keys.length) {
				other._keys[i] = this._keys[i];
			}
		}
		
		for (i in 0...this.defines.length) {
			other.defines[i] = this.defines[i];
		}	
		
		other.lights = this.lights.copy();
		other.pointlights = this.pointlights.copy();
		other.dirlights = this.dirlights.copy();
		other.hemilights = this.hemilights.copy();
		other.spotlights = this.spotlights.copy();
		other.shadows = this.shadows.copy();
		other.shadowvsms = this.shadowvsms.copy();
		other.shadowpcfs = this.shadowpcfs.copy();
	}

	public function reset() {
		for (i in 0...this.defines.length) {
			this.defines[i] = false;
		}
		
		lights = [];
		pointlights = [];
		dirlights = [];
		hemilights = [];
		spotlights = [];
		shadows = [];
		shadowvsms = [];
		shadowpcfs = [];
	}

	public function toString():String {
		finalString = "";
		for (i in 0...this.defines.length) {
			if (this.defines[i] == true) {
				finalString += "#define " + this._keys[i] + "\n";
			}
		}
		
		for (i in 0...this.lights.length) {
			finalString += "#define LIGHT" + i + "\n";
		}
		
		for (i in 0...this.pointlights.length) {
			finalString += "#define POINTLIGHT" + i + "\n";
		}
		
		for (i in 0...this.dirlights.length) {
			finalString += "#define DIRLIGHT" + i + "\n";
		}
		
		for (i in 0...this.hemilights.length) {
			finalString += "#define HEMILIGHT" + i + "\n";
		}
		
		for (i in 0...this.spotlights.length) {
			finalString += "#define SPOTLIGHT" + i + "\n";
		}
		
		for (i in 0...this.shadows.length) {
			finalString += "#define SHADOW" + i + "\n";
		}
		
		for (i in 0...this.shadowvsms.length) {
			finalString += "#define SHADOWVSM" + i + "\n";
		}
		
		for (i in 0...this.shadowpcfs.length) {
			finalString += "#define SHADOWPCF" + i + "\n";
		}
		
		return finalString;
	}
	
}
