package com.babylonhx.culling;

import com.babylonhx.math.Plane;

/**
 * @author Krtolica Vujadin
 */
interface ICullable {
	
	function isInFrustum(frustumPlanes:Array<Plane>):Bool;
	function isCompletelyInFrustum(frustumPlanes:Array<Plane>):Bool;
	
}
