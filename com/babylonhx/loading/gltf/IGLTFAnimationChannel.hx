package com.babylonhx.loading.gltf;

/**
 * @author Krtolica Vujadin
 */
typedef IGLTFAnimationChannel = {
	
	> IGLTFProperty,
	sampler:Int,
    target:IGLTFAnimationChannelTarget;
	
}
