package com.babylonhx.loading.gltf;

/**
 * @author Krtolica Vujadin
 */
typedef IGLTFAccessor = {
	
	> IGLTFChildRootProperty,
	?bufferView:Int,
	?byteOffset:Int,
	componentType:EComponentType,
	?normalized:Bool,
	?count:Int,
	type:String,
	max:Array<Float>,
	min:Array<Float>,
	?sparse:IGLTFAccessorSparse;
	
}
