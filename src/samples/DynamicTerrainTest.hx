package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Space;
import com.babylonhx.math.Perlin;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.mesh.dynamicterrain.DynamicTerrain;
import com.babylonhx.Scene;
import com.babylonhx.Engine;

import lime.utils.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class DynamicTerrainTest {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("camera1",  0, 0, 0, Vector3.Zero(), scene);
		camera.setPosition(new Vector3(0.0, 800.0, 0.01));
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0.0, 1.0, 0.0), scene);
		light.intensity = 0.75;
		light.specular = Color3.Black();
		
		// Map data creation
		// The map is a flat array of successive 3D coordinates (x, y, z).
		// It's defined by a number of points on its width : mapSubX
		// and a number of points on its height : mapSubZ
		
		var mapSubX = 1000;             // point number on X axis
		var mapSubZ = 800;              // point number on Z axis
		var seed = 0.3;                 // seed
		var noiseScale = 0.03;         // noise frequency
		var elevationScale = 6.0;
		
		var noise = new Perlin(seed);
		var mapData = new Float32Array(mapSubX * mapSubZ * 3); // 3 float values per point : x, y and z

		var paths:Array<Array<Vector3>> = [];                             // array for the ribbon model
		for (l in 0...mapSubZ) {
			var path:Array<Vector3> = [];                          // only for the ribbon
			for (w in 0...mapSubX) {
				var x = (w - mapSubX * 0.5) * 2.0;
				var z = (l - mapSubZ * 0.5) * 2.0;
				var y = noise.simplex2(x * noiseScale, z * noiseScale);
				y *= (0.5 + y) * y * elevationScale;   // let's increase a bit the noise computed altitude
				
				mapData[3 *(l * mapSubX + w)] = x;
				mapData[3 * (l * mapSubX + w) + 1] = y;
				mapData[3 * (l * mapSubX + w) + 2] = z;
				
				path.push(new Vector3(x, y, z));
			}
			paths.push(path);
		}
		
		var map = MeshBuilder.CreateRibbon("m", { pathArray: paths, sideOrientation: 2 }, scene);
		map.position.y = -1.0;
		var mapMaterial = new StandardMaterial("mm", scene);
		mapMaterial.wireframe = true;
		mapMaterial.alpha = 0.5;
		map.material = mapMaterial;
		
		// Dynamic Terrain
        // ===============
        var terrainSub = 100;               // 100 terrain subdivisions
        var params = {
            mapData: mapData,               // data map declaration : what data to use ?
            mapSubX: mapSubX,               // how are these data stored by rows and columns
            mapSubZ: mapSubZ,
            terrainSub: terrainSub          // how many terrain subdivisions wanted
        }
        var terrain = new DynamicTerrain("t", params, scene);
        var terrainMaterial = new StandardMaterial("tm", scene);
        terrainMaterial.diffuseColor = Color3.Green();
        //terrainMaterial.alpha = 0.8;
        terrainMaterial.wireframe = true;
        terrain.mesh.material = terrainMaterial;
        terrain.initialLOD = 10;
        terrain.update(true);
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}