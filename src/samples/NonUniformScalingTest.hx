package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class NonUniformScalingTest {

	public function new(scene:Scene) {
		// This creates and positions a free camera (non-mesh)
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		
		// This targets the camera to scene origin
		camera.setTarget(Vector3.Zero());
		
		// This attaches the camera to the canvas
		camera.attachControl();
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;
		
		// Our built-in 'sphere' shape. Params: name, subdivs, size, scene
		var sphere = Mesh.CreateSphere("sphere1", 16, 2, scene);
		sphere.scaling = new Vector3(1, 2, 1);
		
		var sphere2 = Mesh.CreateSphere("sphere1", 16, 2, scene);
		
		sphere2.position.y = -3;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}