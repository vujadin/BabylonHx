package com.babylonhx.loading.obj;

import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.Scene;

import lime.utils.Float32Array;
import lime.utils.Int32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PreMesh {
		
	var vertices:Array<PositionNormalTextured> = [];
	var indices:Array<Int> = [];
	var material:StandardMaterial = null;
	var concatenatedName:String = "";
	

	public function new(material:StandardMaterial) {
		this.material = material;
	}
	
	public function addPart(name:String, addedVertices:Array<PositionNormalTextured>, addedIndices:Array<Int>) {
		if (concatenatedName == "") {
			concatenatedName += "#"; 
		}
		
		concatenatedName += name;
		
		var offset:Int = vertices.length;
		vertices = vertices.concat(addedVertices);
		
		for (index in addedIndices) {
			indices.push(index + offset);
		}
	}

	public function createMesh(scene:Scene, parentID:String = null):Mesh {
		var babylonMesh:Mesh = new Mesh(concatenatedName, scene);
		
		var vertexData:VertexData = new VertexData();
		
		babylonMesh.material = material;
		
		// Vertices
		var positions:Array<Float> = [];
		var normals:Array<Float> = [];
		var uvs:Array<Float> = [];
		
		for (index in 0...vertices.length) {
			vertices[index].DumpPositions(positions);
			vertices[index].DumpNormals(normals);
			vertices[index].DumpUVs(uvs);
		}
		
		if (positions.length > 0) {
			vertexData.positions = new Float32Array(positions);
		}
		if (normals.length > 0) {
			/*for (i in 0...normals.length) {
				normals[i] *= -1;
			}*/
			vertexData.normals = new Float32Array(normals);
		}
		if (uvs.length > 0) {
			vertexData.uvs = new Float32Array(uvs);
		}
		
		indices.reverse();
		vertexData.indices = new Int32Array(indices);
		
		vertexData.applyToMesh(babylonMesh);
		
		return babylonMesh;
	}
	
}
