package com.babylonhx.cameras;

import com.babylonhx.collisions.Collider;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.tools.Tools;

import com.babylonhx.utils.Keycodes;


/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.FreeCamera') class FreeCamera extends TargetCamera {
	
	public var ellipsoid:Vector3 = new Vector3(0.5, 1, 0.5);
	
#if purejs

	public var keysUp:Array<Int> = [38, 87];
	public var keysDown:Array<Int> = [40, 83];
	public var keysLeft:Array<Int> = [37, 65];
	public var keysRight:Array<Int> = [39, 68];
	
#else

	public var keysUp:Array<Int> = [Keycodes.up, Keycodes.key_w];
	public var keysDown:Array<Int> = [Keycodes.down, Keycodes.key_s];
	public var keysLeft:Array<Int> = [Keycodes.left, Keycodes.key_a];
	public var keysRight:Array<Int> = [Keycodes.right, Keycodes.key_d];
	
#end
	
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

	private var _onMouseDown:Dynamic;			
	private var _onMouseUp:Dynamic;			
	private var _onMouseOut:Dynamic;			
	private var _onMouseMove:Dynamic;			
	private var _onKeyDown:Dynamic;			
	private var _onKeyUp:Dynamic;				
	public var _onLostFocus:Void->Void;				
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, position, scene);
	}

	// Controls
	override public function attachControl(?element:Dynamic, noPreventDefault:Bool = false, useCtrlForPanning:Bool = true, enableKeyboard:Bool = true) {
		var previousPosition:Dynamic = null;// { x: 0, y: 0 };
		var engine = this.getEngine();
		
		this._attachedElement = element;
		
		if (this._onMouseDown == null) {
			this._onMouseDown = function(x:Float, y:Float, button:Int) {
				previousPosition = {
					x: x,
					y: y
				};
			};
			
			this._onMouseUp = function(x:Float, y:Float, button:Int) {
				previousPosition = null;				
			};
			
			this._onMouseOut = function() {
				previousPosition = null;
				this._keys = [];				
			};
			
			this._onMouseMove = function(x:Float, y:Float) {
				if (previousPosition == null && !engine.isPointerLock) {
					return;
				}
				
				var offsetX:Float = 0;
				var offsetY:Float = 0;
				
				if (!engine.isPointerLock) {
					offsetX = x - previousPosition.x;
					offsetY = y - previousPosition.y;
				} 
				
				this.cameraRotation.y += offsetX / this.angularSensibility;
				this.cameraRotation.x += offsetY / this.angularSensibility;
				
				previousPosition = {
					x: x,
					y: y
				};				
			};
			
			if (enableKeyboard) {
				
			#if purejs
				
				this._onKeyDown = function(evt:Dynamic) {
					var keyCode = evt.keyCode;
					if (this.keysUp.indexOf(keyCode) != -1 ||
						this.keysDown.indexOf(keyCode) != -1 ||
						this.keysLeft.indexOf(keyCode) != -1 ||
						this.keysRight.indexOf(keyCode) != -1) {
						var index = this._keys.indexOf(keyCode);
						
						if (index == -1) {
							this._keys.push(keyCode);
						}
					}
				};
				
				this._onKeyUp = function(evt:Dynamic) {
					var keyCode = evt.keyCode;
					if (this.keysUp.indexOf(keyCode) != -1 ||
						this.keysDown.indexOf(keyCode) != -1 ||
						this.keysLeft.indexOf(keyCode) != -1 ||
						this.keysRight.indexOf(keyCode) != -1) {
						var index = this._keys.indexOf(keyCode);
						
						if (index >= 0) {
							this._keys.splice(index, 1);
						}
					}
				};
				
			#else
				
				this._onKeyDown = function(keyCode:Int) {
					if (this.keysUp.indexOf(keyCode) != -1 ||
						this.keysDown.indexOf(keyCode) != -1 ||
						this.keysLeft.indexOf(keyCode) != -1 ||
						this.keysRight.indexOf(keyCode) != -1) {
						var index = this._keys.indexOf(keyCode);
						
						if (index == -1) {
							this._keys.push(keyCode);
						}
					}
				};
				
				this._onKeyUp = function(keyCode:Int) {
					if (this.keysUp.indexOf(keyCode) != -1 ||
						this.keysDown.indexOf(keyCode) != -1 ||
						this.keysLeft.indexOf(keyCode) != -1 ||
						this.keysRight.indexOf(keyCode) != -1) {
						var index = this._keys.indexOf(keyCode);
						
						if (index >= 0) {
							this._keys.splice(index, 1);
						}
					}
				};
				
			#end
			
			}
			
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
		
	#if purejs
		
		this.getScene().getEngine().getRenderingCanvas().addEventListener(eventPrefix + "down", function(e) {
			this._onMouseDown(e.clientX, e.clientY, e.button);
		}, false);
		this.getScene().getEngine().getRenderingCanvas().addEventListener(eventPrefix + "up", function(e) {
			this._onMouseUp(e.clientX, e.clientY, e.button);
		}, false);
		//Engine.app.addEventListener(eventPrefix + "out", this._onMouseUp, false);
		this.getScene().getEngine().getRenderingCanvas().addEventListener(eventPrefix + "move", function(e) {
			this._onMouseMove(e.clientX, e.clientY);
		}, false);
		this.getScene().getEngine().getRenderingCanvas().addEventListener("mousemove", function(e) {
			this._onMouseMove(e.clientX, e.clientY);
		}, false);
		/*Engine.app.addEventListener("MSPointerDown", this._onGestureStart, false);
		Engine.app.addEventListener("MSGestureChange", this._onGesture, false);*/
				
		Tools.RegisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);
		
	#else
	
		Engine.keyDown.push(_onKeyDown);
		Engine.keyUp.push(_onKeyUp);
		Engine.mouseDown.push(_onMouseDown);
		Engine.mouseUp.push(_onMouseUp);
		Engine.mouseMove.push(_onMouseMove);
		
	#end
	}

	override public function detachControl(?element:Dynamic) {	
	#if purejs
	
		this.getScene().getEngine().getRenderingCanvas().removeEventListener(eventPrefix + "down", this._onMouseDown, false);
		this.getScene().getEngine().getRenderingCanvas().removeEventListener(eventPrefix + "up", this._onMouseUp, false);
		this.getScene().getEngine().getRenderingCanvas().removeEventListener(eventPrefix + "out", this._onMouseUp, false);
		this.getScene().getEngine().getRenderingCanvas().removeEventListener(eventPrefix + "move", this._onMouseMove, false);
		this.getScene().getEngine().getRenderingCanvas().removeEventListener("mousemove", this._onMouseMove, false);
		/*Engine.app.addEventListener("MSPointerDown", this._onGestureStart, false);
		Engine.app.addEventListener("MSGestureChange", this._onGesture, false);*/
				
		Tools.UnregisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);
		
	#else
	
		Engine.keyDown.remove(_onKeyDown);
		Engine.keyUp.remove(_onKeyUp);
		Engine.mouseDown.remove(_onMouseDown);
		Engine.mouseUp.remove(_onMouseUp);
		Engine.mouseMove.remove(_onMouseMove);
		
	#end
		
		if (this._reset != null) {
			this._reset();
		}
	}

	public function _collideWithWorld(velocity:Vector3) {
		var globalPosition:Vector3 = null;
		
		if (this.parent != null) {
			globalPosition = Vector3.TransformCoordinates(this.position, this.parent.getWorldMatrix());
		} 
		else {
			globalPosition = this.position;
		}
		
		globalPosition.subtractFromFloatsToRef(0, this.ellipsoid.y, 0, this._oldPosition);
		this._collider.radius = this.ellipsoid;
		
		//no need for clone, as long as gravity is not on.
		var actualVelocity = velocity;
		
		//add gravity to the velocity to prevent the dual-collision checking
		if (this.applyGravity) {
			//this prevents mending with cameraDirection, a global variable of the free camera class.
			actualVelocity = velocity.add(this.getScene().gravity);
		}
		
		this.getScene().collisionCoordinator.getNewPosition(this._oldPosition, actualVelocity, this._collider, 3, null, this._onCollisionPositionChange, this.uniqueId);		
	}
	
	private function _onCollisionPositionChange(collisionId:Int, newPosition:Vector3, collidedMesh:AbstractMesh = null) {
		//TODO move this to the collision coordinator!
		if (this.getScene().workerCollisions) {
			newPosition.multiplyInPlace(this._collider.radius);
		}
		
		var updatePosition = function(newPos:Vector3) {
			this._newPosition.copyFrom(newPos);
			
			this._newPosition.subtractToRef(this._oldPosition, this._diffPosition);
			
			var oldPosition = this.position.clone();
			if (this._diffPosition.length() > Engine.CollisionsEpsilon) {
				this.position.addInPlace(this._diffPosition);
				if (this.onCollide != null && collidedMesh != null) {
					this.onCollide(collidedMesh);
				}
			}
		}
		
		updatePosition(newPosition);
	}

	override public function _checkInputs() {		
		if (this._localDirection == null) {
			this._localDirection = Vector3.Zero();
			this._transformedDirection = Vector3.Zero();
		}
		
		// Keyboard
		for (index in 0...this._keys.length) {
			var keyCode = this._keys[index];
			var speed = this._computeLocalCameraSpeed();
			
			if (this.keysLeft.indexOf(keyCode) != -1) {
				this._localDirection.copyFromFloats( -speed, 0, 0);
			} 
			else if (this.keysUp.indexOf(keyCode) != -1) {
				this._localDirection.copyFromFloats(0, 0, speed);
			} 
			else if (this.keysRight.indexOf(keyCode) != -1) {
				this._localDirection.copyFromFloats(speed, 0, 0);
			} 
			else if (this.keysDown.indexOf(keyCode) != -1) {
				this._localDirection.copyFromFloats(0, 0, -speed);
			}
			
			this.getViewMatrix().invertToRef(this._cameraTransformMatrix);
			Vector3.TransformNormalToRef(this._localDirection, this._cameraTransformMatrix, this._transformedDirection);
			this.cameraDirection.addInPlace(this._transformedDirection);
		}
		
		super._checkInputs();
	}

	override public function _decideIfNeedsToMove():Bool {
		return this._needMoveForGravity || Math.abs(this.cameraDirection.x) > 0 || Math.abs(this.cameraDirection.y) > 0 || Math.abs(this.cameraDirection.z) > 0;
	}

	override public function _updatePosition() {
		if (this.checkCollisions && this.getScene().collisionsEnabled) {
			this._collideWithWorld(this.cameraDirection);
		} 
		else {
			this.position.addInPlace(this.cameraDirection);
		}
	}

}
