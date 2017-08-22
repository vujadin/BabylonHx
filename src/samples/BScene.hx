package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;

import com.babylonhx.layer.Layer;

import com.babylonhx.postprocess.renderpipeline.pipelines.StandardRenderingPipeline;
import com.babylonhx.postprocess.renderpipeline.pipelines.DefaultRenderingPipeline;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BScene {

	public function new(scene:Scene) {
		// This creates and positions a free camera (non-mesh)
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		//var camera:ArcRotateCamera = new ArcRotateCamera("camera1", -Math.PI / 2.4, Math.PI / 2.2, 20, Vector3.Zero(), scene);
		
		// This targets the camera to scene origin
		camera.setTarget(Vector3.Zero());
		
		// This attaches the camera to the canvas
		camera.attachControl();
		
		//var bkgLayer = new Layer("background", "assets/img/ground.jpg", scene, true);
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;
		
		// Our built-in 'sphere' shape. Params: name, subdivs, size, scene
		var sphere = Mesh.CreateSphere("sphere1", 16, 2, scene);		
		
		// Move the sphere upward 1/2 its height
		sphere.position.y = 1;
		
		// Our built-in 'ground' shape. Params: name, width, depth, subdivs, scene
		var ground = Mesh.CreateGround("ground1", 6, 6, 2, scene);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
