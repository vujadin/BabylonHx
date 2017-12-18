package com.babylonhx.cameras.inputs;

import com.babylonhx.events.PointerEventTypes;
import com.babylonhx.events.PointerInfo;
import com.babylonhx.events.PointerEvent;
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
	public var pinchPrecision:Float = 12.0;

	/**
	 * pinchDeltaPercentage will be used instead of pinchPrecision if different from 0. 
	 * It defines the percentage of current camera.radius to use as delta when pinch zoom is used.
	 */
	@serialize()
	public var pinchDeltaPercentage:Float = 0;

	@serialize()
	public var panningSensibility:Float = 1000.0;

	@serialize()
	public var multiTouchPanning:Bool = true;

	@serialize()
	public var multiTouchPanAndZoom:Bool = true;

	private var _isPanClick:Bool = false;
	public var pinchInwards:Bool = true;

	private var _pointerInput:PointerInfo->EventState->Void;
	private var _observer:Observer<PointerInfo>;
	private var _onMouseMove:PointerEvent->Void;
	private var _onGestureStart:PointerEvent->Void;
	private var _onGesture:Dynamic;
	

	public function attachControl() {
		var engine = this.camera.getEngine();
		var cacheSoloPointer:Dynamic = null;// { x:Int, y:Int, pointerId:Int, type:Dynamic }; // cache pointer object for better perf on camera rotation
		var pointA:Dynamic = null; // { x:Int, y:Int, pointerId:Int, type:Dynamic };
		var pointB:Dynamic = null; // { x:Int, y:Int, pointerId:Int, type:Dynamic };
		var previousPinchDistance:Int = 0;
		var initialDistance = 0;
		var twoFingerActivityCount:Int = 0;
		var previousMultiTouchPanPosition:Dynamic = { x: 0, y: 0, isPaning: false, isPinching: false };
		
		this._pointerInput = function(p:PointerInfo, s:EventState) {
			var evt = p.event;
			var isTouch = p.event.pointerType == "touch";
			
			if (engine.isInVRExclusivePointerMode) {
				return;
			}
			
			if (p.type != PointerEventTypes.POINTERMOVE && this.buttons.indexOf(evt.button) == -1) {
				return;
			}
			
			if (p.type == PointerEventTypes.POINTERDOWN) {
				// Manage panning with pan button click
				this._isPanClick = evt.button == this.camera._panningMouseButton;
				
				// manage pointers
				cacheSoloPointer = { x: evt.x, y: evt.x, pointerId: evt.button, type: evt.pointerType };
				if (pointA == null) {
					pointA = cacheSoloPointer;
				}
				else if (pointB == null) {
					pointB = cacheSoloPointer;
				}
			}
			else if (p.type == PointerEventTypes.POINTERDOUBLETAP) {
				this.camera.restoreState();
			}
			else if (p.type == PointerEventTypes.POINTERUP) {
				cacheSoloPointer = null;
				previousPinchSquaredDistance = 0;
				previousMultiTouchPanPosition.isPaning = false;
				previousMultiTouchPanPosition.isPinching = false;
				twoFingerActivityCount = 0;
				initialDistance = 0;
				
				if (!isTouch) {
					pointB = null; // Mouse and pen are mono pointer
				}
				
				//would be better to use pointers.remove(evt.pointerId) for multitouch gestures, 
				//but emptying completly pointers collection is required to fix a bug on iPhone : 
				//when changing orientation while pinching camera, one pointer stay pressed forever if we don't release all pointers  
				//will be ok to put back pointers.remove(evt.pointerId); when iPhone bug corrected
				if (engine.badOS) {
					pointA = pointB = null;
				}
				else {
					//only remove the impacted pointer in case of multitouch allowing on most 
					//platforms switching from rotate to zoom and pan seamlessly.
					if (pointB != null && pointA != null && pointA.pointerId == evt.pointerId) {
						pointA = pointB;
						pointB = null;
						cacheSoloPointer = { x: pointA.x, y: pointA.y, pointerId: pointA.pointerId, type: evt.pointerType };
					}
					else if (pointA != null && pointB != null && pointB.pointerId == evt.pointerId) {
						pointB = null;
						cacheSoloPointer = { x: pointA.x, y: pointA.y, pointerId: pointA.pointerId, type: evt.pointerType };
					}
					else {
						pointA = pointB = null;
					}
				}
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
					
					cacheSoloPointer.x = evt.x;
					cacheSoloPointer.y = evt.y;
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
					var pinchDistance = Math.sqrt(pinchSquaredDistance);
					
					if (this.multiTouchPanAndZoom) {
						if (this.pinchDeltaPercentage != 0) {
							this.camera.inertialRadiusOffset += ((pinchSquaredDistance - previousPinchSquaredDistance) * 0.001) * this.camera.radius * this.pinchDeltaPercentage;
						} 
						else {
							this.camera.inertialRadiusOffset += (pinchSquaredDistance - previousPinchSquaredDistance) /
								(this.pinchPrecision * ((this.angularSensibilityX + this.angularSensibilityY) / 2) * direction);
						}
						
						if (this.panningSensibility != 0) {
							var pointersCenterX = (pointA.x + pointB.x) / 2;
							var pointersCenterY = (pointA.y + pointB.y) / 2;
							var pointersCenterDistX = pointersCenterX - previousMultiTouchPanPosition.x;
							var pointersCenterDistY = pointersCenterY - previousMultiTouchPanPosition.y;
							
							previousMultiTouchPanPosition.x = pointersCenterX;
							previousMultiTouchPanPosition.y = pointersCenterY;
							
							this.camera.inertialPanningX += -(pointersCenterDistX) / (this.panningSensibility);
							this.camera.inertialPanningY += (pointersCenterDistY) / (this.panningSensibility);
						}
					}
					else {
						twoFingerActivityCount++;
						
						if (previousMultiTouchPanPosition.isPinching || (twoFingerActivityCount < 20 && Math.abs(pinchDistance - initialDistance) > this.camera.pinchToPanMaxDistance)) {
							if (this.pinchDeltaPercentage != 0) {
								this.camera.inertialRadiusOffset += ((pinchSquaredDistance - previousPinchSquaredDistance) * 0.001) * this.camera.radius * this.pinchDeltaPercentage;
							} 
							else {
								this.camera.inertialRadiusOffset += (pinchSquaredDistance - previousPinchSquaredDistance) /
									(this.pinchPrecision * ((this.angularSensibilityX + this.angularSensibilityY) / 2) * direction);
							}
							previousMultiTouchPanPosition.isPaning = false;
							previousMultiTouchPanPosition.isPinching = true;
						}
						else {
							if (cacheSoloPointer != null && cacheSoloPointer.pointerId == ed.pointerId && this.panningSensibility != 0 && this.multiTouchPanning) {
								if (!previousMultiTouchPanPosition.isPaning) {
									previousMultiTouchPanPosition.isPaning = true;
									previousMultiTouchPanPosition.isPinching = false;
									previousMultiTouchPanPosition.x = ed.x;
									previousMultiTouchPanPosition.y = ed.y;
									return;
								}
								
								this.camera.inertialPanningX += -(ed.x - previousMultiTouchPanPosition.x) / (this.panningSensibility);
								this.camera.inertialPanningY += (ed.y - previousMultiTouchPanPosition.y) / (this.panningSensibility);
							}
						}
						
						if (cacheSoloPointer != null && cacheSoloPointer.pointerId == evt.pointerId) {
							previousMultiTouchPanPosition.x = ed.x;
							previousMultiTouchPanPosition.y = ed.y;
						}
					}
					
					previousPinchSquaredDistance = pinchSquaredDistance;
				}
			}
		}
		
		this._observer = this.camera.getScene().onPointerObservable.add(this._pointerInput, PointerEventTypes.POINTERDOWN | PointerEventTypes.POINTERUP | PointerEventTypes.POINTERMOVE);
		
		this._onMouseMove = function(evt:PointerEvent) {
			if (!engine.isPointerLock) {
				return;
			}
			
			var offsetX = evt.x;
			var offsetY = evt.y;
			
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
