package com.babylonhx.math.polyclip.sweepline;

import com.babylonhx.math.polyclip.geom.Segment;
	
/**
 * ...
 * @haxeport Krtolica Vujadin
 */

/**
 * A container for SweepEvent data. A SweepEvent represents a location of interest (vertex between two polygon edges)
 * as the sweep line passes through the polygons.
 * @author Mahir Iqbal
 */
class SweepEvent {

	public var p:Vector2;
	public var isLeft:Bool; 		// Is the point the left endpoint of the segment (p, other->p)?
	public var polygonType:Int; 	// PolygonType to which this event belongs to: either PolygonClipper.SUBJECT, or PolygonClipper.CLIPPING
	public var otherSE:SweepEvent; 	// Event associated to the other endpoint of the segment
	
	/* 
	 * Does the segment (p, other->p) represent an inside-outside transition
	 * in the polygon for a vertical ray from (p.x, -infinite) that crosses the segment? 
	 */
	public var inOut:Bool;
	public var edgeType:Int; 		// The EdgeType. @see EdgeType.as
	
	public var inside:Bool; 		// Only used in "left" events. Is the segment (p, other->p) inside the other polygon?
	
	
	public function new(p:Vector2, isLeft:Bool, polyType:Int, otherSweepEvent:SweepEvent = null, edgeType:Int = 0) {
		this.p = p;
		this.isLeft = isLeft;
		polygonType = polyType;
		otherSE = otherSweepEvent;
		this.edgeType = edgeType;
	}
	
	public var segment(get, null):Segment;
	private function get_segment():Segment {
		return new Segment(p, otherSE.p);
	}
	
	// Checks if this sweep event is below point p.
	public function isBelow(x:Vector2):Bool {
		function signedArea(p0:Vector2, p1:Vector2, p2:Vector2):Float {
			return (p0.x - p2.x) * (p1.y - p2.y) - (p1.x - p2.x) * (p0.y - p2.y);
		}
		
		return (isLeft) ? (signedArea(p, otherSE.p, x) > 0) : (signedArea(otherSE.p, p, x) > 0);		
	}
	
	public function isAbove(x:Vector2):Bool {
		return !isBelow(x);
	}
	
}
