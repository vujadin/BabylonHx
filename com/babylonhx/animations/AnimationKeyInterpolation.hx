package com.babylonhx.animations;

/**
 * @author Krtolica Vujadin
 */
@:enum abstract AnimationKeyInterpolation(Int) from Int to Int {
	
	/**
	 * Do not interpolate between keys and use the start key value only. Tangents are ignored.
	 */
	public var STEP = 1;
	
}
