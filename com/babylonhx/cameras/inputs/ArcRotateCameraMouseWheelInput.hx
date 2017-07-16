package com.babylonhx.cameras.inputs;

import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Observer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ArcRotateCameraMouseWheelInput implements ICameraInput {
	
	public var camera:ArcRotateCamera;

	private var _wheel:PointerInfo->EventState->Void;
	private var _observer:Observer<PointerInfo>;

	@serialize()
	public wheelPrecision = 3.0;
	

	public function new() {
		// ...
	}

	public function attachControl() {
		this._wheel = function(p:PointerInfo, s:EventState) {
			//sanity check - this should be a PointerWheel event.
			if (p.type != PointerEventTypes.POINTERWHEEL) {
				return;
			}
			var event = p.event;
			var delta:Float = 0;
			if (event.wheelDelta != null) {
				delta = event.wheelDelta / (this.wheelPrecision * 40);
			}
			
			if (delta != 0) {
				this.camera.inertialRadiusOffset += delta;
			}
		};
		
		this._observer = this.camera.getScene().onPointerObservable.add(this._wheel, PointerEventTypes.POINTERWHEEL);
	}

	public detachControl(element: HTMLElement) {
		if (this._observer && element) {
			this.camera.getScene().onPointerObservable.remove(this._observer);
			this._observer = null;
			this._wheel = null;
		}
	}

	public function getTypeName():String {
		return "ArcRotateCameraMouseWheelInput";
	}

	public function getSimpleName():String {
		return "mousewheel";
	}
	
}
