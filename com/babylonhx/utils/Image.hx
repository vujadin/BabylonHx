package com.babylonhx.utils;

import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Image {
	
	public var width:Int;
	public var height:Int;
	public var data:UInt8Array;
	

	public function new(data:UInt8Array, width:Int, height:Int) {
		this.width = width;
		this.height = height;
		this.data = data;
	}
	
}
