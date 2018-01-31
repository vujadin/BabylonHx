package samples;

import com.babylonhx.Scene;
import com.babylonhx.particles.ParticleSystem;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Quaternion;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.materials.lib.fur.FurMaterial;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.cameras.Camera;
import com.babylonhx.loading.SceneLoader;
import com.babylonhx.loading.plugins.BabylonFileLoader;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SponzaDynamicShadows {

	public function new(scene:Scene) {
		SceneLoader.Load("assets/models/sponza/", "SponzaDynamicShadows.babylon", scene.getEngine(), function(sc) {
			scene = sc;
			var node = scene.getMeshByName("litghtmesh");
			var particleSystem = new ParticleSystem("New Particle System", 1000, scene);
			particleSystem.emitter = node;
			particleSystem.name = "New Particle System";
			particleSystem.renderingGroupId = 0;
			particleSystem.emitRate = 200;
			particleSystem.manualEmitCount = -1;
			particleSystem.updateSpeed = 0.005;
			particleSystem.targetStopDuration = 0;
			particleSystem.disposeOnStop = false;
			particleSystem.minEmitPower = 0;
			particleSystem.maxEmitPower = 0.3;
			particleSystem.minLifeTime = 0.2;
			particleSystem.maxLifeTime = 0.5;
			particleSystem.minSize = 0.05;
			particleSystem.maxSize = 0.8;
			particleSystem.minAngularSpeed = 0;
			particleSystem.maxAngularSpeed = 6.283185307179586;
			particleSystem.layerMask = 268435455;
			particleSystem.blendMode = 0;
			particleSystem.forceDepthWrite = false;
			particleSystem.gravity = new Vector3(0, 0, 0);
			particleSystem.direction1 = new Vector3(-7, 8, 3);
			particleSystem.direction2 = new Vector3(7, 8, -3);
			particleSystem.minEmitBox = new Vector3(0, 0, 0);
			particleSystem.maxEmitBox = new Vector3(0, 0, 0);
			particleSystem.color1 = new Color4(0.7, 0.8, 0.5465114353377606, 1);
			particleSystem.color2 = new Color4(0.6707185797327061, 0.5, 0.23185333620389842, 1);
			particleSystem.colorDead = new Color4(0.2980971465478694, 0, 0.3312190517198549, 1);
			particleSystem.textureMask = new Color4(1, 1, 1, 1);
			particleSystem.id = "New Particle System";
			particleSystem.particleTexture = new Texture("assets/models/sponza/sparc.jpg", scene);
			untyped node.attachedParticleSystem = particleSystem;
			particleSystem.start();
			node = cast scene.getNodeByName("litghtmesh");
			node.position = new Vector3(2.5223299803446766, 2.0876, -3.525673483620715);
			node.rotation = new Vector3(0, 0, 0);
			node.rotationQuaternion = new Quaternion(0, 0, 0, -1);
			node.scaling = new Vector3(1, 1, 1);
			
			var shadowGenerator = scene.getLightByName("Omni002").getShadowGenerator();
			
			shadowGenerator.getShadowMap().refreshRate = 0;
			
			scene.activeCamera.attachControl();
			
			scene.getEngine().runRenderLoop(function () {
				scene.render();
			});
		});
	}
	
}