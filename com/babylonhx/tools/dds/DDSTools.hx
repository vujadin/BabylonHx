package com.babylonhx.tools.dds;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Scalar;

import lime.utils.ArrayBufferView;
import lime.utils.ArrayBuffer;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import lime.utils.UInt16Array;
import lime.utils.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
typedef DDSInfo = {
	width:Int,
	height:Int,
	mipmapCount:Int,
	isFourCC:Bool,
	isRGB:Bool,
	isLuminance:Bool,
	isCube:Bool,
	isCompressed:Bool,
	dxgiFormat:Int,
	textureType:Int
}

class DDSTools {
	
	// Based on demo done by Brandon Jones - http://media.tojicode.com/webgl-samples/dds.html
    // All values and structures referenced from:
    // http://msdn.microsoft.com/en-us/library/bb943991.aspx/
    static inline var DDS_MAGIC:Int = 0x20534444;

    static inline var DDSD_CAPS:Int = 0x1;
    static inline var DDSD_HEIGHT:Int = 0x2;
    static inline var DDSD_WIDTH:Int = 0x4;
    static inline var DDSD_PITCH:Int = 0x8;
    static inline var DDSD_PIXELFORMAT:Int = 0x1000;
    static inline var DDSD_MIPMAPCOUNT:Int = 0x20000;
    static inline var DDSD_LINEARSIZE:Int = 0x80000;
    static inline var DDSD_DEPTH:Int = 0x800000;

    static inline var DDSCAPS_COMPLEX:Int = 0x8;
    static inline var DDSCAPS_MIPMAP:Int = 0x400000;
    static inline var DDSCAPS_TEXTURE:Int = 0x1000;

    static inline var DDSCAPS2_CUBEMAP:Int = 0x200;
    static inline var DDSCAPS2_CUBEMAP_POSITIVEX:Int = 0x400;
    static inline var DDSCAPS2_CUBEMAP_NEGATIVEX:Int = 0x800;
    static inline var DDSCAPS2_CUBEMAP_POSITIVEY:Int = 0x1000;
    static inline var DDSCAPS2_CUBEMAP_NEGATIVEY:Int = 0x2000;
    static inline var DDSCAPS2_CUBEMAP_POSITIVEZ:Int = 0x4000;
    static inline var DDSCAPS2_CUBEMAP_NEGATIVEZ:Int = 0x8000;
    static inline var DDSCAPS2_VOLUME:Int = 0x200000;

    static inline var DDPF_ALPHAPIXELS:Int = 0x1;
    static inline var DDPF_ALPHA:Int = 0x2;
    static inline var DDPF_FOURCC:Int = 0x4;
    static inline var DDPF_RGB:Int = 0x40;
    static inline var DDPF_YUV:Int = 0x200;
    static inline var DDPF_LUMINANCE:Int = 0x20000;

    static function FourCCToInt32(value:String):Int {
        return value.charCodeAt(0) +
            (value.charCodeAt(1) << 8) +
            (value.charCodeAt(2) << 16) +
            (value.charCodeAt(3) << 24);
    }

    static function Int32ToFourCC(value:Int):String {
        return String.fromCharCode(value & 0xff) + 
				String.fromCharCode((value >> 8) & 0xff) + 
				 String.fromCharCode((value >> 16) & 0xff) +
				  String.fromCharCode((value >> 24) & 0xff);
    }

    static inline var FOURCC_DXT1:Int = 827611204; // FourCCToInt32("DXT1");
    static inline var FOURCC_DXT3:Int = 861165636; // FourCCToInt32("DXT3");
    static inline var FOURCC_DXT5:Int = 894720068; // FourCCToInt32("DXT5");
    static inline var FOURCC_DX10:Int = 808540228; // FourCCToInt32("DX10");
    static inline var FOURCC_D3DFMT_R16G16B16A16F:Int = 113;
    static inline var FOURCC_D3DFMT_R32G32B32A32F:Int = 116;

    static inline var DXGI_FORMAT_R16G16B16A16_FLOAT:Int = 10;
    static inline var DXGI_FORMAT_B8G8R8X8_UNORM:Int = 88;

    static var headerLengthInt:Int = 31; // The header length in 32 bit ints

    // Offsets into the header array
    static var off_magic:Int = 0;

    static var off_size:Int = 1;
    static var off_flags:Int = 2;
    static var off_height:Int = 3;
    static var off_width:Int = 4;

    static var off_mipmapCount:Int = 7;

    static var off_pfFlags:Int = 20;
    static var off_pfFourCC:Int = 21;
    static var off_RGBbpp:Int = 22;
    static var off_RMask:Int = 23;
    static var off_GMask:Int = 24;
    static var off_BMask:Int = 25;
    static var off_AMask:Int = 26;
    static var off_caps1:Int = 27;
    static var off_caps2:Int = 28;
    static var off_caps3:Int = 29;
    static var off_caps4:Int = 30;
    static var off_dxgiFormat:Int = 32;
	

	public static var StoreLODInAlphaChannel:Bool = false;

	public static function GetDDSInfo(arrayBuffer:Dynamic):DDSInfo {
		var header = new Int32Array(arrayBuffer.getData(), 0, headerLengthInt);
		var extendedHeader = new Int32Array(arrayBuffer.getData(), 0, headerLengthInt + 4);
		
		var mipmapCount = 1;
		if (header[off_flags] & DDSD_MIPMAPCOUNT > 0) {
			mipmapCount = Std.int(Math.max(1, header[off_mipmapCount]));
		}
		
		var fourCC = header[off_pfFourCC];
		var dxgiFormat = (fourCC == FOURCC_DX10) ? extendedHeader[off_dxgiFormat] : 0;
		var textureType = Engine.TEXTURETYPE_UNSIGNED_INT;
		
		switch (fourCC) {
			case DDSTools.FOURCC_D3DFMT_R16G16B16A16F:  
				textureType = Engine.TEXTURETYPE_HALF_FLOAT;                           
				
			case DDSTools.FOURCC_D3DFMT_R32G32B32A32F:
				textureType = Engine.TEXTURETYPE_FLOAT;
				
			case DDSTools.FOURCC_DX10:
				if (dxgiFormat == DDSTools.DXGI_FORMAT_R16G16B16A16_FLOAT) {
					textureType = Engine.TEXTURETYPE_HALF_FLOAT;
				}
		}
		
		return {
			width: header[off_width],
			height: header[off_height],
			mipmapCount: mipmapCount,
			isFourCC: (header[off_pfFlags] & DDPF_FOURCC) == DDPF_FOURCC,
			isRGB: (header[off_pfFlags] & DDPF_RGB) == DDPF_RGB,
			isLuminance: (header[off_pfFlags] & DDPF_LUMINANCE) == DDPF_LUMINANCE,
			isCube: (header[off_caps2] & DDSCAPS2_CUBEMAP) == DDSCAPS2_CUBEMAP,
			isCompressed: (fourCC == FOURCC_DXT1 || fourCC == FOURCC_DXT3 || FOURCC_DXT1 == FOURCC_DXT5),
			dxgiFormat: dxgiFormat,
			textureType: textureType
		};
	}

	// ref: http://stackoverflow.com/questions/32633585/how-do-you-convert-to-half-floats-in-javascript
	private static var _FloatView:Float32Array;
	private static var _Int32View:Int32Array;
	private static function _ToHalfFloat(value:Int):Int {
		if (DDSTools._FloatView == null) {
			DDSTools._FloatView = new Float32Array(1);
			DDSTools._Int32View = new Int32Array(DDSTools._FloatView.buffer);
		}
		
		DDSTools._FloatView[0] = value;
		var x = DDSTools._Int32View[0];
		
		var bits:Int = (x >> 16) & 0x8000; /* Get the sign */
		var m:Int = (x >> 12) & 0x07ff; /* Keep one extra bit for rounding */
		var e:Int = (x >> 23) & 0xff; /* Using int is faster here */
		
		/* If zero, or denormal, or exponent underflows too much for a denormal
		* half, return signed zero. */
		if (e < 103) {
			return bits;
		}
		
		/* If NaN, return NaN. If Inf or exponent overflow, return Inf. */
		if (e > 142) {
			bits |= 0x7c00;
			/* If exponent was 0xff and one mantissa bit was set, it means NaN,
			* not Inf, so make sure we set one mantissa bit too. */
			bits |= ((e == 255) ? 0 : 1) & (x & 0x007fffff);
			return bits;
		}
		
		/* If exponent underflows but not too much, return a denormal */
		if (e < 113) {
			m |= 0x0800;
			/* Extra rounding may overflow and set mantissa to 0 and exponent
			* to 1, which is OK. */
			bits |= (m >> (114 - e)) + ((m >> (113 - e)) & 1);
			return bits;
		}
		
		bits |= ((e - 112) << 10) | (m >> 1);
		bits += m & 1;
		return bits;
	}

	private static function _FromHalfFloat(value:Int):Float {
		var s = (value & 0x8000) >> 15;
		var e = (value & 0x7C00) >> 10;
		var f = value & 0x03FF;
		
		if (e == 0) {
			return (s != 0 ? -1 : 1) * Math.pow(2, -14) * (f / Math.pow(2, 10));
		} 
		else if (e == 0x1F) {
			return f != 0 ? Math.NaN : ((s != 0 ? -1 : 1) * Math.POSITIVE_INFINITY);
		}
		
		return (s != 0 ? -1 : 1) * Math.pow(2, e-15) * (1 + (f / Math.pow(2, 10)));
	}

	private static function _GetHalfFloatAsFloatRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer, lod:Int):Float32Array {   
		var destArray = new Float32Array(dataLength);
		var srcData = new UInt16Array(arrayBuffer, dataOffset);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = (x + y * width) * 4;
				destArray[index] = DDSTools._FromHalfFloat(srcData[srcPos]);
				destArray[index + 1] = DDSTools._FromHalfFloat(srcData[srcPos + 1]);
				destArray[index + 2] = DDSTools._FromHalfFloat(srcData[srcPos + 2]);
				if (DDSTools.StoreLODInAlphaChannel) {
					destArray[index + 3] = lod;
				} 
				else {
					destArray[index + 3] = DDSTools._FromHalfFloat(srcData[srcPos + 3]);
				}
				index += 4;
			}
		}
		
		return destArray;
	} 

	private static function _GetHalfFloatRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer, lod:Int):UInt16Array {   
		if (DDSTools.StoreLODInAlphaChannel) {
			var destArray = new UInt16Array(dataLength);
			var srcData = new UInt16Array(arrayBuffer, dataOffset);
			var index = 0;
			for (y in 0...height) {
				for (x in 0...width) {
					var srcPos = (x + y * width) * 4;
					destArray[index] = srcData[srcPos];
					destArray[index + 1] = srcData[srcPos + 1];
					destArray[index + 2] = srcData[srcPos + 2];
					destArray[index + 3] = DDSTools._ToHalfFloat(lod);
					index += 4;
				}
			}
			
			return destArray;
		}
		
		return new UInt16Array(arrayBuffer, dataOffset, dataLength);
	}           

	private static function _GetFloatRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer, lod:Int):Float32Array {
		if (DDSTools.StoreLODInAlphaChannel) {
			var destArray = new Float32Array(dataLength);
			var srcData = new Float32Array(arrayBuffer, dataOffset);
			var index = 0;
			for (y in 0...height) {
				for (x in 0...width) {
					var srcPos = (x + y * width) * 4;
					destArray[index] = srcData[srcPos];
					destArray[index + 1] = srcData[srcPos + 1];
					destArray[index + 2] = srcData[srcPos + 2];
					destArray[index + 3] = lod;
					index += 4;
				}
			}
			
			return destArray;
		}
		
		return new Float32Array(arrayBuffer, dataOffset, dataLength);
	}

	private static function _GetFloatAsUIntRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer, lod:Int) {   
		var destArray = new UInt8Array(dataLength);
		var srcData = new Float32Array(arrayBuffer, dataOffset);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = Std.int((x + y * width) * 4);
				destArray[index] = Std.int(Scalar.Clamp(srcData[srcPos]) * 255);
				destArray[index + 1] = Std.int(Scalar.Clamp(srcData[srcPos + 1]) * 255);
				destArray[index + 2] = Std.int(Scalar.Clamp(srcData[srcPos + 2]) * 255);
				if (DDSTools.StoreLODInAlphaChannel) {
					destArray[index + 3] = lod;
				} 
				else {
					destArray[index + 3] = Std.int(Scalar.Clamp(srcData[srcPos + 3]) * 255);
				}
				index += 4;
			}
		}
		
		return destArray;
	}

	private static function _GetHalfFloatAsUIntRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer, lod:Int) {   
		var destArray = new UInt8Array(dataLength);
		var srcData = new UInt16Array(arrayBuffer, dataOffset);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = Std.int((x + y * width) * 4);
				destArray[index] = Std.int(Scalar.Clamp(DDSTools._FromHalfFloat(srcData[srcPos])) * 255);
				destArray[index + 1] = Std.int(Scalar.Clamp(DDSTools._FromHalfFloat(srcData[srcPos + 1])) * 255);
				destArray[index + 2] = Std.int(Scalar.Clamp(DDSTools._FromHalfFloat(srcData[srcPos + 2])) * 255);
				if (DDSTools.StoreLODInAlphaChannel) {
					destArray[index + 3] = lod;
				} 
				else {
					destArray[index + 3] = Std.int(Scalar.Clamp(DDSTools._FromHalfFloat(srcData[srcPos + 3])) * 255);
				}
				index += 4;
			}
		}
		
		return destArray;
	}

	private static function _GetRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer):UInt8Array {
		var byteArray = new UInt8Array(dataLength);
		var srcData = new UInt8Array(arrayBuffer, dataOffset);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = (x + y * width) * 4;
				byteArray[index] = srcData[srcPos + 2];
				byteArray[index + 1] = srcData[srcPos + 1];
				byteArray[index + 2] = srcData[srcPos];
				byteArray[index + 3] = srcData[srcPos + 3];
				index += 4;
			}
		}
		
		return byteArray;
	}

	private static function _GetRGBArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer):UInt8Array {            
		var byteArray = new UInt8Array(dataLength);
		var srcData = new UInt8Array(arrayBuffer, dataOffset);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = (x + y * width) * 3;
				byteArray[index] = srcData[srcPos + 2];
				byteArray[index + 1] = srcData[srcPos + 1];
				byteArray[index + 2] = srcData[srcPos];
				index += 3;
			}
		}
		
		return byteArray;
	}

	private static function _GetLuminanceArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer):UInt8Array {
		var byteArray = new UInt8Array(dataLength);
		var srcData = new UInt8Array(arrayBuffer, dataOffset);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = (x + y * width);
				byteArray[index] = srcData[srcPos];
				index++;
			}
		}
		
		return byteArray;
	}

	public static function UploadDDSLevels(engine:Engine, arrayBuffer:Dynamic, info:DDSInfo, loadMipmaps:Bool, faces:Int, lodIndex:Int = -1) {
		var gl = engine.gl;
		var ext:Dynamic = engine.getCaps().s3tc;
		
		var header = new Int32Array(arrayBuffer.getData(), 0, headerLengthInt);
		var fourCC:Int = 0;
		var blockBytes:Int = 0;
		var internalFormat:Int = 0;
		var format:Int = 0;
		var width:Int = 0;
		var height:Int = 0;
		var dataLength:Int = 0; 
		var dataOffset:Int = 0;
		var byteArray:UInt8Array = null;
		var mipmapCount:Int = 0;
		var mip:Int = 0;
		
		if (header[off_magic] != DDS_MAGIC) {
			Tools.Error("Invalid magic number in DDS header");
			return;
		}
		
		if (!info.isFourCC && !info.isRGB && !info.isLuminance) {
			Tools.Error("Unsupported format, must contain a FourCC, RGB or LUMINANCE code");
			return;
		}
		
		if (info.isCompressed && !ext) {
			Tools.Error("Compressed textures are not supported on this platform.");
			return;
		}
		
		var bpp = header[off_RGBbpp];
		dataOffset = header[off_size] + 4;
		
		var computeFormats = false;
		
		if (info.isFourCC) {
			fourCC = header[off_pfFourCC];
			switch (fourCC) {
				case DDSTools.FOURCC_DXT1:
					blockBytes = 8;
					internalFormat = ext.COMPRESSED_RGBA_S3TC_DXT1_EXT;
					
				case DDSTools.FOURCC_DXT3:
					blockBytes = 16;
					internalFormat = ext.COMPRESSED_RGBA_S3TC_DXT3_EXT;
					
				case DDSTools.FOURCC_DXT5:
					blockBytes = 16;
					internalFormat = ext.COMPRESSED_RGBA_S3TC_DXT5_EXT;
					
				case DDSTools.FOURCC_D3DFMT_R16G16B16A16F:  
					computeFormats = true;
					
				case DDSTools.FOURCC_D3DFMT_R32G32B32A32F:
					computeFormats = true;
					
				case DDSTools.FOURCC_DX10:
					// There is an additionnal header so dataOffset need to be changed
					dataOffset += 5 * 4; // 5 uints
					
					var supported = false;
					switch (info.dxgiFormat) {
						case DDSTools.DXGI_FORMAT_R16G16B16A16_FLOAT:
							computeFormats = true;
							supported = true;
							
						case DDSTools.DXGI_FORMAT_B8G8R8X8_UNORM:
							info.isRGB = true;
							info.isFourCC = false;
							bpp = 32;
							supported = true;					
					}
					
				default:
					Tools.Error("Unsupported FourCC code: " + Int32ToFourCC(fourCC));
					return;
			}
		}
		
		if (computeFormats) {
			format = engine._getWebGLTextureType(info.textureType);    
			internalFormat = @:privateAccess engine._getRGBABufferInternalSizedFormat(info.textureType);
		}
		
		mipmapCount = 1;
		if ((header[off_flags] & DDSTools.DDSD_MIPMAPCOUNT) != 0 && loadMipmaps != false) {
			mipmapCount = Std.int(Math.max(1, header[off_mipmapCount]));
		}
		
		for (face in 0...faces) {
			var sampler = faces == 1 ? gl.TEXTURE_2D : (gl.TEXTURE_CUBE_MAP_POSITIVE_X + face);
			
			width = header[off_width];
			height = header[off_height];
			
			for (mip in 0...mipmapCount) {
				if (lodIndex == -1 || lodIndex == mip) {
					// In case of fixed LOD, if the lod has just been uploaded, early exit.
					var i = (lodIndex == -1) ? mip : 0;
					
					if (!info.isCompressed && info.isFourCC) {
						dataLength = Std.int(width * height * 4);
						var floatArray:ArrayBufferView = null;
						
						if ((!engine.getCaps().textureHalfFloat && !engine.getCaps().textureFloat)) { // Required because iOS has many issues with float and half float generation
							if (bpp == 128) {
								floatArray = DDSTools._GetFloatAsUIntRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer, i);   
							}
							else if (bpp == 64) {
								floatArray = DDSTools._GetHalfFloatAsUIntRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer, i);
							}
							
							info.textureType = Engine.TEXTURETYPE_UNSIGNED_INT;
							format = engine._getWebGLTextureType(info.textureType);
							internalFormat = @:privateAccess engine._getRGBABufferInternalSizedFormat(info.textureType);
						}
						else {
							if (bpp == 128) {
								floatArray = DDSTools._GetFloatRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer, i);
							} 
							else if (bpp == 64 && !engine.getCaps().textureHalfFloat) {
								floatArray = DDSTools._GetHalfFloatAsFloatRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer, i);
								
								info.textureType = Engine.TEXTURETYPE_FLOAT;
								format = engine._getWebGLTextureType(info.textureType);    
								internalFormat = @:privateAccess engine._getRGBABufferInternalSizedFormat(info.textureType);                            
							} 
							else { // 64
								floatArray = DDSTools._GetHalfFloatRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer, i);
							}
						}
						
						engine._uploadDataToTexture(sampler, i, internalFormat, width, height, gl.RGBA, format, floatArray);
					} 
					else if (info.isRGB) {
						if (bpp == 24) {
							dataLength = width * height * 3;
							byteArray = DDSTools._GetRGBArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer);
							engine._uploadDataToTexture(sampler, i, gl.RGB, width, height, gl.RGB, gl.UNSIGNED_BYTE, byteArray);
						} 
						else { // 32
							dataLength = width * height * 4;
							byteArray = DDSTools._GetRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer);
							engine._uploadDataToTexture(sampler, i, gl.RGBA, width, height, gl.RGBA, gl.UNSIGNED_BYTE, byteArray);
						}
					} 
					else if (info.isLuminance) {
						var unpackAlignment = gl.getParameter(gl.UNPACK_ALIGNMENT);
						var unpaddedRowSize = width;
						var paddedRowSize = Math.floor((width + unpackAlignment - 1) / unpackAlignment) * unpackAlignment;
						dataLength = paddedRowSize * (height - 1) + unpaddedRowSize;
						
						byteArray = DDSTools._GetLuminanceArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer);
						engine._uploadDataToTexture(sampler, i, gl.LUMINANCE, width, height, gl.LUMINANCE, gl.UNSIGNED_BYTE, byteArray);
					} 
					else {
						dataLength = Std.int(Math.max(4, width) / 4 * Math.max(4, height) / 4 * blockBytes);
						byteArray = new UInt8Array(arrayBuffer, dataOffset, dataLength);
						engine._uploadCompressedDataToTexture(sampler, i, internalFormat, width, height, byteArray);
					}
				}
				dataOffset += Std.int(width * height * (bpp / 8));
				width = Std.int(width * 0.5);
				height = Std.int(height * 0.5);
				
				width = Std.int(Math.max(1.0, width));
				height = Std.int(Math.max(1.0, height));
			}
		}
	}
	
}
