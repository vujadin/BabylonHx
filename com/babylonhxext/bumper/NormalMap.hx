package com.babylonhxext.bumper;

import snow.render.opengl.GL.GLTexture;
import snow.types.Types.ImageInfo;


/**
 * ...
 * @author Krtolica Vujadin
 */
class NormalMap {
	
	private var invert_red = false;
	private var invert_green = false;
	private var invert_source = false;
	
	public var smoothing = -10;
	public var strength = 2.5;
	public var level = 7;
	public var normal_type = "sobel";
	public var normalBitmap:GLTexture;
	

	public function new(element:String, val:Dynamic) {
		switch(element) {
			case "blur_sharp":
				smoothing = val;
				
			case "strength":
				strength = val;
				
			case "level":
				level = val;
				
			case "type":
				normal_type = val;
		}
	}
	
	public function create(image:Dynamic):Dynamic {
		var grayscale = Filter.grayscale(image, !invert_source);
		
		var normal:Dynamic = Filter.sobel(grayscale, strength, level, normal_type);
						
		for (i in 0...normal.data.length){	
			if ((i % 4 == 0 && invert_red) || (i % 4 == 1 && invert_green)) {
				normal.data.setUInt8(i, 255 - normal.data.getUInt8(i));
			}
			else {
				normal.data.setUInt8(i, normal.data.getUInt8(i));
			}
		}
		
		if (smoothing > 0) {
			GausianBlur.sharpen(normal, image.width, image.height, Std.int(Math.abs(smoothing)));
		}
		else if (smoothing < 0) {
			//GausianBlur.blur(normal, image.width, image.height, Std.int(Math.abs(smoothing)));
			normal = Filter.convolute(normal, [1 / 9, 1 / 9, 1 / 9, 1 / 9, 1 / 9, 1 / 9, 1 / 9, 1 / 9, 1 / 9], true);
		}	
		
		return normal;
	}
	
	public function invertRed() {
		invert_red = !invert_red;
		
		/*if (auto_update) {
			createNormalMap();
		}*/
	}

	public function invertGreen() {
		invert_green = !invert_green;
		
		/*if (auto_update) {
			createNormalMap();
		}*/
	}

	public function invertSource() {
		invert_source = !invert_source;
		
		/*if (auto_update) {
			createNormalMap();
		}*/
	}
	
	inline private function getNextPowerOf2(number:Int):Int {
		var i:Int = 2;
		while (i < Math.pow(2, 14)) {
			i *= 2;
			if(i >= number) {
				return i;
			}
		}
		return i;
	}
	
}
