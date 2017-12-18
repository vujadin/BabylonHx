package com.babylonhx.cameras.inputs;

import com.babylonhx.cameras.ICameraInput;
import com.babylonhx.tools.Observer;
import com.babylonhx.events.PointerEvent;
import com.babylonhx.events.PointerInfo;
import com.babylonhx.tools.EventState;
import com.babylonhx.events.PointerEventTypes;

/**
 * ...
 * @author Krtolica Vujadin
 */
class FreeCameraMouseInput implements ICameraInput {
	
	public var camera:FreeCamera;

	@serialize()
	public var buttons:Array<Int> = [0, 1, 2];

	@serialize()
	public var angularSensibility:Float = 2000.0;

	private var _pointerInput:PointerInfo->EventState->Void;
	private var _onMouseMove:PointerEvent->Dynamic = null;
	private var _observer:Observer<PointerInfo>;

	private var previousPosition:Array<Float> = [];
	
	public var touchEnabled:Bool;
	

	public function new(touchEnabled:Bool = true) {
		this.touchEnabled = touchEnabled;
	}
	
	public function attachControl() {
		var engine = this.camera.getEngine();
		
		if (this._pointerInput == null) {
			this._pointerInput = function(p:PointerInfo, s:EventState) {
				var evt = p.event;
				
				if (engine.isInVRExclusivePointerMode) {
					return;
				}
				
				if (!this.touchEnabled && evt.pointerType == "touch") {
					return;
				}
				
				if (p.type != PointerEventTypes.POINTERMOVE && this.buttons.indexOf(evt.button) == -1) {
					return;
				}
				
				if (p.type == PointerEventTypes.POINTERDOWN) {
					this.previousPosition[0] = evt.x;
					this.previousPosition[1] = evt.y;
				}
				else if (p.type == PointerEventTypes.POINTERUP) {
					this.previousPosition = null;
				}				
				else if (p.type == PointerEventTypes.POINTERMOVE) {
					if (this.previousPosition.length == 0 || engine.isPointerLock) {
						return;
					}
					
					var offsetX = evt.x - this.previousPosition[0];
					var offsetY = evt.y - this.previousPosition[1];
					
					if (this.camera.getScene().useRightHandedSystem) {
						this.camera.cameraRotation.y -= offsetX / this.angularSensibility;
					} 
					else {
						this.camera.cameraRotation.y += offsetX / this.angularSensibility;
					}
					
					this.camera.cameraRotation.x += offsetY / this.angularSensibility;
					
					this.previousPosition[0] = evt.x;
					this.previousPosition[1] = evt.y;
				}
			}
		}
		
		this._onMouseMove = function(evt:PointerEvent) {
			if (!engine.isPointerLock) {
				return;
			}
			
			if (engine.isInVRExclusivePointerMode) {
				return;
			}
			
			var offsetX = evt.x;
			var offsetY = evt.y;
			
			if (this.camera.getScene().useRightHandedSystem) {
				this.camera.cameraRotation.y -= offsetX / this.angularSensibility;
			} 
			else {
				this.camera.cameraRotation.y += offsetX / this.angularSensibility;
			}
			
			this.camera.cameraRotation.x += offsetY / this.angularSensibility;
			
			this.previousPosition.splice(0, 2);
		};
		
		this._observer = this.camera.getScene().onPointerObservable.add(this._pointerInput, PointerEventTypes.POINTERDOWN | PointerEventTypes.POINTERUP | PointerEventTypes.POINTERMOVE);
		this.getScene().getEngine().mouseMove.push(this._onMouseMove);
	}

	public function detachControl() {
		if (this._observer != null) {
			this.camera.getScene().onPointerObservable.remove(this._observer);
			
			if (this._onMouseMove != null) {
				this.getScene().getEngine().mouseMove.remove(this._onMouseMove);
			}
			
			this._observer = null;
			this._onMouseMove = null;
			this.previousPosition = null;
		}
	}

	public function getClassName():String {
		return "FreeCameraMouseInput";
	}

	public function getSimpleName():String {
		return "mouse";
	}
	
}
