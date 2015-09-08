package com.babylonhx.utils;

import com.babylonhx.utils.typedarray.UInt8Array;


/**
 * ...
 * @author Krtolica Vujadin
 */
class Image {	

	public var data:UInt8Array;
	public var height:Int = 0;
	public var width:Int = 0;	
	

	public function new(data:UInt8Array, width:Int, height:Int) {
		this.width = width;
		this.height = height;
		
		if (data != null) {	
			this.data = data;
		} 
		else {
			this.data = new UInt8Array(width * height * 4);
		}
	}
	
}
