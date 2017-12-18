package com.babylonhx.math.polyclip.sweepline;

/**
 * haxeport: Krtolica Vujadin
 */

/**
 * EventQueue data structure.
 * @author Mahir Iqbal
 */
class EventQueue  {

	private var elements:Array<SweepEvent>;
	private var sorted:Bool;
	
	
	public function new() {
		elements = new Array<SweepEvent>(); 
		sorted = false;
	}
	
	// If already sorted use insertionSort on the inserted item.
	public inline function enqueue(obj:SweepEvent) {
		if (sorted) {
			var length:Int = elements.length;
			if (length == 0) {
				elements.push(obj);
			}
			
			elements.push(null); // Expand the Vector by one.
			
			var i:Int = length - 1;
			while (i >= 0 && compareSweepEvent(obj, elements[i]) == -1) {
				elements[i + 1] = elements[i];
				i--;
			}
			elements[i + 1] = obj;
		} 
		else {
			elements.push(obj);
		}
	}
	
	// IMPORTANT NOTE: This is not the same as the function in Sweepelements.
	// The ordering is reversed because push and pop are faster.
	private function compareSweepEvent(e1:SweepEvent, e2:SweepEvent):Int {
		if (e1.p.x > e2.p.x) { // Different x coordinate
			return -1;
		}
			
		if (e2.p.x > e1.p.x) { // Different x coordinate
			return 1;
		}
			
		if (!e1.p.equals(e2.p)) { // Different points, but same x coordinate. The event with lower y coordinate is processed first
			return (e1.p.y > e2.p.y) ? -1 : 1;
		}
			
		if (e1.isLeft != e2.isLeft) { // Same point, but one is a left endpoint and the other a right endpoint. The right endpoint is processed first
			return (e1.isLeft) ? -1 : 1;
		}
			
		// Same point, both events are left endpoints or both are right endpoints. The event associate to the bottom segment is processed first
		return e1.isAbove(e2.otherSE.p) ? -1 : 1;
	}
	
	public function dequeue():SweepEvent {
		if (!sorted) {
			sorted = true;
			elements.sort(compareSweepEvent);
		}
		
		return elements.pop();
	}		
	
	public function isEmpty():Bool {
		return elements.length == 0;
	}
	
	public function length():Int {
		return elements.length;
	}
	
}
