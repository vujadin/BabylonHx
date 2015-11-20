package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.lights.shadows.ShadowGenerator;

/**
 * ...
 * @author Krtolica Vujadin
 */
class AdvancedShadows {

	public function new(scene:Scene) {
		var camera = new FreeCamera("Camera", new Vector3(20, 30, -100), scene);
		camera.attachControl();

		// Ground
		var ground01 = Mesh.CreateGround("Spotlight Hard Shadows", 24, 60, 1, scene);
		var ground02 = Mesh.CreateGround("Spotlight Poisson Sampling", 24, 60, 1, scene);
		var ground03 = Mesh.CreateGround("Spotlight VSM", 24, 60, 1, scene);
		var ground04 = Mesh.CreateGround("Spotlight Blur VSM", 24, 60, 1, scene);

		var ground11 = Mesh.CreateGround("Directional Hard Shadows", 24, 60, 1, scene);
		var ground12 = Mesh.CreateGround("Directional Poisson Sampling", 24, 60, 1, scene);
		var ground13 = Mesh.CreateGround("Directional VSM", 24, 60, 1, scene);
		var ground14 = Mesh.CreateGround("Directional Blur VSM", 24, 60, 1, scene);

		var groundMaterial = new StandardMaterial("ground", scene);
		groundMaterial.diffuseTexture = new Texture("assets/img/grass.jpg", scene);
		groundMaterial.specularColor = new Color3(0, 0, 0);
		groundMaterial.emissiveColor = new Color3(0.2, 0.2, 0.2);
		
		ground01.material = groundMaterial;
		ground01.receiveShadows = true;
		ground01.position.x = -30;
		ground02.material = groundMaterial;
		ground02.receiveShadows = true;
		ground02.position.x = 0;
		ground03.material = groundMaterial;
		ground03.receiveShadows = true;
		ground03.position.x = 30;
		ground04.material = groundMaterial;
		ground04.receiveShadows = true;
		ground04.position.x = 60;

		ground11.material = groundMaterial;
		ground11.receiveShadows = true;
		ground11.position.z = 100;
		ground11.position.x = -30;
		ground12.material = groundMaterial;
		ground12.receiveShadows = true;
		ground12.position.z = 100;
		ground13.material = groundMaterial;
		ground13.receiveShadows = true;
		ground13.position.z = 100;
		ground13.position.x = 30;
		ground14.material = groundMaterial;
		ground14.receiveShadows = true;
		ground14.position.z = 100;
		ground14.position.x = 60;


		// --------- SPOTS -------------
		var light00 = new SpotLight("*spot00", new Vector3(-30, 20, -10), new Vector3(0, -1, 0.3), 1.2, 1.5, scene);
		var light01 = new SpotLight("*spot01", new Vector3(0, 20, -10), new Vector3(0, -1, 0.3), 1.2, 1.5, scene);
		var light02 = new SpotLight("*spot02", new Vector3(30, 20, -10), new Vector3(0, -1, 0.3), 1.2, 1.5, scene);
		var light03 = new SpotLight("*spot03", new Vector3(60, 20, -10), new Vector3(0, -1, 0.3), 1.2, 1.5, scene);

		// Boxes
		var box00 = Mesh.CreateBox("*box00", 5, scene);
		box00.position = new Vector3(-30, 5, 0);
		var box01 = Mesh.CreateBox("*box01", 5, scene);
		box01.position = new Vector3(0, 5, 0);
		var box02 = Mesh.CreateBox("*box02", 5, scene);
		box02.position = new Vector3(30, 5, 0);
		var box03 = Mesh.CreateBox("*box03", 5, scene);
		box03.position = new Vector3(60, 5, 0);

		var boxMaterial = new StandardMaterial("mat", scene);
		boxMaterial.diffuseColor = new Color3(1.0, 0, 0);
		boxMaterial.specularColor = new Color3(0.5, 0, 0);
		box00.material = boxMaterial;
		box01.material = boxMaterial;
		box02.material = boxMaterial;
		box03.material = boxMaterial;

		// Inclusions
		light00.includedOnlyMeshes.push(box00);
		light00.includedOnlyMeshes.push(ground01);

		light01.includedOnlyMeshes.push(box01);
		light01.includedOnlyMeshes.push(ground02);

		light02.includedOnlyMeshes.push(box02);
		light02.includedOnlyMeshes.push(ground03);

		light03.includedOnlyMeshes.push(box03);
		light03.includedOnlyMeshes.push(ground04);

		// Shadows
		var shadowGenerator00 = new ShadowGenerator(512, light00);
		shadowGenerator00.getShadowMap().renderList.push(box00);

		var shadowGenerator01 = new ShadowGenerator(512, light01);
		shadowGenerator01.getShadowMap().renderList.push(box01);
		shadowGenerator01.usePoissonSampling = true;

		var shadowGenerator02 = new ShadowGenerator(512, light02);
		shadowGenerator02.getShadowMap().renderList.push(box02);
		shadowGenerator02.useVarianceShadowMap = true;

		var shadowGenerator03 = new ShadowGenerator(512, light03);
		shadowGenerator03.getShadowMap().renderList.push(box03);
		shadowGenerator03.useBlurVarianceShadowMap = true;
		shadowGenerator03.blurBoxOffset = 2.0;

		// --------- DIRECTIONALS -------------
		var light04 = new DirectionalLight("*dir00", new Vector3(0, -0.6, 0.3), scene);
		var light05 = new DirectionalLight("*dir01", new Vector3(0, -0.6, 0.3), scene);
		var light06 = new DirectionalLight("*dir02", new Vector3(0, -0.6, 0.3), scene);
		var light07 = new DirectionalLight("*dir03", new Vector3(0, -0.6, 0.3), scene);
		light04.position = new Vector3(-30, 50, 60);
		light05.position = new Vector3(0, 50, 60);
		light06.position = new Vector3(30, 50, 60);
		light07.position = new Vector3(60, 50, 60);

		// Boxes
		var box04 = Mesh.CreateBox("*box04", 5, scene);
		box04.position = new Vector3(-30, 5, 100);
		var box05 = Mesh.CreateBox("*box05", 5, scene);
		box05.position = new Vector3(0, 5, 100);
		var box06 = Mesh.CreateBox("*box06", 5, scene);
		box06.position = new Vector3(30, 5, 100);
		var box07 = Mesh.CreateBox("*box07", 5, scene);
		box07.position = new Vector3(60, 5, 100);

		box04.material = boxMaterial;
		box05.material = boxMaterial;
		box06.material = boxMaterial;
		box07.material = boxMaterial;

		// Inclusions
		light04.includedOnlyMeshes.push(box04);
		light04.includedOnlyMeshes.push(ground11);

		light05.includedOnlyMeshes.push(box05);
		light05.includedOnlyMeshes.push(ground12);

		light06.includedOnlyMeshes.push(box06);
		light06.includedOnlyMeshes.push(ground13);

		light07.includedOnlyMeshes.push(box07);
		light07.includedOnlyMeshes.push(ground14);

		// Shadows
		var shadowGenerator04 = new ShadowGenerator(512, light04);
		shadowGenerator04.getShadowMap().renderList.push(box04);

		var shadowGenerator05 = new ShadowGenerator(512, light05);
		shadowGenerator05.getShadowMap().renderList.push(box05);
		shadowGenerator05.usePoissonSampling = true;

		var shadowGenerator06 = new ShadowGenerator(512, light06);
		shadowGenerator06.getShadowMap().renderList.push(box06);
		shadowGenerator06.useVarianceShadowMap = true;

		var shadowGenerator07 = new ShadowGenerator(512, light07);
		shadowGenerator07.getShadowMap().renderList.push(box07);
		shadowGenerator07.useBlurVarianceShadowMap = true;
		   
		// Animations
		scene.registerBeforeRender(function () {
			box00.rotation.x += 0.01;
			box00.rotation.z += 0.02;

			box01.rotation.x += 0.01;
			box01.rotation.z += 0.02;

			box02.rotation.x += 0.01;
			box02.rotation.z += 0.02;

			box03.rotation.x += 0.01;
			box03.rotation.z += 0.02;

			box04.rotation.x += 0.01;
			box04.rotation.z += 0.02;

			box05.rotation.x += 0.01;
			box05.rotation.z += 0.02;

			box06.rotation.x += 0.01;
			box06.rotation.z += 0.02;

			box07.rotation.x += 0.01;
			box07.rotation.z += 0.02;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });

	}
	
}