package samples;

import com.babylonhx.Scene;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Scalar;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.Material;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.FresnelParameters;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.loading.ctm.CTMFileLoader;
import com.babylonhx.engine.Engine;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Fresnel2 {
	
	static public var material:StandardMaterial;

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0.0, 0.0, 10.0, Vector3.Zero(), scene);
		camera.setPosition(new Vector3(0, 0, -150));
		camera.attachControl();
		
		scene.clearColor = new Color4(0, 0, 0, 1);
		
		var light = new PointLight("Omni0", new Vector3(-17.6, 18.8, -49.9), scene);
		light.intensity = 0.9;
		
		material = new StandardMaterial("mat", scene);
		material.diffuseColor  = new Color3(0, 0, 0);
		material.emissiveColor = new Color3(1, 1, 1);
		material.specularPower = 128;
		material.alpha         = 0.2;
		material.alphaMode     = Engine.ALPHA_PREMULTIPLIED;
		material.backFaceCulling = true;
		
		// Set opacity fresnel parameters
		var ofp = new FresnelParameters();
		ofp.power = 1.8;
		ofp.leftColor = Color3.White();
		ofp.rightColor = Color3.Black();
		material.opacityFresnelParameters = ofp;
		
		// Set emissive fresnel parameters
		var efp = new FresnelParameters();
		efp.power = 0.5;
		efp.leftColor = new Color3(0.6, 0.8, 0.9);
		efp.rightColor = Color3.FromInt(0x4ad7ff).scale(0.5);
		material.emissiveFresnelParameters = efp;
		
		// Mark fresnel parameters a dirty
		material.markAsDirty(Material.FresnelDirtyFlag);
		
		CTMFileLoader.load("assets/models/lady_with_primroses.ctm", scene, function(meshes:Array<Mesh>, triangleCount:Int) {
			meshes[0].material = material;
			meshes[0].position.y = -50;
			meshes[0].position.x = -10;
			
			var knot = Mesh.CreateTorusKnot("knot", 2, 0.7, 128, 64, 2, 3, scene);
			knot.scaling.set(8, 8, 8);
			knot.position.x = 70;
			knot.material = material;
			
			var sphere = Mesh.CreateSphere("sphere", 20, 50, scene);
			sphere.material = material;
			sphere.position.x = -70;
		});
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}