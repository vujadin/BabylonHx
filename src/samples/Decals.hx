package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.Engine;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Decals {

	public function new(scene:Scene) {
		
		var camera = new ArcRotateCamera("Camera", -Math.PI/2, .7, 5, new Vector3(0, 2, 0), scene);
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.specular = Color3.Black();
		
		//Ground
		var ground = Mesh.CreatePlane("ground", 20.0, scene);
		ground.material = new StandardMaterial("groundMat", scene);
		cast(ground.material, StandardMaterial).diffuseColor = new Color3(1, 1, 1);
		ground.material.backFaceCulling = false;
		ground.position = new Vector3(0, 0, 0);
		ground.rotation = new Vector3(Math.PI / 2, 0, 0);
		
		//Simple crate
		var box = Mesh.CreateBox("crate", 4, scene);
		box.material = new StandardMaterial("Mat", scene);
		cast(box.material, StandardMaterial).diffuseTexture = new Texture("assets/img/crate.png", scene);
		cast(box.material, StandardMaterial).diffuseTexture.hasAlpha = true;
		box.position = new Vector3(0, 2.01, 0);
		
		var decalMaterial = new StandardMaterial("decalMat", scene);
		cast(decalMaterial, StandardMaterial).diffuseTexture = new Texture("assets/img/impact.png", scene);
		cast(decalMaterial, StandardMaterial).diffuseTexture.hasAlpha = true;
		decalMaterial.zOffset = -1;
		
		var onPointerDown = function (x:Int, y:Int, button:Int) {			
			// check if we are under a mesh
			var pickInfo = scene.pick(scene.pointerX, scene.pointerY, function (mesh) { return mesh == box; });
			if (pickInfo.hit) {
				var decalSize = new Vector3(1, 1, 0.01);
				
				// var newDecal = Mesh.CreateDecal("decal", box, pickInfo.pickedPoint, pickInfo.getNormal(true), decalSize);
				// wingy adjusts one line
				var newDecal = Mesh.CreateDecal("decal", box, pickInfo.pickedPoint, pickInfo.getNormal(true), decalSize);
				newDecal.material = decalMaterial;
			}
		}
		
		Engine.mouseDown.push(onPointerDown);
			
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
		
		/*//Adding a light
		var light = new HemisphericLight("Hemi", new Vector3(0, 1, 0), scene);
		
		//Adding an Arc Rotate Camera
		var camera = new ArcRotateCamera("Camera", -1.85, 1.2, 200, Vector3.Zero(), scene);
		
		camera.attachControl(this, true);
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		// The first parameter can be used to specify which mesh to import. Here we import all meshes
		SceneLoader.ImportMesh("", "assets/models/", "skull.babylon", scene, function(newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			//var cat = newMeshes[0];
			
			var cat = Mesh.CreateSphere("sphere", 10, 100.0, scene);
			
			// Set the target of the camera to the first imported mesh
			//camera.target = cat;
			
			var decalMaterial = new StandardMaterial("decalMat", scene);
			decalMaterial.diffuseTexture = new Texture("assets/img/impact.png", scene);
			decalMaterial.diffuseTexture.hasAlpha = true;
			decalMaterial.zOffset = -2;
			
			var onPointerDown = function (x:Int, y:Int, button:Int) {				
				// check if we are under a mesh
				var pickInfo = scene.pick(scene.pointerX, scene.pointerY, function (mesh) { return mesh == cat; });
				if (pickInfo.hit) {
					var decalSize = new Vector3(10, 10, 10);
					
					var newDecal = Mesh.CreateDecal("decal", cat, pickInfo.pickedPoint, pickInfo.getNormal(true), decalSize);
					newDecal.material = decalMaterial;
				}
			}
			
			Engine.mouseDown.push(onPointerDown);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});*/
	}
	
}