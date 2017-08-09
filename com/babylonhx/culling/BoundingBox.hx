package com.babylonhx.culling;

import com.babylonhx.ISmartArrayCompatible;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Tools;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Tmp;

import haxe.ds.Vector;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.BoundingBox') class BoundingBox implements ISmartArrayCompatible implements ICullable {
	
	public var vectors:Vector<Vector3> = new Vector<Vector3>(8);	
	public var center:Vector3;
	public var centerWorld:Vector3;
	public var extendSize:Vector3;
	public var extendSizeWorld:Vector3;
	public var directions:Vector<Vector3> = new Vector<Vector3>(3);
	public var vectorsWorld:Vector<Vector3> = new Vector<Vector3>(8);	
	public var minimumWorld:Vector3;
	public var maximumWorld:Vector3;
	
	public var minimum:Vector3;
	public var maximum:Vector3;

	private var _worldMatrix:Matrix;
	
	public var __smartArrayFlags:Array<Int> = [];	// BHX
	

	public function new(minimum:Vector3, maximum:Vector3) {
		this.minimum = minimum;
		this.maximum = maximum;
		
		// Bounding vectors            
		this.vectors.set(0, this.minimum.clone());
		this.vectors.set(1, this.maximum.clone());
		
		this.vectors.set(2, this.minimum.clone());
		this.vectors[2].x = this.maximum.x;
		
		this.vectors.set(3, this.minimum.clone());
		this.vectors[3].y = this.maximum.y;
		
		this.vectors.set(4, this.minimum.clone());
		this.vectors[4].z = this.maximum.z;
		
		this.vectors.set(5, this.maximum.clone());
		this.vectors[5].z = this.minimum.z;
		
		this.vectors.set(6, this.maximum.clone());
		this.vectors[6].x = this.minimum.x;
		
		this.vectors.set(7, this.maximum.clone());
		this.vectors[7].y = this.minimum.y;
		
		// OBB
		this.center = this.maximum.add(this.minimum).scale(0.5);
		this.extendSize = this.maximum.subtract(this.minimum).scale(0.5);
		this.directions = Vector.fromArrayCopy([Vector3.Zero(), Vector3.Zero(), Vector3.Zero()]);
		
		// World
		for (index in 0...this.vectors.length) {
			this.vectorsWorld[index] = Vector3.Zero();
		}
		this.minimumWorld = Vector3.Zero();
		this.maximumWorld = Vector3.Zero();
		this.centerWorld = Vector3.Zero();
		this.extendSizeWorld = Vector3.Zero();
		
		this._update(Matrix.Identity());
	}

	// Methods
	inline public function getWorldMatrix():Matrix {
		return this._worldMatrix;
	}
	
	inline public function setWorldMatrix(matrix:Matrix):BoundingBox {
        this._worldMatrix.copyFrom(matrix);
		
        return this;
    }

	static var v_update:Vector3;
	inline public function _update(world:Matrix) {
		Vector3.FromFloatsToRef(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, this.minimumWorld);
		Vector3.FromFloatsToRef(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, this.maximumWorld);
		
		for (index in 0...this.vectors.length) {
			var v = this.vectorsWorld[index];
			Vector3.TransformCoordinatesToRef(this.vectors[index], world, v);
			
			if (v.x < this.minimumWorld.x)
				this.minimumWorld.x = v.x;
			if (v.y < this.minimumWorld.y)
				this.minimumWorld.y = v.y;
			if (v.z < this.minimumWorld.z)
				this.minimumWorld.z = v.z;
				
			if (v.x > this.maximumWorld.x)
				this.maximumWorld.x = v.x;
			if (v.y > this.maximumWorld.y)
				this.maximumWorld.y = v.y;
			if (v.z > this.maximumWorld.z)
				this.maximumWorld.z = v.z;
		}
		
		// Extend
		this.maximumWorld.subtractToRef(this.minimumWorld, this.extendSizeWorld);
		this.extendSizeWorld.scaleInPlace(0.5);
		
		// OBB
		this.maximumWorld.addToRef(this.minimumWorld, this.centerWorld);
		this.centerWorld.scaleInPlace(0.5);
		
		Vector3.FromFloat32ArrayToRef(world.m, 0, this.directions[0]);
		Vector3.FromFloat32ArrayToRef(world.m, 4, this.directions[1]);
		Vector3.FromFloat32ArrayToRef(world.m, 8, this.directions[2]);
		
		this._worldMatrix = world;
	}

	public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
		return BoundingBox.IsInFrustum(this.vectorsWorld, frustumPlanes);
	}

	public function isCompletelyInFrustum(frustumPlanes:Array<Plane>):Bool {
		return BoundingBox.IsCompletelyInFrustum(this.vectorsWorld, frustumPlanes);
	}

	public function intersectsPoint(point:Vector3):Bool {
		var delta = -Tools.Epsilon;
		
		if (this.maximumWorld.x - point.x < delta || delta > point.x - this.minimumWorld.x)
			return false;
			
		if (this.maximumWorld.y - point.y < delta || delta > point.y - this.minimumWorld.y)
			return false;
			
		if (this.maximumWorld.z - point.z < delta || delta > point.z - this.minimumWorld.z)
			return false;
			
		return true;
	}

	inline public function intersectsSphere(sphere:BoundingSphere):Bool {
		return BoundingBox.IntersectsSphere(this.minimumWorld, this.maximumWorld, sphere.centerWorld, sphere.radiusWorld);
	}

	inline public function intersectsMinMax(min:Vector3, max:Vector3):Bool {
		if (this.maximumWorld.x < min.x || this.minimumWorld.x > max.x)
			return false;
			
		if (this.maximumWorld.y < min.y || this.minimumWorld.y > max.y)
			return false;
			
		if (this.maximumWorld.z < min.z || this.minimumWorld.z > max.z)
			return false;
			
		return true;
	}
	
	public function dispose(_:Bool = false) {
		vectors = null;
		center = null;
		centerWorld = null;
		extendSize = null;
		extendSizeWorld = null;
		directions = null;
		vectorsWorld = null;
		minimumWorld = null;
		maximumWorld = null;
		
		minimum = null;
		maximum = null;
		
		_worldMatrix = null;
		
		__smartArrayFlags = null;
	}

	// Statics
	public static function Intersects(box0:BoundingBox, box1:BoundingBox):Bool {
		if (box0.maximumWorld.x < box1.minimumWorld.x || box0.minimumWorld.x > box1.maximumWorld.x)
			return false;
			
		if (box0.maximumWorld.y < box1.minimumWorld.y || box0.minimumWorld.y > box1.maximumWorld.y)
			return false;
			
		if (box0.maximumWorld.z < box1.minimumWorld.z || box0.minimumWorld.z > box1.maximumWorld.z)
			return false;
			
		return true;
	}

	inline public static function IntersectsSphere(minPoint:Vector3, maxPoint:Vector3, sphereCenter:Vector3, sphereRadius:Float):Bool {
		Tmp.vector3[0] = Vector3.Clamp(sphereCenter, minPoint, maxPoint);		
		var num = Vector3.DistanceSquared(sphereCenter, Tmp.vector3[0]);		
		return (num <= (sphereRadius * sphereRadius));
	}

	public static function IsCompletelyInFrustum(boundingVectors:Vector<Vector3>, frustumPlanes:Array<Plane>):Bool {
		for (p in 0...6) {
			for (i in 0...8) {
				if (frustumPlanes[p].dotCoordinate(boundingVectors[i]) < 0) {
					return false;
				}
			}
		}
		return true;
	}

	public static function IsInFrustum(boundingVectors:Vector<Vector3>, frustumPlanes:Array<Plane>):Bool {
		for (p in 0...6) {
			var inCount = 8;
			
			for (i in 0...8) {
				if (frustumPlanes[p].dotCoordinate(boundingVectors[i]) < 0) {
					--inCount;
				} 
				else {
					break;
				}
			}
			if (inCount == 0) {
				return false;
			}
		}
		return true;
	}
	
}
