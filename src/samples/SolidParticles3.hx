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
import com.babylonhx.particles.SolidParticleSystem;
import com.babylonhx.particles.SolidParticle;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SolidParticles3 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1",  0, 0, 0, new Vector3(0, 0, -0), scene);
		camera.setPosition(new Vector3(0, 50, -100));
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(1, 0, 0), scene);
		light.intensity = 0.75;
		light.specular = new Color3(0.95, 0.95, 0.81);
		
		var pl = new PointLight("pl", new Vector3(0, 0, 0), scene);
		pl.diffuse = new Color3(1, 1, 1);
		pl.specular = new Color3(0.1, 0.1, 0.12);
		pl.intensity = 0.75;
		
		var mat = new StandardMaterial("mat1", scene);
		mat.backFaceCulling = false;
	  
		var texture = new Texture("assets/img/normalMap.jpg", scene);
		mat.bumpTexture = texture;
		
		// Particle system creation
		var SPS = new SolidParticleSystem('SPS', scene);
		var model = MeshBuilder.CreateSphere("m", { segments: 5, diameterX: 8, diameterZ: 8, diameterY: 16 }, scene);
		SPS.addShape(model, 60);
		var mesh = SPS.buildMesh();
		mesh.material = mat;
		// dispose the model
		model.dispose();
		
		// Define a custom SPS behavior
	  
		var k:Float = 0;
		var p:Float = 0;
		// this function will morph the particles
		var myVertexFunction = function(particle:SolidParticle, vertex:Vector3, i:Int):Vector3 {
			p = i + k + particle.idx / 200;
			if (i < 45) {
				vertex.x += Math.sin(p / 100);
				vertex.y += Math.cos(p / 200);
				vertex.z += Math.sin(p / 300);
			} 
			else {
				vertex.x += Math.cos(p / 100);
				vertex.y += Math.sin(p / 300);
				vertex.z += Math.cos(p / 200);		  
			}
			
			return vertex;
		};
		
		SPS.initParticles = function() {
			var fact = 90;   // density
			
			for (p in 0...SPS.nbParticles) {
				SPS.particles[p].position.x = (Math.random() - 0.5) * fact;
				SPS.particles[p].position.y = (Math.random() - 0.5) * fact;
				SPS.particles[p].position.z = (Math.random() - 0.5) * fact;
				SPS.particles[p].rotation.x = Math.random() * 3.2;
				SPS.particles[p].rotation.y = Math.random() * 3.2;
				SPS.particles[p].rotation.z = Math.random() * 3.2;
				SPS.particles[p].color = new Color4(Math.random(), Math.random(), Math.random(), 1);
			}
		};
		
		SPS.updateParticle = function(particle:SolidParticle) {
			particle.rotation.x += particle.idx / 5000;
			particle.rotation.z += (SPS.nbParticles - particle.idx)  / 1000;
			
			return particle;
		};
		
		// this will be called by SPS.setParticles()
		SPS.updateParticleVertex = myVertexFunction;
		// init all particle values
		SPS.initParticles();
		
		// then set them all
		SPS.computeParticleVertex = true; 
			
		scene.registerBeforeRender(function () {
			k = scene.getEngine().getDeltaTime() * 100;
			pl.position = camera.position;
			SPS.mesh.rotation.y += 0.01;
			SPS.setParticles();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
