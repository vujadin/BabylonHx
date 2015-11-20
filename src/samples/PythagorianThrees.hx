package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.VertexBuffer;
//import com.babylonhx.materials.lib.terrain.TerrainMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PythagorianThrees {
	
	var colorScale:Array<Int> = [
		0xfff7f3, 0xfde0dd, 0xfcc5c0,
		0xfa9fb5, 0xf768a1, 0xdd3497
	];
	
	var meshes:Array<Mesh> = [];
	
	var scene:Scene;

	public function new(scene:Scene) {
		this.scene = scene;
		
		var camera = new ArcRotateCamera("Camera", Math.PI / 3, Math.PI / 2, 8, new Vector3(0, 1.5, 0), scene);
		camera.attachControl();
				
		var hemiLight = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		hemiLight.diffuse = Color3.FromInt(0x50505a);
		hemiLight.intensity = 0.6;
		
		var light = new SpotLight("*spot00", new Vector3(-0.2, 10, -10), new Vector3(0, -1, 1.0), 1.2, 3.1, scene);
		light.intensity = 0.7;
		light.diffuse = Color3.FromInt(0xffffdd);
		
		var ground = Mesh.CreateGround("ground1", 50, 50, 2, scene);
		ground.position.y = -0.5;
		ground.receiveShadows = true;
					
		createTreeGeometry();
		
		var m = Mesh.MergeMeshes(meshes, true, true);
		m.receiveShadows = true;
		var m2 = m.clone("clone");
		m2.position.x = 10;
		m2.rotation.y = Math.PI / 5;
		m2.scaling.set(2.3, 2.3, 2.3);
		m2.receiveShadows = true;
		
		var finalMesh = Mesh.MergeMeshes([m, m2], true, true);
		finalMesh.position.x -= 5;
		cast(finalMesh.material, StandardMaterial).diffuseColor = Color3.FromInt(0xff9f42);
		cast(finalMesh.material, StandardMaterial).checkReadyOnlyOnce = true;
		cast(finalMesh.material, StandardMaterial).checkReadyOnEveryCall = false;
		
		var shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.getShadowMap().renderList.push(finalMesh);
		shadowGenerator.usePoissonSampling = true; 
				
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
	function cubeColor(depth:Int, maxDepth:Int):Int {		
		var a = depth / (maxDepth + 1e-10);
		return colorScale[Math.floor(a * a * colorScale.length)];
	}

	function createCube(d:Int, maxDepth:Int):Mesh {
		var cube = Mesh.CreateBox("box" + d, 1, scene);
		//var cube = Mesh.CreateSphere("sphere" + depth, { segments: 10, diameterX: 1.8, diameterY: 1.8, diameterZ: 1.8 }, scene);
		var color = cubeColor(d, maxDepth);
		cube.material = new StandardMaterial("mat" + d, scene);
		cast(cube.material, StandardMaterial).diffuseColor = Color3.FromInt(color);		
		cast(cube.material, StandardMaterial).checkReadyOnlyOnce = true;
		cast(cube.material, StandardMaterial).checkReadyOnEveryCall = false;
		
		return cube;
	}

	function createTreeGeometry() {
		var maxDepth = 10;
		var angle = Math.PI / 5;
		var ls = Math.cos(angle);
		var rs = Math.sin(angle);
		var x = ls * Math.cos(angle);
		var y = rs * Math.cos(angle);
		
		var L = new Matrix()
			.multiply(Matrix.RotationY(Math.PI / 2))
			.multiply(Matrix.Translation(0, 1, 0))
			.multiply(Matrix.FromValues(ls, 0, 0, 0, 0, ls, 0, 0, 0, 0, ls, 0, 0, 0, 0, 1))
			.multiply(Matrix.RotationZ(angle))
			.multiply(Matrix.Translation(0.065, 0.41, 0));
			
		var R = new Matrix()
			.multiply(Matrix.RotationY(Math.PI / 2))
			.multiply(Matrix.Translation(x, 1 + y, 0))
			.multiply(Matrix.FromValues(rs, 0, 0, 0, 0, rs, 0, 0, 0, 0, rs, 0, 0, 0, 0, 1))
			.multiply(Matrix.RotationZ(angle - Math.PI / 2))
			.multiply(Matrix.Translation(-0.36, 0.71, 0));
			
		function recurse(matrix:Matrix, depth:Int) {
			if (depth <= maxDepth) {								
				var cube = createCube(depth, maxDepth);
				cube.setPivotMatrix(matrix);
				meshes.push(cube);
					
				recurse(matrix.clone().multiply(L), depth + 1);
				recurse(matrix.clone().multiply(R), depth + 1);
			}
		}
		
		recurse(new Matrix(), 0);
	}
	
}
