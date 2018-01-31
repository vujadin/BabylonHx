package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.particles.solid.SolidParticleSystem;
import com.babylonhx.particles.solid.SolidParticle;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SolidParticles2 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1",  0, 0, 0, new Vector3(0, 0, -0), scene);
		camera.setPosition(new Vector3(0, 50, -300));
		camera.attachControl();
	  
		var light = new HemisphericLight("light1", new Vector3(1, 1, 0), scene);
		light.intensity = 0.9;
	  
		var pl = new PointLight("pl", new Vector3(0, 0, 0), scene);
		pl.diffuse = new Color3(1, 1, 1);
		pl.specular = new Color3(0.2, 0.2, 0.8);
		pl.intensity = 0.75;
		
		// texture and material
		var mat = new StandardMaterial("mat1", scene);
		//mat.backFaceCulling = false;
		var texture = new Texture("assets/img/ground.jpg", scene);
		mat.diffuseTexture = texture;
		
		// SPS creation
		var tetra = MeshBuilder.CreatePolyhedron("tetra", { size: 5 }, scene);
		var box = Mesh.CreateBox("box", 5, scene);
		var SPS:SolidParticleSystem = new SolidParticleSystem('SPS', scene);
		SPS.addShape(tetra, 500);
		SPS.addShape(box, 500);
		var mesh = SPS.buildMesh();
		mesh.material = mat;
		mesh.position.y = -50;
		tetra.dispose();  // free memory
		box.dispose();
		
		// SPS behavior definition
		var speed = 1.5;
		var gravity = -0.01;
		
		// init
		SPS.initParticles = function() {
			// just recycle everything
			for (p in 0...SPS.nbParticles) {
				SPS.recycleParticle(SPS.particles[p]);
			}
		};
		
		// recycle
		SPS.recycleParticle = function(particle:SolidParticle) {
			// Set particle new velocity, scale and rotation
			// As this function is called for each particle, we don't allocate new
			// memory by using "new Vector3()" but we set directly the
			// x, y, z particle properties instead
			particle.position.x = 0;
			particle.position.y = 0;
			particle.position.z = 0;
			particle.velocity.x = (Math.random() - 0.5) * speed;
			particle.velocity.y = Math.random() * speed;
			particle.velocity.z = (Math.random() - 0.5) * speed;
			var scale = Math.random() + 0.5;
			particle.scaling.x = scale;
			particle.scaling.y = scale;
			particle.scaling.z = scale;
			particle.rotation.x = Math.random() * 3.5;
			particle.rotation.y = Math.random() * 3.5;
			particle.rotation.z = Math.random() * 3.5;
			particle.color.r = Math.random() * 0.6 + 0.5;
			particle.color.g = Math.random() * 0.6 + 0.5;
			particle.color.b = Math.random() * 0.6 + 0.5;
			particle.color.a = Math.random() * 0.6 + 0.5;
			
			return particle;
		};
		
		// update : will be called by setParticles()
		SPS.updateParticle = function(particle:SolidParticle) {  
			// some physics here 
			if (particle.position.y < 0) {
			  SPS.recycleParticle(particle);
			}
			particle.velocity.y += gravity;                         // apply gravity to y
			(particle.position).addInPlace(particle.velocity);      // update particle new position
			particle.position.y += speed / 2;
			
			var sign = (particle.idx % 2 == 0) ? 1 : -1;            // rotation sign and new value
			particle.rotation.z += 0.1 * sign;
			particle.rotation.x += 0.05 * sign;
			particle.rotation.y += 0.008 * sign;
			
			return particle;
		};
		
		// init all particle values and set them once to apply textures, colors, etc
		SPS.initParticles();
		SPS.setParticles();
	   
		// Tuning : 
		SPS.computeParticleColor = false;
		SPS.computeParticleTexture = false;
		
		//scene.debugLayer.show();
		// animation
		scene.registerBeforeRender(function(_, _) {
			SPS.setParticles();
			pl.position = camera.position;
			SPS.mesh.rotation.y += 0.01;
		});
	  
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
