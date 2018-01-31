package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.math.Vector3;
//import jiglib.vehicles.JCar;
//import jiglib.physics.PhysicsSystem;

import com.babylonhxext.procgeom.plane.ProcCube;
import com.babylonhxext.procgeom.plane.ProcFence;
import com.babylonhxext.procgeom.plane.ProcQuad;
import com.babylonhxext.procgeom.plane.ProcHouse;

import com.babylonhxext.procgeom.cylinder.ProcSphere;
import com.babylonhxext.procgeom.cylinder.ProcCylinder;
import com.babylonhxext.procgeom.cylinder.ProcCylinderBend;
import com.babylonhxext.procgeom.cylinder.ProcCylinderTaper;
import com.babylonhxext.procgeom.cylinder.ProcCylinderBendTaper;
import com.babylonhxext.procgeom.cylinder.ProcMushroom;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PhysicsCar {
	
	//var system:PhysicsSystem;

	public function new(scene:Scene) {
		/*system = PhysicsSystem.getInstance();
		system.setCollisionSystem();
		system.setSolverType("ACCUMULATED");
		system.setGravity(new Vector3(0, -90.8, 0));*/
		
		// Create camera and light
		var light = new PointLight("Point", new Vector3(5, 10, 5), scene);
		var camera = new ArcRotateCamera("Camera", 1, 0.8, 15, new Vector3(0, 0, 0), scene);
		camera.attachControl(this);
		
		var sphere = new ProcSphere(scene).BuildMesh();
		sphere.position.y = -3;
		
		var cyl = new ProcCylinder(scene).BuildMesh();
		cyl.position.x = -2;
		
		var cyl2 = new ProcCylinderTaper(scene).BuildMesh();
		
		var cyl3 = new ProcCylinderBendTaper(scene).BuildMesh();
		cyl3.position.x = 2;
		
		var cube = new ProcCube(scene).BuildMesh();
		cube.position.y = 3;
		
		var fence = new ProcFence(scene).BuildMesh();
		fence.position.x = 2;
		fence.position.y = 3;
		
		var quad = new ProcQuad(scene).BuildMesh();
		
		var house = new ProcHouse(scene).BuildMesh();
		house.position.x = -2;
		house.position.y = 3;
		
		//var mushroom = new ProcMushroom(scene).BuildMesh();
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
