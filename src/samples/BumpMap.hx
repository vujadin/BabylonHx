package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.EventState;
import com.babylonhx.mesh.InstancedMesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BumpMap {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 25, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light3 = new DirectionalLight("Dir0", new Vector3(1, -1, 0), scene);
		var light0 = new PointLight("Omni0", new Vector3(0, 10, 0), scene);
		var light1 = new PointLight("Omni1", new Vector3(0, -10, 0), scene);
		var light2 = new PointLight("Omni2", new Vector3(10, 0, 0), scene);
		
		var lightSphere0 = Mesh.CreateSphere("Sphere0", 16, 0.5, scene);
		var lightSphere1 = Mesh.CreateSphere("Sphere1", 16, 0.5, scene);
		var lightSphere2 = Mesh.CreateSphere("Sphere2", 16, 0.5, scene);
		
		lightSphere0.material = new StandardMaterial("red", scene);
		cast(lightSphere0.material, StandardMaterial).diffuseColor = new Color3(0, 0, 0);
		cast(lightSphere0.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
		cast(lightSphere0.material, StandardMaterial).emissiveColor = new Color3(1, 0, 0);
		
		lightSphere1.material = new StandardMaterial("green", scene);
		cast(lightSphere1.material, StandardMaterial).diffuseColor = new Color3(0, 0, 0);
		cast(lightSphere1.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
		cast(lightSphere1.material, StandardMaterial).emissiveColor = new Color3(0, 1, 0);
		
		lightSphere2.material = new StandardMaterial("blue", scene);
		cast(lightSphere2.material, StandardMaterial).diffuseColor = new Color3(0, 0, 0);
		cast(lightSphere2.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
		cast(lightSphere2.material, StandardMaterial).emissiveColor = new Color3(0, 0, 1);
		
		// Lights colors
		light0.diffuse = new Color3(1, 0, 0);
		light0.specular = new Color3(1, 0, 0);
		
		light1.diffuse = new Color3(0, 1, 0);
		light1.specular = new Color3(0, 1, 0);
		
		light2.diffuse = new Color3(0, 0, 1);
		light2.specular = new Color3(0, 0, 1);
		
		light3.diffuse = new Color3(1, 1, 1);
		light3.specular = new Color3(1, 1, 1);
		
		//new Layer("background", "assets/img/graygrad.jpg", scene, true);
		
		var material = new StandardMaterial("mat", scene);
		material.diffuseTexture = new Texture("assets/img/DiffuseMap.jpg", scene);
		material.diffuseTexture.uScale = material.diffuseTexture.vScale = 3;
		material.bumpTexture = new Texture("assets/img/normalMap.jpg", scene);
		material.bumpTexture.uScale = material.bumpTexture.vScale = 3;
		
		var box = Mesh.CreateBox("box", 4.0, scene);
		box.material = material;
		
		var alpha = 0.0;
		scene.beforeRender = function (_, _) {
			light0.position.set(10 * Math.sin(alpha), 10 * Math.cos(alpha), 0);
			light1.position.set(10 * Math.sin(alpha), 0, -10 * Math.cos(alpha));
			light2.position.set(10 * Math.cos(alpha), 0, 10 * Math.sin(alpha));
			
			lightSphere0.position = light0.position;
			lightSphere1.position = light1.position;
			lightSphere2.position = light2.position;
			
			alpha += 0.01;
		};
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
