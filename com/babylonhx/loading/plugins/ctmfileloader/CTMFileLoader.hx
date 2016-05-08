package com.babylonhx.loading.plugins.ctmfileloader;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.tools.Tools;

import haxe.io.Bytes;
import haxe.io.BytesInput;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMFileLoader {

	static function initOffsets(file:CTMFile, scene:Scene):Array<Mesh> {
		var indices = file.body.indices;
		var start = 0;
		var min = file.body.vertices.length;
		var max = 0;
		var minPrev = min;
		
		var offsets:Array<Dynamic> = [];
	  
		var i:Int = 0;
		while (i < indices.length) {
			for (j in 0...3) {
				var idx = indices[i++];
				
				if (idx < min) {
					min = idx;
				}
				if (idx > max) {
					max = idx;
				}
			}
			
			if (max - min > 65535) {
				i -= 3;
				var k = start;
				while (k < i) {
					indices[k] -= minPrev;
					++k;
				}
				
				offsets.push({ start: start, count: i - start, index: minPrev });
				
				start = i;
				min = file.body.vertices.length;
				max = 0;
			}
			
			minPrev = min;
		}
		
		var k = start;
		while (k < i) {
			indices[k] -= minPrev;
			++k;
		}
		
		offsets.push({ start: start, count: i - start, index: minPrev });
		
		var vertexData:VertexData = new VertexData();
			
		var vertices:Array<Float> = [];
		for (i in 0...file.body.vertices.length) {
			vertices.push(file.body.vertices[i]);
		}
		
		var normals:Array<Float> = [];
		if (file.body.normals != null) {
			
			for (i in 0...file.body.normals.length) {
				normals.push(file.body.normals[i]);
			}			 
		}
		
		var uvs:Array<Float> = [];
		if (file.body.uvMaps != null) {			
			for (i in 0...file.body.uvMaps[0].uv.length) {
				uvs.push(file.body.uvMaps[0].uv[i]);
			}			
		}
		
		if (file.header.attrMapCount > 0 && file.body.attrMaps != null) {
			var colors:Array<Float> = [];
			for (i in 0...file.body.attrMaps[0].attr.length) {
				colors.push(file.body.attrMaps[0].attr[i]);
			}
			vertexData.colors = colors;
		}
		
		var indices:Array<Int> = [];
		for (i in 0...file.body.indices.length) {
			indices.push(file.body.indices[i]);
		}
		
		var meshes:Array<Mesh> = [];
		for (i in 0...offsets.length) {				
			var indicesFinal = indices.slice(Std.int(offsets[i].start * 2), offsets[i].count);
			VertexData.ComputeNormals(vertices, indicesFinal, normals);
			
			vertexData.positions = vertices;
			vertexData.normals = normals;
			vertexData.uvs = uvs;
			vertexData.indices = indicesFinal;
			
			var mesh = new Mesh("ctm", scene);
			vertexData.applyToMesh(mesh);
			mesh.flipFaces(true);
			
			meshes.push(mesh);
		}
		
		return meshes;
	}
	
	static public function load(fileUrl:String, scene:Scene, ?onLoad:Array<Mesh>->Int->Void) {
		Tools.LoadFile(fileUrl, function(data:Bytes) {
			var file = new CTMFile(new BytesInput(data));
			file.load();
			
			var meshes = initOffsets(file, scene);
			
			if (onLoad != null) {
				onLoad(meshes, file.header.triangleCount);
			}
		}, "ctm");
	}
	
	static public function loadGeometry(fileUrl:String, ?onLoad:CTMFile->Void) {
		Tools.LoadFile(fileUrl, function(data:Bytes) {
			var file = new CTMFile(new BytesInput(data));
			file.load();
			
			if (onLoad != null) {
				onLoad(file);
			}
		}, "ctm");
	}
	
}
