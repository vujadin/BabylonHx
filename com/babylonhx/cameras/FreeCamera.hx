package com.babylonhx.cameras;

import com.babylonhx.collisions.Collider;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.Lib;

/**
* ...
* @author Krtolica Vujadin
*/

class FreeCamera extends TargetCamera {
	
	public var ellipsoid:Vector3 = new Vector3(0.5, 1, 0.5);
	public var keysUp:Array<Int> = [38];
	public var keysDown:Array<Int> = [40];
	public var keysLeft:Array<Int> = [37];
	public var keysRight:Array<Int> = [39];
	public var checkCollisions:Bool = false;
	public var applyGravity:Bool = false;
	public var angularSensibility:Float = 2000.0;
	public var onCollide:AbstractMesh->Void;

	private var _keys:Array<Int> = [];
	private var _collider:Collider = new Collider();
	private var _needMoveForGravity:Bool = true;
	private var _oldPosition:Vector3 = Vector3.Zero();
	private var _diffPosition:Vector3 = Vector3.Zero();
	private var _newPosition:Vector3 = Vector3.Zero();
	private var _attachedElement:Dynamic;
	private var _localDirection:Vector3;
	private var _transformedDirection:Vector3;

	private var _onMouseDown:Dynamic->Void;			// MouseEvent->Dynamic
	private var _onMouseUp:Dynamic->Void;			// MouseEvent->Dynamic
	private var _onMouseOut:Dynamic->Void;			// MouseEvent->Dynamic
	private var _onMouseMove:Dynamic->Void;			// MouseEvent->Dynamic
	private var _onKeyDown:Dynamic->Void;			// MouseEvent->Dynamic
	private var _onKeyUp:Dynamic->Void;				// MouseEvent->Dynamic
	public var _onLostFocus:Void->Void;				// MouseEvent->Dynamic

	//public var _waitingLockedTargetId:String;
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, position, scene);
	}

	// Controls
	override public function attachControl(element:Dynamic, noPreventDefault:Bool = false/*?noPreventDefault:Bool*/):Void {
		var previousPosition:Dynamic = null;// { x: 0, y: 0 };
		var engine = this.getEngine();

		if (this._attachedElement != null) {
			return;
		}
		this._attachedElement = element;

		if (this._onMouseDown == null) {
			this._onMouseDown = function(evt:Dynamic) {
				previousPosition = {
					x: evt.localX,
					y: evt.localY
				};

				#if js
				if (noPreventDefault == null) {
					//evt.preventDefault();
				}
				#end
			};

			this._onMouseUp = function(evt:Dynamic) {
				previousPosition = null;
				#if js
				if (noPreventDefault == null) {
					//evt.preventDefault();
				}
				#end
			};

			this._onMouseOut = function(evt:Dynamic) {
				previousPosition = null;
				this._keys = [];
				#if js
				if (noPreventDefault == null) {
					//evt.preventDefault();
				}
				#end
			};

			this._onMouseMove = function(evt:Dynamic) {
				if (previousPosition == null && !engine.isPointerLock) {
					return;
				}

				var offsetX:Float = 0;
				var offsetY:Float = 0;

				if (!engine.isPointerLock) {
					offsetX = evt.localX - previousPosition.x;
					offsetY = evt.localY - previousPosition.y;
				} else {
					#if js
					untyped offsetX = evt.movementX || evt.mozMovementX || evt.webkitMovementX || evt.msMovementX || 0;
					untyped offsetY = evt.movementY || evt.mozMovementY || evt.webkitMovementY || evt.msMovementY || 0;
					#end
				}

				this.cameraRotation.y += offsetX / this.angularSensibility;
				this.cameraRotation.x += offsetY / this.angularSensibility;

				previousPosition = {
					x: evt.localX,
					y: evt.localY
				};
				
				#if js
				if (noPreventDefault == null) {
					//evt.preventDefault();
				}
				#end
			};

			this._onKeyDown = function(evt:Dynamic ) {
				if (this.keysUp.indexOf(evt.keyCode) != -1 ||
					this.keysDown.indexOf(evt.keyCode) != -1 ||
					this.keysLeft.indexOf(evt.keyCode) != -1 ||
					this.keysRight.indexOf(evt.keyCode) != -1) {
					var index = this._keys.indexOf(evt.keyCode);

					if (index == -1) {
						this._keys.push(evt.keyCode);
					}
					#if js
					if (noPreventDefault == null) {
						//evt.preventDefault();
					}
					#end
				}
			};

			this._onKeyUp = function(evt:Dynamic) {
				if (this.keysUp.indexOf(evt.keyCode) != -1 ||
					this.keysDown.indexOf(evt.keyCode) != -1 ||
					this.keysLeft.indexOf(evt.keyCode) != -1 ||
					this.keysRight.indexOf(evt.keyCode) != -1) {
					var index = this._keys.indexOf(evt.keyCode);

					if (index >= 0) {
						this._keys.splice(index, 1);
					}
					#if js
					if (noPreventDefault == null) {
						//evt.preventDefault();
					}
					#end
				}
			};

			this._onLostFocus = function() {
				this._keys = [];
			};

			this._reset = function() {
				this._keys = [];
				previousPosition = null;
				this.cameraDirection = new Vector3(0, 0, 0);
				this.cameraRotation = new Vector2(0, 0);
			};
		}

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, this._onMouseDown, false);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, this._onMouseUp, false);
		//Lib.current.stage.addEventListener(MouseEvent.MOUSE_OUT, this._onMouseOut, false);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, this._onMouseMove, false);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, this._onKeyDown, false);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, this._onKeyUp, false);

		/*Tools.RegisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);*/
	}

	override public function detachControl(element:Dynamic):Void {
		if (this._attachedElement != element) {
			return;
		}

		element.removeEventListener(MouseEvent.MOUSE_DOWN, this._onMouseDown);
		element.removeEventListener(MouseEvent.MOUSE_UP, this._onMouseUp);
		element.removeEventListener(MouseEvent.MOUSE_OUT, this._onMouseOut);
		element.removeEventListener(MouseEvent.MOUSE_MOVE, this._onMouseMove);
		
		element.removeEventListener(KeyboardEvent.KEY_DOWN, this._onKeyDown, false);
		element.removeEventListener(KeyboardEvent.KEY_UP, this._onKeyUp, false);

		/*Tools.UnregisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);*/

		this._attachedElement = null;
		if (this._reset != null) {
			this._reset();
		}
	}

	public function _collideWithWorld(velocity:Vector3):Void {
		var globalPosition:Vector3 = null;

		if (this.parent != null) {
			globalPosition = Vector3.TransformCoordinates(this.position, this.parent.getWorldMatrix());
		} else {
			globalPosition = this.position;
		}

		globalPosition.subtractFromFloatsToRef(0, this.ellipsoid.y, 0, this._oldPosition);
		this._collider.radius = this.ellipsoid;

		this.getScene()._getNewPosition(this._oldPosition, velocity, this._collider, 3, this._newPosition);
		this._newPosition.subtractToRef(this._oldPosition, this._diffPosition);

		if (this._diffPosition.length() > Engine.CollisionsEpsilon) {
			this.position.addInPlace(this._diffPosition);
			if (this.onCollide != null) {
				this.onCollide(this._collider.collidedMesh);
			}
		}
	}

	public function _checkInputs():Void {
		if (this._localDirection == null) {
			this._localDirection = Vector3.Zero();
			this._transformedDirection = Vector3.Zero();
		}

		// Keyboard
		for (index in 0...this._keys.length) {
			var keyCode = this._keys[index];
			var speed = this._computeLocalCameraSpeed();

			if (this.keysLeft.indexOf(keyCode) != -1) {
				this._localDirection.copyFromFloats(-speed, 0, 0);
			} else if (this.keysUp.indexOf(keyCode) != -1) {
				this._localDirection.copyFromFloats(0, 0, speed);
			} else if (this.keysRight.indexOf(keyCode) != -1) {
				this._localDirection.copyFromFloats(speed, 0, 0);
			} else if (this.keysDown.indexOf(keyCode) != -1) {
				this._localDirection.copyFromFloats(0, 0, -speed);
			}

			this.getViewMatrix().invertToRef(this._cameraTransformMatrix);
			Vector3.TransformNormalToRef(this._localDirection, this._cameraTransformMatrix, this._transformedDirection);
			this.cameraDirection.addInPlace(this._transformedDirection);
		}
	}

	override public function _decideIfNeedsToMove():Bool {
		return this._needMoveForGravity || Math.abs(this.cameraDirection.x) > 0 || Math.abs(this.cameraDirection.y) > 0 || Math.abs(this.cameraDirection.z) > 0;
	}

	override public function _updatePosition():Void {
		if (this.checkCollisions && this.getScene().collisionsEnabled) {
			this._collideWithWorld(this.cameraDirection);
			if (this.applyGravity) {
				var oldPosition = this.position;
				this._collideWithWorld(this.getScene().gravity);
				this._needMoveForGravity = (Vector3.DistanceSquared(oldPosition, this.position) != 0);
			}
		} else {
			this.position.addInPlace(this.cameraDirection);
		}
	}

	override public function _update():Void {
		this._checkInputs();
		super._update();
	}

}
