package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.procedurals.standard.FireProceduralTexture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.postprocess.VolumetricLightScatteringPostProcess;
import haxe.Timer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Ribbons {

	public function new(scene:Scene) {
		scene.clearColor = new Color3(0, 0, 0.2);
		var camera = new ArcRotateCamera("Camera", Math.PI / 2 - 0.5, 0.5, 6, Vector3.Zero(), scene);
		//camera.attachControl();
		camera.wheelPrecision = 100;

		// fire material
		var fireMaterial = new StandardMaterial("fireMaterial", scene);
		var fireTexture = new FireProceduralTexture("fire", 256, scene);
		fireTexture.level = 2;
		fireTexture.vScale = 0.5;
		fireMaterial.diffuseColor = new Color3(Math.random() / 2, Math.random() / 2, Math.random() / 2);
		fireMaterial.diffuseTexture = fireTexture;
		fireMaterial.alpha = 1;
		fireMaterial.specularTexture = fireTexture;
		fireMaterial.emissiveTexture = fireTexture;
		fireMaterial.specularPower = 4;
		fireMaterial.backFaceCulling = false;
		fireTexture.fireColors = [
			new Color3(Math.random() / 2, Math.random() / 2, Math.random() / 2),
			new Color3(Math.random() / 2, Math.random() / 2, Math.random() / 2),
			new Color3(Math.random() / 2, Math.random() / 2, Math.random() / 2),
			new Color3(Math.random() / 2, Math.random() / 2, Math.random() / 2),
			new Color3(Math.random() / 2, Math.random() / 2, Math.random() / 2),
			new Color3(Math.random() / 2, Math.random() / 2, Math.random() / 2)
		];
		
		// initial vars
		var delay = 4000;
		var steps = Math.floor(delay / 80);
		
		var paths:Array<Array<Vector3>> = [];
		var targetPaths:Array<Array<Vector3>> = [];
		var m:Array<Int> = [1, 3, 1, 5, 1, 7, 1, 9];
		var lat = 50;
		var lng = 50;
		var deltas = [];
		var colors = fireTexture.fireColors;
		var deltaColors = [];
		var morph = false;
		var counter = 0;
		var rx = 0.0;
		var ry = 0.0;
		var deltarx = Math.random() / 200;
		var deltary = Math.random() / 400;
		
		// harmonic function : populates paths array according to m array
		var harmonic = function (m:Array<Int>, lat, long, paths) {
			var pi = Math.PI;
			var pi2 = Math.PI * 2;
			var steplat = pi / lat;
			var steplon = pi2 / long;
			var index = 0;
			var theta = 0.0;
			while (theta <= pi2) {
				var path = [];
				var phi = 0.0;
				while (phi < pi) {
					var r = 0.0;
					r += Math.pow(Math.sin(Math.floor(m[0]) * phi), Math.floor(m[1]));
					r += Math.pow(Math.cos(Math.floor(m[2]) * phi), Math.floor(m[3]));
					r += Math.pow(Math.sin(Math.floor(m[4]) * theta), Math.floor(m[5]));
					r += Math.pow(Math.cos(Math.floor(m[6]) * theta), Math.floor(m[7]));
					var p = new Vector3(r * Math.sin(phi) * Math.cos(theta), r * Math.cos(phi), r * Math.sin(phi) * Math.sin(theta));
					path.push(p);
					
					phi += steplat;
				}
				paths[index] = path;
				index++;
				
				theta += steplon;
			}
		};
		
		// new SH function : fill targetPaths and delta arrays with Vector3 and colors
		var newSH = function (m:Array<Int>, paths, targetPaths, deltas, deltaColors) {
			morph = true;
			var scl = 1 / steps;
			// new harmonic
			for (i in 0...m.length) {
				var rand = Std.int(Math.random() * 10);
				m[i] = rand;
			}
			harmonic(m, lat, lng, targetPaths);
			// deltas computation
			var index = 0;
			for (p in 0...targetPaths.length) {
				var targetPath = targetPaths[p];
				var path = paths[p];
				for (i in 0...targetPath.length) {
					deltas[index] = (targetPath[i].subtract(path[i])).scale(scl);
					index++;
				}
			}
			// delta colors
			for (c in 0...colors.length) {
				deltaColors[c] = (new Color3(Math.random() / 2, Math.random() / 2, Math.random() / 2)).subtract(colors[c]).scale(scl);
			}
			// new rotation speeds
			deltarx = Math.random() / 200;
			deltary = Math.random() / 400;
		};
		
		// morphing function : update ribbons with intermediate m values
		var morphing = function (mesh:Mesh, m:Array<Int>, paths:Array<Array<Vector3>>, targetPaths:Array<Array<Vector3>>, deltas:Array<Vector3>, deltaColors:Array<Color3>) {
			if (counter == steps) {
				counter = 0;
				morph = false;
				paths = targetPaths;
			}
			else {
				// update paths
				var index = 0;
				for (p in 0...paths.length) {
					var path = paths[p];
					for (i in 0...path.length) {
						path[i] = path[i].add(deltas[index]);
						index++;
					}
				}
				mesh = Mesh.CreateRibbon(null, paths, null, null, null, null, null, null, mesh);
				// update colors
				for (c in 0...colors.length) {
					colors[c] = colors[c].add(deltaColors[c]);
				}
			}
			counter++;
			return mesh;
		};
		
		// SH init & ribbon creation
		harmonic(cast m, lat, lng, paths);
		var mesh = Mesh.CreateRibbon("ribbon", paths, true, false, 0, scene, true);
		mesh.freezeNormals();
		mesh.scaling = new Vector3(1, 1, 1);
		mesh.material = fireMaterial;
		// Volumetric Light
		var volLight = new VolumetricLightScatteringPostProcess("vl", 1.0, camera, mesh, 50, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false);
		volLight.exposure = 0.15;
		volLight.decay = 0.95;
		volLight.weight = 0.5;
		
		var interval:Void->Void = null;
		
		// interval setting
		interval = function () {
			newSH(m, paths, targetPaths, deltas, deltaColors);
			mesh = morphing(mesh, m, paths, targetPaths, deltas, deltaColors);
			Timer.delay(interval, delay);
		};
		
		// immediate first SH
		newSH(m, paths, targetPaths, deltas, deltaColors);
		
		// then animation
		scene.registerBeforeRender(function () {
			if (morph) {
				mesh = morphing(mesh, m, paths, targetPaths, deltas, deltaColors);
			}
			rx += deltarx;
			ry -= deltary;
			mesh.rotation.y = ry;
			mesh.rotation.z = rx;
		});
		
		interval();
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
