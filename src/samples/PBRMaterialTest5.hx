package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.lib.pbr.PBRMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialTest5 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -Math.PI / 4, Math.PI / 2.5, 200, Vector3.Zero(), scene);
		camera.attachControl();
		camera.minZ = 0.1;

		// Light
		new PointLight("point", new Vector3(0, 40, 0), scene);

		// Environment Texture
		var hdrTexture = new HDRCubeTexture("assets/img/room.hdr", scene, 512);

		// Skybox
		var hdrSkybox = Mesh.CreateBox("hdrSkyBox", 1000.0, scene);
		var hdrSkyboxMaterial = new PBRMaterial("skyBox", scene);
		hdrSkyboxMaterial.backFaceCulling = false;
		hdrSkyboxMaterial.reflectionTexture = hdrTexture.clone();
		hdrSkyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		hdrSkyboxMaterial.microSurface = 1.0;
		hdrSkyboxMaterial.cameraExposure = 0.6;
		hdrSkyboxMaterial.cameraContrast = 1.6;
		hdrSkyboxMaterial.disableLighting = true;
		hdrSkybox.material = hdrSkyboxMaterial;
		hdrSkybox.infiniteDistance = true;

		// Create meshes
		var sphereGlass = Mesh.CreateSphere("sphere", 48, 30.0, scene);
		sphereGlass.translate(new Vector3(1, 0, 0), -50);

		var sphereMetal = Mesh.CreateSphere("sphere", 48, 30.0, scene);
		sphereMetal.translate(new Vector3(1, 0, 0), 50);
		
		var sphereGold = Mesh.CreateSphere("sphere", 48, 30.0, scene);
		sphereGold.translate(new Vector3(1, 0, 0), 100);
		
		 var spherePearl = Mesh.CreateSphere("sphere", 48, 30.0, scene);
		spherePearl.translate(new Vector3(1, 0, 0), -100);

		var woodPlank = MeshBuilder.CreateBox("plane", { width: 45, height: 1, depth: 90 }, scene);

		// Create materials
		var glass = new PBRMaterial("glass", scene);
		glass.reflectionTexture = hdrTexture;
		glass.refractionTexture = hdrTexture;
		glass.linkRefractionWithTransparency = true;
		glass.indexOfRefraction = 0.52;
		glass.alpha = 0;
		glass.directIntensity = 0.0;
		glass.environmentIntensity = 0.5;
		glass.cameraExposure = 0.5;
		glass.cameraContrast = 1.7;
		glass.microSurface = 1;
		glass.reflectivityColor = new Color3(0.1, 0.1, 0.1);
		glass.albedoColor = new Color3(0.3, 0.3, 0.3);
		sphereGlass.material = glass;
		
			var pearl = new PBRMaterial("pearl", scene);
		pearl.reflectionTexture = hdrTexture;
		pearl.refractionTexture = hdrTexture;
		pearl.linkRefractionWithTransparency = true;
		pearl.indexOfRefraction = 0.12;
		pearl.alpha = 0.5;
		pearl.directIntensity = 1.0;
		pearl.environmentIntensity = 0.2;
		pearl.cameraExposure = 2.5;
		pearl.cameraContrast = 1.7;
		pearl.microSurface = 0.8;
		pearl.reflectivityColor = new Color3(0, 0.4, 0.1);
		pearl.albedoColor = new Color3(1.0, 1.0,1.0);
		spherePearl.material = pearl;

		var gold = new PBRMaterial("gold", scene);
		gold.reflectionTexture = hdrTexture;
		gold.directIntensity = 0.3;
		gold.environmentIntensity = 0.7;
		gold.cameraExposure = 0.6;
		gold.cameraContrast = 1.6;
		gold.microSurface = 0.96;
		gold.reflectivityColor = new Color3(1.0, 0.8, 0);
		gold.albedoColor = new Color3(1.0, 0.8, 0);
		sphereGold.material = gold;

		var metal = new PBRMaterial("metal", scene);
		metal.reflectionTexture = hdrTexture;
		metal.directIntensity = 0.3;
		metal.environmentIntensity = 0.7;
		metal.cameraExposure = 0.6;
		metal.cameraContrast = 1.6;
		metal.microSurface = 0.96;
		metal.reflectivityColor = new Color3(0.9, 0.9, 0.9);
		metal.albedoColor = new Color3(1.0, 1.0, 1.0);
		sphereMetal.material = metal;

		var wood = new PBRMaterial("wood", scene);
		wood.reflectionTexture = hdrTexture;
		wood.directIntensity = 1.5;
		wood.environmentIntensity = 0.5;
		wood.specularIntensity = 0.3;
		wood.cameraExposure = 0.9;
		wood.cameraContrast = 1.6;

		wood.reflectivityTexture = new Texture("assets/img/reflectivity.png", scene);
		wood.useMicroSurfaceFromReflectivityMapAlpha = true;

		wood.albedoColor = Color3.White();
		wood.albedoTexture = new Texture("assets/img/albedo.png", scene);
		woodPlank.material = wood;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
