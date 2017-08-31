package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */

// We're mainly based on the logic defined into the FreeCamera code
class UniversalCamera extends TouchCamera {
	
	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, position, scene);
		//this.inputs.addGamepad();
	}
	
	override public function getClassName():String {
		return "UniversalCamera";
	}
	
}
