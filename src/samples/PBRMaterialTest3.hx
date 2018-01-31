package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.pbr.PBRMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialTest3 {

	public function new(scene:Scene) {
		//Create a light
		var light = new PointLight("Omni", new Vector3(60, 260, 80), scene);

		//Create an Arc Rotate Camera - aimed negative z this time
		var camera = new ArcRotateCamera("Camera", Math.PI / 2, Math.PI / 2, 110, new Vector3(0.0, 200, 0.0), scene);
		camera.attachControl();
		
		//Creation of relfelction texture
		var reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);	

		//Creation of a skybox
		var skybox = Mesh.CreateBox("skyBox", 100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skyboxMaterial.reflectionTexture = reflectionTexture;
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skybox.renderingGroupId = 0;
		
		// Mesh Creation function
		var createMesh = function (x:Float, z:Float, specular:Float, glossiness:Float) {
			//Creation of a sphere
			var sphere = Mesh.CreateSphere("Sphere_x_" + x +"_z_" + z, 10, 9.0, scene);
			sphere.position.z = z;
			sphere.position.x = x;
			sphere.position.y = 200;
			
			//Creation of a material
			var materialSphere = new PBRMaterial("Material_x_" + x +"_z_" + z, scene);
			materialSphere.reflectionTexture = reflectionTexture;
			materialSphere.albedoColor = new Color3(0.2, 0.9, 1.0);
			materialSphere.reflectivityColor = new Color3(specular, specular, specular);
			materialSphere.microSurface = glossiness;
			
			//Attach the material to the sphere
			sphere.material = materialSphere;
			
			//Change rendering group to not conflict with the skybox
			sphere.renderingGroupId = 1;
		};
		
		//Dynamically create range of 6 spheres demoing most of the 
		//glossiness impact.	
		var x = 38;
		var z = 20;
		var specular = 0.7;
		for (j in 0...6) {
			var glossiness = 0.8 + j / 25;
			createMesh(x, 20, specular, glossiness);			
			x = x - 15;
		}
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
