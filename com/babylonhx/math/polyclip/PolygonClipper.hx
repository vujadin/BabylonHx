package com.babylonhx.math.polyclip;

import com.babylonhx.math.polyclip.sweepline.SweepEvent;
import com.babylonhx.math.polyclip.sweepline.EventQueue;
import com.babylonhx.math.polyclip.sweepline.SweepEventSet;

import com.babylonhx.math.polyclip.geom.Polygon;
import com.babylonhx.math.polyclip.geom.Segment;

import com.babylonhx.math.polyclip.Connector;
import com.babylonhx.math.polyclip.geom.Contour;

/**
 * ...
 * haxeport: Krtolica Vujadin
 */

/**
 * This class contains methods for computing clipping operations on polygons. 
 * It implements the algorithm for polygon intersection given by Francisco Martínez del Río.
 * @see http://wwwdi.ujaen.es/~fmartin/bool_op.html
 * @author Mahir Iqbal
 */

typedef IntersectResult = {
	max: Int,
	Vector21: Vector2,
	Vector22: Vector2
}

class PolygonClipper {

	private var subject:Polygon;
	private var clipping:Polygon;
	
	private var eventQueue:EventQueue;
	
	private static var SUBJECT:Int = 0;
	private static var CLIPPING:Int = 1;
	
	
	public function new(subject:Polygon, clipping:Polygon) {
		this.subject = subject;
		this.clipping = clipping;
		
		eventQueue = new EventQueue();
	}
	
	/**
	 * Computes the polygon operation given by operation.
	 * @see PolygonOp for the operation codes.
	 * @param	operation	A value specifying which boolean operation to compute.
	 * @return	The resulting polygon from the specified clipping operation.
	 */
	public function compute(operation:Int):Polygon {
		var result:Polygon = null;
		
		if (subject.contours.length * clipping.contours.length == 0) {
			if (operation == PolygonOp.DIFFERENCE) {
				result = subject;
			}
			else if (operation == PolygonOp.UNION) {
				result = (subject.contours.length == 0) ? clipping : subject;
			}
			
			return result;
		}
		
		var subjectBB:Rectangle = subject.boundingBox;
		var clippingBB:Rectangle = clipping.boundingBox;
		
		if (!subjectBB.intersects(clippingBB)) {
			if (operation == PolygonOp.DIFFERENCE) {
				result = subject;
			}
			if (operation == PolygonOp.UNION) {
				result = subject;
				for(c in clipping.contours) {
					result.addContour(c);
				}
			}
			
			return result;
		}
		
		// Add each segment to the eventQueue, sorted from left to right.
		for (sCont in subject.contours) {
			var len = sCont.getPoints().length;
			for (pParse1 in 0...len) {
				processSegment(sCont.getSegment(pParse1), SUBJECT);
			}
		}
		
		for (cCont in clipping.contours) {
			var len = cCont.getPoints().length;
			for (pParse2 in 0...len) {
				processSegment(cCont.getSegment(pParse2), CLIPPING);
			}
		}
		
		var connector:Connector = new Connector();
		
		// This is the SweepLine. That is, we go through all the polygon edges
		// by sweeping from left to right.
		var S:SweepEventSet = new SweepEventSet();
		
		var e:SweepEvent;
		var MINMAX_X:Float = Math.min(subjectBB.right, clippingBB.right);
		
		var prev:SweepEvent, next:SweepEvent;
		
		while (!eventQueue.isEmpty()) {
			prev = null;
			next = null;
			
			e = eventQueue.dequeue();
			
			if ((operation == PolygonOp.INTERSECTION && (e.p.x > MINMAX_X)) || (operation == PolygonOp.DIFFERENCE && e.p.x > subjectBB.right)) {
				return connector.toPolygon();
			}
				
			if (operation == PolygonOp.UNION && (e.p.x > MINMAX_X)) {
				if (!e.isLeft) {
					connector.add(e.segment);
				}
				
				while (!eventQueue.isEmpty()) {
					e = eventQueue.dequeue();
					if (!e.isLeft) {
						connector.add(e.segment);
					}
				}
				
				return connector.toPolygon();
			}
			
			if (e.isLeft) {
				var pos:Int = S.insert(e);
				
				prev = (pos > 0) ? S.eventSet[pos - 1] : null;
				next = (pos < S.eventSet.length - 1) ? S.eventSet[pos + 1] : null;				
				
				if (prev == null) {
					e.inside = e.inOut = false;
				} 
				else if (prev.edgeType != EdgeType.NORMAL) {
					if (pos - 2 < 0) {
						// Not sure how to handle the case when pos - 2 < 0, but judging
						// from the C++ implementation this looks like how it should be handled.
						e.inside = e.inOut = false;
						if (prev.polygonType != e.polygonType) {
							e.inside = true;
						}
						else {
							e.inOut = true;
						}
					} 
					else {						
						var prevTwo:SweepEvent = S.eventSet[pos - 2];						
						if (prev.polygonType == e.polygonType) {
							e.inOut = !prev.inOut;
							e.inside = !prevTwo.inOut;
						} 
						else {
							e.inOut = !prevTwo.inOut;
							e.inside = !prev.inOut;
						}
					}
				} 
				else if (e.polygonType == prev.polygonType) {
					e.inside = prev.inside;
					e.inOut = !prev.inOut;
				} 
				else {
					e.inside = !prev.inOut;
					e.inOut = prev.inside;
				}
				
				if (next != null) {
					possibleIntersection(e, next);
				}
				
				if (prev != null) {
					possibleIntersection(e, prev);
				}
			} 
			else {
				var index = 0;
				for (evt in 0...S.eventSet.length) {
					if (e.otherSE == S.eventSet[evt]) index = evt;
				}
				var otherPos:Int = index;
				
				if (otherPos != -1) {
					prev = (otherPos > 0) ? S.eventSet[otherPos - 1] : null;
					next = (otherPos < S.eventSet.length - 1) ? S.eventSet[otherPos + 1] : null;
				}
				
				switch (e.edgeType) {
					case EdgeType.NORMAL:
						switch (operation) {
							case (PolygonOp.INTERSECTION):
								if (e.otherSE.inside) {
									connector.add(e.segment);
								}
								
							case (PolygonOp.UNION):
								if (!e.otherSE.inside) {
									connector.add(e.segment);
								}
								
							case (PolygonOp.DIFFERENCE):
								if (((e.polygonType == SUBJECT) && (!e.otherSE.inside)) || (e.polygonType == CLIPPING && e.otherSE.inside)) {
									connector.add(e.segment);
								}
						}
					case (EdgeType.SAME_TRANSITION):
						if (operation == PolygonOp.INTERSECTION || operation == PolygonOp.UNION) {
							connector.add(e.segment);
						}
						
					case (EdgeType.DIFFERENT_TRANSITION):
						if (operation == PolygonOp.DIFFERENCE) {
							connector.add(e.segment);
						}
				}
				
				if (otherPos != -1) {
					S.remove(S.eventSet[otherPos]);
				}
					
				if (next != null && prev != null) {
					possibleIntersection(next, prev);				
				}
			}
		}
		
		return connector.toPolygon();
	}
	
	private function findIntersection(seg0:Segment, seg1:Segment):IntersectResult {
		var pi0:Vector2 = new Vector2();
		var pi1:Vector2 = new Vector2();
		
		var p0:Vector2 = seg0.start;
		var d0:Vector2 = new Vector2(seg0.end.x - p0.x, seg0.end.y - p0.y);
		var p1:Vector2 = seg1.start;
		var d1:Vector2 = new Vector2(seg1.end.x - p1.x, seg1.end.y - p1.y);
		var sqrEpsilon:Float = 0.0000001; // Antes 0.001
		var E:Vector2 = new Vector2(p1.x - p0.x, p1.y - p0.y);
		var kross:Float = d0.x * d1.y - d0.y * d1.x;
		var sqrKross:Float = kross * kross;
		var sqrLen0:Float = d0.length();
		var sqrLen1:Float = d1.length();
		
		if (sqrKross > sqrEpsilon * sqrLen0 * sqrLen1) {
			// lines of the segments are not parallel
			var s:Float = (E.x * d1.y - E.y * d1.x) / kross;
			if ((s < 0) || (s > 1)) {
				return { max: 0, Vector21: pi0, Vector22: pi1 };
			}
			var t:Float = (E.x * d0.y - E.y * d0.x) / kross;
			if ((t < 0) || (t > 1)) {
				return { max: 0, Vector21: pi0, Vector22: pi1 };
			}
			// intersection of lines is a Vector2 an each segment
			pi0.x = p0.x + s * d0.x;
			pi0.y = p0.y + s * d0.y;
			
			// Uncomment this and the block below if you're getting errors to do with precision.
			if (Vector2.Distance(pi0,seg0.start) < 0.00000001) pi0 = seg0.start;
			if (Vector2.Distance(pi0,seg0.end) < 0.00000001) pi0 = seg0.end;
			if (Vector2.Distance(pi0,seg1.start) < 0.00000001) pi0 = seg1.start;
			if (Vector2.Distance(pi0, seg1.end) < 0.00000001) pi0 = seg1.end;
			
			return { max: 1, Vector21: pi0, Vector22: pi1 };
		}
		
		// lines of the segments are parallel
		var sqrLenE:Float = E.length();
		kross = E.x * d0.y - E.y * d0.x;
		sqrKross = kross * kross;
		if (sqrKross > sqrEpsilon * sqrLen0 * sqrLenE) {
			// lines of the segment are different
			//return [0, pi0, pi1];
			return { max: 0, Vector21: pi0, Vector22: pi1 };
		}
		
		// Lines of the segments are the same. Need to test for overlap of segments.
		var s0:Float = (d0.x * E.x + d0.y * E.y) / sqrLen0;  // so = Dot (D0, E) * sqrLen0
		var s1:Float = s0 + (d0.x * d1.x + d0.y * d1.y) / sqrLen0;  // s1 = s0 + Dot (D0, D1) * sqrLen0
		var smin:Float = Math.min(s0, s1);
		var smax:Float = Math.max(s0, s1);
		var w:Array<Float> = new Array<Float>();
		var imax:Int = findIntersection2(0.0, 1.0, smin, smax, w);
		
		if (imax > 0) {
			pi0.x = p0.x + w[0] * d0.x;
			pi0.y = p0.y + w[0] * d0.y;
			if (Vector2.Distance(pi0,seg0.start) < 0.00000001) pi0 = seg0.start;
			if (Vector2.Distance(pi0,seg0.end) < 0.00000001) pi0 = seg0.end;
			if (Vector2.Distance(pi0,seg1.start) < 0.00000001) pi0 = seg1.start;
			if (Vector2.Distance(pi0,seg1.end) < 0.00000001) pi0 = seg1.end;
			if (imax > 1) {
				pi1.x = p0.x + w[1] * d0.x;
				pi1.y = p0.y + w[1] * d0.y;
			}
		}
		
		//return [imax, pi0, pi1];
		return { max: imax, Vector21: pi0, Vector22: pi1 };
	}
	
	private function findIntersection2(u0:Float, u1:Float, v0:Float, v1:Float, w:Array<Float>):Int {
		if ((u1 < v0) || (u0 > v1)) {
			return 0;
		}
		
		if (u1 > v0) {
			if (u0 < v1) {
				w[0] = (u0 < v0) ? v0 : u0;
				w[1] = (u1 > v1) ? v1 : u1;
				return 2;
			} 
			else {
				// u0 == v1
				w[0] = u0;
				return 1;
			}
		} 
		else {
			// u1 == v0
			w[0] = u1;
			return 1;
		}
	}
	
	private function sec(e1:SweepEvent, e2:SweepEvent):Bool {
		if (e1.p.x > e2.p.x) {  // Different x coordinate
			return true;
		}
		
		if (e2.p.x > e1.p.x) {  // Different x coordinate
			return false;
		}
		
		if (!e1.p.equals(e2.p)) {  // Different points, but same x coordinate. The event with lower y coordinate is processed first
			return e1.p.y > e2.p.y;
		}
		
		if (e1.isLeft != e2.isLeft) {  // Same Vector2, but one is a left endVector2 and the other a right endVector2. The right endVector2 is processed first
			return e1.isLeft;
		}
		
		// Same Vector2, both events are left end points or both are right end points. The event associate to the bottom segment is processed first
		return e1.isAbove(e2.otherSE.p);
	}
	
	private function possibleIntersection(e1:SweepEvent, e2:SweepEvent) {
		//	if ((e1->pl == e2->pl) ) // Uncomment these two lines if self-intersecting polygons are not allowed
		//		return false;
		
		var ip1:Vector2, ip2:Vector2;
		var numIntersections:Int = 0;
		
		var intData:IntersectResult = findIntersection(e1.segment, e2.segment);
		numIntersections = intData.max;
		ip1 = intData.Vector21;
		ip2 = intData.Vector22;
		
		if (numIntersections == 0) {
			return;
		}
		
		if ((numIntersections == 1) && (e1.p.equals(e2.p) || e1.otherSE.p.equals(e2.otherSE.p))) {
			return;
		}
		
		if (numIntersections == 2 && e1.p.equals(e2.p)) {
			return;
		}
		
		if (numIntersections == 1) {
			if (!e1.p.equals(ip1) && !e1.otherSE.p.equals(ip1)) {
				divideSegment (e1, ip1);
			}
			if (!e2.p.equals(ip1) && !e2.otherSE.p.equals(ip1)) {
				divideSegment (e2, ip1);
			}
			
			return;
		}
		
		var sortedEvents:Array<SweepEvent> = [];
		if (e1.p.equals(e2.p)) {
			sortedEvents.push(null); // WTF
		} 
		else if (sec(e1, e2)) {
			sortedEvents.push(e2);
			sortedEvents.push(e1);
		} 
		else {
			sortedEvents.push(e1);
			sortedEvents.push(e2);
		}
		
		if ( e1.otherSE.p.equals(e2.otherSE.p)) {
			sortedEvents.push(null);
		} 
		else if (sec(e1.otherSE, e2.otherSE)) {
			sortedEvents.push(e2.otherSE);
			sortedEvents.push(e1.otherSE);
		} 
		else {
			sortedEvents.push(e1.otherSE);
			sortedEvents.push(e2.otherSE);
		}
		
		if (sortedEvents.length == 2) {
			e1.edgeType = e1.otherSE.edgeType = EdgeType.NON_CONTRIBUTING;
			e2.edgeType = e2.otherSE.edgeType = ((e1.inOut == e2.inOut) ? EdgeType.SAME_TRANSITION : EdgeType.DIFFERENT_TRANSITION);
			
			return;
		}
		
		if (sortedEvents.length == 3) {
			sortedEvents[1].edgeType = sortedEvents[1].otherSE.edgeType = EdgeType.NON_CONTRIBUTING;
			if (sortedEvents[0] != null) {        // is the right endVector2 the shared Vector2?
				sortedEvents[0].otherSE.edgeType = (e1.inOut == e2.inOut) ? EdgeType.SAME_TRANSITION : EdgeType.DIFFERENT_TRANSITION;
			}
			else {								// the shared Vector2 is the left endVector2
				sortedEvents[2].otherSE.edgeType = (e1.inOut == e2.inOut) ? EdgeType.SAME_TRANSITION : EdgeType.DIFFERENT_TRANSITION;
			}
			divideSegment (sortedEvents[0] != null ? sortedEvents[0] : sortedEvents[2].otherSE, sortedEvents[1].p);
			
			return;
		}
		
		if (sortedEvents[0] != sortedEvents[3].otherSE) { 
			// no segment includes totally the otherSE one
			sortedEvents[1].edgeType = EdgeType.NON_CONTRIBUTING;
			sortedEvents[2].edgeType = (e1.inOut == e2.inOut) ? EdgeType.SAME_TRANSITION : EdgeType.DIFFERENT_TRANSITION;
			divideSegment (sortedEvents[0], sortedEvents[1].p);
			divideSegment (sortedEvents[1], sortedEvents[2].p);
			
			return;
		}
		
		sortedEvents[1].edgeType = sortedEvents[1].otherSE.edgeType = EdgeType.NON_CONTRIBUTING;
		divideSegment (sortedEvents[0], sortedEvents[1].p);
		sortedEvents[3].otherSE.edgeType = (e1.inOut == e2.inOut) ? EdgeType.SAME_TRANSITION : EdgeType.DIFFERENT_TRANSITION;
		divideSegment (sortedEvents[3].otherSE, sortedEvents[2].p);
	}
	
	private function divideSegment(e:SweepEvent, p:Vector2) {
		var r:SweepEvent = new SweepEvent(p, false, e.polygonType, e, e.edgeType);
		var l:SweepEvent = new SweepEvent(p, true, e.polygonType, e.otherSE, e.otherSE.edgeType);
		
		if (sec(l, e.otherSE)) {
			e.otherSE.isLeft = true;
			e.isLeft = false;
		}
		
		e.otherSE.otherSE = l;
		e.otherSE = r;
		
		eventQueue.enqueue(l);
		eventQueue.enqueue(r);
	}
	
	private function processSegment(segment:Segment, polyType:Int) {
		if (segment.start.equals(segment.end)) {  // Possible degenerate condition.
			return;
		}
		
		var e1:SweepEvent = new SweepEvent(segment.start, true, polyType);
		var e2:SweepEvent = new SweepEvent(segment.end, true, polyType, e1);
		e1.otherSE = e2;
		
		if (e1.p.x < e2.p.x) {
			e2.isLeft = false;
		} 
		else if (e1.p.x > e2.p.x) {
			e1.isLeft = false;
		} 
		else if (e1.p.y < e2.p.y) { // the segment isLeft vertical. The bottom endVector2 isLeft the isLeft endVector2 
			e2.isLeft = false;
		} 
		else {
			e1.isLeft = false;
		}
		
		// Pushing it so the que is sorted from left to right, with object on the left
		// having the highest priority.
		eventQueue.enqueue(e1);
		eventQueue.enqueue(e2);
	}
	
}
