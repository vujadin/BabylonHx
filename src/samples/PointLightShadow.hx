package samples;

import com.babylonhx.Scene;
import com.babylonhx.lights.PointLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Tools;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PointLightShadow {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 30, Vector3.Zero(), scene);
		camera.lowerRadiusLimit = 5;
		camera.upperRadiusLimit = 40;
		camera.minZ = 0;
		camera.attachControl();
		
		var light = new PointLight("light1", new Vector3(0, 0, 0), scene);
		light.intensity = 0.7;
		
		var lightImpostor = Mesh.CreateSphere("sphere1", 16, 1, scene);
		var lightImpostorMat = new StandardMaterial("mat", scene);
		lightImpostor.material = lightImpostorMat;
		lightImpostorMat.emissiveColor = Color3.Yellow();
		lightImpostorMat.linkEmissiveWithDiffuse = true;
		
		lightImpostor.parent = light;
		
		var knot = Mesh.CreateTorusKnot("knot", 2, 0.2, 128, 64, 4, 1, scene);
		var torus = Mesh.CreateTorus("torus", 8, 1, 32, scene, false);
		
		var torusMat = new StandardMaterial("mat", scene);
		torus.material = torusMat;
		torusMat.diffuseColor = Color3.Red();
		
		var knotMat = new StandardMaterial("mat", scene);
		knot.material = knotMat;
		knotMat.diffuseColor = Color3.White();
		
		// Container
		var container = Mesh.CreateSphere("sphere2", 16, 50, scene, false, Mesh.BACKSIDE);
		var containerMat = new StandardMaterial("mat", scene);
		container.material = containerMat;
		containerMat.diffuseTexture = new Texture("assets/img/RGBA.png", scene);
		containerMat.diffuseTexture.uScale = 10.0;
		containerMat.diffuseTexture.vScale = 10.0;
		
		// Shadow
		var shadowGenerator = new ShadowGenerator(1024, light);
		shadowGenerator.getShadowMap().renderList.push(knot);
		shadowGenerator.getShadowMap().renderList.push(torus);
		shadowGenerator.setDarkness(0.5);
		shadowGenerator.usePoissonSampling = true;
		shadowGenerator.bias = 0;
		
		container.receiveShadows = true;
		torus.receiveShadows = true;
		
		scene.registerBeforeRender(function (_, _) {
			knot.rotation.y += 0.01;
			knot.rotation.x += 0.01;
			
			torus.rotation.y += 0.05;
			torus.rotation.z += 0.03;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
