package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.csg.CSG;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CSGDemo {

	public function new(scene:Scene) {
		var light = new HemisphericLight("dirlight", new Vector3(1, -0.75, 0.25), scene);
		light.diffuse = new Color3(0.95, 0.7, 0.4);
		light.specular = new Color3(0.7, 0.7, 0.4);
		
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
		camera.attachControl(this);
		camera.setPosition(new Vector3(10, 10, 15));
		camera.minZ = 10.0;
				
		var mat0 = new StandardMaterial("mat0", scene);
				
		var a = Mesh.CreateTorus("torus", { diameter: 8, thickness: 3, tessellation: 20 }, scene);
		var b = Mesh.CreateBox("box", { width: 1.5, height: 1.5, depth: 1.5 }, scene);
		b.scaling.y *= 8;
		b.rotation.x = Math.PI / 2;
		a.isVisible = false;
		b.isVisible = false;
				
		var aCSG = CSG.FromMesh(a);
		var bCSG = CSG.FromMesh(b);			
		var subCSG:CSG = aCSG.subtract(bCSG);	
		
		for (i in 0...6) {
			b.rotation.y += Math.PI / 4;
			bCSG = CSG.FromMesh(b);			
			subCSG = subCSG.subtract(bCSG);
		}
		
		var newMesh = subCSG.toMesh("csg", mat0, scene);
		newMesh.position = new Vector3(-12, 0, 0);
				
		a = Mesh.CreateCylinder("cyl", { height: 14, diameterTop: 4, diameterBottom: 4, tessellation: 15, subdivision: 15 }, scene);
		a.isVisible = false;
				
		b.rotation.y = 0;
		b.position.y += 5.5;		
		
		aCSG = CSG.FromMesh(a);
		bCSG = CSG.FromMesh(b);		
		subCSG = aCSG.subtract(bCSG);		
		
		for (i in 0...5) {
			b.rotation.y += Math.PI / 4;
			b.position.y -= 2;
			bCSG = CSG.FromMesh(b);			
			subCSG = subCSG.subtract(bCSG);
		}
		
		var newMesh2 = subCSG.toMesh("csg2", mat0, scene);
		newMesh2.position = new Vector3(10, 0, 0);
						
		a = Mesh.CreateSphere("sphere", { segments: 10, diameterX: 5, diameterY: 5, diameterZ: 5 }, scene);
		b = Mesh.CreateBox("box2", { width: 10, height: 10, depth: 10 }, scene);
		b.scaling.x = 0.02;
		b.rotation.z = Math.PI / 4;
		b.position.x = -3;
		
		aCSG = CSG.FromMesh(a);
		bCSG = CSG.FromMesh(b);
		subCSG = aCSG.subtract(bCSG);
		
		for (i in 0...12) {
			b.position.x += 0.5;
			bCSG = CSG.FromMesh(b);			
			subCSG = subCSG.subtract(bCSG);
		}
		
		var newMesh3 = subCSG.toMesh("csg3", mat0, scene);
		
		scene.removeMesh(a);
		a = null;
		scene.removeMesh(b);
		b = null;
						
		scene.registerBeforeRender(function () {
			camera.alpha += 0.01 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
