package com.babylonhx.culling;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Tools;
import com.babylonhx.math.Vector3;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.BoundingSphere') class BoundingSphere {
	
	public var center:Vector3;
	public var radius:Float;
	public var centerWorld:Vector3;
	public var radiusWorld:Float;

	private var _tempRadiusVector:Vector3 = Vector3.Zero();
	

	public function new(minimum:Vector3, maximum:Vector3) {
		var distance = Vector3.Distance(minimum, maximum);
		
		this.center = Vector3.Lerp(minimum, maximum, 0.5);
		this.radius = distance * 0.5;
		
		this.centerWorld = Vector3.Zero();
		this._update(Matrix.Identity());
	}

	// Methods
	inline public function _update(world:Matrix):Void {
		Vector3.TransformCoordinatesToRef(this.center, world, this.centerWorld);
        Vector3.TransformNormalFromFloatsToRef(1.0, 1.0, 1.0, world, this._tempRadiusVector);
        this.radiusWorld = Math.max(Math.max(Math.abs(this._tempRadiusVector.x), Math.abs(this._tempRadiusVector.y)), Math.abs(this._tempRadiusVector.z)) * this.radius;
	}

	public function isInFrustum(frustumPlanes:Array<Plane>):Bool {
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
		
		if (Math.abs(this.radiusWorld - distance) < Tools.Epsilon) {
			return false;
		}
			
		return true;
	}

	// Statics
	public static function Intersects(sphere0:BoundingSphere, sphere1:BoundingSphere):Bool {
		var x = sphere0.centerWorld.x - sphere1.centerWorld.x;
		var y = sphere0.centerWorld.y - sphere1.centerWorld.y;
		var z = sphere0.centerWorld.z - sphere1.centerWorld.z;
		
		var distance = Math.sqrt((x * x) + (y * y) + (z * z));
		
		if (sphere0.radiusWorld + sphere1.radiusWorld < distance) {
			return false;
		}
		
		return true;
	}

}
