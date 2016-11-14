package samples;

import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhx.math.Vector3;
import com.babylonhx.lights.PointLight;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhxext.loaders.ply.PlyLoader;

import motion.Actuate;
import motion.easing.Cubic;


/**
 * ...
 * @author Krtolica Vujadin
 */
class GodRays {

	public function new(scene:Scene) {
		scene.clearColor = new Color3(0, 0, 0.2);
		
		var light = new PointLight("spot", new Vector3(0, 0, 0), scene);
		light.diffuse = Color3.Red();
		
		var camera = new ArcRotateCamera("Camera", -Math.PI / 2, 0.4, 250, Vector3.Zero(), scene);
		camera.attachControl();
		
		var objParser = new PlyLoader(scene);
		objParser.load("assets/models/", "star.ply", function(meshes:Array<Mesh>) {
			var obj = meshes[0];
			
			camera.target = obj.position;
			
			// Create the "God Rays" effect (volumetric light scattering)
			var godrays = new VolumetricLightScatteringPostProcess('godrays', 1.0, camera, null, 50, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
			godrays.exposure = .2;
			godrays.mesh.billboardMode = 1;
			cast(godrays.mesh.material, StandardMaterial).diffuseTexture = new Texture("assets/img/sun.png", scene, true, false, Texture.BILINEAR_SAMPLINGMODE);
			cast(godrays.mesh.material, StandardMaterial).diffuseTexture.hasAlpha = true;
			cast(godrays.mesh.material, StandardMaterial).diffuseTexture.level = 2;
			godrays.mesh.position = new Vector3(0, -4, -15);
			godrays.mesh.scaling = new Vector3(3, 3, 1);
			
			godrays.mesh.position.copyFrom(obj.position);
			
			scene.registerBeforeRender(function() {
				godrays.mesh.rotation.z += .01;
				obj.rotation.x += 0.01;
				obj.rotation.z += 0.01;
			});
			
			Actuate.tween(camera, 5, { radius: 15 }, false).ease(Cubic.easeOut);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});		
	}
	
}
