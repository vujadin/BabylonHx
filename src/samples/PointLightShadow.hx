package samples;

import com.babylonhx.Scene;
import com.babylonhx.lights.PointLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.postprocess.LensRenderingPipeline;
import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;
import com.babylonhx.particles.ParticleSystem;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PointLightShadow {
	
	var deltaTime:Float = 0; 
	var px:Float = 0;
	var py:Float = 0;
	var pz:Float = 0;
	

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 30, Vector3.Zero(), scene);
		camera.lowerRadiusLimit = 5;
		camera.upperRadiusLimit = 40;
		camera.attachControl();

		var light = new PointLight("light1", new Vector3(0, 0, 0), scene);
		light.intensity = 0.7;
			
		var lightImpostor = Mesh.CreateSphere("sphere1", 16, 1, scene);
		var lightImpostorMat = new StandardMaterial("mat", scene);
		lightImpostor.material = lightImpostorMat;
		lightImpostorMat.emissiveColor = Color3.White();
		lightImpostorMat.linkEmissiveWithDiffuse = true;
		
		lightImpostor.parent = light;

		// { radius: 2, tube: 0.5, radialSegments: 128, tubularSegments: 64, p: 2, q: 3 }
		var knot = Mesh.CreateTorusKnot("knot", 2, 0.2, 128, 64, 4, 1, scene);	
		// { diameter: 5, thickness: 1, tessellation: 10 }
		var torus = Mesh.CreateTorus("torus", 8, 1, 32, scene);
		
		var torusMat = new StandardMaterial("mat", scene);
		torus.material = torusMat;
		torusMat.diffuseColor = Color3.Red();
		
		var knotMat = new StandardMaterial("mat", scene);
		knot.material = knotMat;
		knotMat.diffuseColor = Color3.White();
		
		// Container
		var container =  Mesh.CreateSphere("sphere2", 16, 50, scene, false, Mesh.BACKSIDE);
		var containerMat = new StandardMaterial("mat", scene);
		container.material = containerMat;
		containerMat.diffuseTexture = new Texture("assets/img/amiga.jpg", scene);
		cast(containerMat.diffuseTexture, Texture).uScale = 10.0;
		cast(containerMat.diffuseTexture, Texture).vScale = 10.0;
		
		// Shadow
		var shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.getShadowMap().renderList.push(knot);
		shadowGenerator.getShadowMap().renderList.push(torus);
		shadowGenerator.setDarkness(0.5);
		shadowGenerator.usePoissonSampling = true;	
		
		container.receiveShadows = true;
		torus.receiveShadows = true;
		
		var lensEffect = new LensRenderingPipeline('lens', {
			edge_blur: 1.0,
			chromatic_aberration: 2.0,
			distortion: 0.0,
			dof_focus_distance: 25.0,
			dof_aperture: 3.0,
			grain_amount: 1.0,
			dof_pentagon: true,
			dof_gain: 1.0,
			dof_threshold: 1.0,
			dof_darken: 0.25
		}, scene, 1.0, cast camera);
		
		// Volumetric light effect
		var mats = new StandardMaterial("mats", scene);
		mats.emissiveColor = new Color3(1.0, 1.0, 1.0);

		var godrays = new VolumetricLightScatteringPostProcess('godrays', 1.0, camera, null, 100, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
		cast(godrays.mesh.material, StandardMaterial).diffuseTexture = new Texture('assets/img/sun.png', scene, true, false, Texture.BILINEAR_SAMPLINGMODE);
		cast(godrays.mesh.material, StandardMaterial).diffuseTexture.hasAlpha = true;
		godrays.mesh.position = new Vector3(50, 1, 50);
		godrays.mesh.scaling = new Vector3(6, 6, 6);
		
		// Create a particle system
		var particleSystem = new ParticleSystem("particles", 20000, scene);
		particleSystem.particleTexture = new Texture("assets/img/flare.png", scene);	
		
		particleSystem.minEmitBox = new Vector3(0, 0, 0); 
		particleSystem.maxEmitBox = new Vector3(0, 0, 0); 
		
		particleSystem.direction1 = new Vector3(-7, 8, 3);
		particleSystem.direction2 = new Vector3(7, 8, -3);
		
		particleSystem.gravity = new Vector3(0, -9.81, 0);
		
		particleSystem.minLifeTime = 0.3;
		particleSystem.maxLifeTime = 1.2;	
		
		particleSystem.emitRate = 700;
		
		particleSystem.start();			
	
		scene.registerBeforeRender(function () {
			// delta time
			deltaTime += 0.005;
			
			// Knot rotation
			knot.rotation.y = deltaTime;
			knot.rotation.x = deltaTime * 2.15;
			
			// Torus rotation
			torus.rotation.y = deltaTime * 1.25;
			torus.rotation.z = deltaTime / 2.5;
			
			// Create some random positions
			px = -2.0 + 4.0 * Math.cos(deltaTime * 5.0);
			py = -2.0 + 4.0 * Math.sin(deltaTime * 2.5);
			pz = -2.0 + 4.0 * Math.cos(deltaTime * 1.5) + Math.cos(deltaTime * 3.14);
			
			container.rotation = new Vector3(px / 30.0, py / 10.0, pz / 4.0);		
			torus.position = knot.position = light.position = new Vector3(px, py, pz);
			
			// particleSystem.color1 = new Color4(px/5.0, py/5.0, pz/5.0, 1.0);
			particleSystem.emitter = new Vector3(px, py, pz);
			// Let's have something like "smoke"
			particleSystem.gravity = new Vector3(0, -10.5 + (-9.81 + 9.81 * Math.cos(deltaTime)), 0);
			
			godrays.mesh.position = new Vector3(px, py, pz);
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
