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
class ShaderBuilder5 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1", Math.PI / 2, 1.0, 40, new Vector3(0, 0, 0), scene);
		camera.attachControl(); 
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene); 
		light.intensity = 0.7; 
		
		var sp = Mesh.CreateSphere("sphere1", 16, 10, scene);		 
		sp.material = new ShaderBuilder()
			.Solid({ a: 0. })
			.Reflect({ normal: Normals.Flat, path: 'assets/img/skybox/skybox', revers:true }, 0.3)
			.Effect({ pr: 'length(vec3(px,py,pz)) ' })
			.Effect({ pr: 'pow(pr,3.)*13.' })
			.Light({ normal:Normals.Flat, color: { r: 1., g: 1., b: 1., a: 1. }, supplement: true, direction: 'camera', phonge: '63' })
			.Light({ normal: Normals.Flat, color: { r: 1., g: 1., b: 1., a: 1. }, direction: 'camera', specular: 0.0, phonge: 'pow(length(result.xyz),3.)*0.3' })
			.Light({ normal: Normals.Flat, color: { r: 0., g: 0., b: 0., a: 1. }, supplement: true, direction: 'camera', darkColorMode: true, phonge: '253' })
			.Transparency()
			.BuildMaterial(scene);
				
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
				time++);
		});
			
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
