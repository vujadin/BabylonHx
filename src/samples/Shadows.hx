package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.lights.SpotLight;
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
class Shadows {

	public function new(scene:Scene) {
		// Setup environment
		var camera = new ArcRotateCamera("Camera", 0, 0.8, 90, Vector3.Zero(), scene);
		camera.lowerBetaLimit = 0.1;
		camera.upperBetaLimit = (Math.PI / 2) * 0.9;
		camera.lowerRadiusLimit = 30;
		camera.upperRadiusLimit = 150;
		camera.attachControl(this, true);
		
		// light1
		var light = new DirectionalLight("dir01", new Vector3(-1, -2, -1), scene);
		light.position = new Vector3(20, 40, 20);
		light.intensity = 0.5;
		
		var lightSphere = Mesh.CreateSphere("sphere", 10, 2, scene);
		lightSphere.position = light.position;
		lightSphere.material = new StandardMaterial("light", scene);
		cast(lightSphere.material, StandardMaterial).emissiveColor = new Color3(1, 1, 0);
		
		// light2
		var light2 = new SpotLight("spot02", new Vector3(30, 40, 20), new Vector3(-1, -2, -1), 1.1, 1, scene);
		light2.intensity = 0.5;
		
		var lightSphere2 = Mesh.CreateSphere("sphere", 10, 2, scene);
		lightSphere2.position = light2.position;
		lightSphere2.material = new StandardMaterial("light", scene);
		cast(lightSphere2.material, StandardMaterial).emissiveColor = new Color3(1, 1, 0);
		
		// Ground
		var ground = Mesh.CreateGroundFromHeightMap("ground", "assets/img/heightMap.png", 100, 100, 100, 0, 10, scene, false);
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/grass.jpg", scene);
		groundMaterial.diffuseTexture.uScale = 6;
		groundMaterial.diffuseTexture.vScale = 6;
		groundMaterial.specularColor = new Color3(0, 0, 0);
		ground.position.y = -2.05;
		ground.material = groundMaterial;
		
		// Torus
		var torus = Mesh.CreateTorus("torus", 4, 2, 30, scene, false);
		
		// Shadows
		var shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.getShadowMap().renderList.push(torus);
		shadowGenerator.useVarianceShadowMap = true;
		
		var shadowGenerator2 = new ShadowGenerator(1024, light2);
		shadowGenerator2.getShadowMap().renderList.push(torus);
		shadowGenerator2.usePoissonSampling = true;
		
		ground.receiveShadows = true;
		
		// Animations
		var alpha = 0.0;
		scene.registerBeforeRender(function () {
			torus.rotation.x += 0.01;
			torus.rotation.z += 0.02;
			torus.position = new Vector3(Math.cos(alpha) * 30, 10, Math.sin(alpha) * 30);
			alpha += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
