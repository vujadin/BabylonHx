package samples;

import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;

#if !js
import haxe.Json;
import openfl.Assets;
import org.msgpack.Encoder;
import org.msgpack.MsgPack;
import sys.io.FileOutput;
import sys.io.FileOutput;
import sys.io.File;
#end

/**
 * ...
 * @author Krtolica Vujadin
 */
class LoadScene {

	public function new(scene:Scene) {
		#if !js
		//var level = Json.parse(Assets.getText("scenes/HillValley/HillValley.babylon"));
		//var f = MsgPack.encode(level);
		//var fout = File.write("scenes/HillValley/HillValley.bbin", true);
		//fout.writeBytes(f, 0, f.length - 1);
		//return;
		#end
		
		SceneLoader.RegisterPlugin(BabylonFileLoader.plugin);
		SceneLoader.Load("scenes/Train/", "Train.binary.babylon", scene.getEngine(), function(s:Scene) {
			scene = s;
			
			scene.executeWhenReady(function() {
				if (scene.activeCamera != null) {
					scene.activeCamera.attachControl(this);					
					scene.render();					
				}				
					
				scene.getEngine().runRenderLoop(function () {
					scene.render();
				});
			});
		});
	}
	
}
