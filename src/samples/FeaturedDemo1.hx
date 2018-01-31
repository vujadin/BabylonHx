package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.lib.pbr.PBRMaterial;
import com.babylonhx.probes.ReflectionProbe;

/**
 * ...
 * @author Krtolica Vujadin
 */

// http://www.babylonjs-playground.com/#ILRIF#0
class FeaturedDemo1 {
	
	var cubes:Array<AbstractMesh> = [];

	public function new(scene:Scene) {
		scene.clearColor = new Color3(0, 0, 0);
		
        var camera = new ArcRotateCamera("Camera", 33.7081, 0.9001, 39.91, Vector3.Zero(), scene);
        camera.setTarget(Vector3.Zero());
		
        var light  = new PointLight('light1', new Vector3(0, 10, 0), scene); 
		
        var light1 = new HemisphericLight("hemi", new Vector3(0, 10, 0), scene);
		
        var sphere = Mesh.CreateSphere("s", 32, 5, scene);  
		
        createCubesBall(1000, scene); 
		
        var mat_sphere = new StandardMaterial("s", scene);     
		sphere.material = mat_sphere;   
		
        var probe = new ReflectionProbe("probe", 512, scene);
        probe.renderList.push(sphere);
		
        var cubes_mat = new StandardMaterial("m", scene);        
        cubes_mat.diffuseTexture = new Texture("assets/img/square.jpg", scene);
		cubes[0].material = cubes_mat;
		
        var container = Mesh.CreateBox("cont", 110, scene);
        var mat_cont = new StandardMaterial("mc", scene);
        mat_cont.alpha = 0.1;
        container.material = mat_cont;
        
        var px = 0.0, py = 0.0, pz = 0.0;
		var cr = 0.0, cg = 0.0, cb = 0.0;
        var t = 0.0;
		
        scene.registerBeforeRender(function () {       
	   		// sin/cos random direction
            px = 25.0 * Math.cos(t / 3.5);
            py = 25.0 + 10.0 * Math.sin(t / 4.0);
            pz = 25.0 * Math.cos(t / 4.5);
			
			// sin/cos random color between 0,1
			cr = 0.5 + 0.5 * Math.sin(t / 12);
			cg = 0.5 + 0.5 * Math.sin(t / 14);
			cb = 0.5 + 0.5 * Math.sin(t / 16);
			
			// Change sphere and cubes colors
			mat_sphere.diffuseColor = new Color3(cr, cg, cb);         
			mat_sphere.emissiveColor = new Color3(cr, cg, cb);	
			cubes_mat.diffuseColor = new Color3(cr, cg, cb);	
			
			// Move our sphere
            sphere.position = new Vector3(px, py, pz);
			
			// Make all cubes look at the moving sphere
            for (i in 0...cubes.length) {            
                cubes[i].lookAt(new Vector3(px, py, pz));
            } 
			
            camera.alpha = 4.0 * (Math.PI / 20 + Math.cos(t/30));                           
            camera.beta = 2.0 * (Math.PI / 20 + Math.sin(t / 50));
            camera.radius = 180 + ( -50 + 50 * Math.sin(t / 10));
			
            t += 0.1;
        });
		
		var material = new StandardMaterial("m1", scene);
		material.backFaceCulling = false;
		material.checkReadyOnEveryCall = false;
		material.checkReadyOnlyOnce = true;
		material.diffuseTexture = new Texture("assets/img/t.png", scene);
		material.opacityTexture = new Texture("assets/img/t.png", scene);
		material.alpha = 0.01;
				
		var pp = Mesh.CreatePlane("plane", 0.01, scene);
		pp.material = material;
		pp.parent = camera;
		pp.position.z = 15;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}

	// better random function
	function rnd(min:Float, max:Float):Int {
        return Math.floor(Math.random() * (max - min + 1) + min);
    }

	// Create random cubes in a box of 100x100x100
    function createCubesBall(num:Int, scene:Scene) {        
        for (i in 0...num) {
            if (i == 0) {
                cubes[i] = Mesh.CreateBox("b", 1.0, scene);
			}
            else {
                cubes[i] = cast(cubes[0], Mesh).createInstance("b" + i);
			}
			
            var x = rnd(-50, 50);
            var y = rnd(-50, 50);
            var z = rnd( -50, 50);
			
            cubes[i].scaling = new Vector3(rnd(1.0, 1.5), rnd(1.0, 1.5), rnd(1.0, 10.0));
			
            cubes[i].position = new Vector3(x, y, z);
			
            cubes[i].lookAt(new Vector3(0, 0, 0));
        }            
    }
	
}
