package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.lights.Light;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.lights.shadows.ShadowGenerator;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Shadows2 {

	public function new(scene:Scene) {
						
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		SceneLoader.Load("assets/scenes/", "shadows.babylon", scene.getEngine(), function(s:Scene) {
			scene = s;
			scene.activeCamera.attachControl();
			scene.getMeshByName("Cube").material.alpha = 1;
			scene.getMeshByName("Cube").receiveShadows = true;
			
			var star:Mesh = cast(scene.getMeshByName("star1"), Mesh);
			star.material.alpha = 1;
			
			var light1:SpotLight = cast scene.lights[0];
						
			var shadowGenerator1 = new ShadowGenerator(1024, light1);
			shadowGenerator1.getShadowMap().renderList.push(star);
			shadowGenerator1.useBlurVarianceShadowMap = true;
			shadowGenerator1.blurBoxOffset = 2.0;
			
			var light2:SpotLight = cast scene.lights[1];
						
			var shadowGenerator2 = new ShadowGenerator(1024, light2);
			shadowGenerator2.getShadowMap().renderList.push(star);
			shadowGenerator2.useBlurVarianceShadowMap = true;
			shadowGenerator2.blurBoxOffset = 2.0;
			
			var light3:SpotLight = cast scene.lights[2];
						
			var shadowGenerator3 = new ShadowGenerator(1024, light3);
			shadowGenerator3.getShadowMap().renderList.push(star);
			shadowGenerator3.useBlurVarianceShadowMap = true;
			shadowGenerator3.blurBoxOffset = 2.0;
					
			var alpha = 0.0;
			s.registerBeforeRender(function() {
				star.rotation.x += 0.01;
				star.rotation.z += 0.01;
				
				star.position.y += Math.sin(alpha) / 20;
				
				alpha += 0.02;
			});
			
			new DirectionalLight("dir01", new Vector3(0, -0.5, -1.0), scene);
							
			s.getEngine().runRenderLoop(function () {
				s.render();
			});
		});	
		
	}
	
}
