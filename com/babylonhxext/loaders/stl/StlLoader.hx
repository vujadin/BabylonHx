package com.babylonhxext.loaders.stl;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tools;
import haxe.io.Bytes;
import lime.utils.ByteArray;

#if js
import js.html.DataView;
import js.html.ArrayBuffer;
import js.html.Int8Array;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on https://github.com/tonylukasavage/jsstl
class StlLoader {
	
	private var scene:Scene;
	

	public function new(scene:Scene) {
		this.scene = scene;
	}
	
	public function load(rootUrl:String, file:String, isBinary:Bool, ?onLoad:Array<Mesh>->Void) {
		Tools.LoadFile(rootUrl + file, function(data:Dynamic) {
			if(!isBinary) {
				var mesh = parseStlASCII(data);
				if (onLoad != null) {
					onLoad([mesh]);
				}
			} 
			else {
				var mesh = parseStlBinary(data);
				if (onLoad != null) {
					onLoad([mesh]);
				}
			}
		}, isBinary ? "bin" : "");
	}
	
	function parseStlBinary(stl:Dynamic):Mesh {
		var normals:Array<Float> = [];
		var positions:Array<Float> = [];
		var indices:Array<Int> = [];
		var indicesCount:Int = 0;
		
		// 80-character header (ignored)
		var headerLength = 80;
		
		/*#if js
		
		var str2ab = function(str:String):ArrayBuffer {
			var buf = new ArrayBuffer(str.length); // 2 bytes for each char
			var bufView = new Int8Array(buf);
			for (i in 0...str.length) {
				bufView[i] = str.charCodeAt(i);
			}
			return buf;
		};
		
		var dv = new DataView(str2ab(stl.toString()));// , headerLength); 
		var isLittleEndian = true;
		var triangles = dv.getUint32(headerLength, isLittleEndian);
		
		var offset:Int = headerLength + 4;
		for (i in 0...triangles) {			
			var normal = [
				dv.getFloat32(offset, isLittleEndian),
				dv.getFloat32(offset + 4, isLittleEndian),
				dv.getFloat32(offset + 8, isLittleEndian)
			];
			
			offset += 12;
						
			for (j in 0...3) {
				positions.push(dv.getFloat32(offset, isLittleEndian));
				positions.push(dv.getFloat32(offset + 4, isLittleEndian));
				positions.push(dv.getFloat32(offset + 8, isLittleEndian));
				
				normals.push(normal[0]);
				normals.push(normal[1]);
				normals.push(normal[2]);
					
				offset += 12;
			}
			
			indices.push(indicesCount++);
			indices.push(indicesCount++);
			indices.push(indicesCount++);
			
			// there's also a Uint16 "attribute byte count" that we
			// don't need, it should always be zero.
			offset += 2;   
		}
		
		#else*/
		
		var triangles = stl.getInt32(headerLength);	// get number of triangles
		
		var offset = headerLength + 4;
		for (i in 0...triangles) {
			var normal:Array<Float> = [
				stl.getFloat(offset),
				stl.getFloat(offset + 4),
				stl.getFloat(offset + 8)
			];
			
			offset += 12;
			
			for (j in 0...3) {				
				positions.push(stl.getFloat(offset));
				positions.push(stl.getFloat(offset + 4));
				positions.push(stl.getFloat(offset + 8));
				
				normals.push(normal[0]);
				normals.push(normal[1]);
				normals.push(normal[2]);
				
				offset += 12;
			}
			
			indices.push(indicesCount++);
			indices.push(indicesCount++);
			indices.push(indicesCount++);
			
			// there's also a Uint16 "attribute byte count" that we
			// don't need, it should always be zero.
			offset += 2;   
		}
		
		//#end
		
		var mesh = new Mesh(Tools.uuid(), this.scene);
		
		indices.reverse();
		mesh.setVerticesData(VertexBuffer.PositionKind, positions);
		mesh.setVerticesData(VertexBuffer.NormalKind, normals);
		mesh.setIndices(indices);
		mesh.computeWorldMatrix(true);
		
		return mesh;
	}
	
	function parseStlASCII(stl:String):Mesh {
		var mesh:Mesh = null;
		
		var state = '';
		var lines:Array<String> = stl.split('\n');
		var parts:Array<String> = [];
		
		var normal:Array<Float> = [];
		
		var normals:Array<Float> = [];
		var positions:Array<Float> = [];
		var indices:Array<Int> = [];
		var indicesCount:Int = 0;
		
		var name:String = "";
		var line:String = "";
		
		var len:Int = lines.length;
		for (i in 0...len) {			
			line = StringTools.trim(lines[i]);
			parts = line.split(' ');
			switch (state) {
				case '':
					if (parts[0] != 'solid') {
						trace("ERROR: " + line);
						trace('ERROR: Invalid state "' + parts[0] + '", should be "solid"');
						return null;
					} 
					else {
						name = parts[1];
						mesh = new Mesh(name, this.scene);
						state = 'solid';
					}
					
				case 'solid':
					if (parts[0] != 'facet' || parts[1] != 'normal') {
						trace("ERROR: " + line);
						trace('ERROR: Invalid state "' + parts[0] + '", should be "facet normal"');
						return null;
					} 
					else {
						normal = [
							Std.parseFloat(parts[2]),
							Std.parseFloat(parts[3]),
							Std.parseFloat(parts[4])
						];
						state = 'facet normal';
					}
					
				case 'facet normal':
					if (parts[0] != 'outer' || parts[1] != 'loop') {
						trace("ERROR: " + line);
						trace('ERROR: Invalid state "' + parts[0] + '", should be "outer loop"');
						return null;
					} 
					else {
						state = 'vertex';
					}
					
				case 'vertex': 
					if (parts[0] == 'vertex') {
						positions.push(Std.parseFloat(parts[1]));
						positions.push(Std.parseFloat(parts[2]));
						positions.push(Std.parseFloat(parts[3]));
						
						normals.push(normal[0]);
						normals.push(normal[1]);
						normals.push(normal[2]);
					} 
					else if (parts[0] == 'endloop') {
						indices.push(indicesCount++);
						indices.push(indicesCount++);
						indices.push(indicesCount++);
						state = 'endloop';
					} 
					else {
						trace("ERROR: " + line);
						trace('ERROR: Invalid state "' + parts[0] + '", should be "vertex" or "endloop"');
						return null;
					}
					
				case 'endloop':
					if (parts[0] != 'endfacet') {
						trace("ERROR: " + line);
						trace('ERROR: Invalid state "' + parts[0] + '", should be "endfacet"');
						return null;
					} 
					else {
						state = 'endfacet';
					}
					
				case 'endfacet':
					if (parts[0] == 'endsolid') {
						indices.reverse();
						mesh.setVerticesData(VertexBuffer.PositionKind, positions);
						mesh.setVerticesData(VertexBuffer.NormalKind, normals);
						mesh.setIndices(indices);
						mesh.computeWorldMatrix(true);
						break;
					} 
					else if (parts[0] == 'facet' && parts[1] == 'normal') {
						normal = [
							Std.parseFloat(parts[2]), 
							Std.parseFloat(parts[3]), 
							Std.parseFloat(parts[4])
						];
						state = 'facet normal';
					} 
					else {
						trace("ERROR: " + line);
						trace('ERROR: Invalid state "' + parts[0] + '", should be "endsolid" or "facet normal"');
						return null;
					}
					
				default:
					trace('ERROR: Invalid state "' + state + '"');
				
			}
		}
		
		return mesh;
	}
	
}
