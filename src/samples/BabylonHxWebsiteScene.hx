package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.procedurals.standard.WoodProceduralTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;
import com.babylonhx.Scene;
import com.babylonhx.Engine;
import com.babylonhxext.loaders.obj.ObjLoader;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.bones.Skeleton;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.layer.Layer;

import motion.Actuate;
import motion.easing.Quad;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BabylonHxWebsiteScene {
	
	var sun:Mesh;

	public function new(scene:Scene) {
		var light = new PointLight("Omni0", new Vector3( -2, -2, 0), scene);
		light.intensity = 0.5;
				
		var camera = new ArcRotateCamera("Camera", 3.38, 1.55, 20, Vector3.Zero(), scene);
						
		var objParser = new ObjLoader(scene);
		objParser.load("assets/models/", "Planisferio.obj", function(meshes:Array<Mesh>) {
			meshes[0].rotation.x = Math.PI / 2;
			meshes[0].rotation.z = -Math.PI / 2.5;
			
			light.excludedMeshes = cast meshes;
			
			camera.target = meshes[0].position;
			
			var material = new StandardMaterial("smat", scene);
			material.diffuseColor = Color3.Red();
			material.alpha = 0.9;
			material.specularPower = 0;
						
			material.emissiveFresnelParameters = new FresnelParameters();
			material.emissiveFresnelParameters.bias = 0.8;
			material.emissiveFresnelParameters.leftColor = Color3.Black();
			material.emissiveFresnelParameters.rightColor = Color3.Black();
			
			material.opacityFresnelParameters = new FresnelParameters();
			material.opacityFresnelParameters.power = 8;
			material.opacityFresnelParameters.leftColor = Color3.White();
			material.opacityFresnelParameters.rightColor = Color3.Black();
					
			meshes[0].material = material;
			
			var godrays = new VolumetricLightScatteringPostProcess('godrays', 1.0, camera, null, 50, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
			godrays.exposure = .1;
			sun = godrays.mesh;
			sun.billboardMode = 1;
			cast(sun.material, StandardMaterial).diffuseTexture = new Texture("assets/img/haxe-logo.png", scene, true, false, Texture.BILINEAR_SAMPLINGMODE);
			cast(sun.material, StandardMaterial).diffuseTexture.hasAlpha = true;
			cast(sun.material, StandardMaterial).diffuseTexture.level = 1;			
			sun.scaling = new Vector3(5, 5, 1);
			sun.position = meshes[0].position.clone();
			sun.position.x = 5;
			sun.position.z += 10;
			sun.position.y += 5;
									
			var alpha = 0.0;
			var cnt:Int = 0;
			var angle:Float = 0;
			scene.registerBeforeRender(function() {
				angle = Math.sin(alpha) / 10;
				sun.rotation.z += .004;
				meshes[0].rotation.x = Math.PI / 2 + angle;
				meshes[0].rotation.z = -Math.PI / 2.5 - angle;
				alpha += 0.005;
			});
			
			animateSun();
						
			var layer:Layer = new Layer("background", "assets/img/skybox/Sky_FantasySky_Fire_Cam_px.jpg", scene, true);
			layer.render();
								
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});		
	}
	
	function animateSun() {
		Actuate.tween(sun.position, 15, { y: -6, z: 10 }, false).ease(Quad.easeInOut).onComplete(function() {
			Actuate.tween(sun.position, 15, { y: 5, z: -6 }, false).ease(Quad.easeInOut).onComplete(function() {
				Actuate.tween(sun.position, 15, { y: -6, z: -8 }, false).ease(Quad.easeInOut).onComplete(function() {
					Actuate.tween(sun.position, 15, { y: 1, z: 2 }, false).ease(Quad.easeInOut).onComplete(function() {
						Actuate.tween(sun.position, 15, { y: -5, z: -1 }, false).ease(Quad.easeInOut).onComplete(function() {
							Actuate.tween(sun.position, 15, { y: 5, z: 10 }, false).ease(Quad.easeInOut).onComplete(function() {
								animateSun();
							});
							
						});
						
					});
				});
			});
		});
	}
	
}
