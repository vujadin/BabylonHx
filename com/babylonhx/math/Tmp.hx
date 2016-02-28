package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */

// Temporary pre-allocated objects for engine internal use
// usage in any internal function :
// var tmp = Tmp.Vector3[0];   <= gets access to the first pre-created Vector3
// There's a Tmp array per object type : int, float, Vector2, Vector3, Vector4, Quaternion, Matrix
class Tmp {
	
	public static var color3:Array<Color3> = [Color3.Black(), Color3.Black(), Color3.Black()];
	
	public static var vector2:Array<Vector2> = [Vector2.Zero(), Vector2.Zero(), Vector2.Zero()];  // 3 temp Vector2 at once should be enough
	
	public static var vector3:Array<Vector3> = [Vector3.Zero(), Vector3.Zero(), Vector3.Zero(), Vector3.Zero(), Vector3.Zero(),
                                        Vector3.Zero(), Vector3.Zero(), Vector3.Zero(), Vector3.Zero()];    // 9 temp Vector3 at once should be enough
										
	public static var vector4:Array<Vector4> = [Vector4.Zero(), Vector4.Zero(), Vector4.Zero()];  // 3 temp Vector4 at once should be enough
	
	public static var quaternion:Array<Quaternion> = [new Quaternion(0, 0, 0, 0), new Quaternion(0, 0, 0, 0)];                // 2 temp Quaternions at once should be enough
	
	public static var matrix:Array<Matrix> = [Matrix.Zero(), Matrix.Zero(),
                                          Matrix.Zero(), Matrix.Zero(),
                                          Matrix.Zero(), Matrix.Zero(),
                                          Matrix.Zero(), Matrix.Zero()];                      // 6 temp Matrices at once should be enough

	public function new() {
		
	}
	
}
