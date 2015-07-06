package com.babylonhxext.loaders.ply;

import com.babylonhxext.loaders.ply.PlyParser.Element;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;
import com.babylonhx.tools.Tools;

import haxe.io.StringInput;

/**
 * ...
 * @author Krtolica Vujadin
 */

// based on https://gist.github.com/KeyMaster-/247fee525cf73d086dc3
class PlyLoader {
	
	var scene:Scene;

	public function new(scene:Scene) {
		this.scene = scene;
	}
	
	public function load(rootUrl:String, file:String, ?onLoad:Array<Mesh>->Void) {
		Tools.LoadFile(rootUrl + file, function(data:Dynamic) {
			var normals:Array<Float> = [];
			var positions:Array<Float> = [];
			var indices:Array<Int> = [];
			var indicesCount:Int = 0;
			
			var input = new StringInput(data);
			var parser = new PlyParser(input);
			parser.read();
			
			var vertexElement:Element = parser.elements.get("vertex");
			var faceElement:Element = parser.elements.get("face");
			if (vertexElement == null) {
				throw "The .ply file is missing a \'vertex\' element";
			}
			if (faceElement == null) {
				throw "The .ply file is missing a \'face\' element";
			}
			
			// If the vertex element has a property named 'red', 
			// assume that the vertex includes vertex color data
			var hasVertexColor:Bool = Lambda.has(vertexElement.orderedPropNames, "red");
			
			// If the vertex element has a property named 's', 
			// assume that it has the 's' and 't' properties for UV coordinates
			var hasUVs:Bool = Lambda.has(vertexElement.orderedPropNames, "s");
			
			for (vertex in parser.data.get(vertexElement)) {
				positions.push(vertex.x);
				positions.push(vertex.y);
				positions.push(vertex.z);
				
				normals.push(vertex.nx);
				normals.push(vertex.ny);
				normals.push(vertex.nz);
				/*if (hasVertexColor) {
					v.color.r = vertex.red / 255;
					v.color.g = vertex.green / 255;
					v.color.b = vertex.blue / 255;
				}*/
				/*if (hasUVs) {
					v.uv.uv0.u = vertex.s;
					v.uv.uv0.v = 1 - vertex.t;
				}*/
			}
			
			//Extract faces to lists of Ints
			for (face in parser.data.get(faceElement)) {
				for (i in 0...face.vertex_indices.data.length) {
					indices.push(Std.int(face.vertex_indices.data[i]));
				}
			}
			
			indices.reverse();
						
			var mesh = new Mesh(Tools.uuid(), scene);
			mesh.setVerticesData(VertexBuffer.PositionKind, positions);
			mesh.setVerticesData(VertexBuffer.NormalKind, normals);
			mesh.setIndices(indices);
						
			if (onLoad != null) {
				onLoad([mesh]);
			}
		});
	}
	
}
