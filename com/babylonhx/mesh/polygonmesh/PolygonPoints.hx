package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Vector2;
import com.babylonhx.tools.Tools;


/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.PolygonPoints') class PolygonPoints {
	
	public var elements:Array<IndexedPoint>;
	
	
	public function new() {
		elements = [];
	}
	
	public function add(originalPoints:Array<Vector2>):Array<IndexedPoint> {
		var result:Array<IndexedPoint> = [];
		
		for (point in originalPoints) {
			if (result.length == 0 || !point.equalsWithEpsilon(cast result[0])) {
				var newPoint = new IndexedPoint(point, this.elements.length);
				result.push(newPoint);
				this.elements.push(newPoint);
			}
		}
		
		return result;
	}

	public function computeBounds():PolygonBounds {
		var lmin = new Vector2(this.elements[0].x, this.elements[0].y);
		var lmax = new Vector2(this.elements[0].x, this.elements[0].y);
		
		for(point in this.elements) {
			// x
			if (point.x < lmin.x) {
				lmin.x = point.x;
			}
			else if (point.x > lmax.x) {
				lmax.x = point.x;
			}			
			// y
			if (point.y < lmin.y) {
				lmin.y = point.y;
			}
			else if (point.y > lmax.y) {
				lmax.y = point.y;
			}
		}
		
		return new PolygonBounds(lmin, lmax, lmax.x - lmin.x, lmax.y - lmin.y);
	}
	
}
