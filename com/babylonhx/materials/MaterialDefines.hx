package com.babylonhx.materials;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Manages the defines for the Material.
 */
class MaterialDefines {
	
	//public var _keys:Vector<String>;
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
	
	/**
     * Specifies if the material needs to be re-calculated.
     */
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
	public var shadowesm:Array<Bool> = [];
	public var shadowcube:Array<Bool> = [];
	public var shadowcloseesm:Array<Bool> = [];
	
	public var PROJECTEDLIGHTTEXTURE:Array<Bool> = [];
	
	public var LIGHTMAPEXCLUDED:Bool = false;
	public var lightmapexcluded:Array<Bool> = [];
	public var lightmapnospecular:Array<Bool> = [];
	
	var finalString:String = "";
	

	public function new() {	}

	/**
     * Marks the material to indicate that it has been re-calculated.
     */
	public function markAsProcessed() {
		this._isDirty = false;
		this._areAttributesDirty = false;
		this._areTexturesDirty = false;
		this._areFresnelDirty = false;
		this._areLightsDirty = false;
		this._areMiscDirty = false;
		this._areImageProcessingDirty = false;
	}

	/**
     * Marks the material to indicate that it needs to be re-calculated.
     */
	public function markAsUnprocessed() {
		this._isDirty = true;
	}
	
	/**
     * Marks the material to indicate all of its defines need to be re-calculated.
     */
	public function markAllAsDirty() {
		this._areTexturesDirty = true;
		this._areAttributesDirty = true;
		this._areLightsDirty = true;
		this._areFresnelDirty = true;
		this._areMiscDirty = true;
		this._areImageProcessingDirty = true;
		this._isDirty = true;
	}
	
	/**
     * Marks the material to indicate that image processing needs to be re-calculated.
     */
	public function markAsImageProcessingDirty() {
		this._areImageProcessingDirty = true;
		this._isDirty = true;
	}

	/**
     * Marks the material to indicate the lights need to be re-calculated.
     */
	public function markAsLightDirty() {
		this._areLightsDirty = true;
		this._isDirty = true;
	}

	/**
     * Marks the attribute state as changed.
     */
	public function markAsAttributesDirty() {
		this._areAttributesDirty = true;
		this._isDirty = true;
	}
	
	/**
     * Marks the texture state as changed.
     */
	public function markAsTexturesDirty() {
		this._areTexturesDirty = true;
		this._isDirty = true;
	}

	/**
     * Marks the fresnel state as changed.
     */
	public function markAsFresnelDirty() {
		this._areFresnelDirty = true;
		this._isDirty = true;
	}

	/**
     * Marks the misc state as changed.
     */
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
	
	/**
     * Specifies if two material defines are equal.
     * @param other - A material define instance to compare to.
     * @returns - Boolean indicating if the material defines are equal (true) or not (false).
     */
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
		
		for (i in 0...this.shadowesm.length) {
			if (this.shadowesm[i] != other.shadowesm[i]) {
				return false;
			}
		}
		
		for (i in 0...this.shadowcube.length) {
			if (this.shadowcube[i] != other.shadowcube[i]) {
				return false;
			}
		}
		
		for (i in 0...this.shadowpcf.length) {
			if (this.shadowpcf[i] != other.shadowpcf[i]) {
				return false;
			}
		}
		
		for (i in 0...this.shadowcloseesm.length) {
			if (this.shadowcloseesm[i] != other.shadowcloseesm[i]) {
				return false;
			}
		}
		
		for (i in 0...this.PROJECTEDLIGHTTEXTURE.length) {
			if (this.PROJECTEDLIGHTTEXTURE[i] != other.PROJECTEDLIGHTTEXTURE[i]) {
				return false;
			}
		}
		
		return true;
	}

	/**
     * Clones this instance's defines to another instance.
     * @param other - material defines to clone values to.
     */
	public function cloneTo(other:MaterialDefines) {		
		other.lights = this.lights.copy();
		other.pointlights = this.pointlights.copy();
		other.dirlights = this.dirlights.copy();
		other.hemilights = this.hemilights.copy();
		other.spotlights = this.spotlights.copy();
		other.shadows = this.shadows.copy();
		other.shadowesm = this.shadowesm.copy();
		other.shadowcube = this.shadowcube.copy();
		other.shadowcloseesm = this.shadowcloseesm.copy();
		other.shadowpcf = this.shadowpcf.copy();
		other.PROJECTEDLIGHTTEXTURE = this.PROJECTEDLIGHTTEXTURE.copy();
	}

	/**
     * Resets the material define values.
     */
	public function reset() {		
		lights = [];
		pointlights = [];
		dirlights = [];
		hemilights = [];
		spotlights = [];
		shadows = [];
		shadowesm = [];
		shadowcube = [];
		shadowcloseesm = [];
		shadowpcf = [];
		PROJECTEDLIGHTTEXTURE = [];
	}

	/**
     * Converts the material define values to a string.
     * @returns - String of material define information.
     */
	public function toString():String {
		finalString = "";
		
		var sb:StringBuf = new StringBuf();
		
		for (i in 0...this.lights.length) {
			if (this.lights[i] == true) {
				sb.add("#define LIGHT" + i + "\n");
			}
		}
		
		for (i in 0...this.pointlights.length) {
			if (this.pointlights[i] == true) {
				sb.add("#define POINTLIGHT" + i + "\n");
			}
		}
		
		for (i in 0...this.dirlights.length) {
			if (this.dirlights[i] == true) {
				sb.add("#define DIRLIGHT" + i + "\n");
			}
		}
		
		for (i in 0...this.hemilights.length) {
			if (this.hemilights[i] == true) {
				sb.add("#define HEMILIGHT" + i + "\n");
			}
		}
		
		for (i in 0...this.spotlights.length) {
			if (this.spotlights[i] == true) {
				sb.add("#define SPOTLIGHT" + i + "\n");
			}
		}
		
		for (i in 0...this.shadows.length) {
			if (this.shadows[i] == true) {
				sb.add("#define SHADOW" + i + "\n");
			}
		}
		
		for (i in 0...this.shadowesm.length) {
			if (this.shadowesm[i] == true) {
				sb.add("#define SHADOWESM" + i + "\n");
			}
		}
		
		for (i in 0...this.shadowcube.length) {
			if (this.shadowcube[i] == true) {
				sb.add("#define SHADOWCUBE" + i + "\n");
			}
		}
		
		for (i in 0...this.shadowcloseesm.length) {
			if (this.shadowcloseesm[i] == true) {
				sb.add("#define SHADOWCLOSEESM" + i + "\n");
			}
		}
		
		for (i in 0...this.shadowpcf.length) {
			if (this.shadowpcf[i] == true) {
				sb.add("#define SHADOWPCF" + i + "\n");
			}
		}
		
		for (i in 0...this.PROJECTEDLIGHTTEXTURE.length) {
			if (this.PROJECTEDLIGHTTEXTURE[i] == true) {
				sb.add("#define PROJECTEDLIGHTTEXTURE" + i + "\n");
			}
		}
		
		finalString = sb.toString();
		
		return finalString;
	}
	
}
