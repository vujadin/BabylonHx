package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CellShading {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, Math.PI / 4, 40, Vector3.Zero(), scene);
		var light = new PointLight("Omni", new Vector3(20, 100, 2), scene);
		var sphere = Mesh.CreateSphere("Sphere0", 32, 3, scene);
		var cylinder = Mesh.CreateCylinder("Sphere1", 5, 3, 2, 32, 1, scene);
		var torus = Mesh.CreateTorus("Sphere2", 3, 1, 32, scene);
		
		var cellShadingMaterial = new ShaderMaterial("cellShading", scene, "cellShading",
		{
			uniforms: ["world", "viewProjection"],
			samplers: ["textureSampler"]
		});
		cellShadingMaterial.setTexture("textureSampler", new Texture("assets/img/grass.jpg", scene))
						   .setVector3("vLightPosition", light.position)
						   .setFloats("ToonThresholds", [0.95, 0.5, 0.2, 0.03])
						   .setFloats("ToonBrightnessLevels", [1.0, 0.8, 0.6, 0.35, 0.01])
						   .setColor3("vLightColor", light.diffuse);
		
		sphere.material = cellShadingMaterial;
		sphere.position = new Vector3(-10, 0, 0);
		cylinder.material = cellShadingMaterial;
		torus.material = cellShadingMaterial;
		torus.position = new Vector3(10, 0, 0);
		
		// Animations
		var alpha = 0.0;
		scene.registerBeforeRender(function () {
			sphere.rotation.y = alpha;
			sphere.rotation.x = alpha;
			cylinder.rotation.y = alpha;
			cylinder.rotation.x = alpha;
			torus.rotation.y = alpha;
			torus.rotation.x = alpha;
			
			alpha += 0.05;
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}