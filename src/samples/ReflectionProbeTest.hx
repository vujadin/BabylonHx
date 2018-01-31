package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.MirrorTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.probes.ReflectionProbe;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ReflectionProbeTest {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1", 0, 0, 10, Vector3.Zero(), scene);		
		camera.setPosition(new Vector3(0, 5, -10));
		camera.upperBetaLimit = Math.PI / 2;
		camera.lowerRadiusLimit = 4;
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.intensity = 0.7;
		
		var knot = Mesh.CreateTorusKnot("knot", 1, 0.4, 128, 64, 2, 3, scene);
		
		var yellowSphere = Mesh.CreateSphere("yellowSphere", 16, 1.5, scene);
		yellowSphere.setPivotMatrix(Matrix.Translation(3, 0, 0));
		
		var blueSphere = Mesh.CreateSphere("blueSphere", 16, 1.5, scene);
		blueSphere.setPivotMatrix(Matrix.Translation( -1, 3, 0));
		
		var greenSphere = Mesh.CreateSphere("greenSphere", 16, 1.5, scene);
		greenSphere.setPivotMatrix(Matrix.Translation(0, 0, 3));
		
		var generateSatelliteMaterial = function (root:Mesh, color:Color3, others:Array<Mesh>) {
			var material = new StandardMaterial("satelliteMat" + root.name, scene);
			material.diffuseColor = color;
			var probe = new ReflectionProbe("satelliteProbe" + root.name, 512, scene);
			for (index in 0...others.length) {
				probe.renderList.push(others[index]);
			}
			
			material.reflectionTexture = probe.cubeTexture;
			
			material.reflectionFresnelParameters = new FresnelParameters();
			material.reflectionFresnelParameters.bias = 0.02;
			
			root.material = material;
			probe.attachToMesh(root);
		};
		
		// Mirror
		var mirror = Mesh.CreateBox("Mirror", 1.0, scene);
		mirror.scaling = new Vector3(100.0, 0.01, 100.0);
		var mat = new StandardMaterial("mirror", scene);
		mat.diffuseTexture = new Texture("assets/img/amiga.jpg", scene);
		mat.diffuseTexture.uScale = 10;
		mat.diffuseTexture.vScale = 10;
		mat.reflectionTexture = new MirrorTexture("mirror", 1024, scene, true);
		cast (mat.reflectionTexture, MirrorTexture).mirrorPlane = new Plane(0, -1.0, 0, -2.0);
		cast (mat.reflectionTexture, MirrorTexture).renderList = [greenSphere, yellowSphere, blueSphere, knot];
		mat.reflectionTexture.level = 0.5;
		mirror.material = mat;
		mirror.position = new Vector3(0, -2, 0);
		
		// Main material	
		var mainMaterial = new StandardMaterial("main", scene);
		knot.material = mainMaterial;
		
		var probe = new ReflectionProbe("main", 512, scene);
		probe.renderList.push(yellowSphere);
		probe.renderList.push(greenSphere);
		probe.renderList.push(blueSphere);
		probe.renderList.push(mirror);
		mainMaterial.diffuseColor = new Color3(1, 0.5, 0.5);
		mainMaterial.reflectionTexture = probe.cubeTexture;
		mainMaterial.reflectionFresnelParameters = new FresnelParameters();
		mainMaterial.reflectionFresnelParameters.bias = 0.02;
		
		// Satellite
		generateSatelliteMaterial(yellowSphere, Color3.Yellow(), [greenSphere, blueSphere, knot, mirror]);
		generateSatelliteMaterial(greenSphere, Color3.Green(), [yellowSphere, blueSphere, knot, mirror]);
		generateSatelliteMaterial(blueSphere, Color3.Blue(), [greenSphere, yellowSphere, knot, mirror]);
		
		yellowSphere.material.alpha = 0.8;
		
		// Fog
		scene.fogMode = Scene.FOGMODE_LINEAR;
		scene.fogColor.copyFromColor4(scene.clearColor);
		scene.fogStart = 20.0;
		scene.fogEnd = 50.0;
		
		// Animations
		scene.registerBeforeRender(function(_, _) {
			yellowSphere.rotation.y += 0.01;
			greenSphere.rotation.y += 0.01;
			blueSphere.rotation.y += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
