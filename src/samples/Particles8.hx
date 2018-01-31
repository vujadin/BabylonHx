package samples;

import com.babylonhx.animations.Animation;
import com.babylonhx.animations.Animation.BabylonFrame;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.particles.Particle;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Particles8 {

	public function new(scene:Scene) {
		// This creates and positions a free camera (non-mesh)
		var camera = new ArcRotateCamera("cam", -1.57079633, 1.57079633, 5, new Vector3(0, 0, 0), scene);
		camera.attachControl();
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		// Default intensity is 1. Let's dim the light a small amount
		light.intensity = 0.7;
		
		var color1 = new Color4(0, 0.5, 0, 0.5);
		var color2 = new Color4(0, 1, 0.3, 0.5);
		var colorDead = new Color4(1, 0, 0, 0.1);
		
		var sphere = Mesh.CreateSphere('sphere', 6, 0.1, scene);
		sphere.position.x = 0;
		createPs(sphere, new ParticleSystem("ps1", 3600, scene), color1, color2, colorDead, 1, scene);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
	function createPs(emitter:Mesh, ps:ParticleSystem, color1:Color4, color2:Color4, colorDead:Color4, offset:Float, scene:Scene) {
		var url = "assets/img/star.jpg";
		
		ps.particleTexture = new Texture(url, scene);
		
		ps.minSize = 0.1;
		ps.maxSize = 0.1;
		ps.minLifeTime = 6;
		ps.maxLifeTime = 6;
		ps.minEmitPower = 3;
		ps.maxEmitPower = 3;
		
		ps.minAngularSpeed = 0;
		ps.maxAngularSpeed = Math.PI;
		
		ps.emitter = emitter;
		
		ps.emitRate = 100;
		ps.updateSpeed = 0.02;
		ps.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		
		ps.color1 = color1;
		ps.color2 = color2;
		ps.colorDead = colorDead;
		
		ps.direction1 = new Vector3(1, 0, 0);
		ps.direction2 = new Vector3(1, 0, 0);
		ps.minEmitBox = new Vector3(0, 0, 0);
		ps.maxEmitBox = new Vector3(0, 0, 0);
		
		ps.startPositionFunction = function(worldMatrix:Matrix, positionToUpdate:Vector3, _) {
			var randZ = ps.emitter.position.z + Math.random() * 6 - 3;
			var randX = ps.emitter.position.x + Math.random() * 6 - 3;
			// To have a cone
			// var x = Math.sqrt(9 - randZ * randZ);
			// var randX = (Math.random() > 0.5)? this.emitter.position.x + x : this.emitter.position.x - x;
			var randY = ps.emitter.position.y-3;
			Vector3.TransformCoordinatesFromFloatsToRef(randX, randY, randZ, worldMatrix, positionToUpdate);
		};
		
		ps.updateFunction = function(particles:Array<Particle>) {
			var index:Int = 0;
			while (index < particles.length) {
				if (index < 0) {
					index = 0;
				}
				var particle = particles[index];
				if (particle == null) {
					trace(particles.length, index);
				}
				particle.age += ps._scaledUpdateSpeed;
				
				if (particle.age >= particle.lifeTime) { // Recycle
					@:privateAccess ps._stockParticles.push(particles.splice(index, 1)[0]);
					index--;
					continue;
				} 
				else {
					particle.position.y += (ps.emitter.position.y - particle.position.y ) / 50;
					particle.position.x += (ps.emitter.position.x - particle.position.x ) / 50;
					particle.position.z += (ps.emitter.position.z - particle.position.z ) / 50;
					++index;
				}
			}
		}
		
		ps.start();
	}
	
}
