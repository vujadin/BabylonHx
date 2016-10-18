package com.babylonhx.canvas2d.engine;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Main class used for the Primitive Intersection API
 */
class IntersectInfo2D {
	
	// Input settings, to setup before calling an intersection related method

	/**
	 * Set the pick position, relative to the primitive where the intersection test is made
	 */
	public var pickPosition:Vector2;

	/**
	 * If true the intersection will stop at the first hit, if false all primitives will be tested and the 
	 * intersectedPrimitives array will be filled accordingly (false default)
	 */
	public var findFirstOnly:Bool;

	/**
	 * If true the intersection test will also be made on hidden primitive (false default)
	 */
	public var intersectHidden:Bool;

	// Intermediate data, don't use!
	public var _globalPickPosition:Vector2;
	public var _localPickPosition:Vector2;

	// Output settings, up to date in return of a call to an intersection related method

	/**
	 * The topmost intersected primitive
	 */
	public var topMostIntersectedPrimitive:PrimitiveIntersectedInfo;

	/**
	 * The array containing all intersected primitive, in no particular order.
	 */
	public var intersectedPrimitives:Array<PrimitiveIntersectedInfo>;

	/**
	 * true if at least one primitive intersected during the test
	 */
	public var isIntersected(get, never):Bool;
	private function get_isIntersected():Bool {
		return this.intersectedPrimitives != null && this.intersectedPrimitives.length > 0;
	}
	

	public function new() {
		this.findFirstOnly = false;
		this.intersectHidden = false;
		this.pickPosition = Vector2.Zero();
	}

	public function isPrimIntersected(prim:Prim2DBase):Vector2 {
		for (cur in this.intersectedPrimitives) {
			if (cur.prim == prim) {
				return cur.intersectionLocation;
			}
		}
		
		return null;
	}

	// Internals, don't use
	private function _exit(firstLevel:Bool) {
		if (firstLevel) {
			this._globalPickPosition = null;
		}
	}
	
}
