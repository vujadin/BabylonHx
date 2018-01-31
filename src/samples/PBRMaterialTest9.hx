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
class PBRMaterialTest9 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -6 * Math.PI / 4, 2 * Math.PI / 4, 8, new Vector3(0, -.35, 0), scene);
		camera.attachControl();
		camera.radius = 16.8;
		camera.wheelPrecision = 20;
		
		var hdrTexture = new HDRCubeTexture("assets/img/forest.hdr", scene, 512);
		
		scene.imageProcessingConfiguration.exposure = 0.9;
		scene.imageProcessingConfiguration.contrast = 1.6;
		
		// Skybox
		scene.createDefaultSkybox(hdrTexture, true, 1000, 0.6);
		
		var material = new PBRMaterial("pbr", scene);		
		material.reflectionTexture = hdrTexture;
		
		var image_11 = 'assets/img/ll_D.png';
		var image_9 = 'assets/img/ll_AO.png';
		var image_7 = 'assets/img/ll_N.png';
		var image_6 = 'assets/img/ll_SS.png';
		var texture_11 = new Texture(image_11, scene);
		texture_11.level = 1;
		texture_11.hasAlpha = false;
		var texture_9 = new Texture(image_9, scene);
		texture_9.level = 1;
		texture_9.hasAlpha = false;
		var texture_7 = new Texture(image_7, scene);
		texture_7.level = -0.88;
		texture_7.hasAlpha = false;
		var texture_6 = new Texture(image_6, scene);
		texture_6.level = 1;
		texture_6.hasAlpha = false;
		var color_8 = Color3.FromInt(0xa3a3a3);
		
		material.albedoColor = color_8;
		material.reflectivityColor = Color3.White();
		material.emissiveColor = Color3.Black();
		material.ambientColor = Color3.White();
		material.albedoTexture = texture_11;
		material.albedoTexture.uOffset = 0;
		material.albedoTexture.vOffset = 0;
		material.albedoTexture.uScale = 85;
		material.albedoTexture.vScale = 10;
		material.albedoTexture.uAng = 0;
		material.albedoTexture.vAng = 0;
		material.albedoTexture.wAng = 0;
		material.albedoTexture.wrapU = 1;
		material.albedoTexture.wrapV = 1;
		
		material.ambientTexture = texture_9;
		material.ambientTexture.uOffset = 0;
		material.ambientTexture.vOffset = 0;
		material.ambientTexture.uScale = 85;
		material.ambientTexture.vScale = 10;
		material.ambientTexture.uAng = 0;
		material.ambientTexture.vAng = 0;
		material.ambientTexture.wAng = 0;
		material.ambientTexture.wrapU = 1;
		material.ambientTexture.wrapV = 1;
		
		material.bumpTexture = texture_7;
		material.bumpTexture.uOffset = 0;
		material.bumpTexture.vOffset = 0;
		material.bumpTexture.uScale = 85;
		material.bumpTexture.vScale = 10;
		material.bumpTexture.uAng = 0;
		material.bumpTexture.vAng = 0;
		material.bumpTexture.wAng = 0;
		material.bumpTexture.wrapU = 1;
		material.bumpTexture.wrapV = 1;		
		
		material.microSurfaceTexture = null;
		material.emissiveTexture = null;
		
		material.reflectivityTexture = texture_6;
		material.reflectivityTexture.uOffset = 0;
		material.reflectivityTexture.vOffset = 0;
		material.reflectivityTexture.uScale = 85;
		material.reflectivityTexture.vScale = 10;
		material.reflectivityTexture.uAng = 0;
		material.reflectivityTexture.vAng = 0;
		material.reflectivityTexture.wAng = 0;
		material.reflectivityTexture.wrapU = 1;
		material.reflectivityTexture.wrapV = 1;
		
		material.metallicTexture = null;
		material.microSurface = 0.340;
		material.ambientTextureStrength = 0.780;
		material.useAlphaFromAlbedoTexture = false;
		material.refractionTexture = null;
		material.directIntensity = 0;
		material.environmentIntensity = 3.17;
		material.cameraExposure = 1;
		material.cameraContrast = 1;
		material.specularIntensity = 1.000;
		material.emissiveIntensity = 0.500;
		material.useMicroSurfaceFromReflectivityMapAlpha =false;
		material.useSpecularOverAlpha = false;
		
		var torus = Mesh.CreateTorusKnot("knot", 2, 0.7, 128, 64, 2, 3, scene);
		torus.material = material;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}