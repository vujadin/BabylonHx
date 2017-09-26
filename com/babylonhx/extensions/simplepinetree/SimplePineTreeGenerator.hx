package com.babylonhx.extensions.simplepinetree;

import com.babylonhx.Scene;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Tools as MathTools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SimplePineTreeGenerator {

	public static function Generate(scene:Scene, trunkMaterial:Material, leafMaterial:Material, canopies:Int = 7, baseRadius:Float = 1.8, height:Float = 75, tessellation:Int = 6, twist:Float = 0.6):Mesh {
		if (twist < 0.0 || twist > 1.0) {
			twist = 0.0;
		}
		var curvePoints = function(l:Float, t:Float):Array<Vector3> {
			var path:Array<Vector3> = [];
			var step = l / t;
			var i = 0.0;
			while (i < l) {
				if (i == 0) {
					path.push(new Vector3(0, i, 0));
					path.push(new Vector3(0, i, 0));
				}
				else {
					path.push(new Vector3(MathTools.RandomFloat(-twist, twist), i, MathTools.RandomFloat(-twist, twist)));
					path.push(new Vector3(MathTools.RandomFloat(-twist, twist), i, MathTools.RandomFloat(-twist, twist)));
				}
				i += step;
			}
			
			return path;
		};
		
		var nbL:Int = canopies + 1;
		var curve:Array<Vector3> = curvePoints(height, nbL);
	  
		var radiusFunction = function(i:Int, _) {
			var fact = baseRadius;
			if (i % 2 == 0) { 
				fact = fact / 3; 
			}
			var radius =  (nbL * 2 - i - 1) * fact;
			return radius;
		};  
	  
		var leaves = Mesh.CreateTube("leaves", curve, 0, 6, radiusFunction, 1, scene);
		leaves.convertToFlatShadedMesh();
		
		var trunk = Mesh.CreateCylinder("trunk", height / nbL, nbL * 1.5 - nbL / 2 - 1, nbL * 1.5 - nbL / 2 - 1, 12, 1, scene);
		trunk.convertToFlatShadedMesh();
	  
		leaves.material = leafMaterial;
		trunk.material = trunkMaterial;
		
		var tree = Mesh.CreateBox('', 1, scene);
		tree.isVisible = false;
		
		leaves.parent = tree;
		trunk.parent = tree;
		
		return tree; 
	}
	
}
