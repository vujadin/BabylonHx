package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

// We're mainly based on the logic defined into the FreeCamera code
class UniversalCamera extends TouchCamera {
	
	public var gamepad:Dynamic;// Gamepad;
	private var _gamepads:Dynamic;// Gamepads;
	public var gamepadAngularSensibility:Int = 200;
	public var gamepadMoveSensibility:Int = 40;
	

	public function new(name:String, position:Vector3, scene:Scene) {
		
	}
	
}
