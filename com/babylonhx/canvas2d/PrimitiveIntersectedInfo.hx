package com.babylonhx.canvas2d;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Stores information about a Primitive that was intersected
 */
class PrimitiveIntersectedInfo {
	
	public var prim:Prim2DBase;
	public var intersectionLocation:Vector2;
	

	public function new(prim:Prim2DBase, intersectionLocation:Vecto2) {
		this.prim = prim;
		this.intersectionLocation = intersectionLocation;
	}
	
}
