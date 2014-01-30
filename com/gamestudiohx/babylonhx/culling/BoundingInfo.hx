package com.gamestudiohx.babylonhx.culling;

import com.gamestudiohx.babylonhx.collisions.Collider;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Plane;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

typedef BoundingInfoMinMax = {
	min: Float,
	max: Float
}

class BoundingInfo {
	
	public var boundingBox:BoundingBox;
	public var boundingSphere:BoundingSphere;

	public function new(minimum:Vector3, maximum:Vector3) {
		this.boundingBox = new BoundingBox(minimum, maximum);
        this.boundingSphere = new BoundingSphere(minimum, maximum);
	}
	
	public function _update(world:Matrix, scale:Float) {
        this.boundingBox._update(world);
        this.boundingSphere._update(world, scale);
    }
	
	function extentsOverlap(min0:Float, max0:Float, min1:Float, max1:Float):Bool {
        return !(min0 > max1 || min1 > max0);
    }
	
	function computeBoxExtents(axis:Vector3, box:BoundingBox):BoundingInfoMinMax {
        var p = Vector3.Dot(box.center, axis);

        var r0 = Math.abs(Vector3.Dot(box.directions[0], axis)) * box._extends.x;
        var r1 = Math.abs(Vector3.Dot(box.directions[1], axis)) * box._extends.y;
        var r2 = Math.abs(Vector3.Dot(box.directions[2], axis)) * box._extends.z;

        var r = r0 + r1 + r2;
        return {
            min: p - r,
            max: p + r
        };
    }
	
	function axisOverlap(axis:Vector3, box0:BoundingBox, box1:BoundingBox):Bool {
        var result0 = computeBoxExtents(axis, box0);
        var result1 = computeBoxExtents(axis, box1);

        return extentsOverlap(result0.min, result0.max, result1.min, result1.max);
    }
	
	public function isInFrustrum(frustumPlanes:Array<Plane>):Bool {
        if (!this.boundingSphere.isInFrustrum(frustumPlanes))
            return false;

        return this.boundingBox._isInFrustrum(frustumPlanes);
    }
	
	public function _checkCollision(collider:Collider):Bool {
        return collider._canDoCollision(this.boundingSphere.centerWorld, this.boundingSphere.radiusWorld, this.boundingBox.minimumWorld, this.boundingBox.maximumWorld);
    }
	
	public function intersectsPoint(point:Vector3):Bool {
        if (this.boundingSphere.centerWorld == null) {
            return false;
        }

        if (!this.boundingSphere.intersectsPoint(point)) {
            return false;
        }

        if (!this.boundingBox.intersectsPoint(point)) {
            return false;
        }

        return true;
    }
	
	public function intersects(boundingInfo:BoundingInfo, precise:Bool) {
        if (this.boundingSphere.centerWorld == null || boundingInfo.boundingSphere.centerWorld == null) {
            return false;
        }

        if (!BoundingSphere.intersects(this.boundingSphere, boundingInfo.boundingSphere)) {
            return false;
        }

        if (!BoundingBox.intersects(this.boundingBox, boundingInfo.boundingBox)) {
            return false;
        }

        if (!precise) {
            return true;
        }

        var box0 = this.boundingBox;
        var box1 = boundingInfo.boundingBox;

        if (!axisOverlap(box0.directions[0], box0, box1)) return false;
        if (!axisOverlap(box0.directions[1], box0, box1)) return false;
        if (!axisOverlap(box0.directions[2], box0, box1)) return false;
        if (!axisOverlap(box1.directions[0], box0, box1)) return false;
        if (!axisOverlap(box1.directions[1], box0, box1)) return false;
        if (!axisOverlap(box1.directions[2], box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[0], box1.directions[0]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[0], box1.directions[1]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[0], box1.directions[2]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[1], box1.directions[0]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[1], box1.directions[1]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[1], box1.directions[2]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[2], box1.directions[0]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[2], box1.directions[1]), box0, box1)) return false;
        if (!axisOverlap(Vector3.Cross(box0.directions[2], box1.directions[2]), box0, box1)) return false;

        return true;
    }
	
}
