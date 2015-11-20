package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhxext.polygonmesh.Polygon;
import com.babylonhxext.polygonmesh.PolygonMeshBuilder;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PolygonMesh1 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 50, Vector3.Zero(), scene);
		camera.attachControl(this, true);
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
						
		var polygon = Polygon.StartingAt(-10, -10)
		.addLineTo(10, -10)
		.addLineTo(10, -5)
		.addArcTo(17, 0, 10, 5)
		.addLineTo(10, 10)
		.addLineTo(5, 10)
		.addArcTo(0, 0, -5, 10)
		.addLineTo(-10, 10)
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
