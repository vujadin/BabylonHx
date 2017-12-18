package com.babylonhx.math.polyclip.geom;

/**
 * ...
 * @haxeport Krtolica Vujadin
 */

/**
 * These are simple polygons. They contain a sequence of connected points.
 * These also represent holes inside (complex) Polygons. The algorithm does not require
 * the knowledge of whether a Contour is a hole.
 * @author Mahir Iqbal
 */
class Contour {

	@:allow(com.babylonhx.math.polyclip.geom.Polygon)
	private var points:Array<Vector2> = [];
	public var bounds:Rectangle;
	
	
	public function new(?points:Array<Vector2>) {
		if (points != null) {
			this.points = points;
		}
	}
	
	public function getPoints():Array<Vector2> {
		var _points = points.copy();
		_points.reverse();
		return _points;
	}
	
	public function add(p:Vector2) {
		points.push(p);
	}
	
	public var boundingBox(get, null):Rectangle;
	private function get_boundingBox():Rectangle {
		if (bounds != null) {
			return bounds;
		}
			
		var minX:Float = Math.POSITIVE_INFINITY, minY:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY, maxY:Float = Math.NEGATIVE_INFINITY;
		
		for (p in points) {
			if (p.x > maxX) {
				maxX = p.x;
			}
			if (p.x < minX) {
				minX = p.x;
			}
			if (p.y > maxY) {
				maxY = p.y;
			}
			if (p.y < minY) {
				minY = p.y;
			}
		}
		
		bounds = new Rectangle(minX, minY, maxX - minX, maxY - minY);
		
		return bounds;
	}
	
	public function getSegment(index:Int):Segment {
		if (index == points.length - 1) {
			return new Segment(points[points.length - 1], points[0]);
		}
		
		return new Segment(points[index], points[index + 1]);
	}
	
	/**
	 * Checks if a point is inside a contour using the point in polygon raycast method.
	 * This works for all polygons, whether they are clockwise or counter clockwise,
	 * convex or concave.
	 * @see 	http://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm
	 * @param	p
	 * @param	contour
	 * @return	True if p is inside the polygon defined by contour
	 */
	public inline function containsPoint(p:Vector2):Bool {
		// Cast ray from p.x towards the right
		var intersections:Int = 0;
		for (i in 0...points.length) {
			var curr:Vector2 = points[i];
			var next:Vector2 = (i == points.length - 1) ? points[0] : points[i + 1];
			
			// Edge is from curr to next.
			if ((p.y < next.y && p.y > curr.y) || (p.y < curr.y && p.y > next.y)) {
				if (p.x < Math.max(curr.x, next.x) && next.y != curr.y) {
					// Find where the line intersects...
					var xInt:Float = (p.y - curr.y) * (next.x - curr.x) / (next.y - curr.y) + curr.x;
					if (curr.x == next.x || p.x <= xInt) {
						intersections++;
					}
				}
			}
		}
		
		if (intersections % 2 == 0) {
			return false;
		}
		else {
			return true;			
		}
	}
	
}
