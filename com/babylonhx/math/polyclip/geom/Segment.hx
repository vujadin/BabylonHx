package com.babylonhx.math.polyclip.geom;
 
/**
 * ...
 * @haxeport Krtolica Vujadin
 */

/**
 * The Segment class is used to represent an edge of a polygon.
 * @author Mahir Iqbal
 */
class Segment {

	public var start:Vector2;
	public var end:Vector2;
	
	
	public function new(start:Vector2, end:Vector2) {
		this.start = start;
		this.end = end;
	}
	
}
