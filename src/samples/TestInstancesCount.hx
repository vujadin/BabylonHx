package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Space;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.Scene;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.particles.solid.SolidParticleSystem;
import com.babylonhx.particles.solid.SolidParticle;

import com.babylonhx.animations.Animation;
import com.babylonhx.actions.ActionEvent;
import com.babylonhx.collisions.PickingInfo;

import com.babylonhx.tools.EventState;
import com.babylonhx.utils.Image;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.RawTexture;
import com.babylonhx.materials.textures.procedurals.standard.Plasma;
import com.babylonhx.materials.textures.procedurals.standard.Spiral;
import com.babylonhx.materials.textures.procedurals.standard.Combustion;
import com.babylonhx.materials.textures.procedurals.standard.Electric;
import com.babylonhx.materials.textures.procedurals.standard.Voronoi;

import com.babylonhx.postprocess.NotebookDrawingsPostProcess;
import com.babylonhx.postprocess.WatercolorPostProcess;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TestInstancesCount {

	public function new(scene:Scene) {
		scene.clearColor = new Color4( .5, .5, .5, 1.0);
		var camera = new ArcRotateCamera("camera1",  0, 0, 0, new Vector3(0, 0, -0), scene);
		camera.setPosition(new Vector3(0, 0, -100));
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.groundColor = new Color3(0.5, 0.5, 0.5);
		light.intensity = 0.7;
		
		var pl = new PointLight("pl", new Vector3(0, 0, 0), scene);
		pl.diffuse = new Color3(1, 1, 1);
		pl.specular = new Color3(1, 0, 0);
		pl.intensity = 0.5;
		
		var dirLight = new DirectionalLight("dl", new Vector3(0, -1, 0), scene);
		dirLight.diffuse = Color3.White();
		dirLight.intensity = 0.9;
		dirLight.position = new Vector3(0, 100, 0);
		dirLight.specular = Color3.Black();

		// settings
		var range = 70;             // space size
		var nb = 200;              // particle number
		var speed = 0.6;            // particle max speed
		var rotSpeed = 0.01;        // particle rotation step
		
		var max = range / 2;
		var min = - max;
		
		// boxes
		var box = Mesh.CreateSphere("b", 10, 1, scene);
		var sps = new SolidParticleSystem("sps", scene);
		sps.addShape(box, nb);
		box.dispose();
		var s = sps.buildMesh();
		
		// ground
		var fact = 1.2;
		var ground = MeshBuilder.CreateBox("g", {width: range * fact, height: range * fact, depth: range * fact, sideOrientation: Mesh.BACKSIDE}, scene);
		var groundMat = new StandardMaterial("gm", scene);
		groundMat.alpha = 0.5;
		groundMat.diffuseColor = new Color3(0.8, 0.5, 0.2);
		ground.material = groundMat;
		ground.material.freeze();
		ground.freezeWorldMatrix();
		ground.receiveShadows = true;
		
		// shadows
		var shadowGenerator = new ShadowGenerator(1024, dirLight);
		shadowGenerator.getShadowMap().renderList.push(s);
		shadowGenerator.useBlurCloseExponentialShadowMap = true;
		ground.receiveShadows = true;
		
		// initial particle status
		sps.initParticles = function() {
			for (i in 0...sps.nbParticles) {
				sps.particles[i].position.x = (0.5 - Math.random()) * range;
				sps.particles[i].position.y = (0.5 - Math.random()) * range;
				sps.particles[i].position.z = (0.5 - Math.random()) * range;
				sps.particles[i].rotation.x = 3.15 * Math.random();
				sps.particles[i].rotation.y = 3.15 * Math.random();
				sps.particles[i].rotation.z = 3.15 * Math.random();
				sps.particles[i].velocity.x = (0.5 - Math.random()) * speed;
				sps.particles[i].velocity.y = (0.5 - Math.random()) * speed;
				sps.particles[i].velocity.z = (0.5 - Math.random()) * speed;
				sps.particles[i].color.r = 0.5;
				sps.particles[i].color.g = 0.5;
				sps.particles[i].color.b = 1.0;
			}
			sps.particles[0].color.r = 1.0;
			sps.particles[0].color.g = 1.0;
			sps.particles[0].color.b = 0.0;
			sps.particles[0].scaling = new Vector3(5.0, 5.0, 5.0);
			sps.particles[0].alive = false;
		}
		
		// particle behavior
		sps.updateParticle = function(p) {
			// limits
			if (p.position.x > max || p.position.x < min) { p.velocity.x *= -1; }
			if (p.position.y > max || p.position.y < min) { p.velocity.y *= -1; }
			if (p.position.z > max || p.position.z < min) { p.velocity.z *= -1; }
			// move
			p.position.x += p.velocity.x;
			p.position.y += p.velocity.y;
			p.position.z += p.velocity.z;
			// rotate
			p.rotation.x += rotSpeed;
			p.rotation.y += rotSpeed;
			p.rotation.z += rotSpeed;
			
			if (p.alive && p.intersectsMesh(sps.particles[0])) {
				p.color.r = 1.0;
				p.color.b = 0.0;
				p.color.g = 0.0;
				p.scaling.x = 2.0;
				p.scaling.y = 2.0;
				p.scaling.z = 2.0;
				p.alive = false;
			}
			
			return p;
		};
		
		// init sps
		sps.initParticles();
		sps.setParticles();
		sps.refreshVisibleSize();	// force once the computation of the bounding box
		sps.computeParticleTexture = false;
		
		// animation
		var dir = Vector3.Zero();
		var pos = Vector3.Zero();
		scene.registerBeforeRender(function(_, _) {
			sps.setParticles();
			camera.position.scaleToRef(2, pos);
			dir.copyFrom(pos);
			dir.scaleInPlace(-1);
			dirLight.position = pos;
			dirLight.direction = dir;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
