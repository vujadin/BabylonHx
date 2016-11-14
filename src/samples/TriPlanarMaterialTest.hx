package samples;

import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.materials.lib.triplanar.TriPlanarMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TriPlanarMaterialTest {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(5, 4, -47), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		// Light
		var light = new HemisphericLight("light", new Vector3(0, 1, 0), scene);
		
		// Create tri-planar material
		var triPlanarMaterial = new TriPlanarMaterial("assets/img/triplanar", scene);
		triPlanarMaterial.diffuseTextureX = new Texture("assets/img/rock.png", scene);
		triPlanarMaterial.diffuseTextureY = new Texture("assets/img/grass.png", scene);
		triPlanarMaterial.diffuseTextureZ = new Texture("assets/img/floor.png", scene);
		triPlanarMaterial.normalTextureX = new Texture("assets/img/rockn.png", scene);
		triPlanarMaterial.normalTextureY = new Texture("assets/img/grassn.png", scene);
		triPlanarMaterial.normalTextureZ = new Texture("assets/img/rockn.png", scene);
		triPlanarMaterial.specularPower = 32;
		triPlanarMaterial.tileSize = 1.5;
		
		// Create default material
		var defaultMaterial = new StandardMaterial("ground", scene);
		defaultMaterial.diffuseTexture = new Texture("assets/img/ground.jpg", scene);
		untyped defaultMaterial.diffuseTexture.uScale = 10;
		untyped defaultMaterial.diffuseTexture.vScale = 10;
		defaultMaterial.specularColor = new Color3(0, 0, 0);
		
		// Ground
		var ground = Mesh.CreateGroundFromHeightMap("ground", "assets/img/heightMapTriPlanar.png", 100, 100, 100, 0, 10, scene, false);
		ground.material = triPlanarMaterial;
		
		// Events
		Engine.keyDown.push(function(evt:Dynamic) {
			// draw SSAO with scene when pressed "1"
			if (evt.keyCode == 49) {
				ground.material = triPlanarMaterial;
			}
			else if (evt.keyCode == 50) {
				ground.material = defaultMaterial;
			}
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}