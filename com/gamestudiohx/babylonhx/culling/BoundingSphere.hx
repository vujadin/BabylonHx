package com.gamestudiohx.babylonhx.culling;

import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.math.Plane;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class BoundingSphere {
	
	public var minimum:Vector3;
	public var maximum:Vector3;
	
	public var center:Vector3;
	public var radius:Float;
	
	public var centerWorld:Vector3;
	public var radiusWorld:Float;
	

	public function new(minimum:Vector3, maximum:Vector3) {
		this.minimum = minimum;
        this.maximum = maximum;
        
        var distance:Float = Vector3.Distance(minimum, maximum);
        
        this.center = Vector3.Lerp(minimum, maximum, 0.5);
        this.radius = distance * 0.5;

        this.centerWorld = Vector3.Zero();
        this._update(Matrix.Identity());
	}
	
	public function _update(world:Matrix, scale:Float = 1.0) {
        Vector3.TransformCoordinatesToRef(this.center, world, this.centerWorld);
        this.radiusWorld = this.radius * scale;
    }
	
	public function isInFrustrum(frustumPlanes:Array<Plane>):Bool {
        for (i in 0...6) {
            if (frustumPlanes[i].dotCoordinate(this.centerWorld) <= -this.radiusWorld)
                return false;
        }

        return true;
    }
	
	public function intersectsPoint(point:Vector3):Bool {
        var x = this.centerWorld.x - point.x;
        var y = this.centerWorld.y - point.y;
        var z = this.centerWorld.z - point.z;

        var distance = Math.sqrt((x * x) + (y * y) + (z * z));

        if (this.radiusWorld < distance)
            return false;

        return true;
    }
	
	public static function intersects(sphere0:BoundingSphere, sphere1:BoundingSphere):Bool {
        var x = sphere0.centerWorld.x - sphere1.centerWorld.x;
        var y = sphere0.centerWorld.y - sphere1.centerWorld.y;
        var z = sphere0.centerWorld.z - sphere1.centerWorld.z;

        var distance = Math.sqrt((x * x) + (y * y) + (z * z));

        if (sphere0.radiusWorld + sphere1.radiusWorld < distance)
            return false;

        return true;
    }
	
}
