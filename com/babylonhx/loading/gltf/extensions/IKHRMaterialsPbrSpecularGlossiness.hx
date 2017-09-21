package com.babylonhx.loading.gltf.extensions;

/**
 * @author Krtolica Vujadin
 */
typedef IKHRMaterialsPbrSpecularGlossiness {
	
	var diffuseFactor:Array<Float>;
	var diffuseTexture:IGLTFTextureInfo;
	var specularFactor:Array<Float>;
	var glossinessFactor:Float;
	var specularGlossinessTexture:IGLTFTextureInfo;
  
}
