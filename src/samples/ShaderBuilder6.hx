package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.shaderbuilder.ShaderBuilder;
import com.babylonhx.shaderbuilder.ShaderMaterialHelper;
import com.babylonhx.shaderbuilder.Shader;
import com.babylonhx.shaderbuilder.Helper;
import com.babylonhx.shaderbuilder.Normals;
import com.babylonhx.tools.EventState;
import com.babylonhx.materials.textures.RenderTargetTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShaderBuilder6 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1", Math.PI / 2, 1.0, 40, new Vector3(0, 0, 0), scene);
		camera.attachControl(); 
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene); 
		light.intensity = 0.7; 
		
		for (is in 0...25) {
			var sp = Mesh.CreateSphere("sphere1", 30,5, scene);
			sp.position.x = Math.floor(is / 5.) * 5 - 10.;
			sp.position.z = Math.floor(is % 5.) * 5 - 10.;	
			sp.material = new ShaderBuilder()
				.Solid({ a: 1. })
				.Reflect({ equirectangular:true, 
				path: 'assets/img/tNdkQjJ.jpg', bias:(is + 1) / 5., revers: false }, is + 1.)
				.Effect({ pr: 'pow(pr,3.)*3.' })
				.Effect({ pw: '1.' })
				.BuildMaterial(scene);
				
			sp.material.freeze();
				
			var time = 0;
			var mouse = new Vector2(0, 0);
			var screen = new Vector2(100, 100);
			scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
				ShaderMaterialHelper.SetUniforms(
					cast scene.meshes,
					camera.position,
					camera.target,
					mouse,
					screen,
					time);
			});
		}
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
