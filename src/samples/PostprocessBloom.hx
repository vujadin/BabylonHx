package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.postprocess.BlurPostProcess;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PostprocessBloom {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		camera.attachControl(this);
		var light = new DirectionalLight("dir01", new Vector3(0, -1, -0.2), scene);
		var light2 = new DirectionalLight("dir02", new Vector3(-1, -2, -1), scene);
		light.position = new Vector3(0, 30, 0);
		light2.position = new Vector3(10, 20, 10);

		light.intensity = 0.6;
		light2.intensity = 0.6;

		camera.setPosition(new Vector3(-40, 40, 0));
		camera.lowerBetaLimit = (Math.PI / 2) * 0.9;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		
		// Spheres
		var sphere0 = Mesh.CreateSphere("Sphere0", 16, 10, scene);
		var sphere1 = Mesh.CreateSphere("Sphere1", 16, 10, scene);
		var sphere2 = Mesh.CreateSphere("Sphere2", 16, 10, scene);
		var cube = Mesh.CreateBox("Cube", 10.0, scene);

		sphere0.material = new StandardMaterial("white", scene);
		cast(sphere0.material, StandardMaterial).diffuseColor = new Color3(0, 0, 0);
		cast(sphere0.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
		cast(sphere0.material, StandardMaterial).emissiveColor = new Color3(1.0, 1.0, 1.0);
		
		sphere1.material = sphere0.material;
		sphere2.material = sphere0.material;
		
		cube.material = new StandardMaterial("red", scene);
		cast(cube.material, StandardMaterial).diffuseColor = new Color3(0, 0, 0);
		cast(cube.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
		cast(cube.material, StandardMaterial).emissiveColor = new Color3(1.0, 0, 0);
		   
		// Post-process
		var blurWidth = 1.0;
		
		var postProcess0 = new PassPostProcess("Scene copy", 1.0, camera);
		var postProcess1 = new PostProcess("Down sample", "downsample", ["screenSize", "highlightThreshold"], null, 0.25, camera, Texture.BILINEAR_SAMPLINGMODE);
		postProcess1.onApply = function (effect) {
			effect.setFloat2("screenSize", postProcess1.width, postProcess1.height);
			effect.setFloat("highlightThreshold", 0.90);
		};
		var postProcess2 = new BlurPostProcess("Horizontal blur", new Vector2(1.0, 0), blurWidth, 0.25, camera);
		var postProcess3 = new BlurPostProcess("Vertical blur", new Vector2(0, 1.0), blurWidth, 0.25, camera);
		var postProcess4 = new PostProcess("Final compose", "compose", ["sceneIntensity", "glowIntensity", "highlightIntensity"], ["sceneSampler"], 1, camera);
		postProcess4.onApply = function (effect) {
			effect.setTextureFromPostProcess("sceneSampler", postProcess0);
			effect.setFloat("sceneIntensity", 0.5);
			effect.setFloat("glowIntensity", 0.4);
			effect.setFloat("highlightIntensity", 1.0);
		};
		
		// Animations
		var alpha = 0.0;
		scene.registerBeforeRender(function() {
			sphere0.position = new Vector3(20 * Math.sin(alpha), 0, 20 * Math.cos(alpha));
			sphere1.position = new Vector3(20 * Math.sin(alpha), 0, -20 * Math.cos(alpha));
			sphere2.position = new Vector3(20 * Math.cos(alpha), 0, 20 * Math.sin(alpha));

			cube.rotation.y += 0.01;
			cube.rotation.z += 0.01;

			alpha += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
