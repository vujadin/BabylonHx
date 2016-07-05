package com.babylonhx.materials.lib.sky;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SkyMaterialDefines extends MaterialDefines {
	
	public static inline var CLIPPLANE:Int = 0;
	public static inline var POINTSIZE:Int = 1;
	public static inline var FOG:Int = 2;
	public static inline var VERTEXCOLOR:Int = 3;
	public static inline var VERTEXALPHA:Int = 4;


	public function new() {
		super();
		
		this._keys = Vector.fromData(["CLIPPLANE", "POINTSIZE", "FOG", "VERTEXCOLOR", "VERTEXALPHA"]);
		
		defines = new Vector(this._keys.length);
		for (i in 0...this._keys.length) {
			defines[i] = false;
		}
	}
	
}
