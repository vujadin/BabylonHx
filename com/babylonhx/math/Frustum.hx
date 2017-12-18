package com.babylonhx.math;

/**
* ...
* @author Krtolica Vujadin
*/
@:expose('BABYLON.Frustum') class Frustum {
	
	inline public static function GetPlanes(transform:Matrix):Array<Plane> {
		var frustumPlanes:Array<Plane> = [];
		
		for (index in 0...6) {
			frustumPlanes.push(new Plane(0, 0, 0, 0));
		}
		
		Frustum.GetPlanesToRef(transform, frustumPlanes);
		
		return frustumPlanes;
	}

	inline public static function GetNearPlaneToRef(transform:Matrix, frustumPlane:Plane) {
		frustumPlane.normal.x = transform.m[3] + transform.m[2];
		frustumPlane.normal.y = transform.m[7] + transform.m[6];
		frustumPlane.normal.z = transform.m[11] + transform.m[10];
		frustumPlane.d = transform.m[15] + transform.m[14];
		frustumPlane.normalize();
	}

	inline public static function GetFarPlaneToRef(transform:Matrix, frustumPlane:Plane) {
		frustumPlane.normal.x = transform.m[3] - transform.m[2];
		frustumPlane.normal.y = transform.m[7] - transform.m[6];
		frustumPlane.normal.z = transform.m[11] - transform.m[10];
		frustumPlane.d = transform.m[15] - transform.m[14];
		frustumPlane.normalize();
	}

	inline public static function GetLeftPlaneToRef(transform:Matrix, frustumPlane:Plane) {
		frustumPlane.normal.x = transform.m[3] + transform.m[0];
		frustumPlane.normal.y = transform.m[7] + transform.m[4];
		frustumPlane.normal.z = transform.m[11] + transform.m[8];
		frustumPlane.d = transform.m[15] + transform.m[12];
		frustumPlane.normalize();
	}       
	
	inline public static function GetRightPlaneToRef(transform:Matrix, frustumPlane:Plane) {
		frustumPlane.normal.x = transform.m[3] - transform.m[0];
		frustumPlane.normal.y = transform.m[7] - transform.m[4];
		frustumPlane.normal.z = transform.m[11] - transform.m[8];
		frustumPlane.d = transform.m[15] - transform.m[12];
		frustumPlane.normalize();
	}     
	
	inline public static function GetTopPlaneToRef(transform:Matrix, frustumPlane:Plane) {
		frustumPlane.normal.x = transform.m[3] - transform.m[1];
		frustumPlane.normal.y = transform.m[7] - transform.m[5];
		frustumPlane.normal.z = transform.m[11] - transform.m[9];
		frustumPlane.d = transform.m[15] - transform.m[13];
		frustumPlane.normalize();
	}      
	
	inline public static function GetBottomPlaneToRef(transform:Matrix, frustumPlane:Plane) {
		frustumPlane.normal.x = transform.m[3] + transform.m[1];
		frustumPlane.normal.y = transform.m[7] + transform.m[5];
		frustumPlane.normal.z = transform.m[11] + transform.m[9];
		frustumPlane.d = transform.m[15] + transform.m[13];
		frustumPlane.normalize();
	}           

	/**
	 * Sets the passed array "frustumPlanes" with the 6 Frustum planes computed by the passed transformation matrix.  
	 */
	public static function GetPlanesToRef(transform:Matrix, frustumPlanes:Array<Plane>) {
		// Near
		Frustum.GetNearPlaneToRef(transform, frustumPlanes[0]);
		
		// Far
		Frustum.GetFarPlaneToRef(transform, frustumPlanes[1]);
		
		// Left
		Frustum.GetLeftPlaneToRef(transform, frustumPlanes[2]);
		
		// Right
		Frustum.GetRightPlaneToRef(transform, frustumPlanes[3]);
		
		// Top
		Frustum.GetTopPlaneToRef(transform, frustumPlanes[4]);
		
		// Bottom
		Frustum.GetBottomPlaneToRef(transform, frustumPlanes[5]);
	}
	
}
