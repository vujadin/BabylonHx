package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.TouchCamera') class TouchCamera extends FreeCamera {

	private var _offsetX:Float = Math.NEGATIVE_INFINITY;
	private var _offsetY:Float = Math.NEGATIVE_INFINITY;
	private var _pointerCount:Int = 0;
	private var _pointerPressed:Array<Int> = [];
	private var _onPointerDown:Dynamic;
	private var _onPointerUp:Dynamic;
	private var _onPointerMove:Dynamic;
	
	public var moveSensibility:Float = 500.0;

	
	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, position, scene);
		this.angularSensibility = 200000.0;
	}

	override public function attachControl(useCtrlForPanning:Bool = true, enableKeyboard:Bool = true) {
		var previousPosition:Dynamic = null;// { x: 0, y: 0 };
		
		if (this._onPointerDown == null) {
			this._onPointerDown = function(x:Float, y:Float, touch_id:Int, timestamp:Float) {
				this._pointerPressed.push(touch_id);
				
				if (this._pointerPressed.length != 1) {
					return;
				}
				
				previousPosition = {
					x: x,
					y: y
				};
			};
			
			this._onPointerUp = function(x:Float, y:Float, touch_id:Int, timestamp:Float) {
				var index:Int = this._pointerPressed.indexOf(touch_id);
				
				if (index == -1) {
					return;
				}
				this._pointerPressed.splice(index, 1);
				
				if (index != 0) {
					return;
				}
				
				previousPosition = null;
				this._offsetX = Math.NEGATIVE_INFINITY;
				this._offsetY = Math.NEGATIVE_INFINITY;
			};
			
			this._onPointerMove = function(x:Float, y:Float, dx:Float, dy:Float, touch_id:Int, timestamp:Float) {
				if (previousPosition == null) {
					return;
				}
				
				var index:Int = this._pointerPressed.indexOf(touch_id);
				
				if (index != 0) {
					return;
				}
				
				this._offsetX = x - previousPosition.x;
				this._offsetY = -(y - previousPosition.y);
			};
			
			this._onLostFocus = function() {
				this._offsetX = Math.NEGATIVE_INFINITY;
				this._offsetY = Math.NEGATIVE_INFINITY;
			};
		}

		this.getScene().getEngine().touchDown.push(this._onPointerDown);
		this.getScene().getEngine().touchUp.push(this._onPointerUp);
		this.getScene().getEngine().touchMove.push(this._onPointerMove);
	}

	override public function detachControl() {
		this.getScene().getEngine().touchDown.remove(this._onPointerDown);
		this.getScene().getEngine().touchUp.remove(this._onPointerUp);
		this.getScene().getEngine().touchMove.remove(this._onPointerMove);
	}

	override public function _checkInputs() {
		if (this._offsetX != Math.NEGATIVE_INFINITY) {
			this.cameraRotation.y += this._offsetX / this.angularSensibility;
			
			if (this._pointerPressed.length > 1) {
				this.cameraRotation.x += -this._offsetY / this.angularSensibility;
			} 
			else {
				var speed = this._computeLocalCameraSpeed();
				var direction = new Vector3(0, 0, speed * this._offsetY / this.moveSensibility);
				
				Matrix.RotationYawPitchRollToRef(this.rotation.y, this.rotation.x, 0, this._cameraRotationMatrix);
				this.cameraDirection.addInPlace(Vector3.TransformCoordinates(direction, this._cameraRotationMatrix));
			}
		}
		
		super._checkInputs();
	}
	
}
