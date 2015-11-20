package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.layer.Layer;
import com.babylonhx.mesh.polygonmesh.Polygon;
import com.babylonhx.mesh.polygonmesh.PolygonMeshBuilder;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PolygonMesh3 {
	
	var B = "57.297,49.947,69.757,59.149,74.55,72.61,71.994,82.493,65.178,90.588,55.167,96.04,42.813,98,0,98,0,5.132,36.21,5.132,48.564,7.177,58.575,12.715,65.391,20.894,67.947,30.862,65.072,41.512";
	var Bhole = "58.788,76.188,58.042,67.328,50.268,60.682,30.672,52.673,47.286,40.745,52.504,33.588,51.333,25.409,45.156,19.701,36.210,17.571,15.123,17.571,15.123,85.901,42.813,85.901,52.717,83.174";
	
	var a = "169.335,98,153.573,98,153.573,92.377,141.112,98,126.522,100.045,109.588,97.318,95.743,89.82,86.478,78.745,83.07,65.283,86.478,51.736,95.743,40.660,109.588,33.248,126.522,30.521,141.539,32.651,154.212,38.7,169.335,33.077";
	var ahole = "99.471,65.113,101.601,73.548,107.352,80.449,115.978,85.05,126.521,86.754,136.958,85.05,145.584,80.449,151.441,73.548,153.571,65.113,151.441,56.763,145.584,49.947,136.958,45.346,126.521,43.642,115.978,45.346,107.352,49.947,101.601,56.763";
	
	var b = "220.239,30.521,237.066,33.248,250.911,40.66,260.283,51.736,263.691,65.283,260.293,78.745,250.948,89.820,237.146,97.318,220.369,100.045,205.821,98,193.401,92.377,193.401,98,177.639,98,177.639,0.872,193.614,6.836,193.401,38.019,205.755,32.481";
	var bhole = "220.132,86.754,230.738,85.050,239.331,80.449,245.165,73.548,247.288,65.113,245.165,56.763,239.331,49.947,230.738,45.346,220.132,43.642,209.735,45.346,201.248,49.947,195.52,56.763,193.4,65.113,195.52,73.548,201.248,80.449,209.735,85.050";
	
	var y = "348.888,30.351,293.508,127.82,285.414,111.462,302.028,82.834,272.208,30.351,288.822,30.351,310.548,68.010,332.274,30.351";
	
	var l = "374.02,7.518,374.02,19.617,374.02,19.958,374.02,98,373.594,98,357.406,98,357.406,13.311,357.406,13.141,357.406,0.872";
	
	var o = "425.885,30.351,442.779,33.078,456.694,40.576,466.043,51.737,469.444,65.284,466.043,78.746,456.694,89.821,442.779,97.319,425.885,100.046,408.991,97.319,395.18,89.82,385.938,78.745,382.540,65.283,385.938,51.736,395.18,40.575,408.992,33.077";
	var ohole = "425.885,87.265,436.682,85.561,445.554,80.875,451.541,73.889,453.682,65.284,451.541,56.679,445.554,49.607,436.682,44.836,425.885,43.132,415.085,44.836,406.318,49.607,400.438,56.679,398.301,65.284,400.438,73.889,406.318,80.875,415.085,85.561";
	
	var n = "564.865,65.113,564.865,97.83,549.103,97.83,549.103,65.012,546.867,56.465,541.009,49.458,532.170,44.756,521.413,42.962,511.722,44.501,503.095,48.860,496.918,55.527,494.575,63.988,494.575,97.83,478.174,97.83,478.174,31.863,494.150,37.998,506.716,32.215,521.413,30.181,537.814,32.737,551.339,39.809,560.818,50.288,564.865,63.068";
	
	var H = "663.057,5.132,663.057,98,646.656,98,646.656,57.615,589.785,57.615,589.785,98,573.384,98,573.384,5.132,589.785,9.733,589.785,44.495,646.656,44.495,646.656,9.733";
	
	var x = "757.841,98,738.032,98,714.601,74.314,691.385,98,671.576,98,699.905,69.202,704.803,64.261,671.575,30.351,691.384,30.351,714.601,54.207,738.032,30.351,757.841,30.351,727.382,61.364,724.613,64.261";
	
	
	public function new(scene:Scene) {		
		var camera = new ArcRotateCamera("Camera", -60, 76, 50, new Vector3(50, 10, 380), scene);
		camera.setPosition(new Vector3(360, 670, 240));
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, -1, 0), scene);
						
		var mat = new StandardMaterial("mat", scene);
		mat.diffuseColor = Color3.FromInts(246, 135, 18);
		mat.backFaceCulling = false;
		
		var letters:Array<Mesh> = [];
		
		letters.push(new PolygonMeshBuilder("B", Polygon.Parse(B, ","), scene).addHole(Polygon.Parse(Bhole, ",")).build());
		letters.push(new PolygonMeshBuilder("a", Polygon.Parse(a, ","), scene).addHole(Polygon.Parse(ahole, ",")).build());
		letters.push(new PolygonMeshBuilder("b", Polygon.Parse(b, ","), scene).addHole(Polygon.Parse(bhole, ",")).build());
		letters.push(new PolygonMeshBuilder("y", Polygon.Parse(y, ","), scene).build());
		letters.push(new PolygonMeshBuilder("l", Polygon.Parse(l, ","), scene).build());
		letters.push(new PolygonMeshBuilder("o", Polygon.Parse(o, ","), scene).addHole(Polygon.Parse(ohole, ",")).build());
		letters.push(new PolygonMeshBuilder("n", Polygon.Parse(n, ","), scene).build());
		letters.push(new PolygonMeshBuilder("H", Polygon.Parse(H, ","), scene).build());
		letters.push(new PolygonMeshBuilder("x", Polygon.Parse(x, ","), scene).build());
		
		letters[0].material = mat;
		
		for (letter in letters) {
			letter.material = mat;
			letter.rotation.x += Math.PI;
			letter.rotation.y -= Math.PI / 2;
		}
						
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
