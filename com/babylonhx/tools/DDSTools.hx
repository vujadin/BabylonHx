package com.babylonhx.tools;

import lime.utils.ArrayBuffer;
import lime.utils.ArrayBufferView;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import lime.utils.UInt16Array;
import lime.utils.UInt8Array;

// VK TODO:

/**
 * ...
 * @author Krtolica Vujadin
 */

// Based on demo done by Brandon Jones - http://media.tojicode.com/webgl-samples/dds.html
// All values and structures referenced from:
// http://msdn.microsoft.com/en-us/library/bb943991.aspx/

typedef DDSInfo = {
	
	var width:Int;
	var height:Int;
	var mipmapCount:Int;
	var isFourCC:Bool;
	var isRGB:Bool;
	var isLuminance:Bool;
	var isCube:Bool;
	var isCompressed:Bool;
	var dxgiFormat:Int;
	var textureType:Int;
	
}
	
class DDSTools {
	
	public static var DDS_MAGIC:Int = 0x20534444;

    public static var DDSD_CAPS:Int = 0x1;
	public static var DDSD_HEIGHT:Int = 0x2;
	public static var DDSD_WIDTH:Int = 0x4;
	public static var DDSD_PITCH:Int = 0x8;
	public static var DDSD_PIXELFORMAT:Int = 0x1000;
	public static var DDSD_MIPMAPCOUNT:Int = 0x20000;
	public static var DDSD_LINEARSIZE:Int = 0x80000;
	public static var DDSD_DEPTH:Int = 0x800000;

	public static var DDSCAPS_COMPLEX:Int = 0x8;
	public static var DDSCAPS_MIPMAP:Int = 0x400000;
	public static var DDSCAPS_TEXTURE:Int = 0x1000;

	public static var DDSCAPS2_CUBEMAP:Int = 0x200;
	public static var DDSCAPS2_CUBEMAP_POSITIVEX:Int = 0x400;
	public static var DDSCAPS2_CUBEMAP_NEGATIVEX:Int = 0x800;
	public static var DDSCAPS2_CUBEMAP_POSITIVEY:Int = 0x1000;
	public static var DDSCAPS2_CUBEMAP_NEGATIVEY:Int = 0x2000;
	public static var DDSCAPS2_CUBEMAP_POSITIVEZ:Int = 0x4000;
	public static var DDSCAPS2_CUBEMAP_NEGATIVEZ:Int = 0x8000;
	public static var DDSCAPS2_VOLUME:Int = 0x200000;

	public static var DDPF_ALPHAPIXELS:Int = 0x1;
	public static var DDPF_ALPHA:Int = 0x2;
	public static var DDPF_FOURCC:Int = 0x4;
	public static var DDPF_RGB:Int = 0x40;
	public static var DDPF_YUV:Int = 0x200;
	public static var DDPF_LUMINANCE:Int = 0x20000;
	
	
	static function FourCCToInt32(value:String):Int {
        return value.charCodeAt(0) +
            (value.charCodeAt(1) << 8) +
            (value.charCodeAt(2) << 16) +
            (value.charCodeAt(3) << 24);
    }

    static function Int32ToFourCC(value:Int) {
        return String.fromCharCode(
            value & 0xff,
            (value >> 8) & 0xff,
            (value >> 16) & 0xff,
            (value >> 24) & 0xff
            );
    }
	
	static var FOURCC_DXT1:Int = FourCCToInt32("DXT1");
    static var FOURCC_DXT3:Int = FourCCToInt32("DXT3");
    static var FOURCC_DXT5:Int = FourCCToInt32("DXT5");
    static var FOURCC_DX10:Int = FourCCToInt32("DX10");
    static var FOURCC_D3DFMT_R16G16B16A16F:Int = 113;
    static var FOURCC_D3DFMT_R32G32B32A32F:Int = 116;

    static var DXGI_FORMAT_R16G16B16A16_FLOAT:Int = 10;

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
		var header = new Int32Array(arrayBuffer, 0, headerLengthInt);
		var extendedHeader = new Int32Array(arrayBuffer, 0, headerLengthInt + 4);
		
		var mipmapCount = 1;
		if (header[off_flags] & DDSD_MIPMAPCOUNT != 0) {
			mipmapCount = Math.max(1, header[off_mipmapCount]);
		}
		
		var fourCC:Int = header[off_pfFourCC];
		var dxgiFormat:Int = (fourCC == FOURCC_DX10) ? extendedHeader[off_dxgiFormat] : 0;
		var textureType:Int = Engine.TEXTURETYPE_UNSIGNED_INT;
		
		switch (fourCC) {
			case FOURCC_D3DFMT_R16G16B16A16F:  
				textureType = Engine.TEXTURETYPE_HALF_FLOAT;                           
				
			case FOURCC_D3DFMT_R32G32B32A32F:
				textureType = Engine.TEXTURETYPE_FLOAT;
				
			case FOURCC_DX10:
				if (dxgiFormat == DXGI_FORMAT_R16G16B16A16_FLOAT) {
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
	private static function _ToHalfFloat(value:Float):Float {
		if (DDSTools._FloatView == null) {
			DDSTools._FloatView = new Float32Array(1);
			DDSTools._Int32View = new Int32Array(DDSTools._FloatView.buffer);
		}
		
		DDSTools._FloatView[0] = value;
		var x = DDSTools._Int32View[0];
		
		var bits = (x >> 16) & 0x8000; /* Get the sign */
		var m = (x >> 12) & 0x07ff; /* Keep one extra bit for rounding */
		var e = (x >> 23) & 0xff; /* Using int is faster here */
		
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
			bits |= ((e == 255) ? 0 : 1) && (x & 0x007fffff);
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

	private static function _FromHalfFloat(value: number): number {
		var s = (value & 0x8000) >> 15;
		var e = (value & 0x7C00) >> 10;
		var f = value & 0x03FF;

		if(e === 0) {
			return (s ? -1 : 1) * Math.pow(2, -14) * (f / Math.pow(2, 10));
		} else if (e == 0x1F) {
			return f ? NaN : ((s ? -1 : 1) * Infinity);
		}

		return (s ? -1 : 1) * Math.pow(2, e-15) * (1 + (f / Math.pow(2, 10)));
	}

	private static _GetHalfFloatAsFloatRGBAArrayBuffer(width: number, height: number, dataOffset: number, dataLength: number, arrayBuffer: ArrayBuffer, lod: number): Float32Array {   
		var destArray = new Float32Array(dataLength);
		var srcData = new Uint16Array(arrayBuffer, dataOffset);
		var index = 0;
		for (var y = 0; y < height; y++) {
			for (var x = 0; x < width; x++) {
				var srcPos = (x + y * width) * 4;
				destArray[index] = DDSTools._FromHalfFloat(srcData[srcPos]);
				destArray[index + 1] = DDSTools._FromHalfFloat(srcData[srcPos + 1]);
				destArray[index + 2] = DDSTools._FromHalfFloat(srcData[srcPos + 2]);
				if (DDSTools.StoreLODInAlphaChannel) {
					destArray[index + 3] = lod;
				} else {
					destArray[index + 3] = DDSTools._FromHalfFloat(srcData[srcPos + 3]);
				}
				index += 4;
			}
		}

		return destArray;
	} 

	private static function _GetHalfFloatRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer):UInt16Array {   
		return new UInt16Array(arrayBuffer, dataOffset, dataLength);
	}           

	private static function _GetFloatRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer):Float32Array {
		return new Float32Array(arrayBuffer, dataOffset, dataLength);
	}        

	private static function GetRGBAArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer):UInt8Array {
		var byteArray = new UInt8Array(dataLength);
		var srcData = new UInt8Array(arrayBuffer);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = dataOffset + (x + y * width) * 4;
				byteArray[index] = srcData[srcPos + 2];
				byteArray[index + 1] = srcData[srcPos + 1];
				byteArray[index + 2] = srcData[srcPos];
				byteArray[index + 3] = srcData[srcPos + 3];
				index += 4;
			}
		}
		
		return byteArray;
	}

	private static function GetRGBArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer):UInt8Array {
		var byteArray = new UInt8Array(dataLength);
		var srcData = new UInt8Array(arrayBuffer);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = dataOffset + (x + y * width) * 3;
				byteArray[index] = srcData[srcPos + 2];
				byteArray[index + 1] = srcData[srcPos + 1];
				byteArray[index + 2] = srcData[srcPos];
				index += 3;
			}
		}
		
		return byteArray;
	}

	private static function GetLuminanceArrayBuffer(width:Int, height:Int, dataOffset:Int, dataLength:Int, arrayBuffer:ArrayBuffer):UInt8Array {
		var byteArray = new UInt8Array(dataLength);
		var srcData = new UInt8Array(arrayBuffer);
		var index = 0;
		for (y in 0...height) {
			for (x in 0...width) {
				var srcPos = dataOffset + (x + y * width);
				byteArray[index] = srcData[srcPos];
				index++;
			}
		}
		
		return byteArray;
	}

	public static function UploadDDSLevels(engine:Engine, arrayBuffer:Dynamic, info:DDSInfo, loadMipmaps:Bool, faces:Int) {
		var gl = engine.Gl;
		var ext = engine.getCaps().s3tc;
		
		var header = new Int32Array(arrayBuffer, 0, headerLengthInt);
		var	fourCC:Bool;
		var blockBytes:Int;
		var internalFormat:Int;
		var format:Int;
		var width:Int;
		var height:Int;
		var dataLength:Int;
		var dataOffset:Int;
		var byteArray:UInt8Array;
		var mipmapCount:Int;
		
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
		
		var bpp:Int = header[off_RGBbpp];
		dataOffset:Int = header[off_size] + 4;
		
		var computeFormats:Bool = false;
		
		if (info.isFourCC) {
			fourCC = header[off_pfFourCC];
			switch (fourCC) {
				case FOURCC_DXT1:
					blockBytes = 8;
					internalFormat = ext.COMPRESSED_RGBA_S3TC_DXT1_EXT;
					
				case FOURCC_DXT3:
					blockBytes = 16;
					internalFormat = ext.COMPRESSED_RGBA_S3TC_DXT3_EXT;
					
				case FOURCC_DXT5:
					blockBytes = 16;
					internalFormat = ext.COMPRESSED_RGBA_S3TC_DXT5_EXT;
					
				case FOURCC_D3DFMT_R16G16B16A16F:  
					computeFormats = true;
					
				case FOURCC_D3DFMT_R32G32B32A32F:
					computeFormats = true;
					
				case FOURCC_DX10:
					// There is an additionnal header so dataOffset need to be changed
					dataOffset += 5 * 4; // 5 uints
					
					if (info.dxgiFormat == DXGI_FORMAT_R16G16B16A16_FLOAT) {
						computeFormats = true;
					}
				default:
					Tools.Error("Unsupported FourCC code:", Int32ToFourCC(fourCC));				
			}
		}
		
		if (computeFormats) {
			format = engine._getWebGLTextureType(info.textureType);    
			internalFormat = engine._getRGBABufferInternalSizedFormat(info.textureType);
		}
		
		mipmapCount = 1;
		if (header[off_flags] & DDSD_MIPMAPCOUNT != 0 && loadMipmaps != false) {
			mipmapCount = Math.max(1, header[off_mipmapCount]);
		}
		
		for (face in 0...faces) {
			var sampler = faces == 1 ? gl.TEXTURE_2D : (gl.TEXTURE_CUBE_MAP_POSITIVE_X + face);
			
			width = header[off_width];
			height = header[off_height];
			
			for (i in 0...mipmapCount) {
				if (!info.isCompressed && info.isFourCC) {
					dataLength = width * height * 4;
					var floatArray:ArrayBufferView = null;
					if (bpp == 128) {
						floatArray = DDSTools.GetFloatRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer);
					} 
					else { // 64
						floatArray = DDSTools.GetHalfFloatRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer);
					}
					
					engine._uploadDataToTexture(sampler, i, internalFormat, width, height, gl.RGBA, format, floatArray);
				} 
				else if (info.isRGB) {
					if (bpp == 24) {
						dataLength = width * height * 3;
						byteArray = DDSTools.GetRGBArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer);
						engine._uploadDataToTexture(sampler, i, gl.RGB, width, height, gl.RGB, gl.UNSIGNED_BYTE, byteArray);
					} 
					else { // 32
						dataLength = width * height * 4;
						byteArray = DDSTools.GetRGBAArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer);
						engine._uploadDataToTexture(sampler, i, gl.RGBA, width, height, gl.RGBA, gl.UNSIGNED_BYTE, byteArray);
					}
				} 
				else if (info.isLuminance) {
					var unpackAlignment = gl.getParameter(gl.UNPACK_ALIGNMENT);
					var unpaddedRowSize = width;
					var paddedRowSize = Math.floor((width + unpackAlignment - 1) / unpackAlignment) * unpackAlignment;
					dataLength = paddedRowSize * (height - 1) + unpaddedRowSize;
					
					byteArray = DDSTools.GetLuminanceArrayBuffer(width, height, dataOffset, dataLength, arrayBuffer);
					engine._uploadDataToTexture(sampler, i, gl.LUMINANCE, width, height, gl.LUMINANCE, gl.UNSIGNED_BYTE, byteArray);
				} 
				else {
					dataLength = Math.max(4, width) / 4 * Math.max(4, height) / 4 * blockBytes;
					byteArray = new Uint8Array(arrayBuffer, dataOffset, dataLength);
					engine._uploadCompressedDataToTexture(sampler, i, internalFormat, width, height, byteArray);
				}
				dataOffset += width * height * (bpp / 8);
				width *= 0.5;
				height *= 0.5;
				
				width = Math.max(1.0, width);
				height = Math.max(1.0, height);
			}
		}
	}
	
}
