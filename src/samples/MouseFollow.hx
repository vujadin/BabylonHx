package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.WebVRFreeCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Space;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.Engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MouseFollow {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(0, 0, -10), scene);
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		light.intensity = 0.7;
		
		var plane = Mesh.CreatePlane("plane", 5, scene);
		plane.isPickable = true;
		
		var ball = Mesh.CreateSphere("ball", 8, 1, scene);
		
		scene.onPointerMove = function (_, _, _) {
			var pinfo = scene.pick(scene.pointerX, scene.pointerY);
			
			if (pinfo.hit) {
				ball.position.x = pinfo.pickedPoint.x;
				ball.position.y = pinfo.pickedPoint.y;
			}
		};
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
