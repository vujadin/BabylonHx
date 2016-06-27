package com.babylonhx.culling.octrees;

/**
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.IOctreeContainer') interface IOctreeContainer<T:ISmartArrayCompatible> {
	
	var blocks:Array<OctreeBlock<T>>;
	
}