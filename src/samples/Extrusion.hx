package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.polygonmesh.Polygon;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Space;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Extrusion {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, 0.8, 80, Vector3.Zero(), scene);
		camera.attachControl(this, true);
								
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
					  
		// 2D shape
		var poly = Polygon.StartingAt(-10, -10)
			.addLineTo(10, -10)
			.addLineTo(10, -5)
			.addArcTo(17, 0, 10, 5)
			.addLineTo(10, 10)
			.addLineTo(5, 10)
			.addArcTo(0, 0, -5, 10)
			.addLineTo(-10, 10)
			.close();
			
		var shape:Array<Vector3> = [];
		for (p in poly.getPoints()) {
			shape.push(new Vector3(p.x, p.y, 0));
		}
				
		var createLathe = function(shape:Array<Vector3>, radius:Float = 1, tessellation:Int = 40) {
			var pi2:Float = Math.PI * 2;
			var Y:Vector3 = Axis.Y;
			var shapeLathe:Array<Vector3> = [];
			var  i:Int = 0;
			while (shape[i].x == 0) {
				i++;
			}
			var pt = shape[i];        // first rotatable point
			
			for (i in 0...shape.length) {
				shapeLathe.push(shape[i].subtract(pt));
			}
			// circle path
			var step:Float = pi2 / tessellation;
			var rotated:Vector3 = null;
			var path:Array<Vector3> = [];
			for (i in 0...tessellation) {
				rotated = new Vector3(Math.cos(i * step) * radius, 0, Math.sin(i * step) * radius);
				path.push(rotated);
			}
			// extusion
			var scaleFunction = function(i:Float, distance:Float):Float { return 1; };
			var rotateFunction = function(i:Float, distance:Float):Float { return 0; };
			var lathe = Mesh.ExtrudeShapeCustom("lathe", shapeLathe, path, scaleFunction, rotateFunction, true, false, 0, scene);
			return lathe;
		};
		
		var mat = new StandardMaterial("mat", scene);
				
		var lathe = createLathe(shape, 1, 40);
		lathe.translate(new Vector3(0, 1, 0), -4, Space.LOCAL);
		lathe.material = mat;
		lathe.material.backFaceCulling = false;
				
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
		
}
