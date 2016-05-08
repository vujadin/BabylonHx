package com.babylonhx.loading.plugins.ctmfileloader;

import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMAttrMap {
	
	public var attr:Float32Array;
	public var name:String = "";
	
	
	public function new(attr:Float32Array, name:String = "") {
		this.attr = attr;
		this.name = name;
	}
	
}
