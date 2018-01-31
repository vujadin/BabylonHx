package samples;

import com.babylonhx.Scene;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;


/**
 * ...
 * @author Krtolica Vujadin
 */
class MultiAnim {
	
	var robotMeshes:Array<Mesh> = [];

	public function new(scene:Scene) {
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.intensity = 1.8;
		
		var camera = new FreeCamera("Camera", new Vector3(-7.6458, 1.9236, -22.2599), scene);
		camera.rotation.set(-0.0186, -5.8411, 0);
		camera.attachControl();
		
		/*scene.getEngine().mouseDown.push(function(_, _, _) {
			trace(camera.position, camera.rotation);
		});*/
		
		var skybox = Mesh.CreateBox("skyBox", 10000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/night1", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		
		SceneLoader.ImportMesh("", "assets/models/robot/", "robot.babylon", scene, function (meshes:Array<AbstractMesh>, particles:Array<ParticleSystem>, skeletons:Array<Skeleton>) {	
			for (m in meshes) {
				untyped m.convertToFlatShadedMesh();
				m.scaling.set(0.2, 0.2, 0.2);
				robotMeshes.push(cast m);
				
				untyped m.material.specularColor = Color3.Black();
				untyped m.material.diffuseColor = new Color3(0.9, 0.9, 0.9);
			}
			/*for (s in skeletons) {
				scene.beginAnimation(s, 0, 100, true, 1.0);
			}*/
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
		
		/*SceneLoader.ImportMesh("", "assets/models/robot/", "robotwalk.babylon", scene, function (meshes:Array<AbstractMesh>, particles:Array<ParticleSystem>, skeletons:Array<Skeleton>) {	
			skeletons[0].copyAnimationRange
			for (m in meshes) {
				for (rm in robotMeshes) {
					if (m.name == rm.name) {
						rm.animations.concat(m.animations);
						break;
					}
				}
			}
		});*/
		
		/*SceneLoader.ImportMesh("", "assets/models/robot/", "walk.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {	
			for (s in newSkeletons) {
				s.
			}
		});*/
	}
	
}
