package com.babylonhx.math.polyclip.geom;

/**
 * ...
 * @haxeport Krtolica Vujadin
 */

/**
 * A complex polygon is represented by many contours (i.e. simple polygons).
 * @see Contour.as
 * @author Mahir Iqbal
 */
class Polygon {

	public var contours:Array<Contour> = [];		
	public var bounds:Rectangle;
	
	
	public function new(?contourData:Array<Vector2>) {
		bounds = null;
		if (contourData != null) {
			contours.push(new Contour(contourData));
		}
	}
	
	public function numVertices():Int {
		var verticesCount:Int = 0;
		for (c in contours) {
			verticesCount += c.points.length;
		}
		
		return verticesCount;
	}
	
	public function getVertices():Array<Vector2> {
		var allVertices:Array<Vector2> = [];
		for (c in contours) {
			for (p in c.points) {
				allVertices.push(p);
			}
		}
		
		return allVertices;
	}
	
	public var boundingBox(get, null):Rectangle;
	private function get_boundingBox():Rectangle {
		if (bounds != null) {
			return bounds;
		}
		
		var bb:Rectangle = null;
		for (c in contours) {
			var cBB:Rectangle = c.boundingBox;
			if (bb == null) {
				bb = cBB;
			}
			else {
				bb = bb.union(cBB);
			}
		}
		
		bounds = bb;
		
		return bounds;
	}
	
	public function addContour(c:Contour) {
		contours.push(c);
	}
	
	public function clone():Polygon {
		var poly:Polygon = new Polygon();
		for (cont in this.contours) {
			var c:Contour = new Contour();
			for (p in cont.points) {
				c.add(p.clone());
			}
			
			poly.addContour(c);
		}
		
		return poly;
	}
	
}
