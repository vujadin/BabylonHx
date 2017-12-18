package com.babylonhx.cameras;

import com.babylonhx.cameras.inputs.ArcRotateCameraGamepadInput;
import com.babylonhx.cameras.inputs.ArcRotateCameraKeyboardMoveInput;
import com.babylonhx.cameras.inputs.ArcRotateCameraMouseWheelInput;
import com.babylonhx.cameras.inputs.ArcRotateCameraPointersInput;
import com.babylonhx.cameras.inputs.ArcRotateCameraVRDeviceOrientationInput;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ArcRotateCameraInputsManager extends CameraInputsManager {

	public function new(camera:ArcRotateCamera) {
		super(camera);
	}
	
	public function addMouseWheel():ArcRotateCameraInputsManager {
		this.add(new ArcRotateCameraMouseWheelInput());
		return this;
	}

	public function addPointers():ArcRotateCameraInputsManager {
		this.add(new ArcRotateCameraPointersInput());
		return this;
	}

	public function addKeyboard():ArcRotateCameraInputsManager {
		this.add(new ArcRotateCameraKeyboardMoveInput());
		return this;
	}

	public function addGamepad():ArcRotateCameraInputsManager {
		this.add(new ArcRotateCameraGamepadInput());
		return this;
	}

	public function addVRDeviceOrientation():ArcRotateCameraInputsManager {
		this.add(new ArcRotateCameraVRDeviceOrientationInput());
		return this;
	}
	
}
