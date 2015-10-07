package samples;

import com.babylonhx.Scene;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadScene {

	public function new(scene:Scene) {
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		SceneLoader.Load("assets/scenes/Heart/", "Heart.babylon", scene.getEngine(), function(s:Scene) {
			scene = s;
			scene.activeCamera.attachControl();
			scene.getMeshByName("Labels").setEnabled(false);
			scene.getMeshByName("lums").useVertexColors = false;
			scene.gravity.scaleInPlace(0.5);
				
			s.getEngine().runRenderLoop(function () {
				s.render();
			});
		});	
		
	}
	
}
