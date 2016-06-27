package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.cameras.FreeCamera;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LogarithmicDepth {

	public function new(scene:Scene) {
		//Offset to scene origin to intentionally provoke z-fighting on regular depth computation
		var addX = 40000;
		var addZ = 40000;
		
		// This creates and positions a free camera (non-mesh)
		var camera = new FreeCamera("camera1", new Vector3(addX, 5, addZ + 10), scene);

		// This targets the camera to scene origin
		camera.setTarget(new Vector3(addX, 0, addX));

		// This attaches the camera to the canvas
		camera.attachControl();

		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);

		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;

		// function to create create one of the demonstration objects (gets called below definition)
		var createBlob = function (useLog, offset, text) {
			var sphere = Mesh.CreateSphere(text, 24, 2, scene);

			// Move the sphere upward 1/2 its height
			sphere.position.y = 1;
			sphere.position.x = addX + offset;
			sphere.position.z = addZ;
			
			var box = Mesh.CreateBox("box*", 1, scene);
		
			// Move the sphere upward 1/2 its height
			box.position.y = 0.6;
			box.parent = sphere;
			
			var material = new StandardMaterial("mat", scene);
			//material.reflectionTexture = new CubeTexture("textures/TropicalSunnyDay", scene);
			material.diffuseColor = new Color3(0, 0, 0);
			material.emissiveColor = new Color3(0.5, 0.5, 0.5);
			material.specularPower = 1;
		
			sphere.material = material;
			material.useLogarithmicDepth = useLog;

			var material2 = new StandardMaterial("mat", scene);
			material2.diffuseColor = new Color3(1.0, 0, 0);
			material2.emissiveColor = new Color3(0.5, 0.5, 0.5);
			material2.specularPower = 16;
		
			box.material = material2;
			
			material2.useLogarithmicDepth = useLog;
			
			return box;
		}

		// call the above function twice to create the demonstration objects
		var b1 = createBlob(false, -2, "Using regular depth computation");
		var b2 = createBlob(true, 2, "Using logarithmic depth buffer");
		
		var angle = 0.0;
		
		//register a function to be called every frame to accomplish animation
		scene.registerBeforeRender(function () {
			camera.position.z = addZ + 10 + 5 * Math.sin(angle);
			camera.setTarget(new Vector3(addX, 0, addX));
			angle += 0.01;
			
			b1.rotation.y = angle;
			b2.rotation.y = angle;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
