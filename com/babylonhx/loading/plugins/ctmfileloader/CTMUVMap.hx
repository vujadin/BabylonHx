package com.babylonhx.loading.plugins.ctmfileloader;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMUVMap {
	
	public var uv:Float32Array;
	public var name:String = "";
	public var filename:String = "";
	
	
	public function new(uv:Float32Array, name:String = "", filename:String = "") {
		this.uv = uv;
		this.name = name;
		this.filename = filename;
	}
	
}
