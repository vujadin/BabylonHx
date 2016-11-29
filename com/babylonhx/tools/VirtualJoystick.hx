package com.babylonhx.tools;

import com.babylonhx.PointerInfo.PointerEvent;
import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.display.Graphics;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.d2.events.TouchEvent;

/**
 * ...
 * @author Krtolica Vujadin
 */
enum JoystickAxis {
	X;
	Y;
	Z;
}

class VirtualJoystick {

	public var reverseLeftRight:Bool;
	public var reverseUpDown:Bool;
	public var deltaPosition:Vector3;
	public var pressed:Bool;

	// Used to draw the virtual joystick
	private static var _globalJoystickIndex:Int = 0;
	private static var vjCanvas:Sprite;
	private static var vjCanvasContext:Graphics;
	private static var vjCanvasWidth:Int;
	private static var vjCanvasHeight:Int;
	private static var halfWidth:Int;
	private static var halfHeight:Int;

	private var _action:Void->Void;
	private var _axisTargetedByLeftAndRight:JoystickAxis;
	private var _axisTargetedByUpAndDown:JoystickAxis;
	private var _joystickSensibility:Float;
	private var _inversedSensibility:Float;
	private var _rotationSpeed:Float;
	private var _inverseRotationSpeed:Float;
	private var _rotateOnAxisRelativeToMesh:Bool;
	private var _joystickPointerID:Int;
	private var _joystickColor:Int;
	private var _joystickPointerPos:Vector2;
	private var _joystickPreviousPointerPos:Vector2;
	private var _joystickPointerStartPos:Vector2;
	private var _deltaJoystickVector:Vector2;
	private var _leftJoystick:Bool;
	private var _joystickIndex:Int;
	private var _touches:Map<Int, JTouch>;

	private var _onPointerDownHandlerRef:Int->Int->Int->Void;
	private var _onPointerMoveHandlerRef:Int->Int->Int->Void;
	private var _onPointerUpHandlerRef:Int->Int->Int->Void;
	private var _onPointerOutHandlerRef:Int->Int->Int->Void;
	private var _onResize:Void->Void;
	
	private var _stage:Stage;
	private var _engine:Engine;
	

	public function new(scene:Scene, leftJoystick:Bool = false) {
		if (leftJoystick) {
			this._leftJoystick = true;
		}
		else {
			this._leftJoystick = false;
		}
		
		this._engine = scene.getEngine();
		
		this._joystickIndex = VirtualJoystick._globalJoystickIndex;
		VirtualJoystick._globalJoystickIndex++;
		
		// By default left & right arrow keys are moving the X
		// and up & down keys are moving the Y
		this._axisTargetedByLeftAndRight = JoystickAxis.X;
		this._axisTargetedByUpAndDown = JoystickAxis.Y;
		
		this.reverseLeftRight = false;
		this.reverseUpDown = false;
		
		// collections of pointers
		this._touches = new Map();
		this.deltaPosition = Vector3.Zero();
		
		this._joystickSensibility = 25;
		this._inversedSensibility = 1 / (this._joystickSensibility / 1000);
		this._rotationSpeed = 25;
		this._inverseRotationSpeed = 1 / (this._rotationSpeed / 1000);
		this._rotateOnAxisRelativeToMesh = false;
		
		this._onResize = function() {
			VirtualJoystick.vjCanvasWidth = _engine.width;
			VirtualJoystick.vjCanvasHeight = _engine.height;
			/*VirtualJoystick.vjCanvas.width = VirtualJoystick.vjCanvasWidth;
			VirtualJoystick.vjCanvas.height = VirtualJoystick.vjCanvasHeight;*/
			VirtualJoystick.halfWidth = Std.int(VirtualJoystick.vjCanvasWidth / 2);
			VirtualJoystick.halfHeight = Std.int(VirtualJoystick.vjCanvasHeight / 2);
		};
		
		// injecting a canvas element on top of the canvas 3D game
		if (VirtualJoystick.vjCanvas == null) {
			_engine.onResize.push(this._onResize);
			VirtualJoystick.vjCanvas = new Sprite();
			VirtualJoystick.vjCanvasWidth = _engine.width;
			VirtualJoystick.vjCanvasHeight = _engine.height;
			/*VirtualJoystick.vjCanvas.width = _engine.width;
			VirtualJoystick.vjCanvas.height = _engine.height;*/
			// Support for jQuery PEP polyfill
			VirtualJoystick.vjCanvasContext = VirtualJoystick.vjCanvas.graphics;
			VirtualJoystick.vjCanvasContext.lineStyle(2, 0xffffff);			
			
			_stage = scene.init2D();
			if (_stage != null) {
				_stage.addChild(VirtualJoystick.vjCanvas);
			}
		}
		VirtualJoystick.halfWidth = Std.int(VirtualJoystick.vjCanvasWidth / 2);
		VirtualJoystick.halfHeight = Std.int(VirtualJoystick.vjCanvasHeight / 2);
		this.pressed = false;
		// default joystick color
		this._joystickColor = 0x00FFFF;
		
		this._joystickPointerID = -1;
		// current joystick position
		this._joystickPointerPos = new Vector2(0, 0);
		this._joystickPreviousPointerPos = new Vector2(0, 0);
		// origin joystick position
		this._joystickPointerStartPos = new Vector2(0, 0);
		this._deltaJoystickVector = new Vector2(0, 0);
		
		this._onPointerDownHandlerRef = function(x:Int, y:Int, tID:Int) {
			this._onPointerDown(x, y, tID);
		};
		this._onPointerMoveHandlerRef = function(x:Int, y:Int, tID:Int) {
			this._onPointerMove(x, y, tID);
		};
		this._onPointerOutHandlerRef = function(x:Int, y:Int, tID:Int) {
			this._onPointerUp(x, y, tID);
		};
		this._onPointerUpHandlerRef = function(x:Int, y:Int, tID:Int) {
			this._onPointerUp(x, y, tID);
		};
		
		//#if mobile
		_engine.mouseDown.push(this._onPointerDownHandlerRef);
		_engine.mouseMove.push(this._onPointerMoveHandlerRef);
		_engine.mouseUp.push(this._onPointerUpHandlerRef);
		/*#else
		_stage.addEventListener(MouseEvent.MOUSE_DOWN, this._onPointerDownHandlerRef);
		_stage.addEventListener(MouseEvent.MOUSE_MOVE, this._onPointerMoveHandlerRef);
		_stage.addEventListener(MouseEvent.MOUSE_UP, this._onPointerUpHandlerRef);
		#end*/
		//_stage.addEventListener(TouchEvent.TOUCH_OVER, this._onPointerUpHandlerRef);
		
		_stage.addEventListener(Event.ENTER_FRAME, this._drawVirtualJoystick);
	}

	public function setJoystickSensibility(newJoystickSensibility:Float) {
		this._joystickSensibility = newJoystickSensibility;
		this._inversedSensibility = 1 / (this._joystickSensibility / 1000);
	}

	private function _onPointerDown(x:Int, y:Int, pointerId:Int) {
		var positionOnScreenCondition:Bool;
		trace(pointerId);
		if (this._leftJoystick == true) {
			positionOnScreenCondition = (_stage._mouseX < VirtualJoystick.halfWidth);
		}
		else {
			positionOnScreenCondition = (_stage._mouseX > VirtualJoystick.halfWidth);
		}
		
		if (positionOnScreenCondition && this._joystickPointerID < 0) {
			// First contact will be dedicated to the virtual joystick
			this._joystickPointerID = pointerId;
			this._joystickPointerStartPos.x = x;
			this._joystickPointerStartPos.y = y;
			this._joystickPointerPos = this._joystickPointerStartPos.clone();
			this._joystickPreviousPointerPos = this._joystickPointerStartPos.clone();
			this._deltaJoystickVector.x = 0;
			this._deltaJoystickVector.y = 0;
			this.pressed = true;
			this._touches.set(pointerId, new JTouch(x, y, x, y));
		}
		else {
			// You can only trigger the action buttons with a joystick declared
			if (VirtualJoystick._globalJoystickIndex < 2 && this._action != null) {
				this._action();
				this._touches.set(pointerId, new JTouch(x, y, x, y));
			}
		}
	}

	private function _onPointerMove(x:Int, y:Int, tID:Int) {
		// If the current pointer is the one associated to the joystick (first touch contact)
		if (this._joystickPointerID == tID) {
			this._joystickPointerPos.x = x;
			this._joystickPointerPos.y = y;
			this._deltaJoystickVector = this._joystickPointerPos.clone();
			this._deltaJoystickVector = this._deltaJoystickVector.subtract(this._joystickPointerStartPos);
			
			var directionLeftRight = this.reverseLeftRight ? -1 : 1;
			var deltaJoystickX = directionLeftRight * this._deltaJoystickVector.x / this._inversedSensibility;
			switch (this._axisTargetedByLeftAndRight) {
				case JoystickAxis.X:
					this.deltaPosition.x = Math.min(1, Math.max(-1, deltaJoystickX));
					
				case JoystickAxis.Y:
					this.deltaPosition.y = Math.min(1, Math.max(-1, deltaJoystickX));
					
				case JoystickAxis.Z:
					this.deltaPosition.z = Math.min(1, Math.max(-1, deltaJoystickX));
					
			}
			var directionUpDown = this.reverseUpDown ? 1 : -1;
			var deltaJoystickY = directionUpDown * this._deltaJoystickVector.y / this._inversedSensibility;
			switch (this._axisTargetedByUpAndDown) {
				case JoystickAxis.X:
					this.deltaPosition.x = Math.min(1, Math.max(-1, deltaJoystickY));
					
				case JoystickAxis.Y:
					this.deltaPosition.y = Math.min(1, Math.max(-1, deltaJoystickY));
					
				case JoystickAxis.Z:
					this.deltaPosition.z = Math.min(1, Math.max(-1, deltaJoystickY));
					
			}
		}
		else {
			var data = this._touches.get(tID);
			if (data != null) {
				data.x = x;
				data.y = y;                     
			}
		}
	}

	private function _onPointerUp(x:Int, y:Int, tID:Int) {
		if (this._joystickPointerID == tID) {
			VirtualJoystick.vjCanvasContext.clear();
			this._joystickPointerID = -1;
			this.pressed = false;
		}
		else {
			var touch = this._touches.get(tID);
			if (touch != null) {
				VirtualJoystick.vjCanvasContext.clear();
			}
		}
		this._deltaJoystickVector.x = 0;
		this._deltaJoystickVector.y = 0;

		this._touches.remove(tID);
	}

	/**
	* Change the color of the virtual joystick
	*/
	public function setJoystickColor(newColor:Int) {
		this._joystickColor = newColor;
	}

	public function setActionOnTouch(action:Void->Void) {
		this._action = action;
	}

	// Define which axis you'd like to control for left & right 
	public function setAxisForLeftRight(axis:JoystickAxis) {
		switch (axis) {
			case JoystickAxis.X, JoystickAxis.Y, JoystickAxis.Z:
				this._axisTargetedByLeftAndRight = axis;
				
			default:
				this._axisTargetedByLeftAndRight = JoystickAxis.X;
				
		}
	}

	// Define which axis you'd like to control for up & down 
	public function setAxisForUpDown(axis:JoystickAxis) {
		switch (axis) {
			case JoystickAxis.X, JoystickAxis.Y, JoystickAxis.Z:
				this._axisTargetedByUpAndDown = axis;
				
			default:
				this._axisTargetedByUpAndDown = JoystickAxis.Y;
				
		}
	}

	private function _drawVirtualJoystick() {
		if (this.pressed) {
			for (key in this._touches.keys()) {
				var touch = this._touches[key];
				if (touch.pointerId == this._joystickPointerID) {
					VirtualJoystick.vjCanvasContext.clear();
					VirtualJoystick.vjCanvasContext.lineStyle(6, this._joystickColor);
					VirtualJoystick.vjCanvasContext.drawCircle(this._joystickPointerStartPos.x, this._joystickPointerStartPos.y, 40);
					VirtualJoystick.vjCanvasContext.drawCircle(this._joystickPointerStartPos.x, this._joystickPointerStartPos.y, 60);
					VirtualJoystick.vjCanvasContext.drawCircle(this._joystickPointerPos.x, this._joystickPointerPos.y, 40);
					this._joystickPreviousPointerPos = this._joystickPointerPos.clone();
				}
				else {
					VirtualJoystick.vjCanvasContext.clear();
					VirtualJoystick.vjCanvasContext.beginFill(0xffffff);
					VirtualJoystick.vjCanvasContext.lineStyle(6, 0xff0000);
					VirtualJoystick.vjCanvasContext.drawCircle(touch.x, touch.y, 40);
					VirtualJoystick.vjCanvasContext.endFill();
					touch.prevX = touch.x;
					touch.prevY = touch.y;
				}
			}
		}
	}

	public function releaseCanvas() {
		if (VirtualJoystick.vjCanvas != null) {
			//#if mobile
			_engine.mouseDown.remove(this._onPointerDownHandlerRef);
			_engine.mouseMove.remove(this._onPointerMoveHandlerRef);
			_engine.mouseUp.remove(this._onPointerUpHandlerRef);
			/*#else
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, this._onPointerDownHandlerRef);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, this._onPointerMoveHandlerRef);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, this._onPointerUpHandlerRef);
			#end*/
			_stage.addEventListener(Event.ENTER_FRAME, this._drawVirtualJoystick);
			_stage.removeChild(VirtualJoystick.vjCanvas);
			VirtualJoystick.vjCanvas = null;
		}
	}
	
}

class JTouch {
	
	public var x:Int;
	public var y:Int;
	public var prevX:Int;
	public var prevY:Int;
	public var pointerId:Int;
	
	
	public function new(x:Int = 0, y:Int = 0, prevX:Int = 0, prevY:Int = 0, pointerId = 0) {
		this.x = x;
		this.y = y;
		this.prevX = prevX;
		this.prevY = prevY;
		this.pointerId = pointerId;
	}
	
}
