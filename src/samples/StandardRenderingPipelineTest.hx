package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.pbr.PBRMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.postprocess.renderpipeline.pipelines.StandardRenderingPipeline;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StandardRenderingPipelineTest {

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
		
		// Create mesh
		var woodPlank = MeshBuilder.CreateBox("plane", { width: 65, height: 1, depth: 65 }, scene);
		
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
		
		// Create rendering pipeline
		var pipeline = new StandardRenderingPipeline("standard", scene, 1.0, null, [ camera.id => camera ]);
		pipeline.lensTexture = pipeline.lensFlareDirtTexture = new Texture("assets/img/lensdirt.jpg", scene);
		pipeline.lensStarTexture = new Texture("assets/img/lensstar.png", scene);
		pipeline.lensColorTexture = new Texture("assets/img/lenscolor.png", scene);
		pipeline.lensFlareDistortionStrength = 35;
		pipeline.depthOfFieldDistance = 0.002;
		pipeline.depthOfFieldBlurWidth = 32;
		pipeline.motionStrength = 0.1;
		pipeline.motionBlurSamples = 32;
		
		/*scene.getEngine().runRenderLoop(function () {
            scene.render();
        });*/
	}
	
}