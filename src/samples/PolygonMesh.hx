package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.polygonmesh.Polygon;
import com.babylonhx.mesh.polygonmesh.PolygonMeshBuilder;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PolygonMesh {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 50, Vector3.Zero(), scene);
		camera.attachControl(this, true);
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 1000.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		skybox.infiniteDistance = true;
				
		var polygon = Polygon.StartingAt(-10, -10)
		.addLineTo(10, -10)
		.addLineTo(10, -5)
		.addArcTo(17, 0, 10, 5)
		.addLineTo(10, 10)
		.addLineTo(5, 10)
		.addArcTo(0, 0, -5, 10)
		.addLineTo(-10, 10)
		.addArcTo(-9, 0, -10, -10)
		.close();

		var ground = new PolygonMeshBuilder("ground1", polygon, scene).build();
		ground.material = scene.defaultMaterial;
		ground.material.backFaceCulling = false;
		camera.target = ground.position;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}