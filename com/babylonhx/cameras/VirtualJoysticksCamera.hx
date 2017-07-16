package com.babylonhx.cameras;

import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
class VirtualJoysticksCamera extends FreeCamera {

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, position, scene);
		this.inputs.addVirtualJoystick();
	}
	
}
