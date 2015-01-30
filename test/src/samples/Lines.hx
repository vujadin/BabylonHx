package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Lines {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
		camera.setPosition(new Vector3(20, 200, 400));
		camera.attachControl(this);
		camera.maxZ = 20000;		
		camera.lowerRadiusLimit = 150;
		
		scene.clearColor = new Color3(0, 0, 0);
				
		// Create a whirlpool
		var points = [];
		
		var radius = 0.5;
		var angle = 0.0;
		for (index in 0...1000) {
			points.push(new Vector3(radius * Math.cos(angle), 0, radius * Math.sin(angle)));
			radius += 0.3;
			angle += 0.1;
		}
		
		var whirlpool = Mesh.CreateLines("whirlpool", points, scene, true);
		whirlpool.color = new Color3(1, 1, 1);
		
		var positionData = whirlpool.getVerticesData(VertexBuffer.PositionKind);
		var heightRange = 10;
		var alpha = 0.0;
		scene.registerBeforeRender(function() {
			for (index in 0...1000) {
				positionData[index * 3 + 1] = heightRange * Math.sin(alpha + index * 0.1);
			}
			
			whirlpool.updateVerticesData(VertexBuffer.PositionKind, positionData);
			
			alpha += 0.05 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
