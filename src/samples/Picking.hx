package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.lights.PointLight;
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
class Picking {

	public function new(scene:Scene) {
		// setup environment
		var light0 = new PointLight("Omni", new Vector3(0, 10, 20), scene);
		var freeCamera = new FreeCamera("FreeCamera", new Vector3(0, 0, -30), scene);
		
		// Impact impostor
		var impact = Mesh.CreatePlane("impact", 1, scene);
		impact.material = new StandardMaterial("impactMat", scene);
		cast(impact.material, StandardMaterial).diffuseTexture = new Texture("assets/img/impact.png", scene);
		cast(impact.material, StandardMaterial).diffuseTexture.hasAlpha = true;
		impact.position = new Vector3(0, 0, -0.1);
		
		//Wall
		var wall = Mesh.CreatePlane("wall", 20.0, scene);
		wall.isPickable = true;
		wall.material = new StandardMaterial("wallMat", scene);
		cast(wall.material, StandardMaterial).emissiveColor = new Color3(0.5, 1, 0.5);
		
		//When pointer down event is raised
		scene.onPointerDown = function (x:Float, y:Float, button:Int, pickResult:PickingInfo) {
			// if the click hits the ground object, we change the impact position
			if (pickResult.hit) {
				impact.position.x = pickResult.pickedPoint.x;
				impact.position.y = pickResult.pickedPoint.y;
				
				trace(impact.position.x, impact.position.y);
			}
		};
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}