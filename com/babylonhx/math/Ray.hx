package com.babylonhx.math;

import com.babylonhx.collisions.IntersectionInfo;
import com.babylonhx.culling.BoundingBox;
import com.babylonhx.culling.BoundingSphere;

/**
* ...
* @author Krtolica Vujadin
*/
@:expose('BABYLON.Ray') class Ray {
	
	public var origin:Vector3;
	public var direction:Vector3;
	public var length:Float;
	
	private var _edge1:Vector3;
	private var _edge2:Vector3;
	private var _pvec:Vector3;
	private var _tvec:Vector3;
	private var _qvec:Vector3;
	

	public function new(origin:Vector3, direction:Vector3, ?length:Float) {
		this.origin = origin;
		this.direction = direction;
		this.length = length != null ? length : Math.POSITIVE_INFINITY;
	}

	// Methods
	public function intersectsBoxMinMax(minimum:Vector3, maximum:Vector3):Bool {
		var d:Float = 0.0;
		var maxValue:Float = Math.POSITIVE_INFINITY;
		
		if (Math.abs(this.direction.x) < 0.0000001) {
			if (this.origin.x < minimum.x || this.origin.x > maximum.x) {
				return false;
			}
		}
		else {
			var inv = 1.0 / this.direction.x;
			var min = (minimum.x - this.origin.x) * inv;
			var max = (maximum.x - this.origin.x) * inv;
			
			if(max == Math.NEGATIVE_INFINITY) {
				max = Math.POSITIVE_INFINITY; 
			}
			
			if (min > max) {
				var temp = min;
				min = max;
				max = temp;
			}
			
			d = Math.max(min, d);
			maxValue = Math.min(max, maxValue);
			
			if (d > maxValue) {
				return false;
			}
		}
		
		if (Math.abs(this.direction.y) < 0.0000001) {
			if (this.origin.y < minimum.y || this.origin.y > maximum.y) {
				return false;
			}
		}
		else {
			var inv = 1.0 / this.direction.y;
			var min = (minimum.y - this.origin.y) * inv;
			var max = (maximum.y - this.origin.y) * inv;
			
			if(max == Math.NEGATIVE_INFINITY) {
				max = Math.POSITIVE_INFINITY; 
			}
			
			if (min > max) {
				var temp = min;
				min = max;
				max = temp;
			}
			
			d = Math.max(min, d);
			maxValue = Math.min(max, maxValue);
			
			if (d > maxValue) {
				return false;
			}
		}
		
		if (Math.abs(this.direction.z) < 0.0000001) {
			if (this.origin.z < minimum.z || this.origin.z > maximum.z) {
				return false;
			}
		}
		else {
			var inv = 1.0 / this.direction.z;
			var min = (minimum.z - this.origin.z) * inv;
			var max = (maximum.z - this.origin.z) * inv;
			
			if(max == Math.NEGATIVE_INFINITY) {
				max = Math.POSITIVE_INFINITY; 
			}
			
			if (min > max) {
				var temp = min;
				min = max;
				max = temp;
			}
			
			d = Math.max(min, d);
			maxValue = Math.min(max, maxValue);
			
			if (d > maxValue) {
				return false;
			}
		}
		return true;
	}

	public function intersectsBox(box:BoundingBox):Bool {
		return this.intersectsBoxMinMax(box.minimum, box.maximum);
	}

	public function intersectsSphere(sphere:BoundingSphere):Bool {
		var x = sphere.center.x - this.origin.x;
		var y = sphere.center.y - this.origin.y;
		var z = sphere.center.z - this.origin.z;
		var pyth = (x * x) + (y * y) + (z * z);
		var rr = sphere.radius * sphere.radius;
		
		if (pyth <= rr) {
			return true;
		}
		
		var dot = (x * this.direction.x) + (y * this.direction.y) + (z * this.direction.z);
		if (dot < 0.0) {
			return false;
		}
		
		var temp = pyth - (dot * dot);
		
		return temp <= rr;
	}

	public function intersectsTriangle(vertex0:Vector3, vertex1:Vector3, vertex2:Vector3):IntersectionInfo {
		if (this._edge1 == null) {
			this._edge1 = Vector3.Zero();
			this._edge2 = Vector3.Zero();
			this._pvec = Vector3.Zero();
			this._tvec = Vector3.Zero();
			this._qvec = Vector3.Zero();
		}
		
		vertex1.subtractToRef(vertex0, this._edge1);
		vertex2.subtractToRef(vertex0, this._edge2);
		Vector3.CrossToRef(this.direction, this._edge2, this._pvec);
		var det = Vector3.Dot(this._edge1, this._pvec);
		
		if (det == 0) {
			return null;
		}
		
		var invdet = 1 / det;
		
		this.origin.subtractToRef(vertex0, this._tvec);
		
		var bu = Vector3.Dot(this._tvec, this._pvec) * invdet;
		
		if (bu < 0 || bu > 1.0) {
			return null;
		}
		
		Vector3.CrossToRef(this._tvec, this._edge1, this._qvec);
		
		var bv = Vector3.Dot(this.direction, this._qvec) * invdet;
		
		if (bv < 0 || bu + bv > 1.0) {
			return null;
		}
		
		return new IntersectionInfo(bu, bv, Vector3.Dot(this._edge2, this._qvec) * invdet);
	}

	// Statics
	public static function CreateNew(x:Float, y:Float, viewportWidth:Float, viewportHeight:Float, world:Matrix, view:Matrix, projection:Matrix):Ray {
		var start = Vector3.Unproject(new Vector3(x, y, 0), viewportWidth, viewportHeight, world, view, projection);
		var end = Vector3.Unproject(new Vector3(x, y, 1), viewportWidth, viewportHeight, world, view, projection);
		
		var direction = end.subtract(start);
		direction.normalize();
		
		return new Ray(start, direction);
	}
	
	/**
	* Function will create a new transformed ray starting from origin and ending at the end point. Ray's length will be set, and ray will be 
	* transformed to the given world matrix.
	* @param origin The origin point
	* @param end The end point
	* @param world a matrix to transform the ray to. Default is the identity matrix.
	*/
	public static function CreateNewFromTo(origin:Vector3, end:Vector3, ?world:Matrix):Ray {
		if (world == null) {
			world = Matrix.Identity();
		}
		var direction = end.subtract(origin);
		var length = Math.sqrt((direction.x * direction.x) + (direction.y * direction.y) + (direction.z * direction.z));
		direction.normalize();
		
		return Ray.Transform(new Ray(origin, direction, length), world);
	}

	public static function Transform(ray:Ray, matrix:Matrix):Ray {
		var newOrigin = Vector3.TransformCoordinates(ray.origin, matrix);
		var newDirection = Vector3.TransformNormal(ray.direction, matrix);
		
		return new Ray(newOrigin, newDirection);
	}
	
}
