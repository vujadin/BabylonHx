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
import com.babylonhx.tools.Tools;
import com.babylonhx.layer.Layer;
import com.babylonhx.mesh.polygonmesh.PolygonLib;
import com.babylonhx.mesh.polygonmesh.PolygonMeshBuilder;
import com.babylonhx.extensions.svg.SVG;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SVGTest {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -60, 76, 50, new Vector3(50, 10, 380), scene);
		camera.setPosition(new Vector3(360, 670, 240));
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		var mat = new StandardMaterial("mat", scene);
		mat.diffuseColor = Color3.FromInts(246, 135, 18);
		mat.backFaceCulling = false;
		
		/*Tools.LoadFile("assets/airplane1.svg", function(data:String) {
			trace('done');
			trace(SVG.ToPointArray(data));
		}, "text");*/
		
		/*letters.push(new PolygonMeshBuilder("B", PolygonLib.Parse(B, ","), scene).addHole(PolygonLib.Parse(Bhole, ",")).build());
		letters.push(new PolygonMeshBuilder("a", PolygonLib.Parse(a, ","), scene).addHole(PolygonLib.Parse(ahole, ",")).build());
		letters.push(new PolygonMeshBuilder("b", PolygonLib.Parse(b, ","), scene).addHole(PolygonLib.Parse(bhole, ",")).build());
		letters.push(new PolygonMeshBuilder("y", PolygonLib.Parse(y, ","), scene).build());
		letters.push(new PolygonMeshBuilder("l", PolygonLib.Parse(l, ","), scene).build());
		letters.push(new PolygonMeshBuilder("o", PolygonLib.Parse(o, ","), scene).addHole(PolygonLib.Parse(ohole, ",")).build());
		letters.push(new PolygonMeshBuilder("n", PolygonLib.Parse(n, ","), scene).build());
		letters.push(new PolygonMeshBuilder("H", PolygonLib.Parse(H, ","), scene).build());
		letters.push(new PolygonMeshBuilder("x", PolygonLib.Parse(x, ","), scene).build());
		
		letters[0].material = mat;
		
		for (letter in letters) {
			letter.material = mat;
			letter.rotation.x += Math.PI;
			letter.rotation.y -= Math.PI / 2;
		}*/
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
