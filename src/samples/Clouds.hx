package samples;

import com.babylonhx.layer.Layer;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Clouds {

	/*public function new(scene:Scene) {
		// Creating background layer using a dynamic texture with 2D canvas
        var background = new Layer("back0", null, scene);
        background.texture = new DynamicTexture("dynamic texture", 512, scene, true);
        var textureContext = background.texture.getContext();
        var size = background.texture.getSize();

        textureContext.clearRect(0, 0, size.width, size.height);

        var gradient = textureContext.createLinearGradient(0, 0, 0, 512);
        gradient.addColorStop(0, "#1e4877");
        gradient.addColorStop(0.5, "#4584b4");

        textureContext.fillStyle = gradient;
        textureContext.fillRect(0, 0, 512, 512);
        background.texture.update();

        var camera = new FreeCamera("camera", new Vector3(0, -128, 0), scene);
        camera.fov = 30;
        camera.minZ = 1;
        camera.maxZ = 3000;

        var cloudMaterial = new ShaderMaterial("cloud", scene, {
            vertexElement: "vertexShaderCode",
            fragmentElement: "fragmentShaderCode",
        },
        {
            needAlphaBlending: true,
            attributes: ["position", "uv"],
            uniforms: ["worldViewProjection"],
            samplers: ["textureSampler"]
        });
        cloudMaterial.setTexture("textureSampler", new Texture("cloud.png", scene));
        cloudMaterial.setFloat("fogNear", -100);
        cloudMaterial.setFloat("fogFar", 3000);
        cloudMaterial.setColor3("fogColor", Color3.FromInts(69, 132, 180));

        // Create merged planes
        size = 128;
        var count = 8000;

        var globalVertexData = new VertexData();

        for (var i = 0; i < count; i++) {
            var planeVertexData = VertexData.CreatePlane(128);

            delete planeVertexData.normals; // We do not need normals

            // Transform
            var randomScaling = Math.random() * Math.random() * 1.5 + 0.5;
            var transformMatrix = Matrix.Scaling(randomScaling, randomScaling, 1.0);
            transformMatrix = transformMatrix.multiply(Matrix.RotationZ(Math.random() * Math.PI));
            transformMatrix = transformMatrix.multiply(Matrix.Translation(Math.random() * 1000 - 500, -Math.random() * Math.random() * 100, count - i));

            planeVertexData.transform(transformMatrix);

            // Merge
            globalVertexData.merge(planeVertexData);
        }

        var clouds = new Mesh("Clouds", scene);
        globalVertexData.applyToMesh(clouds);

        clouds.material = cloudMaterial;

        var clouds2 = clouds.clone();
        clouds2.position.z = -500;

        engine.runRenderLoop(function () {
            var cameraDepth = ((Date.now() - start_time) * 0.03) % 8000;

            camera.position.z = cameraDepth;

            scene.render();
        });
	}*/
	
}
