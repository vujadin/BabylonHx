package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Node;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Instances {

	public function new(scene:Scene) {
		var light = new DirectionalLight("dir01", new Vector3(0, -1, -0.3), scene);
		var camera = new FreeCamera("Camera", new Vector3(0, 10, -20), scene);
		camera.attachControl(this);
		camera.speed = 0.4;
		
		light.position = new Vector3(20, 60, 30);
		
		scene.ambientColor = Color3.FromInts(10, 30, 10);
		scene.clearColor = Color3.FromInts(127, 165, 13);
		scene.gravity = new Vector3(0, -0.5, 0);
		
		// Fog
		scene.fogMode = Scene.FOGMODE_EXP;
		scene.fogDensity = 0.02;
		scene.fogColor = scene.clearColor;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 150.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		// Invisible borders
		var border0 = Mesh.CreateBox("border0", 1, scene);
		border0.scaling = new Vector3(1, 100, 100);
		border0.position.x = -50.0;
		border0.checkCollisions = true;
		border0.isVisible = false;
		
		var border1 = Mesh.CreateBox("border1", 1, scene);
		border1.scaling = new Vector3(1, 100, 100);
		border1.position.x = 50.0;
		border1.checkCollisions = true;
		border1.isVisible = false;
		
		var border2 = Mesh.CreateBox("border2", 1, scene);
		border2.scaling = new Vector3(100, 100, 1);
		border2.position.z = 50.0;
		border2.checkCollisions = true;
		border2.isVisible = false;
		
		var border3 = Mesh.CreateBox("border3", 1, scene);
		border3.scaling = new Vector3(100, 100, 1);
		border3.position.z = -50.0;
		border3.checkCollisions = true;
		border3.isVisible = false;
		
		// Ground
		var ground = Mesh.CreateGroundFromHeightMap("ground", "assets/img/heightMap.png", 100, 100, 100, 0, 5, scene, false, function(ground) {
			ground.optimize(100);
			
			// Shadows
			var shadowGenerator = new ShadowGenerator(1024, light);
			
			// Trees
			SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
			SceneLoader.ImportMesh("", "assets/models/tree/", "tree.babylon", scene, function(newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
				cast(newMeshes[0].material, StandardMaterial).opacityTexture = null;
				newMeshes[0].material.backFaceCulling = false;
				newMeshes[0].isVisible = false;
				newMeshes[0].position.y = ground.getHeightAtCoordinates(0, 0); // Getting height from ground object
				
				shadowGenerator.getShadowMap().renderList.push(newMeshes[0]);
				var range = 60;
				var count = 100;
				for (index in 0...count) {
					var newInstance = cast(newMeshes[0], Mesh).createInstance("i" + index);
					//newInstance.rotate(Axis.Y, Math.random() * Math.PI * 2, Space.LOCAL);
					
					var x = range / 2 - Math.random() * range;
					var z = range / 2 - Math.random() * range;
					
					var y = ground.getHeightAtCoordinates(x, z); // Getting height from ground object
					
					newInstance.position = new Vector3(x, y, z);
										
					var scale = 0.5 + Math.random() * 2;
					newInstance.scaling.addInPlace(new Vector3(scale, scale, scale));
					
					shadowGenerator.getShadowMap().renderList.push(newInstance);
				}
				shadowGenerator.getShadowMap().refreshRate = 0; // We need to compute it just once
				shadowGenerator.usePoissonSampling = true;
				
				// Collisions
				camera.checkCollisions = true;
				camera.applyGravity = true;
			});
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/grass.jpg", scene);
		
		groundMaterial.diffuseTexture.uScale = 6;
		groundMaterial.diffuseTexture.vScale = 6;
		groundMaterial.specularColor = new Color3(0, 0, 0);
		ground.material = groundMaterial;
		ground.receiveShadows = true;
		ground.checkCollisions = true;
		
	}
	
}