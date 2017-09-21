package com.babylonhx.loading.gltf;

/**
 * @author Krtolica Vujadin
 */
typedef IGLTFAccessorSparseIndices = {
	
	> IGLTFProperty,
	bufferView:Int,
    ?byteOffset:Int,
    componentType:EComponentType;
	
}
