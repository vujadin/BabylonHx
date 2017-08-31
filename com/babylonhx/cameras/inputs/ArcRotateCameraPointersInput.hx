package com.babylonhx.cameras.inputs;

import com.babylonhx.PointerInfo;
import com.babylonhx.tools.EventState;
import com.babylonhx.tools.Observer;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ArcRotateCameraPointersInput implements ICameraInput {
	
	public var camera:ArcRotateCamera;

	@serialize()
	public var buttons:Array<Int> = [0, 1, 2];

	@serialize()
	public var angularSensibilityX:Float = 1000.0;

	@serialize()
	public var angularSensibilityY:Float = 1000.0;

	@serialize()
	public var pinchPrecision:Float = 6.0;

	@serialize()
	public var panningSensibility:Float = 50.0;

	private var _isPanClick:Bool = false;
	public var pinchInwards:Bool = true;

	private var _pointerInput:PointerInfo->EventState->Void;
	private var _observer:Observer<PointerInfo>;
	private var _onMouseMove:Dynamic;
	private var _onGestureStart:Dynamic;
	private var _onGesture:Dynamic;
	

	public function attachControl() {
		var engine = this.camera.getEngine();
		var cacheSoloPointer:Dynamic = { x:Int, y:Int, pointerId:Int, type:Dynamic }; // cache pointer object for better perf on camera rotation
		var pointA:Dynamic = { x:Int, y:Int, pointerId:Int, type:Dynamic };
		var pointB:Dynamic = { x:Int, y:Int, pointerId:Int, type:Dynamic };
		var previousPinchDistance:Int = 0;

		this._pointerInput = function(p:PointerInfo, s:EventState) {
			var evt = p.event;
			
			if (p.type != PointerEventTypes.POINTERMOVE && this.buttons.indexOf(evt.button) == -1) {
				return;
			}
			
			if (p.type == PointerEventTypes.POINTERDOWN) {
				// Manage panning with pan button click
				this._isPanClick = evt.button == this.camera._panningMouseButton;
				
				// manage pointers
				cacheSoloPointer = { x: evt.x, y: evt.x, pointerId: evt.pointerId, type: evt.pointerType };
				if (pointA == null) {
					pointA = cacheSoloPointer;
				}
				else if (pointB == null) {
					pointB = cacheSoloPointer;
				}
			} 
			else if (p.type == PointerEventTypes.POINTERUP) {
				cacheSoloPointer = null;
				previousPinchDistance = 0;
				
				//would be better to use pointers.remove(evt.pointerId) for multitouch gestures, 
				//but emptying completly pointers collection is required to fix a bug on iPhone : 
				//when changing orientation while pinching camera, one pointer stay pressed forever if we don't release all pointers  
				//will be ok to put back pointers.remove(evt.pointerId); when iPhone bug corrected
				pointA = pointB = null;
			} 
			else if (p.type == PointerEventTypes.POINTERMOVE) {
				// One button down
				if (pointA != null && pointB == null) {
					if (this.panningSensibility != 0 &&
						((evt.ctrlKey && this.camera._useCtrlForPanning) || (!this.camera._useCtrlForPanning && this._isPanClick))) {
						this.camera.inertialPanningX += -(evt.clientX - cacheSoloPointer.x) / this.panningSensibility;
						this.camera.inertialPanningY += (evt.clientY - cacheSoloPointer.y) / this.panningSensibility;
					} 
					else {
						var offsetX = evt.clientX - cacheSoloPointer.x;
						var offsetY = evt.clientY - cacheSoloPointer.y;
						this.camera.inertialAlphaOffset -= offsetX / this.angularSensibilityX;
						this.camera.inertialBetaOffset -= offsetY / this.angularSensibilityY;
					}
					
					cacheSoloPointer.x = evt.clientX;
					cacheSoloPointer.y = evt.clientY;
				}				
				// Two buttons down: pinch
				else if (pointA != null && pointB != null) {
					//if (noPreventDefault) { evt.preventDefault(); } //if pinch gesture, could be useful to force preventDefault to avoid html page scroll/zoom in some mobile browsers
					var ed = (pointA.pointerId == evt.pointerId) ? pointA : pointB;
					ed.x = evt.x;
					ed.y = evt.y;
					var direction = this.pinchInwards ? 1 : -1;
					var distX = pointA.x - pointB.x;
					var distY = pointA.y - pointB.y;
					var pinchSquaredDistance = (distX * distX) + (distY * distY);
					if (previousPinchDistance == 0) {
						previousPinchDistance = pinchSquaredDistance;
						return;
					}
					
					if (pinchSquaredDistance != previousPinchDistance) {
						this.camera.inertialRadiusOffset += (pinchSquaredDistance - previousPinchDistance) /
							(this.pinchPrecision *
								((this.angularSensibilityX + this.angularSensibilityY) / 2) *
								direction);
						previousPinchDistance = pinchSquaredDistance;
					}
				}
			}
		}
		
		this._observer = this.camera.getScene().onPointerObservable.add(this._pointerInput, PointerEventTypes.POINTERDOWN | PointerEventTypes.POINTERUP | PointerEventTypes.POINTERMOVE);
		
		this._onMouseMove = function(evt:PointerEvent) {
			if (!engine.isPointerLock) {
				return;
			}
			
			var offsetX = 0;
			var offsetY = 0;
			
			this.camera.inertialAlphaOffset -= offsetX / this.angularSensibilityX;
			this.camera.inertialBetaOffset -= offsetY / this.angularSensibilityY;
		};
		
		this._onGesture = function(e => {
			this.camera.radius *= e.scale;


			if (e.preventDefault) {
				if (!noPreventDefault) {
					e.stopPropagation();
					e.preventDefault();
				}
			}
		};

		element.addEventListener("mousemove", this._onMouseMove, false);
		element.addEventListener("MSPointerDown", this._onGestureStart, false);
		element.addEventListener("MSGestureChange", this._onGesture, false);

		Tools.RegisterTopRootEvents([
			{ name: "blur", handler: this._onLostFocus }
		]);
	}

	public detachControl(element: HTMLElement) {
		Tools.UnregisterTopRootEvents([
			{ name: "blur", handler: this._onLostFocus }
		]);

		if (element && this._observer) {
			this.camera.getScene().onPointerObservable.remove(this._observer);
			this._observer = null;

			element.removeEventListener("contextmenu", this._onContextMenu);
			element.removeEventListener("mousemove", this._onMouseMove);
			element.removeEventListener("MSPointerDown", this._onGestureStart);
			element.removeEventListener("MSGestureChange", this._onGesture);

			this._isPanClick = false;
			this.pinchInwards = true;

			this._onMouseMove = null;
			this._onGestureStart = null;
			this._onGesture = null;
			this._MSGestureHandler = null;
			this._onLostFocus = null;
			this._onContextMenu = null;
		}
	}

	getClassName(): string {
		return "ArcRotateCameraPointersInput";
	}

	getSimpleName() {
		return "pointers";
	}
	
}
