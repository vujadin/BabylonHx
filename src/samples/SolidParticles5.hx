package samples;

import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;
import com.babylonhx.Scene;
import com.babylonhx.engine.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.particles.solid.SolidParticleSystem;
import com.babylonhx.particles.solid.SolidParticle;
import com.babylonhx.particles.solid.ModelShape;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SolidParticles5 {

	public function new(scene:Scene) {
		scene.clearColor = new Color4( .4, .6, .8, 1.0);
		var camera = new ArcRotateCamera("camera1",  0, 0, 0, new Vector3(0, 0, -0), scene);
		camera.setPosition(new Vector3(0, 60, -200));
		camera.attachControl();
		var light = new HemisphericLight("light1", new Vector3(1, 1, 0), scene);
		light.intensity = 0.9;
		var pl = new PointLight("pl", new Vector3(0, 0, 0), scene);
		pl.diffuse = new Color3(1, 1, 1);
		pl.specular = new Color3(0.9, 0.7, 0.5);
		pl.intensity = 0.8;
		
		var quadsReady = false;
		var setQuads = function(mesh) {
			quadsReady = true;
		};

		var subdivisions = 50;
		var width = 300;
		var height = 300;
		
		var minX = -width / 2;
		var maxX = width / 2;
		var minZ = -height / 2;
		var maxZ = height / 2;
		
		var options = { width: width, height: height, subdivisions: subdivisions, minHeight: 0,  maxHeight: 60, onReady: setQuads };
		var ground = MeshBuilder.CreateGroundFromHeightMap("ground", "assets/img/heightMap.png", options, scene);
		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/ground.jpg", scene);
		untyped groundMaterial.diffuseTexture.uScale = 6;
		untyped groundMaterial.diffuseTexture.vScale = 6;
		groundMaterial.specularColor = new Color3(0, 0, 0);
		ground.material = groundMaterial;
		groundMaterial.freeze();
		ground.freezeWorldMatrix();
		
		var nb = 2000;
		var radius = 0.6;
		
		var sps:SolidParticleSystem = new SolidParticleSystem("sps", scene);
		var model = MeshBuilder.CreateBox("s", { width: radius * 2, height: radius, depth: radius }, scene);
		sps.addShape(model, nb);
		model.dispose();
		sps.buildMesh();
		var mesh = sps.mesh;
		var norm = Vector3.Zero();         // tmp var to store the current ground normal
		var biNorm = Vector3.Zero();       // tmp var to store the current binormal : cross(plane velocity, normal)
		var slope = Vector3.Zero();        // tmp var to store the current slope : cross(normal, binormal) => steering
		
		sps.initParticles = function() {
			for (i in 0...sps.nbParticles) {
				var p = sps.particles;
				p[i].position.x = (width - radius - 1) * (0.5 - Math.random()) + radius;
				p[i].position.z = (height - radius - 1) * (0.5 - Math.random()) + radius;
				p[i].position.y = 50;
				p[i].color.r = Math.random();
				p[i].color.g = Math.random();
				p[i].color.b = Math.random();
				p[i].velocity.x = 0.5 - Math.random();
				p[i].velocity.z = 0.5 - Math.random();
			}
		};
		
		sps.updateParticle = function(particle) {
			if (particle.position.x < minX || particle.position.x > maxX) { particle.velocity.x *= -1; }
			if (particle.position.z < minZ || particle.position.z > maxZ) { particle.velocity.z *= -1; }
			particle.position.addInPlace(particle.velocity);
			// get the ground normal
			ground.getNormalAtCoordinatesToRef(particle.position.x, particle.position.z, norm);
			// compute 3 orthogonal axis to make a target system
			Vector3.CrossToRef(particle.velocity, norm, biNorm);
			Vector3.CrossToRef(biNorm, norm, slope);
			// rotate the particle to this target system
			Vector3.RotationFromAxisToRef(slope, norm, biNorm, particle.rotation);
			
			particle.position.y = radius + ground.getHeightAtCoordinates(particle.position.x, particle.position.z);
			
			return particle;
		};
		
		sps.initParticles();
		sps.computeParticleTexture = false;
		
		scene.registerBeforeRender(function (scene:Scene, _) {
			pl.position = camera.position;
			if (quadsReady) {
				sps.setParticles();
				sps.computeParticleColor = false;
			}
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
