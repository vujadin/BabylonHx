package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.TouchCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Collisions {

	public function new(scene:Scene) {
		// Lights
		var light0 = new DirectionalLight("Omni", new Vector3(-2, -5, 2), scene);
		var light1 = new PointLight("Omni", new Vector3(2, -5, -2), scene);
		
		// Need a free camera for collisions
		var camera = new FreeCamera("FreeCamera", new Vector3(0, -8, -20), scene);
		camera.attachControl(this, true);
		
		//Ground
		var ground = Mesh.CreatePlane("ground", 20.0, scene);
		ground.material = new StandardMaterial("groundMat", scene);
		cast(ground.material, StandardMaterial).diffuseColor = new Color3(1, 1, 1);
		ground.material.backFaceCulling = false;
		ground.position = new Vector3(5, -10, -15);
		ground.rotation = new Vector3(Math.PI / 2, 0, 0);
		
		//Simple crate
		var box = Mesh.CreateBox("crate", 2, scene);
		box.material = new StandardMaterial("Mat", scene);
		cast(box.material, StandardMaterial).diffuseTexture = new Texture("assets/img/crate.png", scene);
		cast(box.material, StandardMaterial).diffuseTexture.hasAlpha = true;
		box.position = new Vector3(5, -9, -10);
		
		//Set gravity for the scene (G force like, on Y-axis)
		scene.gravity = new Vector3(0, -0.9, 0);
		
		// Enable Collisions
		scene.collisionsEnabled = true;
		
		//Then apply collisions and gravity to the active camera
		camera.checkCollisions = true;
		camera.applyGravity = true;
		
		//Set the ellipsoid around the camera (e.g. your player's size)
		camera.ellipsoid = new Vector3(1, 1, 1);
		
		//finally, say which mesh will be collisionable
		ground.checkCollisions = true;
		box.checkCollisions = true;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
