package com.babylonhx.collisions;

import com.babylonhx.math.Plane;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.SubMesh;
import lime.utils.Int32Array;

/**
* ...
* @author Krtolica Vujadin
*/
@:expose('BABYLON.Collider') class Collider {
	
	public var radius:Vector3 = Vector3.One();
	public var retry:Int = 0;
	public var velocity:Vector3;
	public var basePoint:Vector3;
	public var epsilon:Float;
	public var collisionFound:Bool;
	public var velocityWorldLength:Float;
	public var basePointWorld = Vector3.Zero();
	public var velocityWorld = Vector3.Zero();
	public var normalizedVelocity = Vector3.Zero();
	public var initialVelocity:Vector3;
	public var initialPosition:Vector3;
	public var nearestDistance:Float;
	public var intersectionPoint:Vector3;
	public var collidedMesh:AbstractMesh;

	private var _collisionPoint = Vector3.Zero();
	private var _planeIntersectionPoint = Vector3.Zero();
	private var _tempVector = Vector3.Zero();
	private var _tempVector2 = Vector3.Zero();
	private var _tempVector3 = Vector3.Zero();
	private var _tempVector4 = Vector3.Zero();
	private var _edge = Vector3.Zero();
	private var _baseToVertex = Vector3.Zero();
	private var _destinationPoint = Vector3.Zero();
	private var _slidePlaneNormal = Vector3.Zero();
	private var _displacementVector = Vector3.Zero();
	
	private var _collisionMask:Int = -1;
    public var collisionMask(get, set):Int;
	private function get_collisionMask():Int {
		return this._collisionMask;
	}	
	private function set_collisionMask(mask:Int):Int {
		this._collisionMask = !Math.isNaN(mask) ? mask : -1;
		return mask;
	}
	
	
	public function new() {
		
	}

	// Methods
	public function _initialize(source:Vector3, dir:Vector3, e:Float):Void {
		this.velocity = dir;
		Vector3.NormalizeToRef(dir, this.normalizedVelocity);
		this.basePoint = source;
		
		source.multiplyToRef(this.radius, this.basePointWorld);
		dir.multiplyToRef(this.radius, this.velocityWorld);
		
		this.velocityWorldLength = this.velocityWorld.length();
		
		this.epsilon = e;
		this.collisionFound = false;
	}

	public function _checkPointInTriangle(point:Vector3, pa:Vector3, pb:Vector3, pc:Vector3, n:Vector3):Bool {
		pa.subtractToRef(point, this._tempVector);
		pb.subtractToRef(point, this._tempVector2);
		
		Vector3.CrossToRef(this._tempVector, this._tempVector2, this._tempVector4);
		var d = Vector3.Dot(this._tempVector4, n);
		if (d < 0) {
			return false;
		}
			
		pc.subtractToRef(point, this._tempVector3);
		Vector3.CrossToRef(this._tempVector2, this._tempVector3, this._tempVector4);
		d = Vector3.Dot(this._tempVector4, n);
		if (d < 0) {
			return false;
		}
		
		Vector3.CrossToRef(this._tempVector3, this._tempVector, this._tempVector4);
		d = Vector3.Dot(this._tempVector4, n);
		
		return d >= 0;
	}

	public function _canDoCollision(sphereCenter:Vector3, sphereRadius:Float, vecMin:Vector3, vecMax:Vector3):Bool {
		var distance = Vector3.Distance(this.basePointWorld, sphereCenter);
		
		var max = Math.max(Math.max(this.radius.x, this.radius.y), this.radius.z);
		
		if (distance > this.velocityWorldLength + max + sphereRadius) {
			return false;
		}
		
		if (!intersectBoxAASphere(vecMin, vecMax, this.basePointWorld, this.velocityWorldLength + max)) {
			return false;
		}
		
		return true;
	}

	public function _testTriangle(faceIndex:Int, trianglePlanes:Array<Plane>, p1:Vector3, p2:Vector3, p3:Vector3, hasMaterial:Bool) {
		var t0:Float = 0;
		var embeddedInPlane = false;
		
		if (trianglePlanes == null) {
			trianglePlanes = [];
		}
		
		if (trianglePlanes[faceIndex] == null) {
			trianglePlanes[faceIndex] = new Plane(0, 0, 0, 0);
			trianglePlanes[faceIndex].copyFromPoints(p1, p2, p3);
		}
		
		var trianglePlane = trianglePlanes[faceIndex];
		
		if ((!hasMaterial) && !trianglePlane.isFrontFacingTo(this.normalizedVelocity, 0)) {
			return;
		}
		
		var signedDistToTrianglePlane = trianglePlane.signedDistanceTo(this.basePoint);
		var normalDotVelocity = Vector3.Dot(trianglePlane.normal, this.velocity);
		
		if (normalDotVelocity == 0) {
			if (Math.abs(signedDistToTrianglePlane) >= 1.0)
				return;
			embeddedInPlane = true;
			t0 = 0;
		}
		else {
			t0 = (-1.0 - signedDistToTrianglePlane) / normalDotVelocity;
			var t1 = (1.0 - signedDistToTrianglePlane) / normalDotVelocity;
			
			if (t0 > t1) {
				var temp = t1;
				t1 = t0;
				t0 = temp;
			}
			
			if (t0 > 1.0 || t1 < 0.0) {
				return;
			}
			
			if (t0 < 0) {
				t0 = 0;
			}
			
			if (t0 > 1.0) {
				t0 = 1.0;
			}
		}
		
		this._collisionPoint.copyFromFloats(0, 0, 0);
		
		var found = false;
		var t = 1.0;
		
		if (!embeddedInPlane) {
			this.basePoint.subtractToRef(trianglePlane.normal, this._planeIntersectionPoint);
			this.velocity.scaleToRef(t0, this._tempVector);
			this._planeIntersectionPoint.addInPlace(this._tempVector);
			
			if (this._checkPointInTriangle(this._planeIntersectionPoint, p1, p2, p3, trianglePlane.normal)) {
				found = true;
				t = t0;
				this._collisionPoint.copyFrom(this._planeIntersectionPoint);
			}
		}
		
		if (!found) {
			var velocitySquaredLength = this.velocity.lengthSquared();
			
			var a = velocitySquaredLength;
			
			this.basePoint.subtractToRef(p1, this._tempVector);
			var b = 2.0 * (Vector3.Dot(this.velocity, this._tempVector));
			var c = this._tempVector.lengthSquared() - 1.0;
			
			var lowestRoot = getLowestRoot(a, b, c, t);
			if (lowestRoot.found) {
				t = lowestRoot.root;
				found = true;
				this._collisionPoint.copyFrom(p1);
			}
			
			this.basePoint.subtractToRef(p2, this._tempVector);
			b = 2.0 * (Vector3.Dot(this.velocity, this._tempVector));
			c = this._tempVector.lengthSquared() - 1.0;
			
			lowestRoot = getLowestRoot(a, b, c, t);
			if (lowestRoot.found) {
				t = lowestRoot.root;
				found = true;
				this._collisionPoint.copyFrom(p2);
			}
			
			this.basePoint.subtractToRef(p3, this._tempVector);
			b = 2.0 * (Vector3.Dot(this.velocity, this._tempVector));
			c = this._tempVector.lengthSquared() - 1.0;
			
			lowestRoot = getLowestRoot(a, b, c, t);
			if (lowestRoot.found) {
				t = lowestRoot.root;
				found = true;
				this._collisionPoint.copyFrom(p3);
			}
			
			p2.subtractToRef(p1, this._edge);
			p1.subtractToRef(this.basePoint, this._baseToVertex);
			var edgeSquaredLength = this._edge.lengthSquared();
			var edgeDotVelocity = Vector3.Dot(this._edge, this.velocity);
			var edgeDotBaseToVertex = Vector3.Dot(this._edge, this._baseToVertex);
			
			a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
			b = edgeSquaredLength * (2.0 * Vector3.Dot(this.velocity, this._baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
			c = edgeSquaredLength * (1.0 - this._baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;
			
			lowestRoot = getLowestRoot(a, b, c, t);
			if (lowestRoot.found) {
				var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;
				
				if (f >= 0.0 && f <= 1.0) {
					t = lowestRoot.root;
					found = true;
					this._edge.scaleInPlace(f);
					p1.addToRef(this._edge, this._collisionPoint);
				}
			}
			
			p3.subtractToRef(p2, this._edge);
			p2.subtractToRef(this.basePoint, this._baseToVertex);
			edgeSquaredLength = this._edge.lengthSquared();
			edgeDotVelocity = Vector3.Dot(this._edge, this.velocity);
			edgeDotBaseToVertex = Vector3.Dot(this._edge, this._baseToVertex);
			
			a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
			b = edgeSquaredLength * (2.0 * Vector3.Dot(this.velocity, this._baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
			c = edgeSquaredLength * (1.0 - this._baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;
			lowestRoot = getLowestRoot(a, b, c, t);
			if (lowestRoot.found) {
				var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;
				
				if (f >= 0.0 && f <= 1.0) {
					t = lowestRoot.root;
					found = true;
					this._edge.scaleInPlace(f);
					p2.addToRef(this._edge, this._collisionPoint);
				}
			}
			
			p1.subtractToRef(p3, this._edge);
			p3.subtractToRef(this.basePoint, this._baseToVertex);
			edgeSquaredLength = this._edge.lengthSquared();
			edgeDotVelocity = Vector3.Dot(this._edge, this.velocity);
			edgeDotBaseToVertex = Vector3.Dot(this._edge, this._baseToVertex);
			
			a = edgeSquaredLength * (-velocitySquaredLength) + edgeDotVelocity * edgeDotVelocity;
			b = edgeSquaredLength * (2.0 * Vector3.Dot(this.velocity, this._baseToVertex)) - 2.0 * edgeDotVelocity * edgeDotBaseToVertex;
			c = edgeSquaredLength * (1.0 - this._baseToVertex.lengthSquared()) + edgeDotBaseToVertex * edgeDotBaseToVertex;
			
			lowestRoot = getLowestRoot(a, b, c, t);
			if (lowestRoot.found) {
				var f = (edgeDotVelocity * lowestRoot.root - edgeDotBaseToVertex) / edgeSquaredLength;
				
				if (f >= 0.0 && f <= 1.0) {
					t = lowestRoot.root;
					found = true;
					this._edge.scaleInPlace(f);
					p3.addToRef(this._edge, this._collisionPoint);
				}
			}
		}
		
		if (found) {
			var distToCollision = t * this.velocity.length();
			
			if (!this.collisionFound || distToCollision < this.nearestDistance) {
				if (this.intersectionPoint == null) {
					this.intersectionPoint = this._collisionPoint.clone();
				} 
				else {
					this.intersectionPoint.copyFrom(this._collisionPoint);
				}
				
				this.nearestDistance = distToCollision;
				this.collisionFound = true;
			}
		}
	}

	inline public function _collide(trianglePlaneArray:Array<Plane>, pts:Array<Vector3>, indices:Int32Array, indexStart:Int, indexEnd:Int, decal:Int, hasMaterial:Bool) {
		var i:Int = indexStart;
		while(i < indexEnd) {
			var p1 = pts[indices[i] - decal];
			var p2 = pts[indices[i + 1] - decal];
			var p3 = pts[indices[i + 2] - decal];
			
			this._testTriangle(i, trianglePlaneArray, p3, p2, p1, hasMaterial);
			i += 3;
		}
	}

	inline public function _getResponse(pos:Vector3, vel:Vector3) {
		pos.addToRef(vel, this._destinationPoint);
		vel.scaleInPlace((this.nearestDistance / vel.length()));
		
		this.basePoint.addToRef(vel, pos);
		pos.subtractToRef(this.intersectionPoint, this._slidePlaneNormal);
		this._slidePlaneNormal.normalize();
		this._slidePlaneNormal.scaleToRef(this.epsilon, this._displacementVector);
		
		pos.addInPlace(this._displacementVector);
		this.intersectionPoint.addInPlace(this._displacementVector);
		
		this._slidePlaneNormal.scaleInPlace(Plane.SignedDistanceToPlaneFromPositionAndNormal(this.intersectionPoint, this._slidePlaneNormal, this._destinationPoint));
		this._destinationPoint.subtractInPlace(this._slidePlaneNormal);
		
		this._destinationPoint.subtractToRef(this.intersectionPoint, vel);
	}
	
	// Statics
	public static function intersectBoxAASphere(boxMin:Vector3, boxMax:Vector3, sphereCenter:Vector3, sphereRadius:Float):Bool {
        if (boxMin.x > sphereCenter.x + sphereRadius) {
            return false;
		}
		
        if (sphereCenter.x - sphereRadius > boxMax.x) {
            return false;
		}
		
        if (boxMin.y > sphereCenter.y + sphereRadius) {
            return false;
		}
		
        if (sphereCenter.y - sphereRadius > boxMax.y) {
            return false;
		}
		
        if (boxMin.z > sphereCenter.z + sphereRadius) {
            return false;
		}
		
        if (sphereCenter.z - sphereRadius > boxMax.z) {
            return false;
		}
		
        return true;
    }

	public static function getLowestRoot(a:Float, b:Float, c:Float, maxR:Float):Dynamic {
        var determinant = b * b - 4.0 * a * c;
        var result:Dynamic = { root: 0, found: false };
		
        if (determinant < 0) {
            return result;
		}
		
        var sqrtD = Math.sqrt(determinant);
        var r1 = (-b - sqrtD) / (2.0 * a);
        var r2 = ( -b + sqrtD) / (2.0 * a);
		
        if (r1 > r2) {
            var temp = r2;
            r2 = r1;
            r1 = temp;
        }
		
        if (r1 > 0 && r1 < maxR) {
            result.root = r1;
            result.found = true;
            return result;
        }
		
        if (r2 > 0 && r2 < maxR) {
            result.root = r2;
            result.found = true;
            return result;
        }
		
        return result;
    }
	
}
