package com.babylonhx.math;

import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.Angle') class Angle {
	
	public static inline var Orientation_CW:Int = 1;
	public static inline var Orientation_CCW:Int = -1;

	private var _radians:Float;
	
	
	inline public function degrees():Float { 
		return (this._radians * 180 / Math.PI); 
	}
	inline public function radians():Float { 
		return this._radians; 
	}
	
	
	public function new(radians:Float) {
		this._radians = radians;
		if (this._radians < 0) {
			this._radians += (2 * Math.PI);
		}
	}

	inline static public function BetweenTwoPoints(a:Vector2, b:Vector2):Angle {
		var delta = b.subtract(a);
		var theta = Math.atan2(delta.y, delta.x);
		return new Angle(theta);
	}

	static public function FromRadians(radians:Float):Angle {
		return new Angle(radians);
	}

	static public function FromDegrees(degrees:Float):Angle {
		return new Angle(degrees * Math.PI / 180);
	}
	
}
