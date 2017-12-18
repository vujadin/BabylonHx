package com.babylonhx.math.polyclip;

import com.babylonhx.math.polyclip.geom.Segment;
import com.babylonhx.math.polyclip.geom.Contour;
import com.babylonhx.math.polyclip.geom.Polygon;

/**
 * ...
 * @haxeport Krtolica Vujadin
 */

/**
 * Holds intermediate results (PointChains) of the clipping operation and forms them into
 * the final polygon.
 * @author Mahir Iqbal
 */
class Connector {

	private var openPolygons:Array<PointChain>;
	private var closedPolygons:Array<PointChain>;
	
	
	public function new() {
		openPolygons = new Array<PointChain>();
		closedPolygons = new Array<PointChain>();
	}
	
	public function add(s:Segment) {
		// j iterates through the openPolygon chains.
		for (j in 0...openPolygons.length) {
			var chain:PointChain = openPolygons[j];
			if (chain.linkSegment(s)) {
				if (chain.closed) {
					if (chain.pointList.length == 2) {
						// We tried linking the same segment (but flipped end and start) to 
						// a chain. (i.e. chain was <p0, p1>, we tried linking Segment(p1, p0)
						// so the chain was closed illegally.
						chain.closed = false;
						return;
					}
					
					openPolygons.splice(j, 1);
					closedPolygons.push(chain);
				} 
				else {
					var count = j + 1;
					for (i in count...openPolygons.length) {
						// Try to connect this open link to the rest of the chains. 
						// We won't be able to connect this to any of the chains preceding this one
						// because we know that linkSegment failed on those.
						if (chain.linkPointChain(openPolygons[i])) {
							openPolygons.splice(i, 1);
							break;
						}
					}
				}
				
				return;
			}
		}
		
		var newChain:PointChain = new PointChain(s);
		openPolygons.push(newChain);
	}
	
	public function toPolygon():Polygon {
		var polygon:Polygon = new Polygon();
		for (pointChain in closedPolygons) {
			/*if (pointChain.pointList.length == 2)
			{
				// Invalid contour...
				throw new Error("Invalid contour");
			}*/				
			
			var c:Contour = new Contour();
			for(p in pointChain.pointList) {
				c.add(p);
			}
			
			polygon.addContour(c);
		}
		
		return polygon;
	}
	
}
