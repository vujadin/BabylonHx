package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/*import com.babylonhx.postprocess.DreamVisionPostProcess;
import com.babylonhx.postprocess.ThermalVisionPostProcess;
import com.babylonhx.postprocess.BloomPostProcess;
import com.babylonhx.postprocess.CrossHatchingPostProcess;
import com.babylonhx.postprocess.NightVisionPostProcess;
import com.babylonhx.postprocess.CrossStitchingPostProcess;
import com.babylonhx.postprocess.VignettePostProcess;
import com.babylonhx.postprocess.KnittedPostProcess;
import com.babylonhx.postprocess.Blur2PostProcess;
import com.babylonhx.postprocess.ScreenDistortionPostProcess;
import com.babylonhx.postprocess.VibrancePostProcess;
import com.babylonhx.postprocess.HueSaturationPostProcess;
import com.babylonhx.postprocess.InkPostProcess;
import com.babylonhx.postprocess.HexagonalPixelatePostProcess;
import com.babylonhx.postprocess.NaturalColorPostProcess;
import com.babylonhx.postprocess.MosaicPostProcess;
import com.babylonhx.postprocess.BleachBypassPostProcess;
import com.babylonhx.postprocess.LimbDarkeningPostProcess;*/

/**
 * ...
 * @author Krtolica Vujadin
 */
class DisplacementMap {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 2, Vector3.Zero(), scene);
		camera.attachControl(this);
		
		var light = new HemisphericLight("Omni0", new Vector3(0, 1, 0), scene);
		
		var material = new StandardMaterial("kosh", scene);
		var sphere = Mesh.CreateSphere("Sphere", 80, 2, scene, true);
		sphere.position.z -= 2;
		
		var sphere2 = Mesh.CreateSphere("Sphere", 80, 2, scene, true);
		sphere2.position.z += 2;
		
		camera.setPosition(new Vector3(-10, 3, 0));
		
		sphere.applyDisplacementMap("assets/img/golfball.jpg", 0, 0.1);		
		sphere2.applyDisplacementMap("assets/img/golfball.jpg", 0, 0.1, null, true);	// invert displacement
		
		// Sphere material
		material.diffuseTexture = new Texture("assets/img/golfball.jpg", scene);
		sphere.material = material;
		sphere2.material = material;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 200, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/TropicalSunnyDay", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.emissiveColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.disableLighting = true;
		skybox.material = skyboxMaterial;
		//skybox.infiniteDistance = true;
		
		//var dreamPP = new DreamVisionPostProcess("dream", 1.0, camera);
		//var thermalPP = new ThermalVisionPostProcess("thermal", 1.0, camera);
		//var crossHatchPP = new CrossHatchingPostProcess("chpp", 1.0, camera);
		//crossHatchPP.vx_offset = 0.5;
		//var nightVisionPP = new NightVisionPostProcess("nv", "assets/img/transpix.png", 1.0, camera);
		//var crossStitchPP = new CrossStitchingPostProcess("cspp", 1.0, camera);
		//var vignettePP = new VignettePostProcess("vpp", 1.0, camera);
		//var knittedPP = new KnittedPostProcess("kpp", 1.0, camera);
		//var blur2PP = new Blur2PostProcess("fbpp", 1.0, camera);
		//var distortPP = new ScreenDistortionPostProcess("sdpp", 1.0, camera);
		//var vibrancePP = new VibrancePostProcess("vibrancepp", 1.0, camera);
		//var hueSatPP = new HueSaturationPostProcess("denoisepp", 1.0, camera);
		//var inkPP = new InkPostProcess("inkpp", 1.0, camera);
		//var hexPixPP = new HexagonalPixelatePostProcess("hexpixpp", 1.0, camera);
		//var naturalColorPP = new NaturalColorPostProcess("naturalColorPP", 1.0, camera);
		//var bloomPP = new BloomPostProcess("bloomPP", 1.0, camera);
		//var mosaicPP = new MosaicPostProcess("mosaicPP", 1.0, camera);
		//var bleachPP = new BleachBypassPostProcess("bleachPP", 1.0, camera);
		//bleachPP.opacity = -3.8;
		//var limbDarkPP = new LimbDarkeningPostProcess("limbDarkPP", 1.0, camera);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
