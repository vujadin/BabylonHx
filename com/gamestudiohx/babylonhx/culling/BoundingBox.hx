package com.gamestudiohx.babylonhx.culling;

import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Plane;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class BoundingBox {
	
	public var minimum:Vector3;
	public var maximum:Vector3;
	public var vectors:Array<Vector3>;
	public var vectorsWorld:Array<Vector3>;
	
	public var center:Vector3;
	public var _extends:Vector3;
	public var directions:Array<Vector3>;
	
	public var minimumWorld:Vector3;
	public var maximumWorld:Vector3;
	

	public function new(minimum:Vector3, maximum:Vector3) {
		this.minimum = minimum;
        this.maximum = maximum;
        
        // Bounding vectors
        this.vectors = [];

        this.vectors.push(this.minimum.clone());
        this.vectors.push(this.maximum.clone());

        this.vectors.push(this.minimum.clone());
        this.vectors[2].x = this.maximum.x;

        this.vectors.push(this.minimum.clone());
        this.vectors[3].y = this.maximum.y;

        this.vectors.push(this.minimum.clone());
        this.vectors[4].z = this.maximum.z;

        this.vectors.push(this.maximum.clone());
        this.vectors[5].z = this.minimum.z;

        this.vectors.push(this.maximum.clone());
        this.vectors[6].x = this.minimum.x;

        this.vectors.push(this.maximum.clone());
        this.vectors[7].y = this.minimum.y;

        // OBB
        this.center = this.maximum.add(this.minimum).scale(0.5);
        this._extends = this.maximum.subtract(this.minimum).scale(0.5);
        this.directions = [Vector3.Zero(), Vector3.Zero(), Vector3.Zero()];

        // World
        this.vectorsWorld = [];
        for (index in 0...this.vectors.length) {
            this.vectorsWorld[index] = Vector3.Zero();
        }
        this.minimumWorld = Vector3.Zero();
        this.maximumWorld = Vector3.Zero();

        this._update(Matrix.Identity());
	}
	
	public function _update(world:Matrix) {
        Vector3.FromFloatsToRef(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, this.minimumWorld);
        Vector3.FromFloatsToRef(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, this.maximumWorld);

        for (index in 0...this.vectors.length) {
            var v:Vector3 = this.vectorsWorld[index];
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

        // OBB
        this.maximumWorld.addToRef(this.minimumWorld, this.center);
        this.center.scaleInPlace(0.5);

        Vector3.FromArrayToRef(world.m, 0, this.directions[0]);
        Vector3.FromArrayToRef(world.m, 4, this.directions[1]);
        Vector3.FromArrayToRef(world.m, 8, this.directions[2]);
    }
	
	public function _isInFrustrum(frustumPlanes:Array<Plane>):Bool { 
        return BoundingBox.IsInFrustum(this.vectorsWorld, frustumPlanes);
    }
	
	public function intersectsPoint(point:Vector3):Bool {
        if (this.maximumWorld.x < point.x || this.minimumWorld.x > point.x)
            return false;

        if (this.maximumWorld.y < point.y || this.minimumWorld.y > point.y)
            return false;

        if (this.maximumWorld.z < point.z || this.minimumWorld.z > point.z)
            return false;

        return true;
    }
	
	public function intersectsSphere(sphere:BoundingSphere):Bool {
        var vector = Vector3.Clamp(sphere.centerWorld, this.minimumWorld, this.maximumWorld);
        var num = Vector3.DistanceSquared(sphere.centerWorld, vector);
        return (num <= (sphere.radiusWorld * sphere.radiusWorld));
    }
	
	public function intersectsMinMax(min:Vector3, max:Vector3):Bool {
        if (this.maximumWorld.x < min.x || this.minimumWorld.x > max.x)
            return false;

        if (this.maximumWorld.y < min.y || this.minimumWorld.y > max.y)
            return false;

        if (this.maximumWorld.z < min.z || this.minimumWorld.z > max.z)
            return false;

        return true;
    }
	
	public static function intersects(box0:BoundingBox, box1:BoundingBox):Bool {
        if (box0.maximumWorld.x < box1.minimumWorld.x || box0.minimumWorld.x > box1.maximumWorld.x)
            return false;

        if (box0.maximumWorld.y < box1.minimumWorld.y || box0.minimumWorld.y > box1.maximumWorld.y)
            return false;

        if (box0.maximumWorld.z < box1.minimumWorld.z || box0.minimumWorld.z > box1.maximumWorld.z)
            return false;

        return true;
    }
	
	public static function IsInFrustum(boundingVectors:Array<Vector3>, frustumPlanes:Array<Plane>):Bool {
        for (p in 0...6) {
            var inCount:Int = 8;

            for (i in 0...8) {
                if (frustumPlanes[p].dotCoordinate(boundingVectors[i]) < 0) {
                    --inCount;
                } else {
                    break;
                }
            }
            if (inCount == 0)
                return false;
        }
        return true;
    }
	
}
