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
	
	// creates a black and white random noise texture
	public static function createNoise(size:Int = 16):Image {			
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		};
		
		var img = new Image(new UInt8Array(size * size * 4), size, size);
		
		var value:Int = 0;
		var totalPixelsCount = size * size * 4;
		var i:Int = 0;
		while (i < totalPixelsCount) {		
			value = Math.floor((Math.random() * (0.02 - 0.95) + 0.95) * 255);
			img.data[i] = value;
			img.data[i + 1] = value;
			img.data[i + 2] = value;
			img.data[i + 3] = 255;
			
			i += 4;
		}
		
		return img;
	}
	
}
