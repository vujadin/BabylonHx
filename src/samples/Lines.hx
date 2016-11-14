package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.layer.Layer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;
import com.babylonhx.tools.EventState;

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
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
		
		var points:Array<Vector3> = generateLorenz(20000);
		
		var lorenz = Mesh.CreateLines("whirlpool", points, scene, false);
		lorenz.color = Color3.Red();
		
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
			lorenz.rotation.y += 0.01 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
	function generateLorenz(pointsNum:Int):Array<Vector3> {
		var points:Array<Vector3> = [];
		
		var r = 3;
		var o = 15;
		var b = 1;
		var x0 = 0.1;
		var y0 = 0.1;
		var z0 = 0.1;
		var x1 = x0;
		var y1 = y0;
		var z1 = z0;
		var interval = 0.02;
		var zoom = 10;
				
		for(i in 0...pointsNum) {
			x1 = x0 + ( y0 - x0 ) * r * interval;
			y1 = y0 + ( x0 * ( o - z0 ) - y0 ) * interval;
			z1 = z0 + (( x0 * y0 ) - (b * z0) ) * interval;    
			
			// z1-o -> centered
			points.push(new Vector3(x1 * zoom, y1 * zoom, (z1 - o) * zoom));   
			
			x0 = x1;
			y0 = y1;
			z0 = z1;
		}
		
		return points;
	}
	
}
