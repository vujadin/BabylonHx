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
class PBRMaterialTest6 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -6 * Math.PI / 4, 2 * Math.PI / 4, 8, new Vector3(0, -.35, 0), scene);
		camera.attachControl();
		camera.radius = 16.8;
		camera.wheelPrecision = 20;
		
		var material = new PBRMaterial("pbr", scene);		
		material.reflectionTexture = new HDRCubeTexture("assets/img/environment.hdr", scene, 512);
		
		var image_1 = 'assets/img/RGBA.png';
		var image_2 = 'assets/img/splatNormal.png';
		var image_3 = 'assets/img/splatMR.png';
		
		var texture_1 = new Texture(image_1, scene);
		texture_1.level = 1;
		texture_1.hasAlpha = false;
		var texture_2 = new Texture(image_2, scene);
		texture_2.level = 0.64;
		texture_2.hasAlpha = false;
		var texture_3 = new Texture(image_3, scene);
		texture_3.level = 0.5;
		texture_3.hasAlpha = false;
		
		material.albedoColor = Color3.White();
		material.reflectivityColor = Color3.White();
		material.emissiveColor = Color3.Black();
		material.ambientColor = Color3.White();
		material.albedoTexture = texture_1;
		material.albedoTexture.uScale *= 1;
		material.albedoTexture.vScale *= 1;
		material.ambientTexture = null;
		material.bumpTexture = texture_2;
		
		material.bumpTexture.uOffset = 0;
		material.bumpTexture.vOffset = 0;
		material.bumpTexture.uScale = 5.8;
		material.bumpTexture.vScale = 1;
		material.bumpTexture.uAng = 0;
		material.bumpTexture.vAng = 0;
		material.bumpTexture.wAng = 0;
		material.bumpTexture.wrapU = 1;
		material.bumpTexture.wrapV = 1;
		
		material.microSurfaceTexture = null;
		material.emissiveTexture = null;
		material.reflectivityTexture = null;
		material.metallicTexture = texture_3;
		
		material.metallicTexture.uOffset = 0;
		material.metallicTexture.vOffset = 0;
		material.metallicTexture.uScale = 5.8;
		material.metallicTexture.vScale = 1;
		material.metallicTexture.uAng = 0;
		material.metallicTexture.vAng = 0;
		material.metallicTexture.wAng = 0;
		material.metallicTexture.wrapU = 1;
		material.metallicTexture.wrapV = 1;
		
		material.microSurface = 0.500;
		material.ambientTextureStrength = 0.500;
		material.useAlphaFromAlbedoTexture = false;
		material.refractionTexture = null;
		material.directIntensity = 0;
		material.environmentIntensity = 2.97;
		material.cameraExposure = 1;
		material.cameraContrast = 1;
		material.specularIntensity = 1.000;
		material.emissiveIntensity = 0.500;
		material.useMicroSurfaceFromReflectivityMapAlpha =false;
		material.metallic = 1.000;
		material.roughness = 0.100;
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
