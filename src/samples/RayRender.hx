package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;
import com.babylonhx.culling.Ray;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.debug.RayHelper;
import com.babylonhx.postprocess.NotebookDrawingsPostProcess;
import com.babylonhx.postprocess.WatercolorPostProcess;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RayRender {

	public function new(scene:Scene) {
		var camera = new FreeCamera("camera1", new Vector3(10, 8, -5), scene);
		camera.fov = .6;
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.intensity = .5;
		
		var ground = Mesh.CreateGround("ground1", 6, 6, 2, scene);
		ground.position.y = -.1;
		var mat = new StandardMaterial("mat1", scene);
		mat.alpha = .2;
		ground.material = mat;
		
		var box = Mesh.CreateBox("box1", .5, scene);
		box.position.x = 2;
		box.position.y = 1;
		
		var boxTarget = Mesh.CreateBox("box2", 1, scene);
		boxTarget.position.x = 2;
		boxTarget.position.z = 2;
		
		box.lookAt(boxTarget.position);
		box.lookAt(ground.position);
		
		scene.render();
		
		var len = 10;
		
		var ray = new Ray(new Vector3(0, 0, -.5), new Vector3(0, 0, -1), len);
		ray = Ray.Transform(ray, box.getWorldMatrix());
		
		var rayHelper = RayHelper.CreateAndShow(ray, scene, Color3.Red());
		
		Tools.delay(function() { 
			rayHelper.hide();
			box.lookAt(boxTarget.position);
			ray = Ray.Transform(ray, box.getWorldMatrix());
			Tools.delay(function() {
				rayHelper.show(scene, Color3.Green());
			}, 3000);
		}, 3000);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
