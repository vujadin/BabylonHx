package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Bones {

	public function new(scene:Scene) {
		var light = new DirectionalLight("dir01", new Vector3(0, -0.5, -1.0), scene);
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 30, 0), scene);
		camera.setPosition(new Vector3(20, 70, 120));
		camera.attachControl(this);
		light.position = new Vector3(20, 150, 70);
		camera.minZ = 10.0;

		//scene.ambientColor = new Color3(0.3, 0.3, 0.3);

		// Ground
		var ground = Mesh.CreateGround("ground", 1000, 1000, 1, scene, false);
		var groundMaterial = new StandardMaterial("ground", scene);
		var texDiff = new Texture("img/ground/diffuse.png", scene);
		var texSpec = new Texture("img/ground/specular.png", scene);
		var texNorm = new Texture("img/ground/normal.png", scene);
		texDiff.uScale = texDiff.vScale = 15;
		texSpec.uScale = texSpec.vScale = 15;
		texNorm.uScale = texNorm.vScale = 15;
		groundMaterial.diffuseTexture = texDiff;
		groundMaterial.specularTexture = texSpec;
		groundMaterial.bumpTexture = texNorm;
		groundMaterial.diffuseColor = new Color3(0.8, 0.8, 0.8);
		groundMaterial.specularColor = new Color3(0.9, 0.8, 0.7);
		ground.material = groundMaterial;
		ground.receiveShadows = true;

		// Shadows
		var shadowGenerator = new ShadowGenerator(256, light);
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);

		// Meshes
		SceneLoader.ImportMesh("Rabbit", "scenes/Rabbit/", "Rabbit.babylon", scene, function(newMeshes, particleSystems, skeletons) {
			var rabbit = newMeshes[1];
			
			rabbit.scaling = new Vector3(0.4, 0.4, 0.4);
			shadowGenerator.getShadowMap().renderList.push(rabbit);

			/*var rabbit2 = rabbit.clone("rabbit2");
			var rabbit3 = rabbit.clone("rabbit2");

			shadowGenerator.getShadowMap().renderList.push(rabbit2);
			shadowGenerator.getShadowMap().renderList.push(rabbit3);

			rabbit2.position = new Vector3(-50, 0, -20);
			rabbit2.skeleton = rabbit.skeleton.clone("clonedSkeleton");

			rabbit3.position = new Vector3(50, 0, -20);
			rabbit3.skeleton = rabbit.skeleton.clone("clonedSkeleton2");*/

			scene.beginAnimation(skeletons[0], 0, 100, true, 0.8);
			/*scene.beginAnimation(rabbit2.skeleton, 73, 100, true, 0.8);
			scene.beginAnimation(rabbit3.skeleton, 0, 72, true, 0.8);*/
			
			// Dude
			SceneLoader.ImportMesh("him", "scenes/Dude/", "Dude.babylon", scene, function (newMeshes2, particleSystems2, skeletons2) {
				var dude = newMeshes2[0];
				
				for (index in 0...newMeshes2.length) {
					shadowGenerator.getShadowMap().renderList.push(newMeshes2[index]);
				}
				
				dude.rotation.y = Math.PI;
				dude.position = new Vector3(0, 0, -80);
					
				scene.beginAnimation(skeletons2[0], 0, 100, true, 1.0);
				
				scene.getEngine().runRenderLoop(function () {
					scene.render();
				});
			});
		});
	}
	
}
