package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.pbr.PBRMaterial;
import com.babylonhx.probes.ReflectionProbe;
import com.babylonhx.layer.HighlightLayer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialTest2 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -Math.PI / 4, Math.PI / 2.5, 200, Vector3.Zero(), scene);
		camera.attachControl();
		camera.minZ = 0.1;
		
		// Light
		new PointLight("point", new Vector3(0, 40, 0), scene);
		
		// Environment Texture
		var hdrTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		
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
		var sphereGlass = Mesh.CreateSphere("sphereGlass", 48, 30.0, scene);
		sphereGlass.translate(new Vector3(1, 0, 0), -60);
		
		var sphereMetal = Mesh.CreateSphere("sphereMetal", 48, 30.0, scene);
		sphereMetal.translate(new Vector3(1, 0, 0), 60);
		
		var spherePlastic = Mesh.CreateSphere("spherePlastic", 48, 30.0, scene);
		spherePlastic.translate(new Vector3(0, 0, 1), -60);
		
		var woodPlank = MeshBuilder.CreateBox("plane", { width: 65, height: 1, depth: 65 }, scene);
		
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
		glass.reflectivityColor = new Color3(0.2, 0.2, 0.2);
		glass.albedoColor = new Color3(0.95, 0.95, 0.95);
		sphereGlass.material = glass;
		
		var metal = new PBRMaterial("metal", scene);
		metal.reflectionTexture = hdrTexture;
		metal.directIntensity = 0.3;
		metal.environmentIntensity = 0.7;
		metal.cameraExposure = 0.55;
		metal.cameraContrast = 1.6;
		metal.microSurface = 0.96;
		metal.reflectivityColor = new Color3(0.9, 0.9, 0.9);
		metal.albedoColor = new Color3(1, 1, 1);
		sphereMetal.material = metal;
		
		var plastic = new PBRMaterial("plastic", scene);
		plastic.reflectionTexture = hdrTexture;
		plastic.directIntensity = 0.6;
		plastic.environmentIntensity = 0.7;
		plastic.cameraExposure = 0.6;
		plastic.cameraContrast = 1.6;
		plastic.microSurface = 0.96;
		plastic.albedoColor = new Color3(0.206, 0.94, 1);
		plastic.reflectivityColor = new Color3(0.05, 0.05, 0.05);
		spherePlastic.material = plastic;
		
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
		
		var hl = new HighlightLayer("hl", scene);
		hl.addMesh(sphereMetal, Color3.White());
		var hl2 = new HighlightLayer("hl", scene);
		hl2.addMesh(spherePlastic, Color3.Green());
		var hl3 = new HighlightLayer("hl", scene);
		hl3.addMesh(sphereGlass, Color3.Red());
		
		var alpha = 0.0;
		scene.registerBeforeRender(function(_, _) {
			hl.blurHorizontalSize = 0.4 + Math.cos(alpha);
			hl.blurVerticalSize = 0.4 + Math.cos(alpha);
			
			alpha += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
