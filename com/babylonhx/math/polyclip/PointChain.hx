package com.babylonhx.math.polyclip;

import com.babylonhx.math.polyclip.geom.Segment;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Represents a connected sequence of segments. The sequence can only be extended by connecting
 * new segments that share an endpoint with the PointChain.
 * @author Mahir Iqbal
 */

class PointChain {

	public var closed:Bool;
	public var pointList:Array<Vector2>;
	
	
	public function new(s:Segment) {
		pointList = [];
		pointList.push(s.start);
		pointList.push(s.end);
		closed = false;
	}
	
	// Links a segment to the pointChain
	public function linkSegment(s:Segment):Bool {				
		var front:Vector2 = pointList[0];
		var back:Vector2 = pointList[pointList.length - 1];
		
		if (s.start.equals(front)) {
			if (s.end.equals(back)) {
				closed = true;
			}
			else {
				pointList.unshift(s.end);
			}
				
			return true;
		} 
		else if (s.end.equals(back)) {
			if (s.start.equals(front)) {
				closed = true;
			}
			else {
				pointList.push(s.start);
			}
				
			return true;
		} 
		else if (s.end.equals(front)) {
			if (s.start.equals(back)) {
				closed = true;
			}
			else {
				pointList.unshift(s.start);
			}
				
			return true;
		} 
		else if (s.start.equals(back)) {
			if (s.end.equals(front)) {
				closed = true;
			}
			else {
				pointList.push(s.end);
			}
				
			return true;
		}
		
		return false;
	}
	
	// Links another pointChain onto this point chain.
	public function linkPointChain(chain:PointChain):Bool {	
		var firstPoint:Vector2 = pointList[0];
		var lastPoint:Vector2 = pointList[pointList.length - 1];
		
		var chainFront:Vector2 = chain.pointList[0];
		var chainBack:Vector2 = chain.pointList[chain.pointList.length - 1];
		
		if (chainFront.equals(lastPoint)) {
			pointList.pop();
			pointList = pointList.concat(chain.pointList);
			
			return true;
		}
		
		if (chainBack.equals(firstPoint)) {
			pointList.shift(); // Remove the first element, and join this list to chain.pointList.
			pointList = chain.pointList.concat(pointList);
			
			return true;
		}
		
		if (chainFront.equals(firstPoint)) {
			pointList.shift(); // Remove the first element, and join to reversed chain.pointList
			chain.pointList.reverse();
			var reversedChainList:Array<Vector2> = chain.pointList; // Don't need chain so can ruin it
			pointList = reversedChainList.concat(pointList);
			
			return true;
		}
		
		if (chainBack.equals(lastPoint)) {
			pointList.pop();
			pointList.reverse();
			pointList = chain.pointList.concat(pointList);
			
			return true;
		}
		
		return false;
	}
	
}
