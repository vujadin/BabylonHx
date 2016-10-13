package samples;

import com.babylonhx.Engine;
import com.babylonhx.layer.Layer;
import com.babylonhx.lights.PointLight;
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
import com.babylonhxext.loaders.obj.ObjLoader;


/**
 * ...
 * @author Krtolica Vujadin
 */
class Decals {

	public function new(scene:Scene) {
		
		//light
		var light = new PointLight("Omni0", new Vector3(-100, 0, 10), scene);
						
		var camera = new ArcRotateCamera("Camera", 0, 1.2, 5, Vector3.Zero(), scene);
		camera.attachControl(this, false);
		camera.lowerBetaLimit = 0.5;
		camera.upperBetaLimit = (Math.PI / 2) * 0.9;
		camera.upperRadiusLimit = 7;
		camera.lowerRadiusLimit = 2;
		
		new Layer("background", "assets/img/graygrad.jpg", scene, true);
		
		#if mobile
		camera.radius = 3.5;
		#end
						
		var objParser = new ObjLoader(scene);
		objParser.load("assets/models/", "zombie.obj", function(meshes:Array<Mesh>) {
			var zombie = meshes[0];
			zombie.rotation.y = Math.PI / 2;
			
			var material = new StandardMaterial('zombie', scene);
			material.diffuseColor = Color3.FromInt(0xb5d3ef);
			material.specularColor = new Color3(0.07, 0.07, 0.07);
			material.specularPower = 100;
			
			zombie.material = material;
						
			camera.target = zombie.position;
			
			var decalMaterial = new StandardMaterial("decalMat", scene);
			cast(decalMaterial, StandardMaterial).diffuseTexture = new Texture("assets/img/bhole.png", scene);
			cast(decalMaterial, StandardMaterial).diffuseTexture.hasAlpha = true;
			decalMaterial.zOffset = -1;
			
			var onPointerDown = function (x:Int, y:Int, button:Int) {			
				// check if we are under a mesh
				var pickInfo = scene.pick(scene.pointerX, scene.pointerY, function (mesh) { return mesh == zombie; });
				if (pickInfo.hit) {
					var decalSize = new Vector3(0.03, 0.03, 0.03);
					
					var newDecal = Mesh.CreateDecal("decal", zombie, pickInfo.pickedPoint, pickInfo.getNormal(true), decalSize);
					newDecal.material = decalMaterial;
				}
			}

			scene.getEngine().mouseDown.push(onPointerDown);
				
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});	
	}
	
}
