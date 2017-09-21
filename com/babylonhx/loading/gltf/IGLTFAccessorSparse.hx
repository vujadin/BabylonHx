package com.babylonhx.loading.gltf;

/**
 * @author Krtolica Vujadin
 */
typedef IGLTFAccessorSparse = {
	
	> IGLTFProperty,
	count:Int,
	indices:IGLTFAccessorSparseIndices,
	values:IGLTFAccessorSparseValues;
	
}
