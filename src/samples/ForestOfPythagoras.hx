package samples;

import com.babylonhx.Scene;
import com.babylonhx.Engine;
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
import com.babylonhx.materials.textures.procedurals.standard.GrassProceduralTexture;
import com.babylonhx.materials.textures.procedurals.standard.WoodProceduralTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ForestOfPythagoras {
	
	var meshes:Array<Mesh> = [];	
	var scene:Scene;
	

	public function new(scene:Scene) {
		this.scene = scene;
		scene.clearColor = Color3.Black();
				
		var camera = new ArcRotateCamera("Camera", 4, 1.43, 26, new Vector3(0, 1.5, 0), scene);
		camera.attachControl();
			
		var name = "wood";		
		
		var woodMaterial = new StandardMaterial(name, scene);
		var woodTexture = new WoodProceduralTexture(name + "tex", 512, scene);
		woodTexture.ampScale = 20.0;
		woodMaterial.diffuseTexture = woodTexture;
		woodMaterial.specularColor = Color3.Black();
		
		name = "grass";
		
		var grassMaterial = new StandardMaterial(name, scene);
		var grassTexture = new GrassProceduralTexture(name + "tex", 1024, scene);
		grassMaterial.ambientTexture = grassTexture;
		grassMaterial.specularColor = Color3.Black();
		
		var light:SpotLight = new SpotLight("spotlight", new Vector3(-0.2, 70, -70), new Vector3(0, -1, 1.0), 1.0, 70,  scene);
		light.intensity = 2.4;
		light.diffuse = Color3.FromInt(0xffffdd);
		
		var ground = Mesh.CreateGround("ground1", 100, 100, 2, scene);
		ground.material = grassMaterial;
		ground.position.y = -0.5;
		ground.position.z = 15;
		ground.receiveShadows = true;
		
		createTreeGeometry();
		
		var m = Mesh.MergeMeshes(meshes, true, true);
		m.material = woodMaterial;
		cast(m.material, StandardMaterial).checkReadyOnlyOnce = true;
		cast(m.material, StandardMaterial).checkReadyOnEveryCall = false;
		m.position.x = -5;
		m.receiveShadows = true;
		var m2 = m.createInstance("clone");
		m2.position.x = 5;
		m2.rotation.y = Math.PI / 5;
		m2.scaling.set(2.1, 2.1, 2.1);
		m2.receiveShadows = true;
		
		var m3 = m.createInstance("clone2");
		m3.position.x = -2;
		m3.position.z = 10;
		m3.rotation.y = Math.PI / 3;
		m3.scaling.set(1.3, 1.3, 1.3);
		m3.receiveShadows = true;
		
		var m4 = m.createInstance("clone3");
		m4.position.x = -2;
		m4.position.z = -15;
		m4.rotation.y = Math.PI / 2.5;
		m4.scaling.set(1.6, 1.6, 1.6);
		m4.receiveShadows = true;
		
		var m5 = m.createInstance("clone4");
		m5.position.x = -18;
		m5.position.z = -10;
		m5.rotation.y = Math.PI;
		m5.scaling.set(1.9, 1.9, 1.9);
		m5.receiveShadows = true;
		
		var m6 = m.createInstance("clone5");
		m6.position.x = 15;
		m6.position.z = 7;
		m6.rotation.y = Math.PI;
		m6.scaling.set(1.4, 1.4, 1.4);
		m6.receiveShadows = true;
		
		var m7 = m.createInstance("clone6");
		m7.position.x = -15;
		m7.position.z = 10;
		m7.rotation.y = Math.PI * 0.8;
		m7.scaling.set(2.8, 2.8, 2.8);
		m7.receiveShadows = true;
				
		var shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.getShadowMap().renderList.push(m);
		shadowGenerator.getShadowMap().renderList.push(m2);
		shadowGenerator.getShadowMap().renderList.push(m3);
		shadowGenerator.getShadowMap().renderList.push(m4);
		shadowGenerator.getShadowMap().renderList.push(m5);
		shadowGenerator.getShadowMap().renderList.push(m6);
		shadowGenerator.getShadowMap().renderList.push(m7);
		shadowGenerator.getShadowMap().refreshRate = 0;
		shadowGenerator.blurScale = 1;
		shadowGenerator.setDarkness(0.3);
		shadowGenerator.useBlurVarianceShadowMap = true;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
	function createCube(d:Int, maxDepth:Int):Mesh {
		return Mesh.CreateBox("box" + d, 1, scene);
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
