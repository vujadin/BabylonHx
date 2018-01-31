package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.lib.sky.SkyMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Space;
import com.babylonhx.math.Tools as MathTools;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.Scene;
import com.babylonhx.engine.Engine;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.extensions.simpleoaktree.SimpleOakTreeGenerator as SOTG;
import com.babylonhx.extensions.simplepinetree.SimplePineTreeGenerator as SPTG;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SimpleOakTreeTest {
	
	var treeNumber:Int;
	var trees:Array<Mesh>;
	var minSizeBranch:Int;
	var maxSizeBranch:Int;
	var minSizeTrunk:Int;
	var maxSizeTrunk:Int;
	var minRadius:Int;
	var maxRadius:Int;
	

	public function new(scene:Scene) {
		// Update the scene background color
		scene.clearColor = new Color4(0.8, 0.8, 0.8, 1.0);
		
		// Camera attached to the canvas
		var camera = new ArcRotateCamera("Camera", 0.67, 1.2, 150, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, -1), scene);
		light.intensity = 1;
		
		// Sky material
		var skyboxMaterial = new SkyMaterial("skyMaterial", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.freeze();
		
		// Sky mesh (box)
		var skybox = Mesh.CreateBox("skyBox", 2000.0, scene);
		skybox.material = skyboxMaterial;
		
		// Ground
		var ground = Mesh.CreateGround("ground", 1000, 1000, 1, scene);
		ground.material = new StandardMaterial("ground", scene);
		untyped ground.material.diffuseColor = Color3.FromInts(193, 181, 151);
		untyped ground.material.specularColor = Color3.Black();
		
		var trunkMaterial = new StandardMaterial("trunk", scene);
		trunkMaterial.diffuseColor = Color3.FromInts(229, 85, 13);
		trunkMaterial.specularColor = Color3.Black();
		
		var branchMaterial = new StandardMaterial("mat", scene);
		branchMaterial.diffuseColor = Color3.FromInts(47, 198, 33);
		branchMaterial.specularColor = Color3.Black();
		
		this.treeNumber = 20;
		// The list containing all trees
		this.trees = [];
		
		// The size (min/max) of the foliage
		this.minSizeBranch = 15;
		this.maxSizeBranch = 20;
		
		// The size (min/max) of the trunk
		this.minSizeTrunk = 10;
		this.maxSizeTrunk = 15;
		
		// The radius (min/max) of the trunk
		this.minRadius = 1;
		this.maxRadius = 5;
		
		// For all trees to create
		var size:Float = 0;
		var sizeTrunk:Float = 0;
		var radius:Float = 0;
		for (i in 0...this.treeNumber) {
			// Random parameters
			size = MathTools.RandomFloat(this.minSizeBranch, this.maxSizeBranch);
			sizeTrunk = MathTools.RandomFloat(this.minSizeTrunk, this.maxSizeTrunk);
			radius = MathTools.RandomFloat(this.minRadius, this.maxRadius);
			var x = MathTools.RandomFloat(-300, 300);
			var z = MathTools.RandomFloat(-300, 300);
			
			var tree:Mesh = null;
			// Tree creation !
			if (i % 2 == 0) {
				tree = SOTG.Generate(size, sizeTrunk, radius, trunkMaterial, branchMaterial, scene);
			}
			else {
				tree = SPTG.Generate(scene, trunkMaterial, branchMaterial);
				tree.scaling.set(0.5, 0.5, 0.5);
				tree.position.y = 2;
			}
			tree.position.x = x;
			tree.position.z = z;
			this.trees.push(tree);
		}
		
		//leaf material
		var green = new StandardMaterial("green", scene);
		green.diffuseColor = new Color3(0, 1, 0);
		green.backFaceCulling = false;
		
		//trunk and branch material
		var bark = new StandardMaterial("bark", scene);
		bark.diffuseColor = new Color3(0.48, 0.29, 0.15);	
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
