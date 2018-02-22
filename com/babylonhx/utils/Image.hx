package com.babylonhx.utils;

import com.babylonhx.math.RGBA;
import com.babylonhx.math.Perlin;
import com.babylonhx.math.Tools;

import com.babylonhx.utils.typedarray.ArrayBuffer;
import com.babylonhx.utils.typedarray.ArrayBufferView;
import com.babylonhx.utils.typedarray.UInt8Array;


/**
 * ...
 * @author Krtolica Vujadin
 */
class Image {	

	public var data:UInt8Array;
	public var height:Int = 0;
	public var width:Int = 0;	
	

	public function new(?data:ArrayBufferView, width:Int = 256, height:Int = 256) {
		this.width = width;
		this.height = height;
		
		if (data != null) {	
			this.data = new UInt8Array(data.buffer);
		} 
		else {
			this.data = new UInt8Array(width * height * 4);
		}
	}
	
	public function perlinNoise(baseX:Float, baseY:Float, randomSeed:Float) {
		var noise = new Perlin(randomSeed);
		noise.simplex2(baseX, baseY);
	}
	
	inline public function getPixelAt(x:Int, y:Int):RGBA {
		var r = data[y * width * 4 + x * 4];
		var g = data[y * width * 4 + x * 4 + 1];
		var b = data[y * width * 4 + x * 4 + 2];
		var a = data[y * width * 4 + x * 4 + 3];
		
		return RGBA.fromBytes(r, g, b, a);
	}
	
	inline public function setPixelAt(x:Int, y:Int, pixel:RGBA) {
		data[y * width * 4 + x * 4] = (pixel & 0xff000000) >>> 24;
		data[y * width * 4 + x * 4 + 1] = (pixel & 0x00ff0000) >>> 16;
		data[y * width * 4 + x * 4 + 2] = (pixel & 0x0000ff00) >>> 8;
		data[y * width * 4 + x * 4 + 3] = pixel & 0x000000ff;
	}
	
	public static function CreateCheckerboard(size:Int = 256):Image {			
		var img = new Image(new UInt8Array(size * size * 4), size, size);
		
		var value:Int = 0;
		var totalPixelsCount = size * size * 4;
		
		var r:Int = 0;
		var g:Int = 0;
		var b:Int = 0;
		
		for (x in 0...size) {
			for (y in 0...size) {
				var position = (x + size * y) * 4;
				var floorX = Math.floor(x / (size / 8));
				var floorY = Math.floor(y / (size / 8));
				
				if ((floorX + floorY) % 2 == 0) {
					r = g = b = 255;
				} 
				else {
					r = 255;
					g = b = 0;
				}
				
				img.data[position + 0] = r;
				img.data[position + 1] = g;
				img.data[position + 2] = b;
				img.data[position + 3] = 255;
			}
		}
		
		return img;
	}
	
	// creates a black and white random noise texture
	public static function CreateNoise(size:Int = 8):Image {			
		var rand = function(min:Float, max:Float):Float {
			return Math.random() * (max - min) + min;
		};
		
		var img = new Image(null, size, size);
		
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
	
	public static function CreateBumpMap(from:ArrayBufferView):Image {
		if (from == null) {
			return null;
		}
		
		var _width = Std.int(Math.sqrt(from.byteLength) / 2);
		var _height = _width;
		
		var original = new Image(from, _width, _height);
		
		var bumpMap = new Image(null, _width, _height);
		
		var right:Float = 0;
		var left:Float = 0;
		var down:Float = 0;
		var up:Float = 0;
		var normalX:Float = 0;
		var normalY:Float = 0;
		var normalZ:Float = 0;
		var normalSq:Float = 0;
		var alpha:Float = 2;
		var red:Int = 0;
		var green:Int = 0;
		var blue:Int = 0;
		
		for (i in 0..._width) {
			for (j in 0..._height) {
				if (j < _width - 1) {
					right = (original.getPixelAt(i, j + 1));
				}
				else {
					right = 0;
				}
				
				if (j > 0) {
					left = (original.getPixelAt(i, j - 1));
				}
				else {
					left = 0;
				}
				
				if (i < _height - 1) {
					down = (original.getPixelAt(i + 1, j));
				}
				else {
					down = 0;
				}
				
				if (i > 0) {
					up = (original.getPixelAt(i - 1, j));
				}
				else {
					up = 0;
				}
				
				normalX = alpha * (right - left);
				normalY = alpha * (down - up);
				normalZ = 1;
				
				normalSq = Math.sqrt(normalX * normalX + normalY * normalY + 1);
				normalX /= normalSq;
				normalY /= normalSq;
				normalZ /= normalSq;
				
				red = Std.int((1 + normalX) / 2 * 255);
				green = Std.int((1 + normalY) / 2 * 255);
				blue = Std.int((1 + normalZ) / 2 * 255);
				
				bumpMap.setPixelAt(i, j, red << 24 | green << 16 | blue << 8 | 255);
			}
		}
		
		return bumpMap;
	}
	
}
