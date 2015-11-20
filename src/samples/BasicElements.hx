package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
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
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
				
		//Creation of a box
		//(name of the box, size, scene)
		var box = Mesh.CreateBox("box", 6.0, scene);
		
		//Creation of a sphere 
		var sphere = Mesh.CreateSphere("sphere", 10, 10, scene);
		
		//Creation of a plan
		var plan = Mesh.CreatePlane("plane", 10.0, scene);
		
		//Creation of a cylinder
		var cylinder = Mesh.CreateCylinder("cylinder", 8, 5, 5, 16, 16, scene);
		
		// Creation of a torus
		var torus = Mesh.CreateTorus("torus", 5, 1, 10, scene);
		
		// Creation of a knot
		var knot = Mesh.CreateTorusKnot("knot", 2, 0.5, 128, 64, 2, 3, scene);
				
		// Creation of a lines mesh
		var lines = Mesh.CreateLines("lines", [
			new Vector3(-10, 0, 0),
			new Vector3(10, 0, 0),
			new Vector3(0, 0, -10),
			new Vector3(0, 0, 10)
		], scene);
		
		// Creation of a ribbon
		// let's first create many paths along a maths exponential function as an example 
		var exponentialPath = function (p:Int):Array<Vector3> {
			var path:Array<Vector3> = [];
			for (i in -10...10) {
				path.push(new Vector3(p, i, Math.sin(p / 3) * 5 * Math.exp(-(i - p) * (i - p) / 60) + i / 3));
			}
			return path;
		};
		// let's populate arrayOfPaths with all these different paths
		var arrayOfPaths:Array<Array<Vector3>> = [];
		for (p in 0...20) {
			arrayOfPaths[p] = exponentialPath(p);
		}
		
		// (name, array of paths, closeArray, closePath, offset, scene)
		var ribbon = Mesh.CreateRibbon("ribbon", arrayOfPaths, false, false, 0, scene);
		
		// Moving elements
		box.position = new Vector3(-10, 0, 0);   // Using a vector
		sphere.position = new Vector3(0, 10, 0); // Using a vector
		plan.position.z = 10;                            // Using a single coordinate component
		cylinder.position.z = -10;
		torus.position.x = 10;
		knot.position.y = -10;
		ribbon.position = new Vector3(-10, -10, 20);
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
