package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhxext.loaders.obj.ObjLoader;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.mesh.Mesh;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadObjFile {
	
	static var models = ["Brown_Cliff_01"];
	//static var models = ["Brown_Cliff_01", "Brown_Cliff_Bottom_01", "Brown_Cliff_Bottom_Corner_01", "Brown_Cliff_Bottom_Corner_Green_Top_01", "Brown_Cliff_Bottom_Green_Top_01", "Brown_Cliff_Corner_01", "Brown_Cliff_Corner_Green_Top_01", "Brown_Cliff_End_01", "Brown_Cliff_End_Green_Top_01", "Brown_Cliff_Green_Top_01", "Brown_Cliff_Top_01", "Brown_Cliff_Top_Corner_01", "Brown_Waterfall_01", "Brown_Waterfall_Top_01", "Campfire_01", "Fallen_Trunk_01", "Flower_Red_01", "Flower_Tall_Red_01"];

	public function new(scene:Scene) {	
								
		var objLoader = new ObjLoader(scene);
		
		objLoader.load("assets/models/castle/", "castle.obj", function(meshes:Array<Mesh>) {
			var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
			camera.attachControl();
			
			var light = new HemisphericLight("hemi", new Vector3(0, -1, 0), scene);
			light.intensity = 3;
			
			// Skybox
			//var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
			//var skyboxMaterial = new StandardMaterial("skyBox", scene);
			//skyboxMaterial.backFaceCulling = false;
			//skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/Sky_FantasySky_Fire_Cam", scene);
			//skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
			//skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
			//skyboxMaterial.specularColor = new Color3(0, 0, 0);
			//skybox.material = skyboxMaterial;
			//skybox.infiniteDistance = true;
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}
