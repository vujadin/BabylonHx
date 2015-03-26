package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BasicElements {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 50, Vector3.Zero(), scene);
		camera.attachControl(this, true);
		
		//var plight = new PointLight("pointlight", new Vector3(0, 0, 0), scene);
		var plight = new HemisphericLight("hemi", new Vector3(0, 0, 0), scene);
		
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
		
		//var tube = Mesh.CreateTube("tube", [Vector3.Zero(), new Vector3(5, 4, 7), new Vector3(12, 14, 9)], 5, 5, null, scene);
		
		// Moving elements
		box.position = new Vector3(-10, 0, 0);     // Using a vector
		sphere.position = new Vector3(0, 10, 0);   // Using a vector
		plan.position.z = 10;                      // Using a single coordinate component
		cylinder.position.z = -10;
		torus.position.x = 10;
		knot.position.y = -10;
		
		var h = 0.05;
		var color:RGB = { r: 0, g: 0, b: 0 };
		scene.getEngine().runRenderLoop(function () {
			
			h = Tools.Clamp(h + 0.0025 * (0.5 - Math.random()), 0.025, 0.07);
			
			color = ColorTools.toRGB(cast ColorTools.hue2rgb(h, 0.95, 0.9));
			
			plight.diffuse.r = color.r;
			plight.diffuse.b = color.b;
			plight.diffuse.g = color.g;
			plight.intensity = Tools.Clamp(plight.intensity + 0.05 * (0.5 - Math.random()), 0.6, 1);
			
            scene.render();
        });
	}	
	
}
