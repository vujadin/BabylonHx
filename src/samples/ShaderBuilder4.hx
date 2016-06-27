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
import com.babylonhx.tools.EventState;
import com.babylonhx.materials.textures.RenderTargetTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShaderBuilder4 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1",Math.PI/2, 1.0, 40, new Vector3(0, 0, 0), scene);
		camera.attachControl(); 
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene); 
		light.intensity = 0.7; 
		
		var sp = Mesh.CreateSphere("sphere1", 16, 10, scene);
		
		var shb = new ShaderBuilder();
		var sb = Helper.get();
		sp.material = shb
			.Map({ path: 'assets/img/earth.jpg',uv:'vec2(vuv.x,vuv.y*-1. )' })
			.Range(
			'',
			sb.Solid({b:1.}).Build(),
			{ start: -5., end:5. , direction:'pos.x' })
			.BuildMaterial(scene);
			
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
