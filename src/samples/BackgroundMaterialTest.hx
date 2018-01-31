package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.BackgroundMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BackgroundMaterialTest {

	public function new(scene:Scene) {
		// This creates and positions a free camera (non-mesh)
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		
		// This targets the camera to scene origin
		camera.setTarget(Vector3.Zero());
		
		// This attaches the camera to the canvas
		camera.attachControl();
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new DirectionalLight("light1", new Vector3(-1, -3, 1), scene);
		light.position = new Vector3(3, 9, 3);
		
		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;
		
		// Our built-in 'sphere' shape. Params: name, subdivs, size, scene
		var sphere = Mesh.CreateSphere("sphere1", 16, 2, scene);
		
		// Add Shadows
		var generator = new ShadowGenerator(512, light);
		generator.addShadowCaster(sphere);
		
		// Move the sphere upward 1/2 its height
		sphere.position.y = 1;
		
		// Our built-in 'ground' shape. Params: name, width, depth, subdivs, scene
		var ground = Mesh.CreateGround("ground1", 6, 6, 2, scene);
		ground.receiveShadows = true;
		
		// Create and tweak the background material.
		var backgroundMaterial = new BackgroundMaterial("backgroundMaterial", scene);
		backgroundMaterial.diffuseTexture = new Texture("assets/img/paper4.jpg", scene);
		backgroundMaterial.diffuseTexture.uScale = 5.0;//Repeat 5 times on the Vertical Axes
		backgroundMaterial.diffuseTexture.vScale = 5.0;//Repeat 5 times on the Horizontal Axes
		backgroundMaterial.shadowLevel = 0.4;
		ground.material = backgroundMaterial;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}