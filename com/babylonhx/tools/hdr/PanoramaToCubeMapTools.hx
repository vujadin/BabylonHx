package com.babylonhx.tools.hdr;

import com.babylonhx.math.Vector3;

import lime.utils.Float32Array;
import lime.utils.ArrayBuffer;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef CubeMapInfo = {	
	var front:Float32Array;
	var back:Float32Array;
	var left:Float32Array;
	var right:Float32Array;
	var up:Float32Array;
	var down:Float32Array;
	var size:Int;
	/**
	 * The format of the texture.
	 * 
	 * RGBA, RGB.
	 */
	var format:Int;
	
	/**
	 * The type of the texture data.
	 * 
	 * UNSIGNED_INT, FLOAT.
	 */
	var type:Int;
	/**
	 * Specifies whether the texture is in gamma space.
	 */
	var gammaSpace:Bool;
} 
 
class PanoramaToCubeMapTools {
	
	private static var FACE_FRONT:Array<Vector3> = [
		new Vector3(-1.0, -1.0, -1.0),
		new Vector3(1.0, -1.0, -1.0),
		new Vector3(-1.0, 1.0, -1.0),
		new Vector3(1.0, 1.0, -1.0)
	];
	private static var FACE_BACK:Array<Vector3> = [
		new Vector3(1.0, -1.0, 1.0),
		new Vector3(-1.0, -1.0, 1.0),
		new Vector3(1.0, 1.0, 1.0),
		new Vector3(-1.0, 1.0, 1.0)
	];
	private static var  FACE_RIGHT:Array<Vector3> = [
		new Vector3(1.0, -1.0, -1.0),
		new Vector3(1.0, -1.0, 1.0),
		new Vector3(1.0, 1.0, -1.0),
		new Vector3(1.0, 1.0, 1.0)
	];
	private static var FACE_LEFT:Array<Vector3> = [
		new Vector3(-1.0, -1.0, 1.0),
		new Vector3(-1.0, -1.0, -1.0),
		new Vector3(-1.0, 1.0, 1.0),
		new Vector3(-1.0, 1.0, -1.0)
	];
	private static var FACE_DOWN:Array<Vector3> = [
		new Vector3(-1.0, 1.0, -1.0),
		new Vector3(1.0, 1.0, -1.0),
		new Vector3(-1.0, 1.0, 1.0),
		new Vector3(1.0, 1.0, 1.0)
	];
	private static var FACE_UP:Array<Vector3> = [
		new Vector3(-1.0, -1.0, 1.0),
		new Vector3(1.0, -1.0, 1.0),
		new Vector3(-1.0, -1.0, -1.0),
		new Vector3(1.0, -1.0, -1.0)
	];
	

	public function new() {
		
	}
	
	public static function ConvertPanoramaToCubemap(float32Array:Float32Array, inputWidth:Int, inputHeight:Int, size:Int):CubeMapInfo {
		if (float32Array == null) {
			throw "ConvertPanoramaToCubemap: input cannot be null";
		}
		
		if (float32Array.length != inputWidth * inputHeight * 3) {
			throw "ConvertPanoramaToCubemap: input size is wrong";
		}
		
		var textureFront = CreateCubemapTexture(size, FACE_FRONT, float32Array, inputWidth, inputHeight);
		var textureBack = CreateCubemapTexture(size, FACE_BACK, float32Array, inputWidth, inputHeight);
		var textureLeft = CreateCubemapTexture(size, FACE_LEFT, float32Array, inputWidth, inputHeight);
		var textureRight = CreateCubemapTexture(size, FACE_RIGHT, float32Array, inputWidth, inputHeight);
		var textureUp = CreateCubemapTexture(size, FACE_UP, float32Array, inputWidth, inputHeight);
		var textureDown = CreateCubemapTexture(size, FACE_DOWN, float32Array, inputWidth, inputHeight);
		
		return {
			front: textureFront,
			back: textureBack,
			left: textureLeft,
			right: textureRight,
			up: textureUp,
			down: textureDown,
			size: size,
			type: Engine.TEXTURETYPE_FLOAT,
            format: Engine.TEXTUREFORMAT_RGB,
			gammaSpace: false
		};
	}

	private static function CreateCubemapTexture(texSize:Int, faceData:Array<Vector3>, float32Array:Float32Array, inputWidth:Int, inputHeight:Int) {
		var buffer:ArrayBuffer = new ArrayBuffer(texSize * texSize * 4 * 3);
		var textureArray:Float32Array = new Float32Array(buffer);
		
		var rotDX1 = faceData[1].subtract(faceData[0]).scale(1 / texSize);
		var rotDX2 = faceData[3].subtract(faceData[2]).scale(1 / texSize);
		
		var dy:Float = 1 / texSize;
		var fy:Float = 0;
		
		for (y in 0...texSize) {
			var xv1 = faceData[0];
			var xv2 = faceData[2];
			
			for (x in 0...texSize) {
				var v = xv2.subtract(xv1).scale(fy).add(xv1);
				v.normalize();
				
				var color = CalcProjectionSpherical(v, float32Array, inputWidth, inputHeight);
				
				// 3 channels per pixels
				textureArray[y * texSize * 3 + (x * 3) + 0] = color.r;
				textureArray[y * texSize * 3 + (x * 3) + 1] = color.g;
				textureArray[y * texSize * 3 + (x * 3) + 2] = color.b;
				
				xv1 = xv1.add(rotDX1);
				xv2 = xv2.add(rotDX2);
			}
			
			fy += dy;
		}
		
		return textureArray;
	}

	private static function CalcProjectionSpherical(vDir:Vector3, float32Array:Float32Array, inputWidth:Int, inputHeight:Int):Dynamic {
		var theta = Math.atan2(vDir.z, vDir.x);
		var phi   = Math.acos(vDir.y);
		
		while (theta < -Math.PI) theta += 2 * Math.PI;
		while (theta > Math.PI) theta -= 2 * Math.PI;
		
		var dx = theta / Math.PI;
		var dy = phi / Math.PI;
		
		// recenter.
		dx = dx * 0.5 + 0.5;
		
		var px = Math.round(dx * inputWidth);
		if (px < 0) {
			px = 0;
		}
		else if (px >= inputWidth) {
			px = inputWidth - 1;
		}
		
		var py = Math.round(dy * inputHeight);
		if (py < 0) {
			py = 0;
		}
		else if (py >= inputHeight) {
			py = inputHeight - 1;
		}
		
		var inputY = (inputHeight - py - 1);
		var r = float32Array[inputY * inputWidth * 3 + (px * 3) + 0];
		var g = float32Array[inputY * inputWidth * 3 + (px * 3) + 1];
		var b = float32Array[inputY * inputWidth * 3 + (px * 3) + 2];
		
		return {
			r: r,
			g: g,
			b: b
		};
	}
	
}
