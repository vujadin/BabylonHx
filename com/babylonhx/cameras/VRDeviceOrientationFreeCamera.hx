package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.cameras.VRCameraMetrics;

#if (js || web || html5 || purejs)
import js.Browser;
#end

//declare var HMDVRDevice;
//declare var PositionSensorVRDevice;

@:expose('BABYLON.VRDeviceOrientationFreeCamera') class VRDeviceOrientationFreeCamera extends FreeCamera{
	public var _alpha:Float = 0;
	public var _beta:Float = 0;
	public var _gamma:Float = 0;

	private var _offsetOrientation:Dynamic;
	private var _deviceOrientationHandler:Dynamic;

	public function new(name:String, position:Vector3, scene:Scene, compensateDistortion:Bool = true) {
		super(name, position, scene);
		
		var metrics = VRCameraMetrics.GetDefault();
		metrics.compensateDistortion = compensateDistortion;
		this.setCameraRigMode(Camera.RIG_MODE_VR, { vrCameraMetrics: metrics } );
		
		//this._deviceOrientationHandler = this._onOrientationEvent.bind(this);
	}

	public function _onOrientationEvent(evt:Dynamic) {
		#if (js || web || html5 || purejs)
		this._alpha = untyped __js__("+evt.alpha | 0;");
		this._beta = untyped __js__("+evt.beta | 0;");
		this._gamma = untyped __js__("+evt.gamma | 0;");
		#end
		
		if (this._gamma < 0) {
			this._gamma = 90 + this._gamma;
		}
		else {
			// Incline it in the correct angle.
			this._gamma = 270 - this._gamma;
		}
		
		this.rotation.x = this._gamma / 180.0 * Math.PI;   
		this.rotation.y = -this._alpha / 180.0 * Math.PI;   
		this.rotation.z = this._beta / 180.0 * Math.PI;     
	}

	public override function attachControl(?element:Dynamic, noPreventDefault:Bool = false, useCtrlForPanning:Bool = true, enableKeyboard:Bool = true): Void {
		super.attachControl(element, noPreventDefault);
		
		#if (js || web || html5 || purejs)
		untyped window.addEventListener("deviceorientation", this._onOrientationEvent);
		#end
	}

	public override function detachControl(?element:Dynamic): Void {
		super.detachControl(element);
		
		#if (js || web || html5 || purejs)
		untyped window.removeEventListener("deviceorientation", this._onOrientationEvent);
		#end
	}
	
}
