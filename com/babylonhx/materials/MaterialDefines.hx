package com.babylonhx.materials;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MaterialDefines {
	
	public var _keys:Vector<String>;
	private var _isDirty:Bool = true;
	public var _renderId:Int;
	
	public var _areLightsDirty:Bool = true;
	public var _areAttributesDirty:Bool = true;
	public var _areTexturesDirty:Bool = true;
	public var _areFresnelDirty:Bool = true;
	public var _areMiscDirty:Bool = true;  
	public var _areImageProcessingDirty:Bool = true;

	public var _normals:Bool = false;
	public var _uvs:Bool = false;

	public var _needNormals:Bool = false;
	public var _needUVs:Bool = false;
	
	public var isDirty(get, never):Bool;
	inline private function get_isDirty():Bool {
		return this._isDirty;
	}
	
	public var lights:Array<Bool> = [];
	public var pointlights:Array<Bool> = [];
	public var dirlights:Array<Bool> = [];
	public var hemilights:Array<Bool> = [];
	public var spotlights:Array<Bool> = [];
	public var shadows:Array<Bool> = [];
	public var shadowpcf:Array<Bool> = [];
	public var shadowvsms:Array<Bool> = [];
	public var shadowesm:Array<Bool> = [];
	public var shadowqube:Array<Bool> = [];
	public var shadowcloseesm:Array<Bool> = [];
	
	public var LIGHTMAPEXCLUDED:Bool = false;
	public var lightmapexcluded:Array<Bool> = [];
	public var lightmapnospecular:Array<Bool> = [];
	
	var finalString:String = "";
	

	public function new() {	}

	
	public function markAsProcessed() {
		this._isDirty = false;
		this._areAttributesDirty = false;
		this._areTexturesDirty = false;
		this._areFresnelDirty = false;
		this._areLightsDirty = false;
		this._areMiscDirty = false;
		this._areImageProcessingDirty = false;
	}

	public function markAsUnprocessed() {
		this._isDirty = true;
	}
	
	public function markAllAsDirty() {
		this._areTexturesDirty = true;
		this._areAttributesDirty = true;
		this._areLightsDirty = true;
		this._areFresnelDirty = true;
		this._areMiscDirty = true;
		this._areImageProcessingDirty = true;
		this._isDirty = true;
	}
	
	public function markAsImageProcessingDirty() {
		this._areImageProcessingDirty = true;
		this._isDirty = true;
	}

	public function markAsLightDirty() {
		this._areLightsDirty = true;
		this._isDirty = true;
	}

	public function markAsAttributesDirty() {
		this._areAttributesDirty = true;
		this._isDirty = true;
	}
	
	public function markAsTexturesDirty() {
		this._areTexturesDirty = true;
		this._isDirty = true;
	}

	public function markAsFresnelDirty() {
		this._areFresnelDirty = true;
		this._isDirty = true;
	}

	public function markAsMiscDirty() {
		this._areMiscDirty = true;
		this._isDirty = true;
	}
	
	/*public rebuild() {
		if (this._keys) {
			delete this._keys;
		}

		this._keys = [];

		for (var key of Object.keys(this)) {
			if (key[0] === "_") {
				continue;
			}

			this._keys.push(key);
		}
	}*/
	
	public function isEqual(other:MaterialDefines):Bool {		
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
		
		for (i in 0...this.shadowvsms.length) {
			if (this.shadowesm[i] != other.shadowesm[i]) {
				return false;
			}
		}
		
		for (i in 0...this.shadowpcf.length) {
			if (this.shadowpcf[i] != other.shadowpcf[i]) {
				return false;
			}
		}
		
		return true;
	}

	public function cloneTo(other:MaterialDefines) {		
		other.lights = this.lights.copy();
		other.pointlights = this.pointlights.copy();
		other.dirlights = this.dirlights.copy();
		other.hemilights = this.hemilights.copy();
		other.spotlights = this.spotlights.copy();
		other.shadows = this.shadows.copy();
		other.shadowesm = this.shadowesm.copy();
		other.shadowvsms = this.shadowvsms.copy();
		other.shadowpcf = this.shadowpcf.copy();
	}

	public function reset() {		
		lights = [];
		pointlights = [];
		dirlights = [];
		hemilights = [];
		spotlights = [];
		shadows = [];
		shadowesm = [];
		shadowvsms = [];
		shadowpcf = [];
	}

	public function toString():String {
		finalString = "";
		
		for (i in 0...this.lights.length) {
			if (this.lights[i] == true) {
				finalString += "#define LIGHT" + i + "\n";
			}
		}
		
		for (i in 0...this.pointlights.length) {
			if (this.pointlights[i] == true) {
				finalString += "#define POINTLIGHT" + i + "\n";
			}
		}
		
		for (i in 0...this.dirlights.length) {
			if (this.dirlights[i] == true) {
				finalString += "#define DIRLIGHT" + i + "\n";
			}
		}
		
		for (i in 0...this.hemilights.length) {
			if (this.hemilights[i] == true) {
				finalString += "#define HEMILIGHT" + i + "\n";
			}
		}
		
		for (i in 0...this.spotlights.length) {
			if (this.spotlights[i] == true) {
				finalString += "#define SPOTLIGHT" + i + "\n";
			}
		}
		
		for (i in 0...this.shadows.length) {
			if (this.shadows[i] == true) {
				finalString += "#define SHADOW" + i + "\n";
			}
		}
		
		for (i in 0...this.shadowvsms.length) {
			if (this.shadowvsms[i] == true) {
				finalString += "#define SHADOWVSM" + i + "\n";
			}
		}
		
		for (i in 0...this.shadowesm.length) {
			if (this.shadowesm[i] == true) {
				finalString += "#define SHADOWESM" + i + "\n";
			}
		}
		
		for (i in 0...this.shadowpcf.length) {
			if (this.shadowpcf[i] == true) {
				finalString += "#define SHADOWPCF" + i + "\n";
			}
		}
		
		return finalString;
	}
	
}
