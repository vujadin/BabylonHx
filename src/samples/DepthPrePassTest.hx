package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.particles.solid.SolidParticleSystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DepthPrePassTest {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera('camera', 0, 1, 15, new Vector3(0, 0, 0), scene);
		camera.maxZ = 10000;
		camera.attachControl();
		var light = new HemisphericLight('light', new Vector3(0, 1, 0), scene);
		light.intensity = 0.6;
		var ground = Mesh.CreatePlane('ground', 100, scene);
		ground.rotation.x = Math.PI / 2;
		ground.position.y = -0.01;
		
		// Create materials
		var materialO = new StandardMaterial('materialO', scene);
		var materialT = new StandardMaterial('materialT', scene);
		
		materialT.emissiveColor = new Color3(0.1, 0.1, 0.1);
		//materialT.separateCullingPass = true;
		
		// Create meshes
		var space = Mesh.CreateBox("space", 20, scene, true, Mesh.DOUBLESIDE);
		var boxInsideO = Mesh.CreateBox("boxInsideO", 2, scene);
		var boxInsideT = Mesh.CreateBox("boxInsideT", 2, scene);
		var boxOutsideT = Mesh.CreateBox("boxOutsideT", 4, scene);
		var boxOutsideO = Mesh.CreateBox("boxOutsideO", 4, scene);
		
		// Assign positions to meshes
		space.position.y = 10;
		
		boxInsideO.position.x = 2;
		boxInsideO.position.y = 1;
		
		boxInsideT.position.x = -2;
		boxInsideT.position.y = 1;
		
		boxOutsideT.position.x = 16;
		boxOutsideT.position.y = 2;
		
		boxOutsideO.position.x = 16;
		boxOutsideO.position.y = 2;
		boxOutsideO.position.z = 10;
		
		// SPS for opaque & transparent objects
		var SPSO = new SolidParticleSystem('SPSO', scene);
		var SPST = new SolidParticleSystem('SPST', scene);
		
		SPST.addShape(space, 1);
		SPST.addShape(boxInsideT, 1);
		SPST.addShape(boxOutsideT, 1);
		SPSO.addShape(boxInsideO, 1);
		SPSO.addShape(boxOutsideO, 1);
		
		// Copy positions
		SPST.particles[0].position = space.position.clone();
		SPST.particles[1].position = boxInsideT.position.clone();
		SPST.particles[2].position = boxOutsideT.position.clone();
		SPSO.particles[0].position = boxInsideO.position.clone();
		SPSO.particles[1].position = boxOutsideO.position.clone();
		
		// Copy colors
		SPST.particles[0].color = Color4.FromColor3(Color3.Purple());
		SPST.particles[1].color = Color4.FromColor3(Color3.Green());
		SPST.particles[2].color = Color4.FromColor3(Color3.Yellow());
		SPSO.particles[0].color = Color4.FromColor3(Color3.Blue());
		SPSO.particles[1].color = Color4.FromColor3(Color3.Red());
		
		SPST.particles[0].color.a = 0.5;
		SPST.particles[1].color.a = 0.7;
		SPST.particles[2].color.a = 0.9;
		
		space.dispose();
		boxInsideT.dispose();
		boxInsideO.dispose();
		boxOutsideT.dispose();
		boxOutsideO.dispose();
		
		// Build both SPS
		SPSO.buildMesh();
		SPST.buildMesh();
		
		// Set the material
		SPST.mesh.material = materialT;
		SPSO.mesh.material = materialO;
		
		// Vertex alpha needed for transparent mesh
		SPST.mesh.hasVertexAlpha = true;
		
		SPST.setParticles();
		SPSO.setParticles();
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
