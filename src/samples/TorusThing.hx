package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.procedurals.standard.Starfield;
import com.babylonhx.materials.pbr.PBRMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TorusThing {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, Math.PI / 2, 500, Vector3.Zero(), scene);
		
		camera.setTarget(Vector3.Zero());
		
		var light = new HemisphericLight("light1", new Vector3(0, 10, 0), scene);
		var light1  = new PointLight('light1', new Vector3(300,229,0), scene);
		var light2 = new PointLight('light1', new Vector3(34, -50, 100), scene);
		
		var m = new StandardMaterial("m", scene);
		var sphere = Mesh.CreateSphere("sphere1", 48, 1000, scene);
		m.diffuseColor = new Color3(0.2, 0.2, 0.2);
		//m.diffuseTexture = new StarfieldProceduralTexture("sft", 1024, scene);
		m.backFaceCulling = false;
		sphere.material = m;
		
		var reflectionTexture = new Texture("assets/img/flare.png", scene);
		
		var toruses:Array<Mesh> = [];
		var mat:Array<PBRMaterial> = [];
		var space = 0.8;
		var colr = 0.8;
		var colb = 0.8;
		for (i in 1...10) {
			mat[i] = new PBRMaterial("Material2", scene);
			//mat[i].glossiness = 0.9;
			mat[i].reflectionTexture = reflectionTexture;
			//mat[i].specularColor = new Color3(0.8, 0.8, 0.8);
			//mat[i].diffuseColor = new Color3(0, 0, 0); 
			
			toruses[i] = Mesh.CreateTorus("torus",(i + space) * 20.0, 10.0, 60, scene);
			toruses[i].material = mat[i];
		}
		
		var time = 0.0;
		var px:Float = 0;
		var py:Float = 0;
		var pz:Float = 0;
		scene.registerBeforeRender(function (_, _) {    				
			for (j in 1...toruses.length) {
				var bgcol = 0.05 * Math.sin(j * 2.0);
				scene.clearColor = new Color4(bgcol, bgcol, bgcol);
				
				toruses[j].rotation.x = 1.8 * Math.sin((j - time) / 10); 
				toruses[j].rotation.y = 2.2 * Math.cos((j - time) / 10);
				toruses[j].rotation.z = 1.6 * Math.sin((j - time) / 10);
				
				px = 50.0 * Math.cos((j - time) / 30);
				py = 50.0 * Math.sin((j - time) / 10);
				pz = 50.0 * Math.cos((j - time) / 20);				
				
				toruses[j].position.x = px; 
				toruses[j].position.y = py;
				toruses[j].position.z = pz;	
				
				colr = 1.0 * Math.sin((j - time) / 15);
				colb = 1.0 * Math.sin((j - time) / 7.5);
				
				if (colr < 0) colr = 0;
				if (colb < 0) colb = 0;
				
				mat[j].reflectionColor = new Color3(0, 0, 0);
				mat[j].ambientColor = new Color3(0.7, 0.7, 0.7);			
				mat[j].emissiveColor = new Color3(colr, 0, colb);				
				
				light1.position.x = px * 0.2;
				light1.position.y = py * 0.2;
				light1.position.z = pz * 0.2;
			}
			
			//sphere.rotation.x += 0.1; 
			//sphere.rotation.y += 0.015;
			//sphere.rotation.z += 0.025;
						
			time += 0.1;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
