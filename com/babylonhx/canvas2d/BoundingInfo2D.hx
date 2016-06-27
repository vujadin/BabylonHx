package com.babylonhx.canvas2d;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Size;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Stores 2D Bounding Information.
 * This class handles a circle area and a bounding rectangle one.
 */
class BoundingInfo2D {

	/**
	 * The coordinate of the center of the bounding info
	 */
	public var center:Vector2;

	/**
	 * The radius of the bounding circle, from the center of the bounded object
	 */
	public var radius:Float;

	/**
	 * The extent of the bounding rectangle, from the center of the bounded object.
	 * This is an absolute value in both X and Y of the vector which describe the right/top corner of the rectangle, 
	 * you can easily reconstruct the whole rectangle by negating X &| Y.
	 */
	public var extent:Vector2;
	

	public function new() {
		this.radius = 0;
		this.center = Vector2.Zero();
		this.extent = Vector2.Zero();
	}

	public static function CreateFromSize(size:Size):BoundingInfo2D {
		var r = new BoundingInfo2D();
		BoundingInfo2D.CreateFromSizeToRef(size, r);
		
		return r;
	}

	public static function CreateFromRadius(radius:Float):BoundingInfo2D {
		var r = new BoundingInfo2D();
		BoundingInfo2D.CreateFromRadiusToRef(radius, r);
		
		return r;
	}

	public static function CreateFromPoints(points:Array<Vector2>):BoundingInfo2D {
		let r = new BoundingInfo2D();
		BoundingInfo2D.CreateFromPointsToRef(points, r);
		
		return r;
	}

	public static function CreateFromSizeToRef(size:Size, b:BoundingInfo2D) {
		b.center = new Vector2(size.width / 2, size.height / 2);
		b.extent = b.center.clone();
		b.radius = b.extent.length();
	}

	public static function CreateFromRadiusToRef(radius:Float, b:BoundingInfo2D) {
		b.center = Vector2.Zero();
		b.extent = new Vector2(radius, radius);
		b.radius = radius;
	}

	public static function CreateFromPointsToRef(points:Array<Vector2>, b:BoundingInfo2D) {
		var xmin = Math.POSITIVE_INFINITY;
		var ymin = Math.POSITIVE_INFINITY;
		var xmax = Math.POSITIVE_INFINITY;
		var ymax = Math.POSITIVE_INFINITY;
		for (p in points) {
			xmin = Math.min(p.x, xmin);
			xmax = Math.max(p.x, xmax);
			ymin = Math.min(p.y, ymin);
			ymax = Math.max(p.y, ymax);
		}
		BoundingInfo2D.CreateFromMinMaxToRef(xmin, xmax, ymin, ymax, b);
	}

	public static function CreateFromMinMaxToRef(xmin:Float, xmax:Float, ymin:Float, ymax:Float, b:BoundingInfo2D) {
		b.center = new Vector2(xmin + (xmax - xmin) / 2, ymin + (ymax - ymin) / 2);
		b.extent = new Vector2(xmax - b.center.x, ymax - b.center.y);
		b.radius = b.extent.length();
	}

	/**
	 * Duplicate this instance and return a new one
	 * @return the duplicated instance
	 */
	public function clone():BoundingInfo2D {
		var r = new BoundingInfo2D();
		r.center = this.center.clone();
		r.radius = this.radius;
		r.extent = this.extent.clone();
		
		return r;
	}

	public function max():Vector2 {
		let r = Vector2.Zero();
		this.maxToRef(r);
		
		return r;
	}

	public function maxToRef(result:Vector2) {
		result.x = this.center.x + this.extent.x;
		result.y = this.center.y + this.extent.y;
	}

	/**
	 * Apply a transformation matrix to this BoundingInfo2D and return a new instance containing the result
	 * @param matrix the transformation matrix to apply
	 * @return the new instance containing the result of the transformation applied on this BoundingInfo2D
	 */
	public function transform(matrix:Matrix, origin:Vector2 = null):BoundingInfo2D {
		var r = new BoundingInfo2D();
		this.transformToRef(matrix, origin, r);
		
		return r;
	}

	/**
	 * Compute the union of this BoundingInfo2D with a given one, return a new BoundingInfo2D as a result
	 * @param other the second BoundingInfo2D to compute the union with this one
	 * @return a new instance containing the result of the union
	 */
	public function union(other:BoundingInfo2D):BoundingInfo2D {
		var r = new BoundingInfo2D();
		this.unionToRef(other, r);
		
		return r;
	}

	/**
	 * Transform this BoundingInfo2D with a given matrix and store the result in an existing BoundingInfo2D instance.
	 * This is a GC friendly version, try to use it as much as possible, specially if your transformation is inside a loop, allocate the result object once for good outside of the loop and use it everytime.
	 * @param origin An optional normalized origin to apply before the transformation. 0;0 is top/left, 0.5;0.5 is center, etc.
	 * @param matrix The matrix to use to compute the transformation
	 * @param result A VALID (i.e. allocated) BoundingInfo2D object where the result will be stored
	 */
	public function transformToRef(matrix:Matrix, origin:Vector2, result:BoundingInfo2D) {
		// Construct a bounding box based on the extent values
		var p:Array<Vector2> = [];
		p[0] = new Vector2(this.center.x + this.extent.x, this.center.y + this.extent.y);
		p[1] = new Vector2(this.center.x + this.extent.x, this.center.y - this.extent.y);
		p[2] = new Vector2(this.center.x - this.extent.x, this.center.y - this.extent.y);
		p[3] = new Vector2(this.center.x - this.extent.x, this.center.y + this.extent.y);
		
		//if (origin) {
		//    let off = new Vector2((p[0].x - p[2].x) * origin.x, (p[0].y - p[2].y) * origin.y);
		//    for (let j = 0; j < 4; j++) {
		//        p[j].subtractInPlace(off);
		//    }
		//}
		
		// Transform the four points of the bounding box with the matrix
		for (i in 0...4) {
			Vector2.TransformToRef(p[i], matrix, p[i]);
		}
		
		BoundingInfo2D.CreateFromPointsToRef(p, result);
	}

	/**
	 * Compute the union of this BoundingInfo2D with another one and store the result in a third valid BoundingInfo2D object
	 * This is a GC friendly version, try to use it as much as possible, specially if your transformation is inside a loop, allocate the result object once for good outside of the loop and use it everytime.
	 * @param other the second object used to compute the union
	 * @param result a VALID BoundingInfo2D instance (i.e. allocated) where the result will be stored
	 */
	public function unionToRef(other:BoundingInfo2D, result:BoundingInfo2D) {
		var xmax = Math.max(this.center.x + this.extent.x, other.center.x + other.extent.x);
		var ymax = Math.max(this.center.y + this.extent.y, other.center.y + other.extent.y);
		var xmin = Math.min(this.center.x - this.extent.x, other.center.x - other.extent.x);
		var ymin = Math.min(this.center.y - this.extent.y, other.center.y - other.extent.y);
		
		BoundingInfo2D.CreateFromMinMaxToRef(xmin, xmax, ymin, ymax, result);
	}
	
}
