package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.cameras.VRCameraMetrics;

#if (js || purejs || web || html5) 
import js.Browser;
import js.html.Navigator;
#end


//declare var HMDVRDevice;
//declare var PositionSensorVRDevice;

@:expose('BABYLON.WebVRFreeCamera') class WebVRFreeCamera extends FreeCamera {
	
	public var _hmdDevice:Dynamic = null;
	public var _sensorDevice:Dynamic = null;
	public var _cacheState:Dynamic = null;
	public var _cacheQuaternion:Quaternion = new Quaternion();
	public var _cacheRotation:Vector3 = Vector3.Zero();
	public var _vrEnabled:Bool = false;
	
	
	public function new(name:String, position:Vector3, scene:Scene, compensateDistortion:Bool = true) {
		super(name, position, scene);            
		
		var metrics = VRCameraMetrics.GetDefault();
		metrics.compensateDistortion = compensateDistortion;
		this.setCameraRigMode(Camera.RIG_MODE_VR, { vrCameraMetrics: metrics } );
		
		//this._getWebVRDevices = this._getWebVRDevices.bind(this);
	}
	
	private function _getWebVRDevices(devices:Array<Dynamic>) {
		var size:Int = devices.length;
		var i:Int = 0;
		
		// Reset devices.
		this._sensorDevice = null;
		this._hmdDevice = null;
		
		// Search for a HmdDevice.
		while (i < size && this._hmdDevice == null) {
			if (Type.getClassName(Type.getClass(devices[i])) == 'HMDVRDevice') {
				this._hmdDevice = devices[i];
			}
			i++;
		}
		
		i = 0;
		
		while (i < size && this._sensorDevice == null) {
			if (Type.getClassName(Type.getClass(devices[i])) == 'PositionSensorVRDevice' && (this._hmdDevice == null || devices[i].hardwareUnitId == this._hmdDevice.hardwareUnitId)) {
				this._sensorDevice = devices[i];
			}
			i++;
		}
		
		this._vrEnabled = this._sensorDevice != null && this._hmdDevice != null ? true : false;
	}
	
	override public function _checkInputs() {
		if (this._vrEnabled) {
			this._cacheState = this._sensorDevice.getState();
			this._cacheQuaternion.copyFromFloats(this._cacheState.orientation.x, this._cacheState.orientation.y, this._cacheState.orientation.z, this._cacheState.orientation.w);
			this._cacheQuaternion.toEulerAnglesToRef(this._cacheRotation);
			
			this.rotation.x = -this._cacheRotation.x;
			this.rotation.y = -this._cacheRotation.y;
			this.rotation.z = this._cacheRotation.z;
		}
		
		super._checkInputs();
	}
	
	override public function attachControl(useCtrlForPanning:Bool = false, enableKeyboard:Bool = true) {
		super.attachControl();
		#if (js || purejs || web || html5) 
		var nav:Navigator = untyped Browser.window.navigator;
		if (untyped nav.getVRDevices != null) {
			untyped nav.getVRDevices().then(this._getWebVRDevices);
		}
		else if (untyped nav.mozGetVRDevices != null) {
			untyped nav.mozGetVRDevices(this._getWebVRDevices);
		}
		#end
	}
	
	override public function detachControl() {
		super.detachControl();
		this._vrEnabled = false;
	}
	
}
