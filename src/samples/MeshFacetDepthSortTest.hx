package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Color3;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MeshFacetDepthSortTest {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0.2, 0.4, 0.8, 1.0);
		var camera = new ArcRotateCamera("cam", 0, 0, 0, Vector3.Zero(), scene);    
		camera.attachControl();
		camera.setPosition(new Vector3(0, 0, -10));
		
		var light = new PointLight("pl", camera.position, scene);
		light.intensity = 1.0;
		
		var mat = new StandardMaterial("m", scene);
		mat.diffuseColor = Color3.Yellow();
		mat.wireframe = true;
		mat.alpha = 0.6;
		
		var mesh = MeshBuilder.CreateTorusKnot("mesh", { updatable: false }, scene);
		mesh.material = mat;
		mesh.mustDepthSortFacets = true;
		mesh.position.x = -4.0;
		
		var mesh2 = MeshBuilder.CreateTorusKnot("mesh2", { }, scene);
		mesh2.material = mat;
		mesh2.position.x = 4.0;
		
		var mesh3 = MeshBuilder.CreateCapsule("meshCapsule", scene);
		
		var mat2 = new StandardMaterial("m2", scene);
		//mat2.wireframe = true;
		mesh3.material = mat2;
	   
		scene.registerBeforeRender(function(_, _) {
			mesh.rotation.y += 0.01;
			mesh.updateFacetData();
			
			mesh2.rotation.y += 0.01;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
