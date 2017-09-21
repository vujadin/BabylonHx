package com.babylonhx.loading.gltf;

/**
 * @author Krtolica Vujadin
 */
typedef IGLTFAnimationSampler = {
	
	> IGLTFProperty,
	input:Int,
	?interpolation:String,
	output:Int;
	
}
