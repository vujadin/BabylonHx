package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.engine.Engine;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PremultiplyAlphaTest {

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
		
		// Move the sphere upward 1/2 its height
		sphere.position.y = 1;
		
		var mat = new StandardMaterial("toto", scene);
		
		sphere.material = mat;
		
		mat.backFaceCulling = false;
		mat.alpha = 0.3;
		
		mat.alphaMode = Engine.ALPHA_PREMULTIPLIED;
		
		// Our built-in 'ground' shape. Params: name, width, depth, subdivs, scene
		var ground = Mesh.CreateGround("ground1", 6, 6, 2, scene);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}