package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Materials {

	public function new(scene:Scene) {
		//Create a light
		var light = new PointLight("Omni", new Vector3( -60, 60, 80), scene);
		
		//Create an Arc Rotate Camera - aimed negative z this time
		var camera = new ArcRotateCamera("Camera", Math.PI / 2, 1.0, 110, Vector3.Zero(), scene);
		camera.attachControl(this, true);
				
		//Creation of 6 spheres
		var sphere1 = Mesh.CreateSphere("Sphere1", 10, 9.0, scene);
		var sphere2 = Mesh.CreateSphere("Sphere2", 2, 9.0, scene);//Only two segments
		var sphere3 = Mesh.CreateSphere("Sphere3", 10, 9.0, scene);
		var sphere4 = Mesh.CreateSphere("Sphere4", 10, 9.0, scene);
		var sphere5 = Mesh.CreateSphere("Sphere5", 10, 9.0, scene);
		var sphere6 = Mesh.CreateSphere("Sphere6", 10, 9.0, scene);
		
		//Position the spheres
		sphere1.position.x = 40;
		sphere2.position.x = 25;
		sphere3.position.x = 10;
		sphere4.position.x = -5;
		sphere5.position.x = -20;
		sphere6.position.x = -35;
		
		//Creation of a plane
		var plane = Mesh.CreatePlane("plane", 120, scene);
		plane.position.y = -5;
		plane.rotation.x = Math.PI / 2;
				
		//Creation of a red material with alpha
		var materialSphere2 = new StandardMaterial("texture2", scene);
		materialSphere2.diffuseColor = new Color3(1, 0, 0); //Red
		materialSphere2.alpha = 0.3;
		
		//Creation of a material with an image texture
		var materialSphere3 = new StandardMaterial("texture3", scene);
		materialSphere3.diffuseTexture = new Texture("assets/img/misc.jpg", scene);
		
		//Creation of a material with translated texture
		var materialSphere4 = new StandardMaterial("texture4", scene);
		materialSphere4.diffuseTexture = new Texture("assets/img/misc.jpg", scene);
		materialSphere4.diffuseTexture.vOffset = 0.1;//Vertical offset of 10%
		materialSphere4.diffuseTexture.uOffset = 0.4;//Horizontal offset of 40%
		
		//Creation of a material with an alpha texture
		var materialSphere5 = new StandardMaterial("texture5", scene);
		materialSphere5.diffuseTexture = new Texture("assets/img/tree.png", scene);
		materialSphere5.diffuseTexture.hasAlpha = true;//Has an alpha
		
		//Creation of a material and show all the faces
		var materialSphere6 = new StandardMaterial("texture6", scene);
		materialSphere6.diffuseTexture = new Texture("assets/img/tree.png", scene);
		materialSphere6.diffuseTexture.hasAlpha = true;//Have an alpha
		materialSphere6.backFaceCulling = false;//Show all the faces of the element
		
		//Creation of a repeated textured material
		var materialPlane = new StandardMaterial("texturePlane", scene);
		materialPlane.diffuseTexture = new Texture("assets/img/grass.jpg", scene);
		materialPlane.diffuseTexture.uScale = 5.0;//Repeat 5 times on the Vertical Axes
		materialPlane.diffuseTexture.vScale = 5.0;//Repeat 5 times on the Horizontal Axes
		materialPlane.backFaceCulling = false;//Allways show the front and the back of an element
		
		//Creation of a material with wireFrame
		var materialSphere1 = new StandardMaterial("texture1", scene);
		materialSphere1.wireframe = true;
		//materialSphere1.alpha = 0.9;
		
		//Apply the materials to meshes
		sphere1.material = materialSphere1;
		sphere2.material = materialSphere2;
		
		sphere3.material = materialSphere3;
		sphere4.material = materialSphere4;
		
		sphere5.material = materialSphere5;
		sphere6.material = materialSphere6;
		
		plane.material = materialPlane;
				
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
