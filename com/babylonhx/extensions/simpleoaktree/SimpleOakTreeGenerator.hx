package com.babylonhx.extensions.simpleoaktree;

import com.babylonhx.Scene;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Tools as MathTools;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SimpleOakTreeGenerator {

	public static function Generate(sizeBranch:Float, sizeTrunk:Float, radius:Float, trunkMaterial:Material, leafMaterial:Material, scene:Scene):Mesh {
		var tree = new Mesh("tree", scene);
		tree.isVisible = false;
		
		var leaves = new Mesh("leaves", scene);
		
		var vertexData = VertexData.CreateSphere({ segments: 4, diameter: sizeBranch }); 
		
		vertexData.applyToMesh(leaves, false);
		
		var positions = leaves.getVerticesData(VertexBuffer.PositionKind);
		var indices = leaves.getIndices();
		var numberOfPoints = Std.int(positions.length / 3);
		
		var map:Array<Array<Dynamic>> = [];
		var max:Array<Vector3> = [];
		
		for (i in 0...numberOfPoints) {
			var p = new Vector3(positions[i * 3], positions[i * 3 + 1], positions[i * 3 + 2]);
			
			if (p.y >= sizeBranch / 2) {
				max.push(p);
			}
			
			var found = false;
			var index = 0;
			while (index < map.length && !found) {
				var array:Array<Dynamic> = map[index];
				var p0 = array[0];
				if (p0.equals(p) || (p0.subtract(p)).lengthSquared() < 0.01) {
					array.push(i * 3);
					found = true;
				}
				
				++index;
			}
			
			if (!found) {
				var array:Array<Dynamic> = [];
				array.push(p);
				array.push(i * 3);
				map.push(array);
			}
		}
		
		for (array in map) {
			var min = -sizeBranch / 20;
			var max = sizeBranch / 20;
			var rx = MathTools.RandomFloat(min, max);
			var ry = MathTools.RandomFloat(min, max);
			var rz = MathTools.RandomFloat(min, max);
			
			for (index in 1...array.length) {
				var i = array[index];
				positions[i] += rx;
				positions[i + 1] += ry;
				positions[i + 2] += rz;
			}
		}
		
		leaves.setVerticesData(VertexBuffer.PositionKind, positions);
		var normals:Array<Float> = [];
		VertexData.ComputeNormals(positions, indices, normals);
		leaves.setVerticesData(VertexBuffer.NormalKind, new Float32Array(normals));
		leaves.convertToFlatShadedMesh();		
		leaves.material = leafMaterial;
		
		var trunk = Mesh.CreateCylinder("trunk", sizeTrunk, radius - 2 < 1 ? 1 : radius - 2, radius, 10, 2, scene);
		var trunkY = trunk.getBoundingInfo().boundingBox.maximum.y;
		trunk.position.y = trunkY;
		
		var leavesY = leaves.getBoundingInfo().boundingBox.maximum.y;
		leaves.position.y = trunkY + leavesY;
		
		trunk.material = trunkMaterial;
		trunk.convertToFlatShadedMesh();
		
		leaves.parent = tree;
		trunk.parent = tree;
		
		return tree;
	}
	
}