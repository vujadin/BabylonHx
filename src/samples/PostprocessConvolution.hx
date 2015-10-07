package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.postprocess.ConvolutionPostProcess;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PostprocessConvolution {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		camera.attachControl(this);
		
		var light = new DirectionalLight("dir01", new Vector3(0, -1, -0.2), scene);
		var light2 = new DirectionalLight("dir02", new Vector3(-1, 2, -1), scene);
		light.position = new Vector3(0, 30, 0);
		light2.position = new Vector3(10, 20, 10);
		
		light.intensity = 0.6;
		light2.intensity = 0.6;
		
		camera.setPosition(new Vector3( -40, 40, 0));
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 500.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
			
		// Spheres
		var sphere0 = Mesh.CreateSphere("Sphere0", 16, 10, scene);
		var sphere1 = Mesh.CreateSphere("Sphere1", 16, 10, scene);
		var sphere2 = Mesh.CreateSphere("Sphere2", 16, 10, scene);
		var cube = Mesh.CreateBox("Cube", 10.0, scene);
		
		sphere0.material = new StandardMaterial("white", scene);
		cast(sphere0.material, StandardMaterial).diffuseColor = new Color3(0.5, 0.5, 1.0);
		
		sphere1.material = sphere0.material;
		sphere2.material = sphere0.material;
		
		sphere0.convertToFlatShadedMesh();
		sphere1.convertToFlatShadedMesh();
		sphere2.convertToFlatShadedMesh();
		
		cube.material = new StandardMaterial("red", scene);
		cast(cube.material, StandardMaterial).diffuseColor = new Color3(1.0, 0.5, 0.5);
		cast(cube.material, StandardMaterial).specularColor = new Color3(0, 0, 0);
		   
		// Post-process
		var postProcess = new ConvolutionPostProcess("convolution", ConvolutionPostProcess.EmbossKernel, 1.0, camera);
		
		// Animations
		var alpha = 0.0;
		scene.registerBeforeRender(function() {
			sphere0.position = new Vector3(20 * Math.sin(alpha), 0, 20 * Math.cos(alpha));
			sphere1.position = new Vector3(20 * Math.sin(alpha), -20 * Math.cos(alpha), 0);
			sphere2.position = new Vector3(0, 20 * Math.cos(alpha), 20 * Math.sin(alpha));
			
			cube.rotation.y += 0.01;
			cube.rotation.z += 0.01;
			
			alpha += 0.05;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
