package com.babylonhx.loading.plugins.ctmfileloader;

import com.babylonhx.loading.plugins.ctmfileloader.lzma.LZMA;

import com.babylonhx.utils.typedarray.ArrayBuffer;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt16Array;
import com.babylonhx.utils.typedarray.UInt32Array;
import com.babylonhx.utils.typedarray.UInt8Array;

import haxe.io.BytesInput;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:enum 
abstract CompressionMethod(Int) {
	var RAW = 0x00574152;
	var MG1 = 0x0031474d;
	var MG2 = 0x0032474d;	
}

@:enum 
abstract Flags(Int) {	
	var NORMALS = 0x00000001;	
}
 
class CTM {

	static public function decompress(stream:BytesInput, size:Int, interleaved:CTMInterleavedStream) {
		var offset = stream.position;
		LZMA.decompress(stream, stream, interleaved, interleaved.data.length);
		stream.position = offset + 5 + size;
	}
	
	static public function restoreIndices(indices:UInt32Array, len:Int) {		
		var i:Int = 3;
		if (len > 0){
			indices[2] += indices[0];
			indices[1] += indices[0];
		}
		while (i < len) {
			indices[i] += indices[i - 3];
			
			if (indices[i] == indices[i - 3]) {
				indices[i + 1] += indices[i - 2];
			}
			else {
				indices[i + 1] += indices[i];
			}
			
			indices[i + 2] += indices[i];
			
			i += 3;
		}
    }

	static public function restoreGridIndices(gridIndices:UInt32Array, len:Int) {
		for (i in 1...len) {
			gridIndices[i] += gridIndices[i - 1];
		}
	}

	static public function restoreVertices(vertices:Float32Array, grid:CTMFileMG2Header, gridIndices:UInt32Array, precision:Float) {
		var gridIdx:Int;
		var delta:Int;
		var x:Int;
		var y:Int;
		var z:Int;
		var intVertices:UInt32Array = new UInt32Array(vertices.buffer, vertices.byteOffset, vertices.length);
		var ydiv:Int = grid.divx;
		var zdiv = ydiv * grid.divy;
		var prevGridIdx:Int = 0x7fffffff;
		var prevDelta:Int = 0;
		var len:Int = gridIndices.length;
		
		var i:Int = 0;
		var j:Int = 0;
		while (i < len) {
			x = gridIdx = gridIndices[i++];
			
			z = cast ~~(x / zdiv);
			x -= cast ~~(z * zdiv);
			y = cast ~~(x / ydiv);
			x -= cast ~~(y * ydiv);
			
			delta = intVertices[j];
			if (gridIdx == prevGridIdx){
				delta += prevDelta;
			}
			
			vertices[j] = grid.lowerBoundx + x * grid.sizex + precision * delta;
			vertices[j + 1] = grid.lowerBoundy + y * grid.sizey + precision * intVertices[j + 1];
			vertices[j + 2] = grid.lowerBoundz + z * grid.sizez + precision * intVertices[j + 2];
			
			prevGridIdx = gridIdx;
			prevDelta = delta;
			
			j += 3;
		}
	}

	static public function restoreNormals(normals:Float32Array, smooth:Float32Array, precision:Float) {
		var ro:Float;
		var phi:Float;
		var theta:Float;
		var sinPhi:Float;
		var nx:Float;
		var ny:Float;
		var nz:Float;
		var by:Float;
		var bz:Float;
		var len:Float;
		var intNormals:UInt32Array = new UInt32Array(normals.buffer, normals.byteOffset, normals.length);
		var i:Int = 0;
		var k:Int = normals.length;
		var PI_DIV_2:Float = 3.141592653589793238462643 * 0.5;
		
		while (i < k) {
			ro = intNormals[i] * precision;
			phi = intNormals[i + 1];
			
			if (phi == 0) {
				normals[i]     = smooth[i]     * ro;
				normals[i + 1] = smooth[i + 1] * ro;
				normals[i + 2] = smooth[i + 2] * ro;
			}
			else {		  
				if (phi <= 4) {
					theta = (intNormals[i + 2] - 2) * PI_DIV_2;
				}
				else {
					theta = ((intNormals[i + 2] * 4 / phi) - 2) * PI_DIV_2;
				}
				
				phi *= precision * PI_DIV_2;
				sinPhi = ro * Math.sin(phi);
				
				nx = sinPhi * Math.cos(theta);
				ny = sinPhi * Math.sin(theta);
				nz = ro * Math.cos(phi);
				
				bz = smooth[i + 1];
				by = smooth[i] - smooth[i + 2];
				
				len = Math.sqrt(2 * bz * bz + by * by);
				if (len > 1e-20) {
					by /= len;
					bz /= len;
				}
				
				normals[i]     = smooth[i]     * nz + (smooth[i + 1] * bz - smooth[i + 2] * by) * ny - bz * nx;
				normals[i + 1] = smooth[i + 1] * nz - (smooth[i + 2]      + smooth[i]   ) * bz  * ny + by * nx;
				normals[i + 2] = smooth[i + 2] * nz + (smooth[i]     * by + smooth[i + 1] * bz) * ny + bz * nx;
			}
			
			i += 3;
		}
	}

	static public function restoreMap(map:Float32Array, count:Int, precision:Float) {
		var delta:Int;
		var value:Int;
		var intMap:UInt32Array = new UInt32Array(map.buffer, map.byteOffset, map.length);
		var len = map.length;
		
		for (i in 0...count) {
			delta = 0;
			
			var j:Int = i;
			while (j < len) {
				value = intMap[j];
				
				delta += (value & 1) != 0 ? -((value + 1) >> 1) : value >> 1;
				
				map[j] = delta * precision;
				
				j += count;
			}
		}
	}

	static public function calcSmoothNormals(indices:UInt32Array, vertices:Float32Array):Float32Array {
		var smooth:Float32Array = new Float32Array(vertices.length);
		var indx:Int;
		var indy:Int;
		var indz:Int;
		var nx:Float;
		var ny:Float;
		var nz:Float;
		var v1x:Float;
		var v1y:Float;
		var v1z:Float;
		var v2x:Float;
		var v2y:Float;
		var v2z:Float;
		var len:Float;
		
		var i:Int = 0;
		while (i < indices.length) {
			indx = Std.int(indices[i++] * 3);
			indy = Std.int(indices[i++] * 3);
			indz = Std.int(indices[i++] * 3);
			
			v1x = vertices[indy]     - vertices[indx];
			v2x = vertices[indz]     - vertices[indx];
			v1y = vertices[indy + 1] - vertices[indx + 1];
			v2y = vertices[indz + 1] - vertices[indx + 1];
			v1z = vertices[indy + 2] - vertices[indx + 2];
			v2z = vertices[indz + 2] - vertices[indx + 2];
			
			nx = v1y * v2z - v1z * v2y;
			ny = v1z * v2x - v1x * v2z;
			nz = v1x * v2y - v1y * v2x;
			
			len = Math.sqrt(nx * nx + ny * ny + nz * nz);
			if (len > 1e-10) {
				nx /= len;
				ny /= len;
				nz /= len;
			}
			
			smooth[indx]     += nx;
			smooth[indx + 1] += ny;
			smooth[indx + 2] += nz;
			smooth[indy]     += nx;
			smooth[indy + 1] += ny;
			smooth[indy + 2] += nz;
			smooth[indz]     += nx;
			smooth[indz + 1] += ny;
			smooth[indz + 2] += nz;
		}
		
		i = 0;
		while (i < smooth.length) {
			len = Math.sqrt(smooth[i] * smooth[i] + smooth[i + 1] * smooth[i + 1] + smooth[i + 2] * smooth[i + 2]);
			
			if (len > 1e-10) {
				smooth[i]     /= len;
				smooth[i + 1] /= len;
				smooth[i + 2] /= len;
			}
			
			i += 3;
		}
		
		return smooth;
	}

	static public function isLittleEndian():Bool {
		var buffer = new ArrayBuffer(2);
		var bytes = new UInt8Array(buffer);
		var ints = new UInt16Array(buffer);
		
		bytes[0] = 1;
		
		return ints[0] == 1;
	}	
	
}
