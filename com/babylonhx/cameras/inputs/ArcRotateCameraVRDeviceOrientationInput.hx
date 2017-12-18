package com.babylonhx.cameras.inputs;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ArcRotateCameraVRDeviceOrientationInput implements ICameraInput {

	public var camera:ArcRotateCamera;

	public var alphaCorrection:Float = 1;
	public var betaCorrection:Float = 1;
	public var gammaCorrection:Float = 1;

	private var _alpha:Float = 0;
	private var _gamma:Float = 0;
	private var _dirty:Bool = false;

	private var _deviceOrientationHandler:Void->Void;
	

	public function new() {
		this._deviceOrientationHandler = this._onOrientationEvent.bind(this);
	}

	public function attachControl() {
		this.camera.attachControl();
		this.camera.getScene().getEngine.onResize.push(this._deviceOrientationHandler);
	}

	public function _onOrientationEvent() {
		/*if (evt.alpha != null) {
			this._alpha = +evt.alpha | 0;
		}
		
		if (evt.gamma != null) {
			this._gamma = +evt.gamma | 0;
		}*/
		this._dirty = true;
	}

	public function checkInputs() {
		if (this._dirty) {
			this._dirty = false;
			
			if (this._gamma < 0) {
				this._gamma = 180 + this._gamma;
			}
			
			this.camera.alpha = (-this._alpha / 180.0 * Math.PI) % Math.PI * 2;
			this.camera.beta = (this._gamma / 180.0 * Math.PI);
		}
	}

	public function detachControl() {
		this.camera.getScene().getEngine.onResize.push(this._deviceOrientationHandler);
	}

	public function getClassName():String {
		return "ArcRotateCameraVRDeviceOrientationInput";
	}

	public function getSimpleName():String {
		return "VRDeviceOrientation";
	}
	
}
