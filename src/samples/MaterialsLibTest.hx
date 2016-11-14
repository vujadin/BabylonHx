package samples;

import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.lib.fire.FireMaterial;
import com.babylonhx.materials.lib.water.WaterMaterial;
import com.babylonhx.materials.lib.simple.SimpleMaterial;
import com.babylonhx.materials.lib.pbr.PBRMaterial;
import com.babylonhx.materials.lib.lava.LavaMaterial;
import com.babylonhx.materials.lib.normal.NormalMaterial;
import com.babylonhx.materials.lib.terrain.TerrainMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.Scene;
import com.babylonhx.math.Vector3; 
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color3;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;


/**
 * ...
 * @author Krtolica Vujadin
 */
class MaterialsLibTest {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", Math.PI / 2, Math.PI / 6, 50, Vector3.Zero(), scene);
		camera.attachControl();
		// Lights
		var hemisphericLight = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		var pointLight = new PointLight("point", new Vector3(20, 20, 10), scene);
		pointLight.setEnabled(false);
		var directionalLight = new DirectionalLight("directional", new Vector3(0,-1, 0), scene);
		directionalLight.setEnabled(false);
		var spotLight = new SpotLight("spot", new Vector3(0, -30, 0), new Vector3(0, 1, 0), 1.1, 1, scene);
		spotLight.setEnabled(false);
		// Create meshes
		var sphere = Mesh.CreateSphere("sphere", 32, 30, scene);
		sphere.position.x = 25;
		
		var plane = MeshBuilder.CreateBox("plane", { width: 30, height: 1, depth:30 }, scene);
		//plane.setEnabled(false);
		
		var ground = Mesh.CreateGround("ground", 512, 512, 32, scene);
		ground.scaling = new Vector3(0.1, 0.1, 0.1);
		ground.position.y = -25;
		//ground.setEnabled(false);
		
		var knot = Mesh.CreateTorusKnot("knot", 10, 2, 128, 64, 4, 6, scene);
		//knot.setEnabled(false);
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
		//skybox.setEnabled(false);
		var currentMesh = sphere;
		// Rabbit
		var rabbit:Mesh;
		SceneLoader.ImportMesh("Rabbit", "assets/models/Rabbit/", "Rabbit.babylon", scene, function (newMeshes, particleSystems, skeletons) {
			rabbit = cast newMeshes[1];
			//rabbit.setEnabled(false);
			rabbit.scaling = new Vector3(0.3, 0.3, 0.3);
			scene.beginAnimation(skeletons[0], 0, 100, true, 0.8);
			// Shadow caster
			var shadowCaster = Mesh.CreateTorus("torus",  4, 2, 30, scene);
			//shadowCaster.setEnabled(false);
			shadowCaster.position = new Vector3(0, 30, 0);
			
			var shadowCaster2 = Mesh.CreateTorus("torus", 4, 2, 30, scene);
			//shadowCaster2.setEnabled(false);
			shadowCaster2.position = new Vector3(0, -30, 0);
			
			var shadowCaster3 = Mesh.CreateTorus("torus", 4, 2, 30, scene);
			//shadowCaster3.setEnabled(false);
			shadowCaster3.position = new Vector3(20, 20, 10);
			var shadowGenerator = new ShadowGenerator(1024, directionalLight);
			shadowGenerator.getShadowMap().renderList.push(shadowCaster);
			shadowGenerator.usePoissonSampling = true;
			
			var shadowGenerator2 = new ShadowGenerator(1024, spotLight);
			shadowGenerator2.getShadowMap().renderList.push(shadowCaster2);
			shadowGenerator2.usePoissonSampling = true;
			
			var shadowGenerator3 = new ShadowGenerator(1024, pointLight);
			shadowGenerator3.getShadowMap().renderList.push(shadowCaster3);
			shadowGenerator3.usePoissonSampling = true;
			// Register a render loop to repeatedly render the scene
			scene.registerBeforeRender(function () {
				shadowCaster.rotation.x += 0.01;
				shadowCaster.rotation.y += 0.01;
				shadowCaster2.rotation.x += 0.01;
				shadowCaster2.rotation.y += 0.01;
				shadowCaster3.rotation.x += 0.01;
				shadowCaster3.rotation.y += 0.01;
			});
			
			// Fog
			scene.fogMode = Scene.FOGMODE_NONE;
			scene.fogDensity = 0.01;
			
			// Create shaders
			var std = new StandardMaterial("std", scene);
			std.diffuseTexture = new Texture("assets/img/amiga.jpg", scene);
			untyped std.diffuseTexture.uScale = 5;
			untyped std.diffuseTexture.vScale = 5;
			// Lava
			var lava = new LavaMaterial("lava", scene);
			lava.diffuseTexture = new Texture("assets/img/lava/lavatile.jpg", scene);
			untyped lava.diffuseTexture.uScale = 0.5;
			untyped lava.diffuseTexture.vScale = 0.5;
			lava.noiseTexture = new Texture("assets/img/lava/cloud.png", scene);
			lava.fogColor = Color3.Black();
			lava.speed = 2.5;
			var simple = new SimpleMaterial("simple", scene);
			simple.diffuseTexture = new Texture("assets/img/amiga.jpg", scene);
			untyped simple.diffuseTexture.uScale = 5;
			untyped simple.diffuseTexture.vScale = 5;
			var normal = new NormalMaterial("normal", scene);
						
			var water = new WaterMaterial("water", scene);
			water.backFaceCulling = false;
			water.enableRenderTargets(false);
			water.bumpTexture = new Texture("assets/img/waterbump.png", scene);
			water.windForce = -45;
			water.waveHeight = 1.3;
			water.windDirection = new Vector2(1, 1);
			water.addToRenderList(skybox);
			water.addToRenderList(shadowCaster);
			water.addToRenderList(shadowCaster2);
			water.addToRenderList(shadowCaster3);
			
			var fire = new FireMaterial("fire", scene);
			fire.diffuseTexture = new Texture("assets/img/fire/diffuse.png", scene);
			fire.distortionTexture = new Texture("assets/img/fire/distortion.png", scene);
			fire.opacityTexture = new Texture("assets/img/fire/opacity.png", scene);
			
			var terrain = new TerrainMaterial("terrain", scene);
			terrain.specularColor = new Color3(0.5, 0.5, 0.5);
			terrain.specularPower = 64;
			terrain.mixTexture = new Texture("assets/img/mixMap.png", scene);
			terrain.diffuseTexture1 = new Texture("assets/img/grass.png", scene);
			terrain.diffuseTexture2 = new Texture("assets/img/rock.png", scene);
			terrain.diffuseTexture3 = new Texture("assets/img/floor.png", scene);
			
			terrain.bumpTexture1 = new Texture("assets/img/grassn.png", scene);
			terrain.bumpTexture2 = new Texture("assets/img/rockn.png", scene);
			terrain.bumpTexture3 = new Texture("assets/img/floor_bump.png", scene);
			
			terrain.diffuseTexture1.uScale = terrain.diffuseTexture1.vScale = 10;
			terrain.diffuseTexture2.uScale = terrain.diffuseTexture2.vScale = 10;
			terrain.diffuseTexture3.uScale = terrain.diffuseTexture3.vScale = 10;
			
			ground.material = terrain;
			
			var pbr = preparePBR(scene);
			
			sphere.material = pbr;
							
			// Default to std
			var currentMaterial = std;
							
			sphere.receiveShadows = true;
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
	function preparePBR(scene:Scene) {
		var pbr = new PBRMaterial("pbr", scene);
		pbr.diffuseTexture = new Texture("assets/img/amiga.jpg", scene);
		untyped pbr.diffuseTexture.uScale = 5;
		untyped pbr.diffuseTexture.vScale = 5;
		pbr.specularColor = Color3.Gray();
		untyped pbr.specularPower = 0.8;
		
		pbr.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
			
		return pbr;
	}
	
}
