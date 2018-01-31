package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.layer.HighlightLayer;
import com.babylonhx.materials.pbr.PBRMaterial;
import com.babylonhx.loading.obj.ObjLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMetalicWorkflow {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -Math.PI / 4, Math.PI / 2.5, 280, Vector3.Zero(), scene);
		camera.attachControl();
		camera.minZ = 0.1;
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);		
		light.intensity = 0.7;
		
		var hdrTexture = new HDRCubeTexture("assets/img/lake.hdr", scene, 256);
		
		var exposure = 0.6;
		var contrast = 1.6;
		
		var hdrSkybox = Mesh.CreateBox("hdrSkyBox", 1000.0, scene);
		var hdrSkyboxMaterial = new PBRMaterial("skyBox", scene);
		hdrSkyboxMaterial.backFaceCulling = false;
		hdrSkyboxMaterial.reflectionTexture = hdrTexture.clone();
		hdrSkyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		hdrSkyboxMaterial.microSurface = 1.0;
		hdrSkyboxMaterial.cameraExposure = exposure;
		hdrSkyboxMaterial.cameraContrast = contrast;
		hdrSkyboxMaterial.disableLighting = true;
		hdrSkybox.material = hdrSkyboxMaterial;
		hdrSkybox.infiniteDistance = true;
		
		var objLoader = new ObjLoader(scene);
		objLoader.load("assets/models/", "low.obj", function(meshes:Array<Mesh>) {
			var material = new PBRMaterial("test", scene);
			
			material.reflectionTexture = hdrTexture;
			material.albedoTexture = new Texture("assets/img/albedo.jpg", scene);
			material.ambientTexture = new Texture("assets/img/ambient.jpg", scene);
			material.emissiveTexture = new Texture("assets/img/emissive.jpg", scene);
			material.emissiveColor = Color3.White();
			material.bumpTexture = new Texture("assets/img/normal.jpg", scene, true);
			material.invertNormalMapX = true;
			
			material.metallicTexture = new Texture("assets/img/metallicmerge.jpg", scene);
			material.useRoughnessFromMetallicTextureAlpha = false;
			material.useRoughnessFromMetallicTextureGreen = true;
			
			meshes[0].material = material;
			meshes[0].position.y -= 80;
			
			var hl = new HighlightLayer("hl", scene, { alphaBlendingMode: 6 });
			hl.addMesh(meshes[0], Color3.White(), true);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
