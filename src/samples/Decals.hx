package samples;

import com.babylonhx.layer.Layer;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.loading.obj.ObjLoader;


/**
 * ...
 * @author Krtolica Vujadin
 */
class Decals {

	public function new(scene:Scene) {
		
		var light = new HemisphericLight("Hemi", new Vector3(0, 1, 0), scene);

		var camera = new ArcRotateCamera("Camera", -1.85, 1.2, 200, Vector3.Zero(), scene);
		camera.attachControl();
		
		#if mobile
		camera.radius = 3.5;
		#end
		
		//SceneLoader.ImportMesh("Shcroendiger'scat", "assets/models/", "SSAOcat.babylon", scene, function (meshes, _, _) {
			//var zombie:AbstractMesh = meshes[0];
			var zombie = Mesh.CreateTorusKnot("knot", 15, 6.5, 128, 64, 2, 3, scene);
			zombie.rotation.y = Math.PI / 2;
			
			var material = new StandardMaterial('zombie', scene);
			material.diffuseColor = Color3.FromInt(0xb5d3ef);
			material.specularColor = new Color3(0.07, 0.07, 0.07);
			material.specularPower = 100;
			
			zombie.material = material;
			
			camera.target = zombie.position;
			
			var decalMaterial = new StandardMaterial("decalMat", scene);
			decalMaterial.diffuseTexture = new Texture("assets/img/bhole.png", scene);
			decalMaterial.diffuseTexture.hasAlpha = true;
			decalMaterial.specularColor = Color3.Black();
			decalMaterial.zOffset = -2;
			
			var onPointerDown = function (_) {			
				// check if we are under a mesh
				var pickInfo = scene.pick(scene.pointerX, scene.pointerY, function (mesh) { return mesh == zombie; });
				if (pickInfo.hit) {
					var decalSize = new Vector3(3, 3, 3);
					
					var newDecal = Mesh.CreateDecal("decal", zombie, pickInfo.pickedPoint, pickInfo.getNormal(true), decalSize);
					newDecal.material = decalMaterial;
				}
			};
			
			scene.getEngine().mouseDown.push(onPointerDown);
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		//});	
	}
	
}
