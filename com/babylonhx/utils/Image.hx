package com.babylonhx.utils;

import com.babylonhx.math.RGBA;
import com.babylonhx.math.Perlin;
import com.babylonhx.math.Tools;

import lime.utils.UInt8Array;


/**
 * ...
 * @author Krtolica Vujadin
 */
class Image {	

	public var data:UInt8Array;
	public var height:Int = 0;
	public var width:Int = 0;	
	

	public function new(?data:UInt8Array, width:Int = 256, height:Int = 256) {
		this.width = width;
		this.height = height;
		
		if (data != null) {	
			this.data = data;
		} 
		else {
			this.data = new UInt8Array(width * height * 4);
		}
	}
	
	inline public function getPixelAt(x:Int, y:Int):RGBA {
		var r = data[y * width * 4 + x * 4];
		var g = data[y * width * 4 + x * 4 + 1];
		var b = data[y * width * 4 + x * 4 + 2];
		var a = data[y * width * 4 + x * 4 + 3];
		
		return RGBA.fromBytes(r, g, b, a);
	}
	
	inline public function setPixelAt(x:Int, y:Int, pixel:RGBA) {
		data[y * this.width * 4 + x * 4] = pixel;
	}
	
	public static function createCheckerboard(size:Int = 256):Image {			
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
	public static function createNoise(size:Int = 8):Image {			
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
	
	public static function createPerlinNoise(r:Dynamic, g:Dynamic, b:Dynamic, a:Int, size:Int = 8):Image {
		var img = new Image(new UInt8Array(size * size * 4), size, size);
		
		var perlinNoise = new Perlin(0.5);
		
		var t = Tools.RandomInt(0, 100);
		
		var count = Std.int(size / 2);
		for (x in 0...count) {
			for (y in 0...count) {
				var _r = perlinNoise.noise3d(x / r.size, y / r.size, t / 16) * 0.5 + 0.5;
				var _g = perlinNoise.noise3d(x / g.size, y / g.size, t / 16) * 0.5 + 0.5;
				var _b = perlinNoise.noise3d(x / b.size, y / b.size, t / 16) * 0.5 + 0.5;
				
				/*var _r = perlinNoise.noise3d(x / r.size, y / r.size / 5, t / 16) * 0.5 + 0.5;
				var _g = perlinNoise.noise3d(x / g.size / 6, y / g.size, t / 16) * 0.5 + 0.5;
				var _b = perlinNoise.noise3d(x / b.size, y / b.size, t / 16) * 0.5 + 0.5;*/
				
				img.data[(x + y * count) * 4 + 0] = Std.int(_r * r.strength);        
				img.data[(x + y * count) * 4 + 1] = Std.int(_g * r.strength);
				img.data[(x + y * count) * 4 + 2] = Std.int(_b * r.strength);        
				img.data[(x + y * count) * 4 + 3] = a;
			}
		}
		
		return img;
	}
	
}
