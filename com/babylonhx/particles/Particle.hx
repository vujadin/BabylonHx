package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color4;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Particle') class Particle {
	
	public var position:Vector3 = Vector3.Zero();
	public var direction:Vector3 = Vector3.Zero();
	public var color:Color4 = new Color4(0, 0, 0, 0);
	public var colorStep:Color4 = new Color4(0, 0, 0, 0);
	
	public var lifeTime:Float = 1.0;
	public var age:Float = 0;
	public var size:Float = 0;
	public var angle:Float = 0;
	public var angularSpeed:Float = 0;
		

	public function new() {
		//
	}
	
}
