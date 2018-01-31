package samples;

import com.babylonhx.Scene;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Viewport;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.actions.ActionManager;
import com.babylonhx.actions.ExecuteCodeAction;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Minimap {

	public function new(scene:Scene) {
		//Camera
		var camera = new FreeCamera("Camera", new Vector3(0, 5, -30), scene);	
		camera.angularSensibility = -5000;
		camera.setTarget(Vector3.Zero());	
		
		var light = new HemisphericLight("light1", new Vector3(1, 0.5, 0), scene);
		light.intensity = 0.6;
		
		// Minimap
		var mm = new FreeCamera("minimap", new Vector3(0, 0, 0), scene); 
		mm.mode = Camera.ORTHOGRAPHIC_CAMERA;
		mm.setTarget(new Vector3(0, 0, 0));
		mm.orthoLeft = -50 / 2;
		mm.orthoRight = 50 / 2;
		mm.orthoTop =  50 / 2;
		mm.orthoBottom = -50 / 2;
		mm.rotation.x = Math.PI / 2;
		mm.viewport = new Viewport(0, 0, 0.32, 0.32);		
		
		scene.activeCamera = camera;
		scene.activeCameras.push(camera);
		scene.activeCameras.push(mm);
		scene.cameraToUseForPointers = camera;
		
		camera.attachControl();
		
		var sphere = Mesh.CreateSphere("s", 8, 2, scene);
		var material = new StandardMaterial("texture1", scene);
		material.emissiveColor = Color3.Red();
		material.backFaceCulling = false;
		sphere.material = material;
		sphere.position.y = 10;
		
		sphere.actionManager = new ActionManager(scene);
		sphere.actionManager.registerAction(new ExecuteCodeAction(ActionManager.OnPointerOverTrigger, function(_) {	
			untyped sphere.material.emissiveColor = Color3.Blue();
		}));
		sphere.actionManager.registerAction(new ExecuteCodeAction(ActionManager.OnPointerOutTrigger, function(_) {
			untyped sphere.material.emissiveColor = Color3.Red();
		}));		
		
		var box = Mesh.CreateBox("box", 4, scene);
		var material2 = new StandardMaterial("texture2", scene);
		material2.emissiveColor = Color3.Green();
		material2.backFaceCulling = false;
		box.material = material2;
		box.position = new Vector3(0, 0, 0);		
		
		var ground = Mesh.CreateGround("ground1", 100, 100, 2, scene);
		var material3 = new StandardMaterial("texture3", scene);
		material3.emissiveColor = Color3.Blue();
		material3.backFaceCulling = false;
		ground.material = material3;
		ground.position = new Vector3(0, 0, 0);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
