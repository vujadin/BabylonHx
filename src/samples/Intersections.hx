package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Intersections {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 1, 0.8, 70, new Vector3(5, 0, 0), scene);
		camera.attachControl(this, true);
		
		// Material
		var matPlan = new StandardMaterial("matPlan1", scene);
		matPlan.backFaceCulling = false;
		matPlan.emissiveColor = new Color3(0.2, 1, 0.2);
		
		var matBB = new StandardMaterial("matBB", scene);
		matBB.emissiveColor = new Color3(1, 1, 1);
		matBB.wireframe = true;
		
		// Intersection point
		var pointToIntersect = new Vector3(-30, 0, 0);
		var origin = Mesh.CreateSphere("origin", 4, 0.3, scene);
		origin.position = pointToIntersect;
		origin.material = matPlan;
		
		// Create two planes
		var plan1 = Mesh.CreatePlane("plane1", 20, scene);
		plan1.position = new Vector3(13, 0, 0);
		plan1.rotation.x = -Math.PI / 4;
		plan1.material = matPlan;
		
		var plan2 = Mesh.CreatePlane("plane2", 20, scene);
		plan2.position = new Vector3(-13, 0, 0);
		plan2.rotation.x = -Math.PI / 4;
		plan2.material = matPlan;
		
		// AABB - Axis aligned bounding box
		var planAABB = Mesh.CreateBox("AABB", 20, scene);
		planAABB.material = matBB;
		planAABB.position = new Vector3(13, 0, 0);
		planAABB.scaling = new Vector3(1, Math.cos(Math.PI / 4), Math.cos(Math.PI / 4));
		
		// OBB - Object boundind box
		var planOBB = Mesh.CreateBox("OBB", 20, scene);
		planOBB.scaling = new Vector3(1, 1, 0.05);
		planOBB.parent = plan2;
		planOBB.material = matBB;
		
		// Balloons
		var balloon1 = Mesh.CreateSphere("balloon1", 10, 2.0, scene);
		var balloon2 = Mesh.CreateSphere("balloon2", 10, 2.0, scene);
		var balloon3 = Mesh.CreateSphere("balloon3", 10, 2.0, scene);
		balloon1.material = new StandardMaterial("matBallon", scene);
		balloon2.material = new StandardMaterial("matBallon", scene);
		balloon3.material = new StandardMaterial("matBallon", scene);
		
		balloon1.position = new Vector3(6, 5, 0);
		balloon2.position = new Vector3(-6, 5, 0);
		balloon3.position = new Vector3( -30, 5, 0);
		
		//Animation
		var alpha = Math.PI;
		scene.registerBeforeRender(function () {
			
			//Balloon 1 intersection -- Precise = false
			if (balloon1.intersectsMesh(plan1, false)) {
				cast(balloon1.material, StandardMaterial).emissiveColor = new Color3(1, 0, 0);
			} else {
				cast(balloon1.material, StandardMaterial).emissiveColor = new Color3(1, 1, 1);
			}
			
			//Balloon 2 intersection -- Precise = true
			if (balloon2.intersectsMesh(plan2, true)) {
				cast(balloon2.material, StandardMaterial).emissiveColor = new Color3(1, 0, 0);
			} else {
				cast(balloon2.material, StandardMaterial).emissiveColor = new Color3(1, 1, 1);
			}
			
			//balloon 3 intersection on single point
			if (balloon3.intersectsPoint(pointToIntersect)) {
				cast(balloon3.material, StandardMaterial).emissiveColor = new Color3(1, 0, 0);
			} else {
				cast(balloon3.material, StandardMaterial).emissiveColor = new Color3(1, 1, 1);
			}
			
			alpha += 0.01;
			balloon1.position.y += Math.cos(alpha) / 10;
			balloon2.position.y = balloon1.position.y;
			balloon3.position.y = balloon1.position.y;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
