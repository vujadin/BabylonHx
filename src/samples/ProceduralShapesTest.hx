package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.mesh.polygonmesh.PolygonLib;
import com.babylonhx.mesh.polygonmesh.PolygonMeshBuilder;
import com.babylonhx.math.polyclip.geom.Polygon;
import com.babylonhx.math.polyclip.PolygonClipper;
import com.babylonhx.math.polyclip.PolygonOp;
import com.babylonhx.materials.textures.procedurals.TextureBuilder;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ProceduralShapesTest {

	public function new(scene:Scene) {
		var camera:ArcRotateCamera = new ArcRotateCamera("camera1", -Math.PI / 2.4, Math.PI / 2.2, 120, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(0, 1, 0), scene);
		light.intensity = 0.7;
		
		var shape = PolygonLib.Gear(0, 0, 10, 22, 28);
		var shape2 = PolygonLib.RoundPoly(33, 33, 7, 35);
		
		var poly1 = new Polygon(shape);
		var poly2 = new Polygon(shape2);
		
		var pc = new PolygonClipper(poly2, poly1);
		var operation:Int = PolygonOp.UNION;
		
		var result = pc.compute(operation);
		
		var shapeMesh = new PolygonMeshBuilder("pmb", result.contours[0].getPoints(), scene).addHole(PolygonLib.Poly(5, 5, 6, 6)).addHole(PolygonLib.Poly(15, 15, 8, 6)).build(false, 20);
		
		var tb = new TextureBuilder(512, 512);	
		
		// LSD
		/*tb.sinePlasma(0,0.256000012159348,0.256000012159348,256);
		tb.moveDistort(0,0,128,128);
		tb.noiseDistort(0,0,1234567,3);
		tb.twirlLayer(0,0,50,5000);
		tb.sineLayerRGB(0,0,0.00800000037997961,0.0160000007599592,0.00999999977648258);
		tb.subPlasma(1,64,321116544,128,true);
		tb.perlinNoise(2,64,969423872,256,113,4,true);
		tb.twirlLayer(2,2,200,5000);
		tb.edgeHLayer(2,2);
		tb.moveDistort(2,2,128,128);
		tb.twirlLayer(2,2,200,5000);
		tb.sharpenLayer(2,2);
		tb.particle(3,1);
		tb.tileLayer(3,3);
		tb.tileLayer(3,3);
		tb.twirlLayer(3,3,500,5000);
		tb.moveDistort(3,3,128,128);
		tb.twirlLayer(3,3,500,5000);
		tb.noiseDistort(3,3,894802816,3);
		tb.scaleLayerHSV(3,3,1,1,1.5);
		tb.colorLayer(4,255,255,255);
		tb.addLayers(0,1,4,1,-1.5);
		tb.addLayers(4,2,4,1,1.25);
		tb.mulLayers(4,3,4,1,1);
		tb.blurLayer(4,4);*/
		
		// Metal
		/*tb.sinePlasma(0,0.25,0.0900000035762787,256); 
		tb.woodLayer(0,0,2); 
		tb.erodeLayer(0,0); 
		tb.erodeLayer(0,0); 
		tb.moveDistort(0,0,128,255); 
		tb.embossLayer(0,0); 
		tb.invertLayer(0,0); 
		tb.blurLayer(0,0);		
		tb.perlinNoise(1,128,9876543,256,150,8,false); 
		tb.perlinNoise(2,128,9876543,256,150,8,true); 
		tb.addLayers(0,1,4,1,0.219999998807907);  
		tb.addLayers(4,2,4,1,0.150000005960464);*/
		
		tb.perlinNoise(0,64,1788537984,256,150,8,false); 
		tb.sculptureLayer(0,0); 
		tb.adjustLayerRGB(0,0,-25,-10,25); 
		tb.perlinNoise(1,64,958198656,256,150,8,false); 
		tb.embossLayer(1,1); 
		tb.adjustLayerRGB(1,1,25,0,-25); 
		tb.perlinNoise(2,64,151024000,256,150,8,false); 
		tb.adjustLayerRGB(2,2,25,25,-25); 
		tb.mulLayers(0,1,4,1,1); 
		tb.mulLayers(4,2,4,1,1); 
		
		var tbTex0 = tb.generateTexture(4, scene, "TextureBuilderTest0");
		
		var mat = new StandardMaterial('noisetex', scene);
		mat.diffuseTexture = tbTex0;
		shapeMesh.material = mat;
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
