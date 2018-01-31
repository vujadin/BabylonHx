package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.MirrorTexture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.Scene;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Particles5 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		camera.setPosition(new Vector3(-5, 5, 0));
		camera.lowerBetaLimit = 0.1;
		camera.upperBetaLimit = (Math.PI / 2) * 0.99;
		camera.lowerRadiusLimit = 5;
		camera.attachControl();
		
		// Mirror
		var mirror = Mesh.CreateBox("Mirror", 1.0, scene);
		mirror.scaling = new Vector3(100.0, 0.01, 100.0);
		var mirrormaterial = new StandardMaterial("mirror", scene);
		mirrormaterial.diffuseColor = new Color3(0.4, 0.4, 0.4);
		mirrormaterial.specularColor = new Color3(0, 0, 0);
		mirrormaterial.reflectionTexture = new MirrorTexture("mirror", 512, scene, true);
		cast (mirrormaterial.reflectionTexture, MirrorTexture).mirrorPlane = new Plane(0, -1.0, 0, 0.0);
		mirrormaterial.reflectionTexture.level = 0.2;
		mirror.position = new Vector3(0, 0.0, 0);
		
		// Emitters
		var emitter0 = Mesh.CreateBox("emitter0", 0.1, scene);
		emitter0.isVisible = false;
		
		var emitter1 = Mesh.CreateBox("emitter1", 0.1, scene);
		emitter1.isVisible = false;
		
		cast (mirrormaterial.reflectionTexture, MirrorTexture).renderList.push(emitter0);
		cast (mirrormaterial.reflectionTexture, MirrorTexture).renderList.push(emitter1);
		mirror.material = mirrormaterial;
		
		// Particles
		var particleSystem = new ParticleSystem("particles", 4000, scene);
		particleSystem.particleTexture = new Texture("assets/img/flare.png", scene);
		particleSystem.minAngularSpeed = -0.5;
		particleSystem.maxAngularSpeed = 0.5;
		particleSystem.minSize = 0.1;
		particleSystem.maxSize = 0.5;
		particleSystem.minLifeTime = 0.5;
		particleSystem.maxLifeTime = 2.0;
		particleSystem.minEmitPower = 0.5;
		particleSystem.maxEmitPower = 4.0;
		particleSystem.emitter = emitter0;
		particleSystem.emitRate = 400;
		particleSystem.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		particleSystem.minEmitBox = new Vector3(-0.5, 0, -0.5);
		particleSystem.maxEmitBox = new Vector3(0.5, 0, 0.5);
		particleSystem.direction1 = new Vector3(-1, 1, -1);
		particleSystem.direction2 = new Vector3(1, 1, 1);
		particleSystem.color1 = new Color4(1, 0, 0, 1);
		particleSystem.color2 = new Color4(0, 1, 1, 1);
		particleSystem.gravity = new Vector3(0, -2.0, 0);
		particleSystem.start();
		
		var particleSystem2 = new ParticleSystem("particles", 4000, scene);
		particleSystem2.particleTexture = new Texture("assets/img/flare.png", scene);
		particleSystem2.minSize = 0.1;
		particleSystem2.maxSize = 0.3;
		particleSystem2.minEmitPower = 1.0;
		particleSystem2.maxEmitPower = 2.0;
		particleSystem2.minLifeTime = 0.5;
		particleSystem2.maxLifeTime = 1.0;
		particleSystem2.emitter = emitter1;
		particleSystem2.emitRate = 500;
		particleSystem2.blendMode = ParticleSystem.BLENDMODE_ONEONE;
		particleSystem2.minEmitBox = new Vector3(0, 0, 0);
		particleSystem2.maxEmitBox = new Vector3(0, 0, 0);
		particleSystem2.gravity = new Vector3(0, -0.5, 0);
		particleSystem2.direction1 = new Vector3(0, 0, 0);
		particleSystem2.direction2 = new Vector3(0, 0, 0);
		particleSystem2.start();
		
		var alpha = 0.0;
		scene.registerBeforeRender(function (_, _) {
			emitter1.position.x = 3 * Math.cos(alpha);
			emitter1.position.y = 1.0;
			emitter1.position.z = 3 * Math.sin(alpha);
			alpha += 0.05 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
