package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.lib.grid.GridMaterial;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class GridMaterialTest {

	public function new(scene:Scene) {
		
		// This creates and positions a free camera (non-mesh)
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		//camera.setCameraRigMode(Camera.RIG_MODE_VR, { } );
		
		// This targets the camera to scene origin
		camera.setTarget(Vector3.Zero());
		
		// This attaches the camera to the canvas
		camera.attachControl();
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;
		
		// Our built-in 'ground' shape. Params: name, width, depth, subdivs, scene
		var ground = Mesh.CreateGround("ground1", 6, 6, 2, scene);
		ground.material = new GridMaterial("gridmat", scene);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
