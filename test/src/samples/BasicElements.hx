package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BasicElements {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 50, Vector3.Zero(), scene);
		camera.attachControl(this, true);
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		//Creation of a box
		//(name of the box, size, scene)
		var box = Mesh.CreateBox("box", 6.0, scene);
		
		//Creation of a sphere 
		//(name of the sphere, segments, diameter, scene) 
		var sphere = Mesh.CreateSphere("sphere", 10, 10.0, scene);
		
		//Creation of a plan
		//(name of the plane, size, scene)
		var plan = Mesh.CreatePlane("plane", 10.0, scene);
		
		//Creation of a cylinder
		//(name, height, diameter, tessellation, scene, updatable)
		var cylinder = Mesh.CreateCylinder("cylinder", 3, 3, 3, 6, 1, scene, false);
		
		// Creation of a torus
		// (name, diameter, thickness, tessellation, scene, updatable)
		var torus = Mesh.CreateTorus("torus", 5, 1, 10, scene, false);
		
		// Creation of a knot
		// (name, radius, tube, radialSegments, tubularSegments, p, q, scene, updatable)
		var knot = Mesh.CreateTorusKnot("knot", 2, 0.5, 128, 64, 2, 3, scene);
		
		// Creation of a lines mesh
		var lines = Mesh.CreateLines("lines", [
			new Vector3(-10, 0, 0),
			new Vector3(10, 0, 0),
			new Vector3(0, 0, -10),
			new Vector3(0, 0, 10)
		], scene);
		
		// Moving elements
		box.position = new Vector3(-10, 0, 0);   // Using a vector
		sphere.position = new Vector3(0, 10, 0); // Using a vector
		plan.position.z = 10;                            // Using a single coordinate component
		cylinder.position.z = -10;
		torus.position.x = 10;
		knot.position.y = -10;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
