package com.babylonhx.cameras.inputs;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ArcRotateCameraGamepadInput implements ICameraInput {
	
	public var camera:ArcRotateCamera;

	public var gamepad:Gamepad;
	private var _gamepads:Gamepads;

	@serialize()
	public var gamepadRotationSensibility:Float = 80;

	@serialize()
	public var gamepadMoveSensibility:Float = 40;
	

	public function new() {
		// ...
	}
	
	public function attachControl() {
		this._gamepads = new Gamepads(function(gamepad:Gamepad) { this._onNewGameConnected(gamepad); });
	}
	
	public function detachControl() {
		if (this._gamepads != null) {
			this._gamepads.dispose();
		}
		this.gamepad = null;
	}

	public function checkInputs() {
		if (this.gamepad != null) {
			var camera = this.camera;
			var RSValues = this.gamepad.rightStick;
			
			if (RSValues.x != 0) {
				var normalizedRX = RSValues.x / this.gamepadRotationSensibility;
				if (normalizedRX != 0 && Math.abs(normalizedRX) > 0.005) {
					camera.inertialAlphaOffset += normalizedRX;
				}
			}
			
			if (RSValues.y != 0) {
				var normalizedRY = RSValues.y / this.gamepadRotationSensibility;
				if (normalizedRY != 0 && Math.abs(normalizedRY) > 0.005) {
					camera.inertialBetaOffset += normalizedRY;
				}
			}
			
			var LSValues = this.gamepad.leftStick;
			if (LSValues.y != 0) {
				var normalizedLY = LSValues.y / this.gamepadMoveSensibility;
				if (normalizedLY != 0 && Math.abs(normalizedLY) > 0.005) {
					this.camera.inertialRadiusOffset -= normalizedLY;
				}
			}
		}
	}

	private functin _onNewGameConnected(gamepad:Gamepad) {
		// Only the first gamepad can control the camera
		if (gamepad.index == 0) {
			this.gamepad = gamepad;
		}
	}

	public function getTypeName():String {
		return "ArcRotateCameraGamepadInput";
	}

	public function getSimpleName():String {
		return "gamepad";
	}
	
}
