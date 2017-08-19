package com.babylonhx.culling;

import com.babylonhx.collisions.Collider;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Vector3;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.BoundingInfo') class BoundingInfo implements ICullable {
	
	public var minimum:Vector3;
	public var maximum:Vector3;
	public var boundingBox:BoundingBox;
	public var boundingSphere:BoundingSphere;
	
	public var isLocked(get, set):Bool;
	private var _isLocked:Bool = false;

	
	public function new(minimum:Vector3, maximum:Vector3) {
		this.minimum = minimum;
		this.maximum = maximum;
		this.boundingBox = new BoundingBox(minimum, maximum);
		this.boundingSphere = new BoundingSphere(minimum, maximum);
	}
	
	inline private function get_isLocked():Bool {
		return this._isLocked;
	}
	inline private function set_isLocked(value:Bool):Bool {
		return this._isLocked = value;
	}

	// Methods
	inline public function update(world:Matrix) {
		if (this._isLocked) {
			return;
		}
		
		this.boundingBox._update(world);
		this.boundingSphere._update(world);
	}

	public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
		if (!this.boundingSphere.isInFrustum(frustumPlanes)) {
			return false;
		}
		
		return this.boundingBox.isInFrustum(frustumPlanes);
	}
	
	/**
 	 * Gets the world distance between the min and max points of the bounding box
 	 */
	public var diagonalLength(get, never):Float;
	private function get_diagonalLength():Float {
        var boundingBox = this.boundingBox;
        var size = boundingBox.maximumWorld.subtract(boundingBox.minimumWorld);
	    return size.length();
	} 

	inline public function isCompletelyInFrustum(frustumPlanes:Array<Plane>):Bool {
		return this.boundingBox.isCompletelyInFrustum(frustumPlanes);
	}
   
	inline public function _checkCollision(collider:Collider):Bool {
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

	public function intersects(boundingInfo:BoundingInfo, precise:Bool = false):Bool {
		if (this.boundingSphere.centerWorld == null || boundingInfo.boundingSphere.centerWorld == null) {
			return false;
		}
		
		if (!BoundingSphere.Intersects(this.boundingSphere, boundingInfo.boundingSphere)) {
			return false;
		}
		
		if (!BoundingBox.Intersects(this.boundingBox, boundingInfo.boundingBox)) {
			return false;
		}
		
		if (precise) {
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
	
	// Statics
	private static function computeBoxExtents(axis:Vector3, box:BoundingBox):Dynamic {
        var p = Vector3.Dot(box.center, axis);
		
        var r0 = Math.abs(Vector3.Dot(box.directions[0], axis)) * box.extendSize.x;
        var r1 = Math.abs(Vector3.Dot(box.directions[1], axis)) * box.extendSize.y;
        var r2 = Math.abs(Vector3.Dot(box.directions[2], axis)) * box.extendSize.z;
		
        var r = r0 + r1 + r2;
		
        return {
            min: p - r,
            max: p + r
        };
    }

    inline private static function extentsOverlap(min0:Float, max0:Float, min1:Float, max1:Float):Bool {
		return !(min0 > max1 || min1 > max0);
	}

    inline private static function axisOverlap(axis:Vector3, box0:BoundingBox, box1:BoundingBox):Bool {
        var result0 = computeBoxExtents(axis, box0);
        var result1 = computeBoxExtents(axis, box1);
		
        return extentsOverlap(result0.min, result0.max, result1.min, result1.max);
    }
	
}
