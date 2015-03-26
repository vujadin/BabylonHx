package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CustomRenderTarget {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, Vector3.Zero(), scene);
		var material = new StandardMaterial("kosh", scene);
		material.diffuseColor = Color3.Purple();
		var light = new PointLight("Omni0", new Vector3(-17.6, 18.8, -49.9), scene);
		
		camera.attachControl(this);
		camera.setPosition(new Vector3(-15, 10, -20));
		camera.minZ = 1.0;
		camera.maxZ = 120.0;
		
		// Skybox
		var skybox = Mesh.CreateBox("skyBox", 100.0, scene);
		var skyboxMaterial = new StandardMaterial("skyBox", scene);
		skyboxMaterial.backFaceCulling = false;
		skyboxMaterial.reflectionTexture = new CubeTexture("assets/img/skybox/skybox", scene);
		skyboxMaterial.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
		skyboxMaterial.diffuseColor = new Color3(0, 0, 0);
		skyboxMaterial.specularColor = new Color3(0, 0, 0);
		skybox.material = skyboxMaterial;
		
		// depth material
		ShadersStore.Shaders.set("depth.vertex", "#ifdef GL_ES\n" +
			"precision highp float;\n" +
			"#endif\n" +
			"attribute vec3 position;\n" +
			"uniform mat4 worldViewProjection;\n" +
			"void main(void) {\n" +
			"gl_Position = worldViewProjection * vec4(position, 1.0);\n" +
			"}");
		ShadersStore.Shaders.set("depth.fragment", "#ifdef GL_ES\n" +
			"precision highp float;\n" +
			"#endif\n" +
			"void main(void) {\n" +
			"float depth =  1.0 - (2.0 / (100.0 + 1.0 - gl_FragCoord.z * (100.0 - 1.0)));\n" +
			"gl_FragColor = vec4(depth, depth, depth, 1.0);\n" +
			"}");
			
		var depthMaterial = new ShaderMaterial("depth", scene, "depth",
			{
				attributes: ["position"],
				uniforms: ["worldViewProjection"]
			});
			
		depthMaterial.backFaceCulling = false;
		
		// Plane
		var plane = Mesh.CreatePlane("map", 10, scene);
		plane.billboardMode = AbstractMesh.BILLBOARDMODE_ALL;
		plane.scaling.y = 1.0 / scene.getEngine().getAspectRatio(scene.activeCamera);
		
		// Render target
		var renderTarget = new RenderTargetTexture("depth", 1024, scene);
		renderTarget.renderList.push(skybox);
		scene.customRenderTargets.push(renderTarget);
		
		renderTarget.onBeforeRender = function () {
			for (index in 0...renderTarget.renderList.length) {
				renderTarget.renderList[index]._savedMaterial = renderTarget.renderList[index].material;
				renderTarget.renderList[index].material = depthMaterial;
			}
		}
		
		renderTarget.onAfterRender = function () {
			// Restoring previoux material
			for (index in 0...renderTarget.renderList.length) {
				renderTarget.renderList[index].material = renderTarget.renderList[index]._savedMaterial;
			}
		}
		
		// Spheres
		var spheresCount:Int = 20;
		var alpha = 0.0;
		for (index in 0...spheresCount) {
			var sphere = Mesh.CreateSphere("Sphere" + index, 32, 3, scene);
			sphere.position.x = 10 * Math.cos(alpha);
			sphere.position.z = 10 * Math.sin(alpha);
			sphere.material = material;
			
			alpha += (2 * Math.PI) / spheresCount;
			
			renderTarget.renderList.push(sphere);
		}
		
		// Plane material
		var mat = new StandardMaterial("plan mat", scene);
		mat.diffuseColor = Color3.Black();
		mat.specularColor = Color3.Black();
		mat.emissiveTexture = renderTarget;
		
		plane.material = mat;
		
		// Animations
		scene.registerBeforeRender(function () {
			camera.alpha += 0.01 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}