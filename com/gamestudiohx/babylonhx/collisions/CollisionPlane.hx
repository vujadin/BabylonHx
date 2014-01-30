package com.gamestudiohx.babylonhx.collisions;

import com.gamestudiohx.babylonhx.tools.math.Vector3;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class CollisionPlane {
	
	public var normal:Vector3;
	public var origin:Vector3;
	public var equation:Array<Float>;
	

	public function new(origin:Vector3, normal:Vector3) {
		this.normal = normal;
        this.origin = origin;

        normal.normalize();

        this.equation = [];
        this.equation[0] = normal.x;
        this.equation[1] = normal.y;
        this.equation[2] = normal.z;
        this.equation[3] = -(normal.x * origin.x + normal.y * origin.y + normal.z * origin.z);
	}
	
	public function isFrontFacingTo(direction:Vector3, epsilon:Float):Bool {
        var dot = Vector3.Dot(this.normal, direction);

        return (dot <= epsilon);
    }
	
	public function signedDistanceTo(point:Vector3):Vector3 {
        return Vector3.Dot(point, this.normal) + this.equation[3];
    }
	
	public function CreateFromPoints(p1:Vector3, p2:Vector3, p3:Vector3):CollisionPlane {
        var normal = Vector3.Cross(p2.subtract(p1), p3.subtract(p1));

        return new CollisionPlane(p1, normal);
    }
	
}
