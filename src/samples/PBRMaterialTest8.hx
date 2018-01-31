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
class PBRMaterialTest8 {

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", -6 * Math.PI / 4, 2 * Math.PI / 4, 8, new Vector3(0, -.35, 0), scene);
		camera.attachControl();
		camera.radius = 16.8;
		camera.wheelPrecision = 20;
		
		var material = new PBRMaterial("pbr", scene);		
		material.reflectionTexture = new HDRCubeTexture("assets/img/parking.hdr", scene, 512);
		trace('hdr parsed');
		var image_7 = 'assets/img/pst_D.png';
		var image_9 = 'assets/img/pst_AO.png';
		var image_6 = 'assets/img/pst_N.png';
		var image_11 = 'assets/img/micro.jpg';
		var image_8 = 'assets/img/pst_SS.png';
		
		var texture_7 = new Texture(image_7, scene);
		texture_7.level = 1;
		texture_7.hasAlpha = false;
		var texture_9 = new Texture(image_9, scene);
		texture_9.level = 1;
		texture_9.hasAlpha = false;
		var texture_6 = new Texture(image_6, scene);
		texture_6.level = -1;
		texture_6.hasAlpha = false;
		var texture_11 = new Texture(image_11, scene);
		texture_11.level = 0.99;
		texture_11.hasAlpha = false;
		var texture_8 = new Texture(image_8, scene);
		texture_8.level = 0.5;
		texture_8.hasAlpha = false;
		
		material.albedoColor = Color3.White();
		material.reflectivityColor = Color3.White();
		material.emissiveColor = Color3.Black();
		material.ambientColor = Color3.White();
		material.albedoTexture = texture_7;
		
		material.albedoTexture.uOffset = 0;
		material.albedoTexture.vOffset = 0;
		material.albedoTexture.uScale = 4;
		material.albedoTexture.vScale = 2.23;
		material.albedoTexture.uAng = 0;
		material.albedoTexture.vAng = 0;
		material.albedoTexture.wAng = 0;
		material.albedoTexture.wrapU = 1;
		material.albedoTexture.wrapV = 1;
		
		material.ambientTexture = texture_9;		
		material.ambientTexture.uOffset = 0;
		material.ambientTexture.vOffset = 0;
		material.ambientTexture.uScale = 4;
		material.ambientTexture.vScale = 2.23;
		material.ambientTexture.uAng = 0;
		material.ambientTexture.vAng = 0;
		material.ambientTexture.wAng = 0;
		material.ambientTexture.wrapU = 1;
		material.ambientTexture.wrapV = 1;
		
		material.bumpTexture = texture_6;		
		material.bumpTexture.uOffset = 0;
		material.bumpTexture.vOffset = 0;
		material.bumpTexture.uScale = 4;
		material.bumpTexture.vScale = 2.23;
		material.bumpTexture.uAng = 0;
		material.bumpTexture.vAng = 0;
		material.bumpTexture.wAng = 0;
		material.bumpTexture.wrapU = 1;
		material.bumpTexture.wrapV = 1;
		
		material.microSurfaceTexture = texture_11;
		material.microSurfaceTexture.uScale *= 1;
		material.microSurfaceTexture.vScale *= 1;
		material.emissiveTexture = null;
		
		material.reflectivityTexture = texture_8;		
		material.reflectivityTexture.uOffset = 0;
		material.reflectivityTexture.vOffset = 0;
		material.reflectivityTexture.uScale = 4;
		material.reflectivityTexture.vScale = 2.23;
		material.reflectivityTexture.uAng = 0;
		material.reflectivityTexture.vAng = 0;
		material.reflectivityTexture.wAng = 0;
		material.reflectivityTexture.wrapU = 1;
		material.reflectivityTexture.wrapV = 1;
		
		material.metallicTexture = null;
		material.microSurface = 1.000;
		material.ambientTextureStrength = 1.000;
		material.useAlphaFromAlbedoTexture = false;
		material.refractionTexture = null;
		material.directIntensity = 0;
		material.environmentIntensity = 2.0300000000000002;
		material.cameraExposure = 1;
		material.cameraContrast = 1;
		material.specularIntensity = 1.000;
		material.emissiveIntensity = 0.500;
		material.useMicroSurfaceFromReflectivityMapAlpha =false;
		material.useSpecularOverAlpha = false;
		var mesh = Mesh.CreateSphere("sphere", 10, 10, scene);
		mesh.material = material;
		
		scene.getEngine().runRenderLoop(function () {
			scene.render();
		});
	}
	
}
