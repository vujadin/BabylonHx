package com.babylonhx.ui;

import com.babylonhx.utils.typedarray.UInt8Array;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.ColorMatrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.DynamicTexture;
import haxe.ds.Vector;


class Graphics {
	
public static function colorTransform (scene:Scene, texture:DynamicTexture, rect:Rectangle, colorMatrix:ColorMatrix):Void {
		
		var data = texture._canvas.data;
		var stride = texture._canvas.width * 4;
		var offset:Int;
		
		var rowStart = Std.int (rect.top + texture._canvas.offsetY);
		var rowEnd = Std.int (rect.bottom + texture._canvas.offsetY);
		var columnStart = Std.int (rect.left + texture._canvas.offsetX);
		var columnEnd = Std.int (rect.right + texture._canvas.offsetX);
		
		var r, g, b, a, ex = 0;
		
		for (row in rowStart...rowEnd) {
			
			for (column in columnStart...columnEnd) {
				
				offset = (row * stride) + (column * 4);
				
				a = Std.int ((data[offset + 3] * colorMatrix.alphaMultiplier) + colorMatrix.alphaOffset);
				ex = a > 0xFF ? a - 0xFF : 0;
				b = Std.int ((data[offset + 2] * colorMatrix.blueMultiplier) + colorMatrix.blueOffset + ex);
				ex = b > 0xFF ? b - 0xFF : 0;
				g = Std.int ((data[offset + 1] * colorMatrix.greenMultiplier) + colorMatrix.greenOffset + ex);
				ex = g > 0xFF ? g - 0xFF : 0;
				r = Std.int ((data[offset] * colorMatrix.redMultiplier) + colorMatrix.redOffset + ex);
				
				data[offset] = r > 0xFF ? 0xFF : r;
				data[offset + 1] = g > 0xFF ? 0xFF : g;
				data[offset + 2] = b > 0xFF ? 0xFF : b;
				data[offset + 3] = a > 0xFF ? 0xFF : a;
				
			}
			
		}
		
		scene.getEngine().updateDynamicTexture(texture._texture, texture._canvas, false);
		
	}


public static function fillRect (scene:Scene, texture:DynamicTexture,  rect:Rectangle, color:Int):Void {
		
		var a = (texture._canvas.transparent) ? ((color & 0xFF000000) >>> 24) : 0xFF;
		var r = (color & 0x00FF0000) >>> 16;
		var g = (color & 0x0000FF00) >>> 8;
		var b = (color & 0x000000FF);
		
		var rgba = (r | (g << 8) | (b << 16) | (a << 24));
		var data = texture._canvas.data;
		if (rect.width == texture._canvas.width && rect.height == texture._canvas.height && rect.x == 0 && rect.y == 0 && texture._canvas.offsetX == 0 && texture._canvas.offsetY == 0) {
			trace(rgba);
			var length = texture._canvas.width * texture._canvas.height;
			
			var j = 0;
			for (i in 0...length) {
				
				j = i * 4;
				
				#if (js || snow)  
				data[j + 0] = r;
				data[j + 1] = g;
				data[j + 2] = b;
				data[j + 3] = a;
				#else
				data.setUInt32 (j, rgba);
				#end
				
			}
			
		} else {
			
			var stride = texture._canvas.width * 4;
			var offset:Int;
			
			var rowStart = Std.int (rect.y + texture._canvas.offsetY);
			var rowEnd = Std.int (rect.bottom + texture._canvas.offsetY);
			var columnStart = Std.int (rect.x + texture._canvas.offsetX);
			var columnEnd = Std.int (rect.right + texture._canvas.offsetX);
			
			for (row in rowStart...rowEnd) {
				
				for (column in columnStart...columnEnd) {
					
					offset = (row * stride) + (column * 4);
					
					#if (js || snow)  
					data[offset] = r;
					data[offset + 1] = g;
					data[offset + 2] = b;
					data[offset + 3] = a;
					#else
					data.setUInt32 (offset, rgba);
					#end
					
				}
				
			}
			
		}
		scene.getEngine().updateDynamicTexture(texture._texture, texture._canvas, false);
	}
	
	
	public static function floodFill (scene:Scene, texture:DynamicTexture, x:Int, y:Int, color:Int):Void {
		
		var data = texture._canvas.data;
		var offset = (((y + texture._canvas.offsetY) * (texture._canvas.width * 4)) + ((x + texture._canvas.offsetX) * 4));
		var hitColorR = data[cast offset + 0];
		var hitColorG = data[cast offset + 1];
		var hitColorB = data[cast offset + 2];
		var hitColorA = texture._canvas.transparent ? data[cast offset + 3] : 0xFF;
		
		var r = (color & 0xFF0000) >>> 16;
		var g = (color & 0x00FF00) >>> 8;
		var b = (color & 0x0000FF);
		var a = texture._canvas.transparent ? (color & 0xFF000000) >>> 24 : 0xFF;
		
		if (hitColorR == r && hitColorG == g && hitColorB == b && hitColorA == a) return;
		
		var dx = [ 0, -1, 1, 0 ];
		var dy = [ -1, 0, 0, 1 ];
		
		var minX = -texture._canvas.offsetX;
		var minY = -texture._canvas.offsetY;
		var maxX = minX + texture._canvas.width;
		var maxY = minY + texture._canvas.height;
		
		var queue = new Array<Int> ();
		queue.push (x);
		queue.push (y);
		
		while (queue.length > 0) {
			
			var curPointY = queue.pop ();
			var curPointX = queue.pop ();
			
			for (i in 0...4) {
				
				var nextPointX = curPointX + dx[i];
				var nextPointY = curPointY + dy[i];
				
				if (nextPointX < minX || nextPointY < minY || nextPointX >= maxX || nextPointY >= maxY) {
					
					continue;
					
				}
				
				var nextPointOffset = (nextPointY * texture._canvas.width + nextPointX) * 4;
				
				if (data[nextPointOffset + 0] == hitColorR && data[nextPointOffset + 1] == hitColorG && data[nextPointOffset + 2] == hitColorB && data[nextPointOffset + 3] == hitColorA) {
					
					data[nextPointOffset + 0] = r;
					data[nextPointOffset + 1] = g;
					data[nextPointOffset + 2] = b;
					data[nextPointOffset + 3] = a;
					
					queue.push (nextPointX);
					queue.push (nextPointY);
					
				}
				
			}
			
		}
		
		scene.getEngine().updateDynamicTexture(texture._texture, texture._canvas, false);
		
	}
	

	
}
