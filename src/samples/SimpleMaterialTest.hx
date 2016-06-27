package samples;

import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.lib.simple.SimpleMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SimpleMaterialTest {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(5, 4, -47), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		var light = new HemisphericLight("light", new Vector3(0, 1, 0), scene);
		
		var ground = Mesh.CreateGroundFromHeightMap("ground", "assets/img/heightMap.png", 100, 100, 100, 0, 10, scene, false);
		
		// create SimpleMaterial
		var groundMaterial = new SimpleMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/ground.jpg", scene);
		untyped groundMaterial.diffuseTexture.uScale = 6;
		untyped groundMaterial.diffuseTexture.vScale = 6;
		ground.position.y = -2.05;
		ground.material = groundMaterial;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}