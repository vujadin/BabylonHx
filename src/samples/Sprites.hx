package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.Scene;
import com.babylonhx.sprites.Sprite;
import com.babylonhx.sprites.SpriteManager;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Sprites {

	public function new(scene:Scene) {
		// Create camera and light
		var light = new PointLight("Point", new Vector3(5, 10, 5), scene);
		var camera = new ArcRotateCamera("Camera", 1, 0.8, 8, new Vector3(0, 0, 0), scene);
		camera.attachControl(this);
		
		// Create a sprite manager to optimize GPU ressources
		// Parameters : name, imgUrl, capacity, cellSize, scene
		var spriteManagerTrees = new SpriteManager("treesManager", "assets/img/tree.png", 2000, 800, scene);
		
		//We create 2000 trees at random positions
		for (i in 0...2000) {
			var tree = new Sprite("tree", spriteManagerTrees);
			tree.position.x = Math.random() * 100 - 50;
			tree.position.z = Math.random() * 100 - 50;
			
			//Some "dead" trees
			if (Math.round(Math.random() * 5) == 0) {
				tree.angle = Math.PI * 90 / 180;
				tree.position.y = -0.3;
			}
		}
		
		//Create a manager for the player's sprite animation
		var spriteManagerPlayer = new SpriteManager("playerManager", "assets/img/player.png", 2, 64, scene);
		
		// First animated player
		var player = new Sprite("player", spriteManagerPlayer);
		player.playAnimation(0, 40, true, 100);
		player.position.y = -0.3;
		player.size = 0.3;
		
		// Second standing player
		var player2 = new Sprite("player2", spriteManagerPlayer);
		player2.stopAnimation(); // Not animated
		player2.cellIndex = 2; // Going to frame number 2
		player2.position.y = -0.3;
		player2.position.x = 1;
		player2.size = 0.3;
		player2.invertU = true; //Change orientation
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
