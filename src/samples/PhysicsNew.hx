package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.Scene;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.physics.BabylonPhysics;
import com.babylonhx.math.Vector3;


/**
 * ...
 * @author Krtolica Vujadin
 */
class PhysicsNew {
	
	var phys:BabylonPhysics;

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0.86, 1.37, 50, Vector3.Zero(), scene);
		camera.attachControl(this);
		camera.maxZ = 50000;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		phys = new BabylonPhysics(scene);
		phys.gravity = new Vector3(0, -100, 0);
		
		var mat = new StandardMaterial("mat", scene);
		
		var cube = phys.createCube(mat, 10, new Vector3(5, 0.5, 5));
		cube.movable = false;
		cube.y = -10;
		
		var sphere = phys.createSphere(mat);
		sphere.y = 15;
		
		var sphere2 = phys.createSphere(mat);
		sphere.y = 35;
		sphere.x = 0.5;
		
		var box = phys.createCube(mat);
		box.y = 70;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
			phys.step();
		});		
	}
	
}
