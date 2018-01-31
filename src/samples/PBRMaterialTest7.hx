package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.pbr.PBRMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialTest7 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -6 * Math.PI / 4, 2 * Math.PI / 4, 8, new Vector3(0, -.35, 0), scene);
		camera.attachControl();
		camera.radius = 16.8;
		camera.wheelPrecision = 20;
		
		var material = new PBRMaterial("pbr", scene);		
		material.reflectionTexture = new HDRCubeTexture("assets/img/parking.hdr", scene, 512);
		
		var image_9 = 'assets/img/si_AO.png';
		var image_7 = 'assets/img/si_D.png';
		
		var texture_9 = new Texture(image_9, scene);
		texture_9.level = 0.77;
		texture_9.hasAlpha = false;
		var texture_7 = new Texture(image_7, scene);
		texture_7.level = 1;
		texture_7.hasAlpha = false;
		var color_10 = Color3.FromInt(0x141414);
		
		material.albedoColor = color_10;
		material.reflectivityColor = Color3.White();
		material.emissiveColor = Color3.Black();
		material.ambientColor = Color3.White();
		material.albedoTexture = null;
		material.ambientTexture = texture_9;
		
		material.ambientTexture.uOffset = 0;
		material.ambientTexture.vOffset = 0;
		material.ambientTexture.uScale = 9.24;
		material.ambientTexture.vScale = 1.29;
		material.ambientTexture.uAng = 0;
		material.ambientTexture.vAng = 0;
		material.ambientTexture.wAng = 0;
		material.ambientTexture.wrapU = 1;
		material.ambientTexture.wrapV = 1;
		
		material.bumpTexture = null;
		material.microSurfaceTexture = null;
		material.emissiveTexture = null;
		material.reflectivityTexture = null;
		material.metallicTexture = texture_7;
		
		material.metallicTexture.uOffset = 0;
		material.metallicTexture.vOffset = 0;
		material.metallicTexture.uScale = 9.24;
		material.metallicTexture.vScale = 1.29;
		material.metallicTexture.uAng = 0;
		material.metallicTexture.vAng = 0;
		material.metallicTexture.wAng = 0;
		material.metallicTexture.wrapU = 1;
		material.metallicTexture.wrapV = 1;
		
		material.microSurface = 0.040;
		material.ambientTextureStrength = 1.000;
		material.useAlphaFromAlbedoTexture = false;
		material.alpha = 1;
		material.refractionTexture = material.reflectionTexture;
		material.indexOfRefraction = 0.44;
		material.directIntensity = 1.69;
		material.environmentIntensity = 1.83;
		material.cameraExposure = 1;
		material.cameraContrast = 1;
		material.specularIntensity = 0.810;
		material.emissiveIntensity = 0.500;
		material.useMicroSurfaceFromReflectivityMapAlpha = false;
		material.metallic = 1.000;
		material.roughness = 0.480;
		material.useRoughnessFromMetallicTextureGreen = true;
		material.useMetallnessFromMetallicTextureBlue = true;
		material.useRoughnessFromMetallicTextureAlpha = false;
		material.useMicroSurfaceFromReflectivityMapAlpha = false;
		material.useAutoMicroSurfaceFromReflectivityMap = false;
		material.useLightmapAsShadowmap = false;
		material.useAlphaFromAlbedoTexture = false;
		
		var torus = Mesh.CreateTorusKnot("knot", 2, 0.9, 128, 64, 2, 3, scene);
		torus.material = material;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
