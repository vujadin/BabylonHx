package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
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
class Particles9 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("cam", -1.57079633, 1.57079633, 10, new Vector3(0, 0, 0), scene);
		camera.attachControl();		
		camera.setTarget(Vector3.Zero());
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		light.intensity = 0.7;
		
		var sphere = Mesh.CreateSphere("sphere1", 16, 2, scene);
		var sphere2 = Mesh.CreateSphere("sphere2", 16, 2, scene);
		sphere.position.x = -3;
		sphere2.position.x = 3;
		sphere2.position.y = 1;
		
		var dif = sphere2.position.subtract(sphere.position);
		
		var particleSystem = new ParticleSystem("particles", 2000, scene);
		particleSystem.particleTexture = new Texture("assets/img/star.jpg", scene);
		
		particleSystem.emitter = sphere; 
		particleSystem.minEmitBox = new Vector3(0, 0, 0);
		particleSystem.maxEmitBox = dif;
		
		particleSystem.color1 = new Color4(0.7, 0.8, 3.0, 1.0);
		particleSystem.color2 = new Color4(0.9, 0.5, 0.0, 1.0);
		particleSystem.colorDead = new Color4(0, 0, 0.2, 0.0);		
		particleSystem.minSize = 0.1;
		particleSystem.maxSize = 0.3;
		particleSystem.minLifeTime = .0;
		particleSystem.maxLifeTime = .1;
		particleSystem.emitRate = 10000;
		particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		particleSystem.gravity = new Vector3(0, 0, 0);
		particleSystem.direction1 = new Vector3(5, 5, 5);
		particleSystem.direction2 = new Vector3(-5, -5, -5);
		particleSystem.minAngularSpeed = 0;
		particleSystem.maxAngularSpeed = Math.PI * 2;
		particleSystem.minEmitPower = 1;
		particleSystem.maxEmitPower = 3;
		
		particleSystem.start();
		
		var s1 = sphere;
		var s2 = sphere2;
		var pSys = particleSystem;
		
		pSys.startPositionFunction = function(worldMatrix:Matrix, positionToUpdate:Vector3, _) {
			var jif = s2.position.subtract(s1.position);
			var t = Math.random();
			var randX = jif.x * t;
			var randY = jif.y * t;
			var randZ = jif.z * t;
			
			Vector3.TransformCoordinatesFromFloatsToRef(randX, randY, randZ, worldMatrix, positionToUpdate);
		};
		
		var time = 0.0;
		scene.registerBeforeRender(function(_, _) {
			time += .02;
			s1.position.x = -Math.sin(time) * 3;
			s1.position.y = Math.sin(time) * 2;
			s1.position.z = Math.sin(time) * 2;
			s2.position.x = Math.cos(time / 2) * 2.5;
			s2.position.y = Math.cos(time) * 2;
			s2.position.z = -Math.sin(time) * 1.5;
		});
		
		scene.getEngine().runRenderLoop(function () {			
			scene.render();
		});
	}
	
}
