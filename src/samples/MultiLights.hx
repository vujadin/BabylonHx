package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.lib.sky.SkyMaterial;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFile;
import com.babylonhx.loading.plugins.ctmfileloader.CTMFileLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;


/**
 * ...
 * @author Krtolica Vujadin
 */
class MultiLights {

	public function new(scene:Scene) {
		// Setup camera
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		camera.setPosition(new Vector3(-10, 10, 0));
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.intensity = 1.8;
		
		/*// Sky material
		var skyboxMaterial = new SkyMaterial("skyMaterial", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.freeze();

		// Sky mesh (box)
		var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
		skybox.material = skyboxMaterial;*/
		
		var lightSpheres:Array<Mesh> = [];
		var lights:Array<PointLight> = [];
		var lightTags:Array<Vector3> = [];
		
		var lightsCount = 64;
		
		var generateLight = function () {
			var light = new PointLight("Omni", new Vector3(0, 0, 0), scene);
			var lightSphere = Mesh.CreateSphere("Sphere", 16, 0.1, scene);
			
			lightTags.push(new Vector3(
				1 - Math.random() * 2,
				1 - Math.random() * 2,
				1 - Math.random() * 2
			));
			
			lightSphere.material = new StandardMaterial("mat", scene);
			untyped lightSphere.material.diffuseColor = new Color3(0, 0, 0);
			untyped lightSphere.material.specularColor = new Color3(0, 0, 0);
			untyped lightSphere.material.emissiveColor = new Color3(Math.random(), Math.random(), Math.random());
			
			light.diffuse = untyped lightSphere.material.emissiveColor;
			light.specular = untyped lightSphere.material.emissiveColor;
			
			lightSpheres.push(lightSphere);
			lights.push(light);
		};
		
		SceneLoader.ImportMesh("", "assets/models/chest/", "chest.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			for (m in newMeshes) {
				untyped m.material.maxSimultaneousLights = lightsCount;
				m.material.freeze();
			}
		});
		
		/*CTMFileLoader.load("assets/models/frenkie/manu_jarvinen_excavator.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			var mat = new StandardMaterial("mat", scene);
			mat.diffuseColor = new Color3(0, 0, 0);
			mat.diffuseTexture = new Texture("assets/models/chest/difuse.jpg", scene);
			mat.bumpTexture = new Texture("assets/models/chest/normal.jpg", scene);
			mat.specularTexture = new Texture("assets/models/chest/specular.jpg", scene);
			mat.maxSimultaneousLights = lightsCount;
			mat.freeze();
			meshes[0].material = mat;
			//meshes[0].scaling.set(0.3, 0.3, 0.3);
		});*/
		
		for (index in 0...lightsCount) {
			generateLight();
		}
		
		// Animations
		var alpha = 0.0;
		scene.beforeRender = function (scene:Scene, ?ev:Dynamic) {			
			for (index in 0...lightsCount) {
				var light = lights[index];
				light.position = new Vector3(10 * Math.sin(alpha) * lightTags[index].x, -10 * Math.sin(alpha) * lightTags[index].y, 10 * Math.cos(alpha) * lightTags[index].z);
				
				lightSpheres[index].position = lights[index].position;
			}
			
			alpha += 0.01;
		};
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
