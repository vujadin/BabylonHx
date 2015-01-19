package com.babylonhx.culling.octrees;

/**
 * @author Krtolica Vujadin
 */

interface IOctreeContainer<T> {
	var blocks:Array<OctreeBlock<T>>;
}