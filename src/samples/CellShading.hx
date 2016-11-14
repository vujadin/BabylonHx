package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CellShading {
	
	var vertexShader = ["", 
		"// Attributes",
		"attribute vec3 position;",
		"attribute vec3 normal;",
		"attribute vec2 uv;",
		
		"// Uniforms",
		"uniform mat4 world;",
		"uniform mat4 viewProjection;",
		
		"// Normal",
		"varying vec3 vPositionW;",
		"varying vec3 vNormalW;",
		"varying vec2 vUV;",
		
		"void main(void) {",
		"vec4 outPosition = viewProjection * world * vec4(position, 1.0);",
		"gl_Position = outPosition;",
		
		"vPositionW = vec3(world * vec4(position, 1.0));",
		"vNormalW = normalize(vec3(world * vec4(normal, 0.0)));",
		
		"vUV = uv;",
		"}"
	];
	
	var fragmentShader = ["",
		"// Lights",
		"varying vec3 vPositionW;",
		"varying vec3 vNormalW;",
		"varying vec2 vUV;",
		
		"// Refs",
		"uniform float ToonThresholds[4];",
		"uniform float ToonBrightnessLevels[5];",
		"uniform vec3 vLightPosition;",
		"uniform vec3 vLightColor;",
		
		"uniform sampler2D textureSampler;",
		
		"void main(void) {",
		"// Light",
		"vec3 lightVectorW = normalize(vLightPosition - vPositionW);",
		
		"// diffuse",
		"float ndl = max(0., dot(vNormalW, lightVectorW));",
		
		"vec3 color = texture2D(textureSampler, vUV).rgb * vLightColor;",
		
		"if (ndl > ToonThresholds[0]) { color *= ToonBrightnessLevels[0]; }",
		"else if (ndl > ToonThresholds[1]) { color *= ToonBrightnessLevels[1]; }",
		"else if (ndl > ToonThresholds[2]) { color *= ToonBrightnessLevels[2]; }",
		"else if (ndl > ToonThresholds[3]) { color *= ToonBrightnessLevels[3]; }",
		"else { color *= ToonBrightnessLevels[4]; }",
		
		"gl_FragColor = vec4(color, 1.);",
		"}"
	];

	public function new(scene:Scene) {
		ShadersStore.Shaders.set("cellShading.vertex", vertexShader.join("\n"));
		ShadersStore.Shaders.set("cellShading.fragment", fragmentShader.join("\n"));
		
		var camera = new ArcRotateCamera("Camera", 0, Math.PI / 4, 40, Vector3.Zero(), scene);
		camera.attachControl();
		
		var light = new PointLight("Omni", new Vector3(20, 100, 2), scene);
		
		var sphere = Mesh.CreateSphere("Sphere0", 32, 3, scene);
		var cylinder = Mesh.CreateCylinder("Sphere1", 5, 3, 2, 32, 1, scene);
		var torus = Mesh.CreateTorus("Sphere2", 3, 1, 32, scene);
		
		var cellShadingMaterial = new ShaderMaterial("cellShading", scene, "cellShading",
		{
			uniforms: ["world", "viewProjection"],
			samplers: ["textureSampler"]
		});
		cellShadingMaterial.setTexture("textureSampler", new Texture("assets/img/grassn.png", scene))
						   .setVector3("vLightPosition", light.position)
						   .setFloats("ToonThresholds", [0.95, 0.5, 0.2, 0.03])
						   .setFloats("ToonBrightnessLevels", [1.0, 0.8, 0.6, 0.35, 0.01])
						   .setColor3("vLightColor", light.diffuse);
		
		sphere.material = cellShadingMaterial;
		sphere.position = new Vector3(-10, 0, 0);
		cylinder.material = cellShadingMaterial;
		torus.material = cellShadingMaterial;
		torus.position = new Vector3(10, 0, 0);
		
		// Animations
		var alpha = 0.0;
		scene.registerBeforeRender(function(_, _) {
			sphere.rotation.y = alpha;
			sphere.rotation.x = alpha;
			cylinder.rotation.y = alpha;
			cylinder.rotation.x = alpha;
			torus.rotation.y = alpha;
			torus.rotation.x = alpha;
			
			alpha += 0.05;
		});
		
		scene.getEngine().runRenderLoop(function() {
            scene.render();
        });
	}
	
}