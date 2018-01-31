package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.polygonmesh.PolygonLib;
import com.babylonhx.mesh.polygonmesh.PolygonMeshBuilder;
import com.babylonhx.mesh.VertexData;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.Scene;

import lime.utils.Float32Array;
import lime.utils.UInt32Array;

import com.babylonhx.materials.textures.procedurals.TextureBuilder;

import com.babylonhx.extensions.proctree.Tree;
import com.babylonhx.extensions.proctree.TreeMath;

import com.babylonhx.math.OpenSimplexNoise;
import com.babylonhx.math.OpenSimplexNoiseTileable3D;
import com.babylonhx.utils.Image;
import com.babylonhx.materials.textures.Texture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PolygonMesh1 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 3 * Math.PI / 2, Math.PI / 8, 50, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		
		var polygon = PolygonLib.StartingAt(-10, -10)
		.addLineTo(10, -10)
		.addLineTo(10, -5)
		.addArcTo(17, 0, 10, 5)
		.addLineTo(10, 10)
		.addLineTo(5, 10)
		.addArcTo(0, 0, -5, 10)
		.addLineTo(-10, 10)
		.close();
		
		var ground = new PolygonMeshBuilder("ground1", polygon, scene).build();
		ground.material = new StandardMaterial('ground', scene);
		ground.material.backFaceCulling = false;
		camera.target = ground.position;
		
		var tb = new TextureBuilder(256, 256);		
		tb.perlinNoise(0,64,694787904,256,121,4,true);
		tb.sharpenLayer(0,0);
		tb.sineLayerRGB(0,0,0.0140000004321337,0.0299999993294477,0.164000004529953);
		tb.noiseDistort(0,0,58340664,2);		
		var tbTex0 = tb.generateTexture(0, scene, "TextureBuilderTest0");
		
		cast (ground.material, StandardMaterial).diffuseTexture = tbTex0;
		
		
		var tree = new Tree({
			"seed": 499,
			"segments": 8,
			"levels": 5,
			"vMultiplier": 1,
			"twigScale": 0.28,
			"initalBranchLength": 0.5,
			"lengthFalloffFactor": 0.98,
			"lengthFalloffPower": 1.08,
			"clumpMax": 0.414,
			"clumpMin": 0.282,
			"branchFactor": 2.2,
			"dropAmount": 0.24,
			"growAmount": 0.044,
			"sweepAmount": 0,
			"maxRadius": 0.096,
			"climbRate": 0.39,
			"trunkKink": 0,
			"treeSteps": 5,
			"taperRate": 0.958,
			"radiusFalloffRate": 0.71,
			"twistRate": 2.97,
			"trunkLength": 1.95
		});
		
		var treeIndices:Array<Int> = TreeMath.flattenArray(tree.faces);
		treeIndices.reverse();
		var treePositions:Array<Float> = TreeMath.flattenArray(tree.verts);
		var treeNormals:Array<Float> = TreeMath.flattenArray(tree.normals);
		var treeUvs:Array<Float> = TreeMath.flattenArray(tree.uvs);
		
		var _positions = new Float32Array(treePositions);
		var _indices = new UInt32Array(treeIndices);
		var _normals = new Float32Array(treeNormals);
		var _uvs = new Float32Array(treeUvs);
		
		// sides
		VertexData._ComputeSides(Mesh.DEFAULTSIDE, _positions, _indices, _normals, _uvs);
		
		// Result
		var vertexData = new VertexData();
		
		vertexData.indices = _indices;
		vertexData.positions = _positions;
		vertexData.normals = _normals;
		vertexData.uvs = _uvs;
		
		var treeMesh = new Mesh("treeTrunk", scene);
		vertexData.applyToMesh(treeMesh, false);
		treeMesh.material = new StandardMaterial('treemat', scene);
		
		
		treeIndices = TreeMath.flattenArray(tree.facesTwig);
		treeIndices.reverse();
		treePositions = TreeMath.flattenArray(tree.vertsTwig);
		treeNormals = TreeMath.flattenArray(tree.normalsTwig);
		treeUvs = TreeMath.flattenArray(tree.uvsTwig);
		
		var _positions = new Float32Array(treePositions);
		var _indices = new UInt32Array(treeIndices);
		var _normals = new Float32Array(treeNormals);
		var _uvs = new Float32Array(treeUvs);
		
		// sides
		VertexData._ComputeSides(Mesh.DEFAULTSIDE, _positions, _indices, _normals, _uvs);
		
		// Result
		var vertexData2 = new VertexData();
		
		vertexData2.indices = _indices;
		vertexData2.positions = _positions;
		vertexData2.normals = _normals;
		vertexData2.uvs = _uvs;
		
		var treeTwigMesh = new Mesh("treeTwig", scene);
		vertexData2.applyToMesh(treeTwigMesh, false);
		treeTwigMesh.material = new StandardMaterial('treetwigmat', scene);
		
		tb.sinePlasma(0, 0.25, 0.0900000035762787, 256);
		tb.woodLayer(0, 0, 2); 
		tb.erodeLayer(0, 0); 
		tb.erodeLayer(0, 0);
		tb.moveDistort(0, 0, 128, 255); 
		tb.embossLayer(0, 0); 
		tb.invertLayer(0, 0); 
		tb.blurLayer(0, 0);		
		tb.perlinNoise(1, 128, 9876543, 256, 150, 8, false); 
		tb.perlinNoise(2, 128, 9876543, 256, 150, 8, true); 
		tb.addLayers(0, 1, 4, 1, 0.219999998807907);
		tb.addLayers(4, 2, 4, 1, 0.150000005960464);
		
		var tbTex8 = tb.generateTexture(4, scene, "TextureBuilderTest8");
		
		cast (treeMesh.material, StandardMaterial).diffuseTexture = tbTex8;
		treeTwigMesh.material = treeMesh.material;
		
		var shape = PolygonLib.RoundGear(0, 0, 10, 22, 28);
		var roundGearShape = new PolygonMeshBuilder("roundgear", shape, scene).build();
		roundGearShape.position.set(10, 16, 0);
		roundGearShape.scaling.set(0.2, 0.2, 0.2);
		
		var WIDTH:Int = 256;
		var HEIGHT:Int = 256;
		var FEATURE_SIZE:Float = 4;
		var noise = new OpenSimplexNoiseTileable3D(2, 2, 2);
		
		var img:Image = new Image(null, WIDTH, HEIGHT);
		
		for (y in 0...HEIGHT) {
			for (x in 0...WIDTH) {
				var value = noise.eval(x / FEATURE_SIZE, y / FEATURE_SIZE, 0.0);
				var rgb = Std.int((value + 1) * 127.5);
				img.setPixelAt(x, y, rgb);
			}
		}
		
		var matT = new StandardMaterial('noisetex', scene);
		matT.diffuseTexture = Texture.fromImage("", img, scene);
		roundGearShape.material = matT;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
