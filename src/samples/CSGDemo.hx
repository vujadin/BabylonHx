package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.materials.MultiMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.csg.CSG;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CSGDemo {

	public function new(scene:Scene) {
		var light = new DirectionalLight("dir01", new Vector3(0, -0.5, -1.0), scene);
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
		camera.attachControl(this);
		camera.setPosition(new Vector3(10, 10, 10));
		light.position = new Vector3(20, 150, 70);
		camera.minZ = 10.0;
		
		scene.ambientColor = new Color3(0.3, 0.3, 0.3);
		
		var sourceMat = new StandardMaterial("sourceMat", scene);
		sourceMat.wireframe = true;
		sourceMat.backFaceCulling = false;
		
		var a = Mesh.CreateSphere("sphere", 16, 4, scene);
		var b = Mesh.CreateBox("box", 4, scene);
		var c = Mesh.CreateBox("box", 4, scene);
		
		a.material = sourceMat;
		b.material = sourceMat;
		c.material = sourceMat;
		
		a.position.y += 5;
		b.position.y += 2.5;
		c.position.y += 3.5;
		c.rotation.y += Math.PI / 8.0;
		
		var aCSG = CSG.FromMesh(a);
		var bCSG = CSG.FromMesh(b);
		var cCSG = CSG.FromMesh(c);
		
		// Set up a MultiMaterial
		var mat0 = new StandardMaterial("mat0", scene);
		var mat1 = new StandardMaterial("mat1", scene);
		
		mat0.diffuseColor.copyFromFloats(0.8, 0.2, 0.2);
		mat0.backFaceCulling = false;
		
		mat1.diffuseColor.copyFromFloats(0.2, 0.8, 0.2);
		mat1.backFaceCulling = false;
		
		var subCSG:CSG = bCSG.subtract(aCSG);
		var newMesh = subCSG.toMesh("csg", mat0, scene);
		newMesh.position = new Vector3( -10, 0, 0);
		
		subCSG = aCSG.subtract(bCSG);
		newMesh = subCSG.toMesh("csg2", mat0, scene);
		newMesh.position = new Vector3(10, 0, 0);
		
		subCSG = aCSG.intersect(bCSG);
		newMesh = subCSG.toMesh("csg3", mat0, scene);
		newMesh.position = new Vector3(0, 0, 10);
		
		// Submeshes are built in order : mat0 will be for the first cube, and mat1 for the second
		var multiMat = new MultiMaterial("multiMat", scene);
		multiMat.subMaterials.push(mat0);
		multiMat.subMaterials.push(mat1);
		
		// Last parameter to true means you want to build 1 subMesh for each mesh involved
		subCSG = bCSG.subtract(cCSG);
		newMesh = subCSG.toMesh("csg4", multiMat, scene, true);
		newMesh.position = new Vector3(0, 0, -10);
		
		var lines = Mesh.CreateLines("lines", [
			new Vector3(-10, 0, 0),
			new Vector3(10, 0, 0),
			new Vector3(0, 0, -10),
			new Vector3(0, 0, 10)
		], scene);
		
		scene.registerBeforeRender(function () {
			camera.alpha += 0.01 * scene.getAnimationRatio();
		});
	}
	
}