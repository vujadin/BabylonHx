package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.procedurals.standard.FireProceduralTexture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Path3D;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RibbonTest2 {

	public function new(scene:Scene) {
		scene.clearColor = new Color3( .5, .5, .5);
	
		// camera
		var camera = new ArcRotateCamera("camera1",  0, 0, 0, new Vector3(0, 0, -0), scene);
		camera.setPosition(new Vector3(0, 0, -100));
		camera.attachControl();
		// lights
		var light = new HemisphericLight("light1", new Vector3(1, 0.5, 0), scene);
		light.intensity = 0.7;
		var spot = new SpotLight("spot", new Vector3(25, 15, -10), new Vector3(-1, -0.8, 1), 15, 1, scene);
		spot.diffuse = new Color3(1, 1, 1);
		spot.specular = new Color3(0, 0, 0);
		spot.intensity = 0.8;
		// material
		var mat = new StandardMaterial("mat1", scene);
		mat.alpha = 1.0;
		//mat.diffuseColor = new Color3(0.5, 0.5, 1.0);
		mat.backFaceCulling = false;
		//mat.wireframe = true;
		//texture
		var texture = new Texture("assets/img/metal.jpg", scene);
		texture.vScale = 10.0;
		texture.uScale = 2.0;
		mat.diffuseTexture = texture;
	  
		// curve
		var curvePoints = function(l, t) {
			var path = [];
			var step = l / t;
			var i = -l / 2;
			while (i <= l/2) {
				path.push(new Vector3(12 * Math.sin(i / 10), i, 0 ));
				i += step;
			}
			return path;
		};
		var curve = curvePoints(40, 200);
	  
		// shape 2D
		var shape = [
			new Vector3(0, 1, -1),  
			new Vector3(0 , 1, 0),
			new Vector3(0 , 0.6, 0.3),
			new Vector3(0 , 0.8, 0.8),
			new Vector3(0 , 0.3, 0.6),
			new Vector3(0 , 0, 1),
			new Vector3(0, -1, 1)
  		];		
		
		// EXTRUDATOR !!!
		function extrude(shape:Array<Vector3>, curve, scale, rotation, scaleFunction, rotateFunction, rbCA, rbCP, custom) {
			var path3D = new Path3D(curve);
			var tangents = path3D.getTangents();
			var normals = path3D.getNormals();
			var binormals = path3D.getBinormals();
			var distances = path3D.getDistances();
			var shapePaths = [];
			var angle = 0.0;
			var returnScale = function(i, distance) { return scale;  };
			var returnRotation = function(i, distance) { return rotation; };
			var rotate = custom ? rotateFunction : returnRotation;
			var scl = custom ? scaleFunction : returnScale;
		
			var angleStep:Float = 0;
			for (i in 0...curve.length) {
			  var shapePath = [];
				  for (p in 0...shape.length) {
					    angleStep = rotate(i, distances[i]);
					    var scaleRatio = scl(i, distances[i]);
					    var rotationMatrix = Matrix.RotationAxis(tangents[i], angle);
					    var planed = ((tangents[i].scale(shape[p].x)).add(normals[i].scale(shape[p].y)).add(binormals[i].scale(shape[p].z)));
					    var rotated = Vector3.TransformCoordinates(planed, rotationMatrix).scaleInPlace(scaleRatio).add(curve[i]);
					    shapePath.push(rotated);
				  }
				  shapePaths.push(shapePath);
				  angle += angleStep;
			}
			var mesh = Mesh.CreateRibbon("extrude", shapePaths, rbCA, rbCP, 0, scene);
			return mesh;
		}	
		
		// curve visualizer
		var line = Mesh.CreateLines("line", curve, scene);
		line.color = Color3.Red();
		
		// custom scale function
		var myScaling = function(i:Int, distance:Float):Float {
			var scale = 6;
			var scale = Math.cos(distance / 40) * 8;
			return scale;
		};
		
		// custom rotation function
		var myRotation = function(i:Int, distance:Float):Float {
			var rotation = Math.PI / 8;
			var rotation = distance / 400 * Math.PI / 3;
			return rotation;
		};
		
		// extrusion
		var extruded = extrude(shape, curve, 2, 0, myScaling, myRotation, false, false, false );
		extruded.material = mat;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}