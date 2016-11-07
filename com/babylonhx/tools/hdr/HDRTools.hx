package com.babylonhx.tools.hdr;

import com.babylonhx.tools.hdr.PanoramaToCubeMapTools.CubeMapInfo;
import com.babylonhx.utils.typedarray.ArrayBuffer;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef HDRInfo = {	
	var height:Int;
	var width:Int;
	var dataPosition:Int;  
};
 
class HDRTools {
	
	private static function Ldexp(mantissa:Float, exponent:Float):Float {
		if (exponent > 1023) {
			return mantissa * Math.pow(2, 1023) * Math.pow(2, exponent - 1023);
		}
		
		if (exponent < -1074) {
			return mantissa * Math.pow(2, -1074) * Math.pow(2, exponent + 1074);
		}
		
		return mantissa * Math.pow(2, exponent);
	}

	private static function Rgbe2float(float32array:Float32Array, red:Float, green:Float, blue:Float, exponent:Float, index:Int) {
		if (exponent > 0) {   /*nonzero pixel*/
			exponent = HDRTools.Ldexp(1.0, exponent - (128 + 8));
			
			float32array[index + 0] = red * exponent;
			float32array[index + 1] = green * exponent;
			float32array[index + 2] = blue * exponent;
		}
		else {
			float32array[index + 0] = 0;
			float32array[index + 1] = 0;
			float32array[index + 2] = 0;
		}
	}

	private static function readStringLine(uint8array:UInt8Array, startIndex:Int):String {
		var line = "";
		var character = "";
		
		for (i in startIndex...uint8array.length - startIndex) {
			character = String.fromCharCode(uint8array[i]);
			if (character == "\n" && uint8array[i] != 44) {
				break;
			}
			
			line += character;
		}
		
		return line;
	}

	/* minimal header reading. modify if you want to parse more information */
	public static function RGBE_ReadHeader(uint8array:UInt8Array):HDRInfo {
		var height:Int = 0;
		var width:Int = 0;
		
		var line = HDRTools.readStringLine(uint8array, 0);
		if (line.charAt(0) != '#' || line.charAt(1) != '?') {
			throw "Bad HDR Format.";
		}
		
		var endOfHeader = false;
		var findFormat = false;
		var lineIndex:Int = 0;
		
		do {
			lineIndex += (line.length + 1);
			line = HDRTools.readStringLine(uint8array, lineIndex);
			
			if (line == "FORMAT=32-bit_rle_rgbe") {
				findFormat = true;
			}
			else if (line.length == 0) {
				endOfHeader = true;
			}
		} 
		while (!endOfHeader);
		
		if (!findFormat) {
			throw "HDR Bad header format, unsupported FORMAT"; 
		}
		
		lineIndex += (line.length + 1);
		line = HDRTools.readStringLine(uint8array, lineIndex);
		
		var sizeRegexp:EReg = ~/^\-Y (.*) \+X (.*)$/g;
		
		var match = sizeRegexp.match(line);
		// TODO. Support +Y and -X if needed.
		if (!match) {
			throw "HDR Bad header format, no size"; 
		}
		var matched = sizeRegexp.matched(0);
		var strings = matched.split(" ");
		width = Std.parseInt(strings[3]);
		height = Std.parseInt(strings[1]);
		if (width < 8 || width > 0x7fff) {
			throw "HDR Bad header format, unsupported size"; 
		}
		
		lineIndex += (line.length + 1);
		
		var hdrinfo:HDRInfo = {
			height: height,
			width: width,
			dataPosition: lineIndex
		};
		
		return hdrinfo;
	}

	public static function GetCubeMapTextureData(buffer:Dynamic, size:Int):CubeMapInfo {
		var uint8array:UInt8Array = UInt8Array.fromBytes(buffer);
		var hdrInfo = HDRTools.RGBE_ReadHeader(uint8array);
		var data = HDRTools.RGBE_ReadPixels_RLE(uint8array, hdrInfo);
		
		var cubeMapData = PanoramaToCubeMapTools.ConvertPanoramaToCubemap(data, hdrInfo.width, hdrInfo.height, size);
		
		return cubeMapData;
	}

	public static function RGBE_ReadPixels(uint8array:UInt8Array, hdrInfo:HDRInfo):Float32Array {
		// Keep for multi format supports.
		return HDRTools.RGBE_ReadPixels_RLE(uint8array, hdrInfo);
	}

	private static function RGBE_ReadPixels_RLE(uint8array: #if (js || purejs || web || html5) Dynamic #else UInt8Array #end , hdrInfo:HDRInfo):Float32Array {
		var num_scanlines = hdrInfo.height;
		var scanline_width = hdrInfo.width;
		
		var a:Int = 0;
		var b:Int = 0;
		var c:Int = 0;
		var d:Int = 0;
		var count:Int = 0;
		var dataIndex = hdrInfo.dataPosition;
		var index:Int = 0;
		var endIndex:Int = 0;
		
		var scanLineArrayBuffer = new ArrayBuffer(scanline_width * 4); // four channel R G B E
		var scanLineArray = new UInt8Array(scanLineArrayBuffer);
		
		// 3 channels of 4 bytes per pixel in float.
		var resultBuffer = new ArrayBuffer(hdrInfo.width * hdrInfo.height * 4 * 3); 
		var resultArray = new Float32Array(resultBuffer);
		
		// read in each successive scanline
		while(num_scanlines > 0) {
			a = uint8array[dataIndex++];
			b = uint8array[dataIndex++];
			c = uint8array[dataIndex++];
			d = uint8array[dataIndex++];
			
			if (a != 2 || b != 2 || (c & 0x80) != 0) {
			    // this file is not run length encoded
				throw "HDR Bad header format, not RLE"; 
			}
			
			if (((c << 8) | d) != scanline_width) {
				throw "HDR Bad header format, wrong scan line width"; 
			}
			
			index = 0;
			
			// read each of the four channels for the scanline into the buffer
			for(i in 0...4) {
				endIndex = (i + 1) * scanline_width;
				
				while(index < endIndex) {
					a = uint8array[dataIndex++];
					b = uint8array[dataIndex++];
					
					if (a > 128) {
						// a run of the same value
						count = a - 128;
						if ((count == 0) || (count > endIndex - index)) {
							throw "HDR Bad Format, bad scanline data (run)";
						}
						
						while(count-- > 0) {
							scanLineArray[index++] = b;
						}
					}
					else {
						// a non-run
						count = a;
						if ((count == 0) || (count > endIndex - index)) {
							throw "HDR Bad Format, bad scanline data (non-run)";
						}
						
						scanLineArray[index++] = b;
						if (--count > 0) {
							for (j in 0...count) {
								scanLineArray[index++] = uint8array[dataIndex++];
							}
						}
					}
				}
			}
			
			// now convert data from buffer into floats
			for(i in 0...scanline_width) {
				a = scanLineArray[i];
				b = scanLineArray[i + scanline_width];
				c = scanLineArray[i + 2 * scanline_width];
				d = scanLineArray[i + 3 * scanline_width];
				
				HDRTools.Rgbe2float(resultArray, a, b, c, d, (hdrInfo.height - num_scanlines) * scanline_width * 3 + i * 3);
			}
			
			num_scanlines--;
		}
		
		return resultArray;
	}
	
}
