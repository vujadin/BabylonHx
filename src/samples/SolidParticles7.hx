package samples;

import com.babylonhx.Scene;
import com.babylonhx.events.PointerEvent;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.particles.solid.SolidParticleSystem;
import com.babylonhx.particles.solid.SolidParticle;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SolidParticles7 {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0.2, 0.4, 0.8, 1.0);
		var camera = new ArcRotateCamera("cam", 0, 0, 0, Vector3.Zero(), scene);    
		camera.attachControl();
		
		var light = new PointLight("pl", camera.position, scene);
		light.intensity = 1.0;
		
		var mat = new StandardMaterial("m", scene);
		//mat.diffuseColor = Color3.Yellow();
		mat.alpha = 0.85;
		
		var particleNb = 300; 
		var areaSize = 100.0;
		var particleSize = 12.0;
		camera.setPosition(new Vector3(0, 0, -areaSize * 2.0));
		
		// particle initialization function
		var initParticle = function(particle:SolidParticle) {			
			particle.position.x = areaSize * (Math.random() - 0.5);
			particle.position.y = areaSize * (Math.random() - 0.5);
			particle.position.z = areaSize * (Math.random() - 0.5);
			
			particle.rotation.x = 6.28 * Math.random();
			particle.rotation.y = 6.28 * Math.random();
			particle.rotation.z = 6.28 * Math.random();
			
			particle.scaling.x = particleSize * Math.random() + 0.5;
			particle.scaling.y = particleSize * Math.random() + 0.5;
			particle.scaling.z = particleSize * Math.random() + 0.5;
			
			particle.color.r = 0.5 + Math.random() * 0.6;
			particle.color.g = 0.5 + Math.random() * 0.6;
			particle.color.b = 0.5 + Math.random() * 0.6;
			
			return particle;
		};
		
		// SPS creation
		var sps = new SolidParticleSystem("sps", scene, {enableDepthSort: true});
		//var model = MeshBuilder.CreatePlane("m", {}, scene);
		var model = Mesh.CreateBox("m", 1, scene);
		var model2 = MeshBuilder.CreatePolyhedron("m2", {size: 0.5}, scene);
		sps.addShape(model, Std.int(particleNb * 0.5));
		sps.addShape(model2, Std.int(particleNb * 0.5));
		model.dispose();
		model2.dispose();
		sps.buildMesh();
		var particles = sps.mesh;
		particles.material = mat;
		
		sps.computeParticleTexture = false;
		
		// init particles
		sps.updateParticle = initParticle;
		sps.setParticles();
		//sps.depthSortParticles = false;
	   
		// animation
		sps.updateParticle = function(p:SolidParticle) { return p; };
		scene.registerBeforeRender(function(_, _) {
			sps.setParticles();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
