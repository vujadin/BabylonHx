package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.procedurals.standard.StarfieldProceduralTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StarfieldMaterialTest {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1", Math.PI / 4, Math.PI / 4, 3,  new Vector3(0, 0, 0), scene);
		
		camera.attachControl();
		
		var sphere = Mesh.CreateSphere("sphere1", 16, 2, scene);
		
		var starfield = new StarfieldProceduralTexture("s0", 1024, scene);
		
		var mat = new StandardMaterial("mat", scene);
		mat.emissiveTexture = starfield;
		mat.disableLighting = true;
		
		sphere.material = mat;
		
		starfield.zoom = 2;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}