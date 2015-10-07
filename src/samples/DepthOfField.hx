package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.postprocess.LensRenderingPipeline;
import com.babylonhx.Scene;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DepthOfField {

	public function new(scene:Scene) {
		//Adding a light
		var light = new HemisphericLight("omni", new Vector3(0, 1, 0.1), scene);
		light.diffuse = new Color3(0.1, 0.1, 0.17);
		light.specular = new Color3(0.1, 0.1, 0.1);
		var light2 = new HemisphericLight("dirlight", new Vector3(1, -0.75, 0.25), scene);
		light2.diffuse = new Color3(0.95, 0.7, 0.4);
		light.specular = new Color3(0.7, 0.7, 0.4);

		//Adding an Arc Rotate Camera
		var camera = new ArcRotateCamera("Camera", 0.2, 1.0, 300, new Vector3(0, 10.0, 0), scene);
		camera.attachControl();
		camera.lowerRadiusLimit = 1;
		camera.maxZ = 2000;

		var lensEffect = new LensRenderingPipeline('lens', {
			edge_blur: 1.0,
			chromatic_aberration: 1.0,
			distortion: 1.0,
			dof_focus_depth: 200 / camera.maxZ,	// this sets the focus depth at a distance of 200
			dof_aperture: 3.0,		// set high to increase effect
			grain_amount: 1.0,
			dof_pentagon: true,
			dof_gain: 1.0,
			dof_threshold: 1.0,
		}, scene, 1.0, [camera]);

		// generate ground
		var ground = Mesh.CreateGround("ground1", 300, 300, 2, scene);
		var ground_material = new StandardMaterial('ground', scene);
		ground_material.diffuseColor = new Color3(0.3, 0.3, 0.4);
		ground_material.specularColor = new Color3(0.04, 0.04, 0.04);
		ground_material.specularPower = 10;
		ground.material = ground_material;

		// skull material
		var material = new StandardMaterial('building', scene);
		material.diffuseColor = new Color3(0.8, 0.8, 0.85);
		material.specularColor = new Color3(0.07, 0.07, 0.07);
		material.specularPower = 100;

		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		SceneLoader.ImportMesh("", "assets/models/", "skull.babylon", scene, function (newMeshes:Array<AbstractMesh>, newParticles:Array<ParticleSystem>, newSkeletons:Array<Skeleton>) {
			var mesh:Mesh = cast newMeshes[0];

			var inst:InstancedMesh;
			var size:Float = 0;
			var angle:Float = 0;
			var dist:Float = 0;
			var count = 8;

			// generate skull instances
			for (i in 0...count) {
				angle = Math.PI * 2 * i / count;

				inst = mesh.createInstance('skull_inst');
				size = 0.75 + 0.5 * Math.random();
				dist = 100.0 + 15 * Math.random();

				inst.scaling.copyFromFloats(size, size, size);
				inst.rotation.y = -angle + Math.PI / 2;

				inst.position.y = size * 30.0;
				inst.position.x = Math.cos(angle) * dist;
				inst.position.z = Math.sin(angle) * dist;
			}

			for (i in 0...count) {
				angle = Math.PI * 2 * i / count;

				inst = mesh.createInstance('skull_inst');
				size = 0.25 + 0.25 * Math.random();
				dist = 30.0 + 5 * Math.random();

				inst.scaling.copyFromFloats(size, size, size);
				inst.rotation.y = -angle - Math.PI / 2;

				inst.position.y = size * 30.0;
				inst.position.x = Math.cos(angle) * dist;
				inst.position.z = Math.sin(angle) * dist;

			}

			mesh.setEnabled(false);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});

		});
	}
	
}