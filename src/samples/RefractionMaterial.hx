package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.probes.ReflectionProbe;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.procedurals.standard.Marble;
import com.babylonhx.tools.EventState;
import com.babylonhx.utils.Image;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.Scene;
import com.babylonhx.layer.HighlightLayer;
import com.babylonhx.loading.ctm.CTMFile;
import com.babylonhx.loading.ctm.CTMFileLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RefractionMaterial {

	public function new(scene:Scene) {
		var camera:ArcRotateCamera = new ArcRotateCamera("camera1", -Math.PI / 2.4, Math.PI / 2.2, 20, Vector3.Zero(), scene);	
		camera.position.y = 3;
		camera.wheelPrecision = 0.02;
		camera.attachControl();		
		camera.upperBetaLimit = Math.PI / 2;
		camera.lowerRadiusLimit = 4;
		camera.lowerRadiusLimit = 20;
		camera.upperRadiusLimit = 26;
		
		var hemiLight = new HemisphericLight('hemi', new Vector3(0, 1, 0), scene);
		hemiLight.intensity = 0.2;
		
		var light0 = new PointLight("Omni0", new Vector3(0, 7, 0), scene);
		var light1 = new PointLight("Omni1", new Vector3(0, -7, 0), scene);
		var light2 = new PointLight("Omni2", new Vector3(7, 0, 0), scene);
		
		light0.diffuse = Color3.Yellow();
		light0.specular = Color3.Yellow();
		
		light1.diffuse = Color3.Green();
		light1.specular = Color3.Green();
		
		light2.diffuse = Color3.Purple();
		light2.specular = Color3.Purple();
		
		var yellowSphere = Mesh.CreateSphere("yellowSphere", 8, 2, scene);
		var yellowMaterial = new StandardMaterial("yellowMaterial", scene);
		yellowMaterial.emissiveColor = Color3.Yellow();
		yellowMaterial.diffuseColor = Color3.Black();
		yellowMaterial.specularColor = new Color3(0, 0, 0);
		yellowSphere.material = yellowMaterial;
		
		var hl1 = new HighlightLayer("hl1", scene);
		hl1.addMesh(yellowSphere, Color3.Yellow());
		
		var greenSphere = Mesh.CreateSphere("greenSphere", 8, 2, scene);
		var greenMaterial = new StandardMaterial("greenMaterial", scene);
		greenMaterial.emissiveColor = Color3.Green();
		greenMaterial.diffuseColor = Color3.Black();
		greenMaterial.specularColor = new Color3(0, 0, 0);
		greenSphere.material = greenMaterial;
		
		var hl1 = new HighlightLayer("hl2", scene);
		hl1.addMesh(greenSphere, Color3.Green());
		
		var redSphere = Mesh.CreateSphere("redSphere", 8, 2, scene);
		var redMaterial = new StandardMaterial("redMaterial", scene);
		redMaterial.emissiveColor = Color3.Purple();
		redMaterial.diffuseColor = Color3.Black();
		redMaterial.specularColor = new Color3(0, 0, 0);
		redSphere.material = redMaterial;
		
		var hl1 = new HighlightLayer("hl3", scene);
		hl1.addMesh(redSphere, Color3.Purple());
		
		// Ground
		var ground = Mesh.CreateBox("Mirror", 1.0, scene);
		ground.scaling = new Vector3(100.0, 0.01, 100.0);
		ground.material = new StandardMaterial("ground", scene);
		cast (ground.material, StandardMaterial).diffuseTexture = new Texture("assets/img/tiles.jpg", scene);
		cast (ground.material, StandardMaterial).bumpTexture = new Texture("assets/img/tiles_bump.jpg", scene);
		untyped cast (ground.material, StandardMaterial).bumpTexture.uScale = 15;
		untyped cast (ground.material, StandardMaterial).bumpTexture.vScale = 15;
		untyped cast (ground.material, StandardMaterial).diffuseTexture.uScale = 15;
		untyped cast (ground.material, StandardMaterial).diffuseTexture.vScale = 15;
		ground.position = new Vector3(0, -2, 0);
		
		var boxMat = new StandardMaterial('boxmat', scene);
		boxMat.diffuseTexture = new Texture('assets/img/Stonebigknot.jpg', scene);
		boxMat.bumpTexture = new Texture('assets/img/Stonebigknot_bump.jpg', scene);
		boxMat.diffuseColor = Color3.White();
		var boxes:Array<Mesh> = [];
		for (i in 0...4) {
			var box = Mesh.CreateBox('box' + i, 3, scene);
			box.material = boxMat;
			box.position = (switch (i) {
				case 0:
					new Vector3(10, -0.5, 10);
					
				case 1: 
					new Vector3( -10, -0.5, 10);
					
				case 2: 
					new Vector3(-10, -0.5, -10);
					
				case 3:
					new Vector3(10, -0.5, -10);
					
				default:
					Vector3.Zero();
			});
			box.rotation.y = Math.random();
			boxes.push(box);
		}
		
		// Main material	
		var mainMaterial = new StandardMaterial("main", scene);
		
		var probe = new ReflectionProbe("main", 1024, scene);
		probe.renderList.push(yellowSphere);
		probe.renderList.push(greenSphere);
		probe.renderList.push(redSphere);
		probe.renderList.push(ground);
		for (b in boxes) {
			probe.renderList.push(b);
		}
		mainMaterial.diffuseColor = new Color3(1, 0.5, 0.5);
		mainMaterial.refractionTexture = probe.cubeTexture;
		mainMaterial.refractionFresnelParameters = new FresnelParameters();
		mainMaterial.refractionFresnelParameters.bias = 0.5;
		mainMaterial.refractionFresnelParameters.power = 16;
		mainMaterial.refractionFresnelParameters.leftColor = Color3.Black();
		mainMaterial.refractionFresnelParameters.rightColor = Color3.White();
		mainMaterial.refractionFresnelParameters.isEnabled = false;
		mainMaterial.indexOfRefraction = 1.05;
		
		CTMFileLoader.load("assets/models/lady_with_primroses.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			for (m in meshes) {
				probe.renderList.push(m);
				m.scaling.set(0.08, 0.08, 0.08);
				m.material = mainMaterial;
				m.position.y = -2;
			}
		});
		
		// Fog
		scene.fogMode = Scene.FOGMODE_LINEAR;
		scene.fogColor = Color3.Black();
		scene.clearColor = new Color4(0, 0, 0, 1);
		scene.fogStart = 25.0;
		scene.fogEnd = 50.0;
		
		// Animations
		var alpha = 0.0;
		var beta = 0.0;
		var gamma = 0.0;
		var theta = 0.0;
		scene.registerBeforeRender(function (_, _) {
			light0.position.set(-7 * Math.sin(alpha), Math.cos(theta), 7 * Math.cos(alpha));
			light1.position.set(7 * Math.sin(alpha), Math.cos(gamma), -7 * Math.cos(alpha));
			light2.position.set(-7 * Math.cos(alpha), Math.cos(beta), 7 * Math.sin(alpha));
			
			yellowSphere.position = light0.position;
			greenSphere.position = light1.position;
			redSphere.position = light2.position;
			
			alpha += 0.01;
			beta += 0.1;
			gamma += 0.05;
			theta += 0.08;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}