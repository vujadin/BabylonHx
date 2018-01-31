package samples;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;
import com.babylonhx.materials.lib.cell.CellMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.Scene;
import com.babylonhx.lights.PointLight;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CellMat {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0.5, 0.5, 0.5, 1.0);
		
		var camera = new ArcRotateCamera("Camera", 0, Math.PI / 2, 12, Vector3.Zero(), scene);
		camera.attachControl();
		
		var knot = Mesh.CreateTorusKnot("knot", 2, 0.5, 128, 64, 2, 3, scene);
		var light = new PointLight("light", new Vector3(10, 10, 10), scene);
		
		var cell = new CellMaterial("cell", scene);
		cell.diffuseTexture = new Texture("assets/img/amiga.jpg", scene);
		cell.diffuseTexture.uScale = cell.diffuseTexture.vScale = 3;
		cell.computeHighLevel = true;
		knot.material = cell;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
