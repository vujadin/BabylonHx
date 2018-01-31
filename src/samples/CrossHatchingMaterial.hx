package samples;

import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.tools.ColorTools;
import com.babylonhx.tools.Tools;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.ShaderMaterial;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CrossHatchingMaterial {

	public function new(scene:Scene) {
			
		ShadersStore.Shaders.set("crossHatchingVertexShader", "" +
			"attribute vec3 position; \n" +
			"attribute vec3 normal; \n" + 
			"attribute vec2 uv; \n" + 
			
			"varying vec3 vNormal; \n" +
            "varying vec2 vUV; \n" +
            "varying float depth; \n" +
            "varying vec3 vPosition; \n" +
            "varying float nDotVP; \n" +
			
            "uniform vec2 repeat; \n" +
            "uniform float showOutline; \n" +
			"uniform vec3 lightPosition; \n" +
			"uniform mat4 worldViewProjection; \n" +
			
            "void main() { \n" +
			
            "    vec3 posInc = vec3(0.); \n" +
            "    if (showOutline == 1.) posInc = normal; \n" +
			
            "    vUV = repeat * uv; \n" +
			
            "    vec4 mvPosition = worldViewProjection * vec4(position + posInc, 1.0); \n" +
            "    gl_Position = mvPosition; \n" +
			
			"    vPosition = mvPosition.xyz; \n" +
            "    vNormal = normal; \n" +
            "    depth = (length(position.xyz) / 90.); \n" +
            "    depth = .5 + .5 * depth; \n" +
			
            "    nDotVP = max(0., dot(vNormal, normalize(vec3(lightPosition)))); \n" +
			
            "}"
		);
			
		ShadersStore.Shaders.set("crossHatchingPixelShader", "" +
			"uniform sampler2D hatch1; \n" +
            "uniform sampler2D hatch2; \n" +
            "uniform sampler2D hatch3; \n" +
            "uniform sampler2D hatch4; \n" +
            "uniform sampler2D hatch5; \n" +
            "uniform sampler2D hatch6; \n" +
            "uniform sampler2D paper; \n" +
            "uniform vec2 resolution; \n" +
            "uniform vec2 bkgResolution; \n" +
            "uniform vec3 lightPosition; \n" +
			
            "vec3 color = vec3(1., 0., 1.); \n" +
            "vec3 lightColor = vec3(1.); \n" +
			
            "varying vec2 vUV; \n" +
            "varying vec3 vNormal; \n" +
            "varying float depth; \n" +
            "varying vec3 vPosition; \n" +
            "varying float nDotVP; \n" +
			
            "uniform float ambientWeight; \n" +
            "uniform float diffuseWeight; \n" +
            "uniform float rimWeight; \n" +
            "uniform float specularWeight; \n" +
            "uniform float shininess; \n" +
            "uniform float invertRim; \n" +
            "uniform float solidRender; \n" +
            "uniform float showOutline; \n" +
            "uniform vec4 inkColor; \n" +
			
            "vec4 shade() { \n" +
			
            "    float diffuse = nDotVP; \n" +
            "    float specular = 0.; \n" +
            "    float ambient = 1.; \n" +
			
            "    vec3 n = normalize(vNormal); \n" +
			
            "    vec3 r = -reflect(lightPosition, n); \n" +
            "    r = normalize(r); \n" +
            "    vec3 v = -vPosition.xyz; \n" +
            "    v = normalize(v); \n" +
            "    float nDotHV = max(0., dot(r, v)); \n" +
			
            "    if (nDotVP != 0.) specular = pow(nDotHV, shininess); \n" +
            "    float rim = max(0., abs(dot(n, normalize(-vPosition.xyz)))); \n" +
            "    if (invertRim == 1.) rim = 1. - rim; \n" +
			
            "    float shading = ambientWeight * ambient + diffuseWeight * diffuse + rimWeight * rim + specularWeight * specular; \n" +
			
            "    /*if (solidRender == 1.0) return vec4(shading);*/ \n" +
			
            "    vec4 c = vec4(1. ,1., 1., 1.); \n" +
            "    float step = 1. / 6.; \n" +
            "    if (shading <= step) { \n" +
            "        c = mix(texture2D(hatch6, vUV), texture2D(hatch5, vUV), 6. * shading); \n" +
            "    } \n" +
            "    if (shading > step && shading <= 2. * step) { \n" +
            "        c = mix(texture2D(hatch5, vUV), texture2D(hatch4, vUV) , 6. * (shading - step)); \n" +
            "    } \n" +
            "    if (shading > 2. * step && shading <= 3. * step) { \n" +
            "        c = mix(texture2D(hatch4, vUV), texture2D(hatch3, vUV), 6. * (shading - 2. * step)); \n" +
            "    } \n" +
            "    if (shading > 3. * step && shading <= 4. * step) { \n" +
            "        c = mix(texture2D(hatch3, vUV), texture2D(hatch2, vUV), 6. * (shading - 3. * step)); \n" +
            "    } \n" +
            "    if (shading > 4. * step && shading <= 5. * step) { \n" +
            "        c = mix(texture2D(hatch2, vUV), texture2D(hatch1, vUV), 6. * (shading - 4. * step)); \n" +
            "    } \n" +
            "    if (shading > 5. * step) { \n" +
            "        c = mix(texture2D(hatch1, vUV), vec4(1.), 6. * (shading - 5. * step)); \n" +
            "    } \n" +
			
            "    vec4 src = mix(mix(inkColor, vec4(1.), c.r), c, .5); \n" +
			
            "    return src; \n" +
            "} \n" +
			
            "void main() { \n" +
			
            "    vec2 nUV = vec2(mod(gl_FragCoord.x, bkgResolution.x) / bkgResolution.x, mod(gl_FragCoord.y, bkgResolution.y) / bkgResolution.y); \n" +
            "    vec4 dst = vec4(texture2D(paper, nUV).rgb, 1.); \n" +
			
            "    vec4 src = (.5 * inkColor) * shade(); \n" +			
            "    vec4 c = src * dst; \n" +			
            "    gl_FragColor = vec4(c.rgb, 1.); \n" +
			
            "}"
		);
		
		var shaderMaterial = new ShaderMaterial("crossHatchingMat", scene, {
				vertex: "crossHatching",
				fragment: "crossHatching",
			}, {
				attributes: ["position", "normal", "uv"],
				uniforms: [
					"repeat", "lightPosition", "showOutline", "resolution", "bkgResolution", "lightPosition", "ambientWeight", "diffuseWeight",
					"rimWeight", "specularWeight", "shininess", "invertRim", "solidRender", "inkColor", "worldViewProjection"
				]
			}
		);
		shaderMaterial.setFloat("showOutline", 1);
		shaderMaterial.setFloat("ambientWeight", 0);
		shaderMaterial.setFloat("diffuseWeight", 0.49);
		shaderMaterial.setFloat("rimWeight", 0.46);
		shaderMaterial.setFloat("specularWeight", 1);
		shaderMaterial.setFloat("shininess", 49);
		shaderMaterial.setFloat("invertRim", 1);
		shaderMaterial.setVector4("inkColor", new Vector4(0.28, 0.65, 0.9, 1));
		//shaderMaterial.setFloat("solidRender", 0.0);
		shaderMaterial.setVector2("resolution", new Vector2(scene.getEngine().width, scene.getEngine().height));
		shaderMaterial.setVector2("bkgResolution", new Vector2(1024, 1024));
		shaderMaterial.setVector3("lightPosition", new Vector3(-100, 100, 0));
		
		shaderMaterial.setTexture("paper", new Texture("assets/img/paper4.jpg", scene));
		shaderMaterial.setTexture("hatch1", new Texture("assets/img/hatch_0.jpg", scene));
		shaderMaterial.setTexture("hatch2", new Texture("assets/img/hatch_1.jpg", scene));
		shaderMaterial.setTexture("hatch3", new Texture("assets/img/hatch_2.jpg", scene));
		shaderMaterial.setTexture("hatch4", new Texture("assets/img/hatch_3.jpg", scene));
		shaderMaterial.setTexture("hatch5", new Texture("assets/img/hatch_4.jpg", scene));
		shaderMaterial.setTexture("hatch6", new Texture("assets/img/hatch_5.jpg", scene));
		
		shaderMaterial.setVector2("repeat", new Vector2(20, 2));
		
		//Browser.document.body.style.backgroundImage = "url(assets/img/paper4.jpg)";
		
		var camera = new ArcRotateCamera("ArcRotateCamera", 1, 0.8, 5, new Vector3(0, 0, 0), scene);
		camera.attachControl();
		camera.lowerRadiusLimit = 1;
		camera.wheelPrecision = 20;
		
		scene.clearColor = new Color4(0, 0, 0, 0);
		
		var sphere = Mesh.CreateSphere("sphere", 10, 1, scene);
		sphere.material = shaderMaterial;
		
		var engine = scene.getEngine();
		
		/*scene.registerBeforeRender(function(_, _) {
			shaderMaterial.setFloat("showOutline", 1);
			shaderMaterial.setFloat("ambientWeight", 0);
			shaderMaterial.setFloat("diffuseWeight", 100 / 100);
			shaderMaterial.setFloat("rimWeight", 46 / 100);
			shaderMaterial.setFloat("specularWeight", 1);
			shaderMaterial.setFloat("shininess", 49);
			shaderMaterial.setFloat("invertRim", 1);
			shaderMaterial.setVector4("inkColor", new Vector4(0.28, 0.28, 0.64, 1));
			//shaderMaterial.setFloat("solidRender", 1.0);
			shaderMaterial.setVector2("resolution", new Vector2(engine.getRenderWidth(), engine.getRenderHeight()));
			shaderMaterial.setVector2("bkgResolution", new Vector2(600, 600));
			shaderMaterial.setVector3("lightPosition", new Vector3(-100, 100, 0));
			
			shaderMaterial.setTexture("paper", new Texture("assets/img/paper4.jpg", scene));
			shaderMaterial.setTexture("hatch1", new Texture("assets/img/hatch_0.jpg", scene));
			shaderMaterial.setTexture("hatch2", new Texture("assets/img/hatch_1.jpg", scene));
			shaderMaterial.setTexture("hatch3", new Texture("assets/img/hatch_2.jpg", scene));
			shaderMaterial.setTexture("hatch4", new Texture("assets/img/hatch_3.jpg", scene));
			shaderMaterial.setTexture("hatch5", new Texture("assets/img/hatch_4.jpg", scene));
			shaderMaterial.setTexture("hatch6", new Texture("assets/img/hatch_5.jpg", scene));
			
			shaderMaterial.setVector2("repeat", new Vector2(20, 2));
		});*/
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
		
	}
	
}
