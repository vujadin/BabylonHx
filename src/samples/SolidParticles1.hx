package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.particles.SolidParticleSystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SolidParticles1 {

	public function new(scene:Scene) {
		scene.clearColor = Color3.Black();
		var camera = new ArcRotateCamera("camera1",  0, 0, 0, new Vector3(0, 0, -0), scene);
		camera.setPosition(new Vector3(0, 10, -200));
		camera.attachControl();
		
		var pl = new PointLight("pl", new Vector3(0, 0, 0), scene);
		pl.diffuse = new Color3(1, 1, 1);
		pl.intensity = 1.0;
	  
		var nb = 20000;    		// nb of triangles
		var fact = 100; 			// cube size
		
		// position function 
		var myPositionFunction = function(particle, i, s) {
			particle.position.x = (Math.random() - 0.5) * fact;
			particle.position.y = (Math.random() - 0.5) * fact;
			particle.position.z = (Math.random() - 0.5) * fact;
			particle.rotation.x = Math.random() * 3.15;
			particle.rotation.y = Math.random() * 3.15;
			particle.rotation.z = Math.random() * 1.5;
			particle.color = new Color4(particle.position.x / fact + 0.5, particle.position.y / fact + 0.5, particle.position.z / fact + 0.5, 1.0);
		};
	 
		// model 
		var model = Mesh.CreateBox("box", 2.5, scene);
	  
		// SPS creation
		var SPS = new SolidParticleSystem('SPS', scene, { isPickable: true });
		SPS.addShape(model, nb);
		var mesh = SPS.buildMesh();
		// dispose the model
		model.dispose();
	  
		// SPS init
		SPS.initParticles = function () {
			for (p in 0...SPS.nbParticles) {
				myPositionFunction(SPS.particles[p], 0, 0);
			}
		};
		
		SPS.initParticles();		// compute particle initial status
		SPS.setParticles();		// updates the SPS mesh and draws it
		SPS.refreshVisibleSize(); // updates the BBox for pickability
	  
		// Optimizers after first setParticles() call
		// This will be used only for the next setParticles() calls
		SPS.computeParticleTexture = false;
	  
		scene.onPointerDown = function(x, y, button, pickResult) {
			var faceId = pickResult.faceId;
			if (faceId == -1) {
				return;
			}
			var idx = SPS.pickedParticles[faceId].idx;
			var p = SPS.particles[idx];
			p.color.r = 1;
			p.color.b = 0;
			p.color.g = 0;
			p.scale.x = 5;
			p.scale.y = 5;
			p.scale.z = 5;
			SPS.setParticles();
		};
		
		// SPS mesh animation
		scene.registerBeforeRender(function() {
			pl.position = camera.position;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}