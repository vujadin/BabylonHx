package com.babylonhxext.bumper;

import snow.platform.native.render.opengl.GL.GLTexture;
import snow.types.Types.ImageInfo;
import snow.utils.Float32Array;
import snow.assets.AssetImage;
import snow.utils.Int8Array;
import snow.utils.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Filter {
	
	public static function createImageData(width:Int, height:Int):Dynamic {
		return {
			width: width, 
			height: width, 
			data: new UInt8Array(width * height * 4)
		};
	}
			
	public static function convolute(pixels:Dynamic, weights:Array<Float>, opaque:Bool):Dynamic {
		var side = Math.round(Math.sqrt(weights.length));
		var halfSide = Math.floor(side / 2);
		
		var src = pixels.data;
		var sw = pixels.width;
		var sh = pixels.height;
		
		var w = sw;
		var h = sh;
		
		var output = {
			width: w, 
			height: h, 
			data: new Int8Array(w * h * 4)
		};
		
		var dst = output.data;
		
		var alphaFac = opaque ? 1 : 0;
		
		var sx:Float = 0;
		var sy:Float = 0;
		var dstOff:Int = 0;
		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;
		var a:Float = 0;
		var scy:Float = 0;
		var scx:Float = 0;
		var srcOff:Int = 0;
		var wt:Float = 0;
		
		for (y in 0...h) {			
			for (x in 0...w) {
				sy = y;
				sx = x;
				dstOff = (y * w + x) * 4;
				r = g = b = a = 0;
				
				for (cy in 0...side) {
					for (cx in 0...side) {
						scy = sy + cy - halfSide;
						scx = sx + cx - halfSide;
						
						if (scy >= 0 && scy < sh && scx >= 0 && scx < sw) {							
							srcOff = Std.int((scy * sw + scx) * 4);
							wt = weights[Std.int(cy * side+cx)];
							
							r += src.getUInt8(srcOff) * wt;
							g += src.getUInt8(srcOff + 1) * wt;
							b += src.getUInt8(srcOff + 2) * wt;
							a += src.getUInt8(srcOff + 3) * wt;
						}
					}
				}
				
				dst.setInt8(dstOff, cast r);
				dst.setInt8(dstOff + 1, cast g);
				dst.setInt8(dstOff + 2, cast b);
				dst.setInt8(dstOff + 3, cast(a + alphaFac * (255 - a)));
			}
		}
		
		return output;
	}
	
	public static function grayscale(pixels:Dynamic, invert:Bool = false):Dynamic {
		var d = pixels.data;
		var i:Int = 0;
		var brightness:Int = 0;
		while(i < d.length) {
			var r = d.getUInt8(i);
			var g = d.getUInt8(i + 1);
			var b = d.getUInt8(i + 2);
			/*
			// CIE luminance for the RGB
			// The human eye is bad at seeing red and blue, so we de-emphasize them.
			var v = Std.int(0.2126 * r + 0.7152 * g + 0.0722 * b);
			// converting to Luminance Y (YCbCr)
			//var v = 0.299*r + 0.587*g + 0.114*b;
			v = invert ? (255 - v) : v;
			*/			
			brightness = (3 * r + 4 * g + b) >>> 3;
			d.setUInt8(i, brightness);
			d.setUInt8(i + 1, brightness);
			d.setUInt8(i + 2, brightness);
					
			//d.setUInt8(i, v);
			//d.setUInt8(i + 1, v);
			//d.setUInt8(i + 2, v);
			
			i += 4;
		}
		
		trace(pixels.data.length);
		
		return pixels;
	}
	
	public static function sobel(pixels:Dynamic, strength:Float, level:Float, type:String):Dynamic {
		var src = pixels.data;
		
		var w = pixels.width;
		var h = pixels.height;
		
		var output = {
			width: w, 
			height: h, 
			data: new UInt8Array(w * h * 4)
		};
		
		var dst = output.data;
			
		var max_size = w * h * 4;
		
		var tl, l, bl, t, b, tr, r, br, dX:Float = 0, dY:Float = 0, dZ:Float = 0, l:Float = 0;
		// blue value of normal map
		strength = Math.max(strength, 0.0001);
		var dZ = 1.0 / strength * (1.0 + Math.pow(2.0, level)); // very costly operation!
		var dZ2 = dZ * dZ;
		
		var filter_type = 0;
		if (type == "sobel") {
			filter_type = 0;
		}
		else if (type == "scharr") {
			filter_type = 1;
		}
		
		var wm4 = w * 4;
		for (y in 0...h) {
			for (x in 0...w) {
				var dstOff:Int = (y * w + x) * 4;
				
				// very costly operation!
				if (x == 0 || x == w - 1 || y == 0 || y == h - 1) {
					tl = src.getUInt8(mod(dstOff - 4 - wm4, max_size));   	 // top left  
					l  = src.getUInt8(mod(dstOff - 4, max_size));   		 // left  
					bl = src.getUInt8(mod(dstOff - 4 + wm4, max_size));   	 // bottom left  
					t  = src.getUInt8(mod(dstOff - wm4, max_size));   	 	 // top  
					b  = src.getUInt8(mod(dstOff + wm4, max_size));   	 	 // bottom  
					tr = src.getUInt8(mod(dstOff + 4 - wm4, max_size));   	 // top right  
					r  = src.getUInt8(mod(dstOff + 4, max_size));   		 // right  
					br = src.getUInt8(mod(dstOff + 4 + wm4, max_size));   	 // bottom right  
				}
				else {
					tl = src.getUInt8(dstOff - 4 - wm4);   	// top left
					l  = src.getUInt8(dstOff - 4);   		// left
					bl = src.getUInt8(dstOff - 4 + wm4);   	// bottom left
					t  = src.getUInt8(dstOff - wm4);   		// top
					b  = src.getUInt8(dstOff + wm4);   		// bottom
					tr = src.getUInt8(dstOff + 4 - wm4);   	// top right
					r  = src.getUInt8(dstOff + 4);   		// right
					br = src.getUInt8(dstOff + 4 + wm4);   	// bottom right
				}
				
				if (filter_type == 0) { 	  // "sobel"
					dX = tl + l * 2 + bl - tr - r * 2 - br;		//tl*1.0 + l*2.0 + bl*1.0 - tr*1.0 - r*2.0 - br*1.0;
					dY = tl + t * 2 + tr - bl - b * 2 - br;		//tl*1.0 + t*2.0 + tr*1.0 - bl*1.0 - b*2.0 - br*1.0;
				}
				else if (filter_type == 1) {  // "scharr"
					dX = tl * 3.0 + l * 10.0 + bl * 3.0 - tr * 3.0 - r * 10.0 - br * 3.0;
					dY = tl * 3.0 + t * 10.0 + tr * 3.0 - bl * 3.0 - b * 10.0 - br * 3.0;
				}
				
				l = Math.sqrt((dX * dX) + (dY * dY) + dZ2);
				
				dst.setUInt8(dstOff, Std.int(dX / l * 0.5 + 0.5) * 255); 		// red
				dst.setUInt8(dstOff + 1, Std.int((dY / l * 0.5 + 0.5) * 255)); 	// green
				dst.setUInt8(dstOff + 2, Std.int(dZ / l * 255)); 				// blue
				dst.setUInt8(dstOff + 3, cast src.getUInt8(dstOff + 3));
			}
		}
		
		return output;
	}
	
	private static inline function mod(n1:Int, n2:Int):Int {
		return ((n1 % n2) + n2) % n2;
	}
	
}
