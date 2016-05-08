package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.shaderbuilder.ShaderBuilder;
import com.babylonhx.shaderbuilder.ShaderMaterialHelper;
import com.babylonhx.tools.EventState;
import com.babylonhxext.loaders.obj.ObjLoader;
import com.babylonhx.shaderbuilder.Shader;
import com.babylonhx.shaderbuilder.Helper;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShaderBuilder1 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1", 3., 3., 0., new Vector3(0, 5, -10), scene);
		
		camera.setTarget(Vector3.Zero());
		
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		
		light.intensity = 0.7;
		
	  
		var sp = Mesh.CreateSphere("sphere1", 16,10, scene);
		 
		var shb = new ShaderBuilder();
		var sb = Helper.get();
		sp.material = shb.Range(sb.Solid({r:1.}).Build(), sb.Solid({r:1.,g:1.}).Build(), { start: -0.5, end: 1.0, direction: 'pos.y+noise(pos-vec3(0.,time*0.01,0.))' }) 
				.Reference("1")
				.Yellow(1, sb.InLine('discard;').Build(), { rangeStep: -0.0 , rangePower: -0.01 } )			   
				.Back().BuildMaterial(scene); 
				
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