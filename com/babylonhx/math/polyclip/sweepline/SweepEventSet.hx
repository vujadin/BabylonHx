package com.babylonhx.math.polyclip.sweepline;

/**
 * ...
 * @haxeport Krtolica Vujadin
 */

/**
 * This is the data structure that simulates the SweepLine as it parses through
 * EventQueue, which holds the events sorted from left to right (x-coordinate).
 * @author Mahir Iqbal
 */
class SweepEventSet {

	public var eventSet:Array<SweepEvent>;
	
	
	public function new() {
		eventSet = new Array<SweepEvent>();
	}
	
	public function remove(key:SweepEvent) {
		var keyIndex:Int = Lambda.indexOf(eventSet, key);
		if (keyIndex == -1) {
			return;
		}
		
		eventSet.splice(keyIndex, 1);
	}
	
	public function insert(item:SweepEvent):Int {
		var length:Int = eventSet.length;
		if (length == 0) {
			eventSet.push(item);
			return 0;
		}
		
		eventSet.push(null); // Expand the Vector by one.
		
		var i:Int = length - 1;
		while (i >= 0 && segmentCompare(item, eventSet[i])) {  // reverseSC(eventSet[i], item) == 1)
			eventSet[i + 1] = eventSet[i];
			i--;
		}
		eventSet[i + 1] = item;
		
		return i + 1;
	}
	
	private function segmentCompare(e1:SweepEvent, e2:SweepEvent):Bool {
		function signedArea(p0:Vector2, p1:Vector2, p2:Vector2):Float {
			return (p0.x - p2.x) * (p1.y - p2.y) - (p1.x - p2.x) * (p0.y - p2.y);
		}
		
		if (e1 == e2) {
			return false;
		}
		
		if (signedArea(e1.p, e1.otherSE.p, e2.p) != 0 || signedArea(e1.p, e1.otherSE.p, e2.otherSE.p) != 0) {
			if (e1.p.equals(e2.p)) {
				return e1.isBelow(e2.otherSE.p);
			}
			
			if (compareSweepEvent(e1, e2)) {
				return e2.isAbove(e1.p);
			}
			
			return e1.isBelow(e2.p);
		}
		
		if (e1.p.equals(e2.p)) {  // Segments colinear
			return false;
		}
		
		return compareSweepEvent(e1, e2);		
	}
	
	// Should only be called by segmentCompare
	private function compareSweepEvent(e1:SweepEvent, e2:SweepEvent):Bool {
		if (e1.p.x > e2.p.x) {  // Different x coordinate
			return true;
		}
			
		if (e2.p.x > e1.p.x) {  // Different x coordinate
			return false;
		}
			
		if (!e1.p.equals(e2.p)) {  // Different points, but same x coordinate. The event with lower y coordinate is processed first
			return e1.p.y > e2.p.y;
		}
			
		if (e1.isLeft != e2.isLeft) {  // Same point, but one is a left endpoint and the other a right endpoint. The right endpoint is processed first
			return e1.isLeft;
		}
			
		// Same point, both events are left endpoints or both are right endpoints. The event associate to the bottom segment is processed first
		return e1.isAbove(e2.otherSE.p);
	}
	
}
