package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.layer.Layer;
import com.babylonhx.layer.HighlightLayer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.InstancedMesh;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class HighlightLayerInstances {

	public function new(scene:Scene) {
 		var camera = new ArcRotateCamera("cam", 6.0, 2.50, 110, Vector3.Zero(), scene);
		camera.attachControl();
		
		// This creates a light, aiming 0,1,0 - to the sky (non-mesh)
		var light = new PointLight("light1", new Vector3(0, 100, 0), scene);
		light.position = camera.position;
		
		//Creation of relfelction texture
		var reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);	
		
		//Creation of a skybox
		var skybox = Mesh.CreateBox("skyBox", 500, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		skyboxMaterial.reflectionTexture = reflectionTexture;
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.disableLighting = true;
		skybox.renderingGroupId = 0;
		
		var material = new StandardMaterial("m", scene);
		material.reflectionTexture = reflectionTexture;
		material.diffuseColor = new Color3(0, 0, 0);
		material.emissiveColor = new Color3(0.5, 0.5, 0.5);
		material.alpha = 0.2;
		material.specularPower = 64;
		material.backFaceCulling = true;
		
		// Fresnel
		material.reflectionFresnelParameters = new FresnelParameters();
		material.reflectionFresnelParameters.bias = 0.1;
		
		material.emissiveFresnelParameters = new FresnelParameters();
		material.emissiveFresnelParameters.bias = 0.6;
		material.emissiveFresnelParameters.power = 4;
		
		material.opacityFresnelParameters = new FresnelParameters();
		material.opacityFresnelParameters.leftColor = Color3.White();
		material.opacityFresnelParameters.rightColor = Color3.Black();
		
		var rotator:Array<InstancedMesh> = [];
		
		var hl = new HighlightLayer("hl", scene);
		var mesh = Mesh.CreateBox("b", 1, scene, false, Mesh.DEFAULTSIDE);
		mesh.setEnabled(false);
		hl.addMesh(mesh, Color3.Red());
		
		for (i in 0...100) {
			var im = mesh.createInstance("c");
			rotator[i] = im;
			
			rotator[i].scaling = new Vector3(15.0, 0.95, 15.0);
			rotator[i].position.y = 50 - i;
			
			rotator[i].material = material;
		}
		
		var t = 0.0;
		scene.registerBeforeRender(function(_, _) {			
			for (i in 0...rotator.length) {
				rotator[i].rotation.y = 25.0 * Math.cos((t - i) / 50);
				rotator[i].scaling.x = 15 * Math.cos((t - i) / 50);
				rotator[i].scaling.z = 15 * Math.sin((t - i) / 50);
				
				rotator[i].position.x = 12 * Math.cos((t * 3 - i) / 10) * Math.sin((t - i) / 10);
				rotator[i].position.z = 12 * Math.sin((t + 1 - i) / 10) - 12 * Math.cos((t * 3 - i) / 10);				
			}
			
			t = Tools.Now() * 0.005;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
		});
	}
	
}
