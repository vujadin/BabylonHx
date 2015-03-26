package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LOD {

	public function new(scene:Scene) {
		var camera = new FreeCamera("Camera", new Vector3(0, 0, 0), scene);
		camera.attachControl(this);
		var hemi = new HemisphericLight("hemi", new Vector3(0, 1.0, 0), scene);
		
		scene.fogColor = scene.clearColor;
		scene.fogMode = Scene.FOGMODE_LINEAR;
		scene.fogStart = 10;
		scene.fogEnd = 50;
		
		// Materials
		var materialAmiga = new StandardMaterial("amiga", scene);
		materialAmiga.diffuseTexture = new Texture("assets/img/amiga.jpg", scene);
		materialAmiga.emissiveColor = new Color3(0.5, 0.5, 0.5);
		materialAmiga.diffuseTexture.uScale = 5;
		materialAmiga.diffuseTexture.vScale = 5;
		
		var materialRed = new StandardMaterial("red", scene);
		materialRed.emissiveColor = new Color3(0.5, 0, 0);
		
		// Create a wall of knots
		var count = 3;
		var scale = 4;
		
		var knot00 = Mesh.CreateTorusKnot("knot0", 0.5, 0.2, 128, 64, 2, 3, scene);
		/*var knot01 = Mesh.CreateTorusKnot("knot1", 0.5, 0.2, 32, 16, 2, 3, scene);
		var knot02 = Mesh.CreateTorusKnot("knot2", 0.5, 0.2, 24, 12, 2, 3, scene);
		var knot03 = Mesh.CreateTorusKnot("knot3", 0.5, 0.2, 16, 8, 2, 3, scene);
		
		knot00.material = materialAmiga;
		knot01.material = materialAmiga;
		knot02.material = materialRed;
		knot03.material = materialRed;
		
		knot00.setEnabled(false);
		knot01.setEnabled(false);
		knot02.setEnabled(false);
		knot03.setEnabled(false);
		
		knot00.addLODLevel(15, knot01);
		knot00.addLODLevel(30, knot02);
		knot00.addLODLevel(45, knot03);
		knot00.addLODLevel(55, null);
		
		for (x in 0...7) {
			for (y in 0...7) {
				for (z in 5...10) {
					var knot = knot00.createInstance("knotI");
					
					knot.position = new Vector3(x * scale, y * scale, z * scale);
				}
			}
		}*/
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
