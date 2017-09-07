package com.babylonhx.cameras;

import com.babylonhx.behaviors.cameras.BouncingBehavior;
import com.babylonhx.behaviors.cameras.FramingBehavior;
import com.babylonhx.behaviors.cameras.AutoRotationBehavior;
import com.babylonhx.collisions.Collider;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.math.Tools;
import com.babylonhx.utils.Keycodes;
import com.babylonhx.tools.Observable;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ArcRotateCamera') class ArcRotateCamera extends TargetCamera {
	
	public var inertialAlphaOffset:Float = 0;
	public var inertialBetaOffset:Float = 0;
	public var inertialRadiusOffset:Float = 0;
	public var lowerAlphaLimit:Null<Float> = null;
	public var upperAlphaLimit:Null<Float> = null;
	public var lowerBetaLimit:Null<Float> = 0.01;
	public var upperBetaLimit:Null<Float> = Math.PI;
	public var lowerRadiusLimit:Null<Float> = null;
	public var upperRadiusLimit:Null<Float> = null;
	public var angularSensibilityX:Float = 1000.0;
	public var angularSensibilityY:Float = 1000.0;
	public var wheelPrecision:Float = 3.0;
	public var pinchPrecision:Float = 2.0;
	public var panningSensibility:Float = 50;
	public var inertialPanningX:Float = 0;
	public var inertialPanningY:Float = 0;
	
	#if purejs
	public var keysUp:Array<Int> = [38];
	public var keysDown:Array<Int> = [40];
	public var keysLeft:Array<Int> = [37];
	public var keysRight:Array<Int> = [39];
	#else
	public var keysUp:Array<Int> = [Keycodes.up];
	public var keysDown:Array<Int> = [Keycodes.down];
	public var keysLeft:Array<Int> = [Keycodes.left];
	public var keysRight:Array<Int> = [Keycodes.right];
	#end
	
	public var zoomOnFactor:Float = 1;
	public var targetScreenOffset:Vector2 = Vector2.Zero();
	public var pinchInwards:Bool = true;
	public var allowUpsideDown:Bool = true;
	
	
	private var _keys:Array<Int> = [];
	//public var _viewMatrix = new Matrix();
	private var _attachedElement:Dynamic;

	private var _onContextMenu:Dynamic;
	private var _onPointerDown:Dynamic;
	private var _onPointerUp:Dynamic;
	private var _onPointerMove:Dynamic;
	private var _wheel:Dynamic;
	private var _onMouseMove:Dynamic;
	private var _onKeyDown:Int->Void = function(keycode:Int) { };
	private var _onKeyUp:Int->Void = function(keycode:Int) { };
	private var _onLostFocus:Void->Void;
	//public var _reset:Void->Void;
	private var _onGestureStart:Dynamic;
	private var _onGesture:Dynamic;
    private var _MSGestureHandler:Dynamic;
	
	// Panning
	public var panningAxis:Vector3 = new Vector3(1, 1, 0);
	private var _localDirection:Vector3;
	private var _transformedDirection:Vector3;
	private var _isRightClick:Bool = false;
	private var _isCtrlPushed:Bool = false;
	
	// Behaviors
	private var _bouncingBehavior:BouncingBehavior;
	public var useBouncingBehavior(get, set):Bool;
	private function get_useBouncingBehavior():Bool {
		return this._bouncingBehavior != null;
	}
	private function set_useBouncingBehavior(value:Bool):Bool {
		if (value == this.useBouncingBehavior) {
			return value;
		}
		
		if (value) {
			this._bouncingBehavior = new BouncingBehavior();
			this.addBehavior(cast this._bouncingBehavior);
		} 
		else {
			this.removeBehavior(cast this._bouncingBehavior);
			this._bouncingBehavior = null;
		}
		return value;
	}
	
	private var _framingBehavior:FramingBehavior;
	public var useFramingBehavior(get, set):Bool;
	inline private function get_useFramingBehavior():Bool {
		return this._framingBehavior != null;
	}
	private function set_useFramingBehavior(value:Bool):Bool {
		if (value == this.useFramingBehavior) {
			return value;
		}
		
		if (value) {
			this._framingBehavior = new FramingBehavior();
			this.addBehavior(cast this._framingBehavior);
		}
		else {
			this.removeBehavior(cast this._framingBehavior);
			this._framingBehavior = null;
		}
		return value;
	}

	private var _autoRotationBehavior:AutoRotationBehavior;
	public var useAutoRotationBehavior(get, set):Bool; 
	inline private function get_useAutoRotationBehavior():Bool {
		return this._autoRotationBehavior != null;
	}
	private function set_useAutoRotationBehavior(value:Bool):Bool {
		if (value == this.useAutoRotationBehavior) {
			return value;
		}
		
		if (value) {
			this._autoRotationBehavior = new AutoRotationBehavior();
			this.addBehavior(cast this._autoRotationBehavior);
		} 
		else {
			this.removeBehavior(cast this._autoRotationBehavior);
			this._autoRotationBehavior = null;
		}
		return value;
	}
	
	public var onMeshTargetChangedObservable:Observable<AbstractMesh> = new Observable<AbstractMesh>();

	// Collisions
	public var onCollide:AbstractMesh->Void;
	public var checkCollisions:Bool = false;
	public var collisionRadius:Vector3 = new Vector3(0.5, 0.5, 0.5);
	private var _collider:Collider = new Collider();
	private var _previousPosition:Vector3 = Vector3.Zero();
	private var _collisionVelocity:Vector3 = Vector3.Zero();
	private var _newPosition:Vector3 = Vector3.Zero();
	private var _previousAlpha:Float;
	private var _previousBeta:Float;
	private var _previousRadius:Float;
	//due to async collision inspection
	private var _collisionTriggered:Bool;
	
	public var alpha:Float = 0;
	public var beta:Float = 0;
	public var radius:Float = 0;
	
	@serializeAsVector3("target")
	private var _target:Dynamic;
	private var _targetHost:AbstractMesh;
	
	public var target(get, set):Dynamic;
	inline private function get_target():Dynamic {
		return this._target;
	}
	inline private function set_target(value:Dynamic):Dynamic {
		this.setTarget(value);
		return value;
	}
	
	private var _targetBoundingCenter:Vector3;
	

	public function new(name:String, alpha:Float, beta:Float, radius:Float, target:Dynamic, scene:Scene) {
		super(name, Vector3.Zero(), scene);
		
		this._target = Vector3.Zero();
		if (target != null) {
			this.setTarget(target);
		}
		
		this.alpha = alpha;
		this.beta = beta;
		this.radius = radius;
		
		this.getViewMatrix();
		//this.inputs = new ArcRotateCameraInputsManager(this);
		//this.inputs.addKeyboard().addMouseWheel().addPointers();	
	}

	public function _getTargetPosition():Vector3 {
		return /*this.target.getAbsolutePosition != null ? this.target.getAbsolutePosition() : */this.target;
	}

	// Cache
	override public function _initCache() {
		super._initCache();
		this._cache.target = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		this._cache.alpha = null;
		this._cache.beta = null;
		this._cache.radius = null;
		this._cache.targetScreenOffset = null;
	}

	override public function _updateCache(ignoreParentClass:Bool = false) {
		if (!ignoreParentClass) {
			super._updateCache();
		}
		
		this._cache.target.copyFrom(this._getTargetPosition());
		this._cache.alpha = this.alpha;
		this._cache.beta = this.beta;
		this._cache.radius = this.radius;
		this._cache.targetScreenOffset = this.targetScreenOffset.clone();
	}
	
	// State

	/**
	 * Store current camera state (fov, position, etc..)
	 */
	private var _storedAlpha:Float;
	private var _storedBeta:Float;
	private var _storedRadius:Float;
	private var _storedTarget:Vector3;     

	override public function storeState():Camera {
		this._storedAlpha = this.alpha;
		this._storedBeta = this.beta;
		this._storedRadius = this.radius;
		this._storedTarget = this._getTargetPosition().clone();
		
		return super.storeState();
	}

	/**
	 * Restored camera state. You must call storeState() first
	 */
	override public function _restoreStateValues():Bool {
		if (!super._restoreStateValues()) {
			return false;
		}
		
		this.alpha = this._storedAlpha;
		this.beta = this._storedBeta;
		this.radius = this._storedRadius;
		this.setTarget(this._storedTarget);
		
		this.inertialAlphaOffset = 0;
		this.inertialBetaOffset = 0;
		this.inertialRadiusOffset = 0;
		
		return true;
	}

	// Synchronized
	override public function _isSynchronizedViewMatrix():Bool {
		if (!super._isSynchronizedViewMatrix()) {
			return false;
		}
			
		return this._cache.target.equals(this._getTargetPosition())
			&& this._cache.alpha == this.alpha
			&& this._cache.beta == this.beta
			&& this._cache.radius == this.radius
			&& this._cache.targetScreenOffset.equals(this.targetScreenOffset);
	}

	// Methods
	override public function attachControl(useCtrlForPanning:Bool = true, enableKeyboard:Bool = true) {
		#if purejs
		var cacheSoloPointer:Dynamic; // cache pointer object for better perf on camera rotation
		var previousPinchDistance:Float = 0.0;
		var pointers:com.babylonhx.tools.SmartCollection = new com.babylonhx.tools.SmartCollection();
		#else
		var previousPosition:Dynamic = null;
		var pointerId:Int = -1;
		#end
		
		var engine = this.getEngine();
		
		if (this._onPointerDown == null) {
			
		#if purejs
			this._onPointerDown = function(evt:Dynamic) {
				// Manage panning
				this._isRightClick = evt.button == 2;
				
				// manage pointers
				var _dummy = { dummy: 'dummy' };
				pointers.add(evt.pointerId != null ? evt.pointerId : _dummy, { x: evt.clientX, y: evt.clientY, type: evt.pointerType });
				cacheSoloPointer = pointers.item(evt.pointerId != null ? evt.pointerId : _dummy);
				if (!noPreventDefault) {
					evt.preventDefault();
				}
			};
			
			this._onPointerUp = function(evt:Dynamic) {
				cacheSoloPointer = null;
				previousPinchDistance = 0;
				
				//would be better to use pointers.remove(evt.pointerId) for multitouch gestures, 
				//but emptying completly pointers collection is required to fix a bug on iPhone : 
				//when changing orientation while pinching camera, one pointer stay pressed forever if we don't release all pointers  
				//will be ok to put back pointers.remove(evt.pointerId); when iPhone bug corrected
				pointers.empty();
								   
				if (!noPreventDefault) {
					evt.preventDefault();
				}
			};
			
			this._onContextMenu = function(evt:Dynamic) {
				evt.preventDefault();
			};
			
			this._onPointerMove = function(evt:Dynamic) {
				if (!noPreventDefault) {
					evt.preventDefault();
				}
				
				switch (pointers.count) {
					
					case 1: //normal camera rotation
						if (this.panningSensibility != 0 && ((this._isCtrlPushed && useCtrlForPanning) || (!useCtrlForPanning && this._isRightClick))) {
							this.inertialPanningX += -(evt.clientX - cacheSoloPointer.x) / this.panningSensibility;
                                this.inertialPanningY += (evt.clientY - cacheSoloPointer.y) / this.panningSensibility;
                            } 
							else {
                                var offsetX = evt.clientX - cacheSoloPointer.x;
                                var offsetY = evt.clientY - cacheSoloPointer.y;
                                this.inertialAlphaOffset -= offsetX / this.angularSensibilityX;
                                this.inertialBetaOffset -= offsetY / this.angularSensibilityY;
                            }
                            cacheSoloPointer.x = evt.clientX;
                            cacheSoloPointer.y = evt.clientY;
						
					case 2: //pinch
						//if (noPreventDefault) { evt.preventDefault(); } //if pinch gesture, could be usefull to force preventDefault to avoid html page scroll/zoom in some mobile browsers
						pointers.item(evt.pointerId).x = evt.clientX;
						pointers.item(evt.pointerId).y = evt.clientY;
						var direction = this.pinchInwards ? 1 : -1;
						var distX = pointers.getItemByIndex(0).x - pointers.getItemByIndex(1).x;
						var distY = pointers.getItemByIndex(0).y - pointers.getItemByIndex(1).y;
						var pinchSquaredDistance = (distX * distX) + (distY * distY);
						if (previousPinchDistance == 0) {
							previousPinchDistance = pinchSquaredDistance;
							return;
						}
						
						if (pinchSquaredDistance != previousPinchDistance) {
							this.inertialRadiusOffset += (pinchSquaredDistance - previousPinchDistance) / (this.pinchPrecision * this.wheelPrecision * this.angularSensibilityX * direction);
							previousPinchDistance = pinchSquaredDistance;
						}
						
					default:
						if (pointers.item(evt.pointerId) != null) {
							pointers.item(evt.pointerId).x = evt.clientX;
							pointers.item(evt.pointerId).y = evt.clientY;
						}
				}
			};
			
			this._onMouseMove = function(evt:Dynamic) {
				if (!engine.isPointerLock) {
					return;
				}
				
				var offsetX = untyped evt.movementX || evt.mozMovementX || evt.webkitMovementX || evt.msMovementX || 0;
				var offsetY = untyped evt.movementY || evt.mozMovementY || evt.webkitMovementY || evt.msMovementY || 0;
				
				this.inertialAlphaOffset -= offsetX / this.angularSensibilityX;
				this.inertialBetaOffset -= offsetY / this.angularSensibilityY;
				
				if (!noPreventDefault) {
					evt.preventDefault();
				}
			};
			
			this._wheel = function(event:Dynamic) {
				var delta = 0.0;
				if (event.wheelDelta != null) {
					delta = event.wheelDelta / (this.wheelPrecision * 40);
				} 
				else if (event.detail != null) {
					delta = -event.detail / this.wheelPrecision;
				}
				
				if (delta != 0.0) {
					this.inertialRadiusOffset += delta;
				}
				
				if (event.preventDefault != null) {
					if (!noPreventDefault) {
						event.preventDefault();
					}
				}
			};
			
		#else
			
			this._onPointerDown = function(x:Float, y:Float, button:Int) {
				previousPosition = {
					x: x,
					y: y
				};
			};
			
			this._onPointerUp = function(x:Float, y:Float, button:Int) {
				previousPosition = null;
			};	
			
			this._onMouseMove = function(x:Int, y:Int) {
				if (previousPosition == null && !engine.isPointerLock) {
                    return;
                }
				
				var offsetX:Float = 0;
                var offsetY:Float = 0;
				
                if (!engine.isPointerLock) {
                    offsetX = x - previousPosition.x;
                    offsetY = y - previousPosition.y;
                }
				
				this.inertialAlphaOffset -= offsetX / this.angularSensibilityX;
				this.inertialBetaOffset -= offsetY / this.angularSensibilityY;	
				
				previousPosition = {
					x: x, 
					y: y
                };
			};
			
			this._wheel = function(delta:Float) {
				var _delta = delta / wheelPrecision;
				
			#if !js
                this.inertialRadiusOffset += _delta;
			#else
				this.inertialRadiusOffset += _delta / 20;
			#end
			};
			
		#end			
			
			if (enableKeyboard) {
				this._onKeyDown = function(keycode:Int) {
					if (this.keysUp.indexOf(keycode) != -1 ||
						this.keysDown.indexOf(keycode) != -1 ||
						this.keysLeft.indexOf(keycode) != -1 ||
						this.keysRight.indexOf(keycode) != -1) {
						var index = this._keys.indexOf(keycode);
						
						if (index == -1) {
							this._keys.push(keycode);
						}					
					}
				};
				
				this._onKeyUp = function(keycode:Int) {
					if (this.keysUp.indexOf(keycode) != -1 ||
						this.keysDown.indexOf(keycode) != -1 ||
						this.keysLeft.indexOf(keycode) != -1 ||
						this.keysRight.indexOf(keycode) != -1) {
						var index = this._keys.indexOf(keycode);
						
						if (index >= 0) {
							this._keys.splice(index, 1);
						}					
					}
				};
			}
			
			this._onLostFocus = function() {
				this._keys = [];				
				
			#if purejs
				pointers.empty();
				previousPinchDistance = 0;
				cacheSoloPointer = null;
			#else
				pointerId = 0;
			#end
			};
			
			this._reset = function() {
				this._keys = [];
				this.inertialAlphaOffset = 0;
				this.inertialBetaOffset = 0;
				this.inertialRadiusOffset = 0;				
				
			#if purejs
				pointers.empty();
				previousPinchDistance = 0;
				cacheSoloPointer = null;
			#else
				previousPosition = null;
				pointerId = 0;
			#end
			};
			
		}
		
		#if purejs
		var canvas = this.getScene().getEngine().getRenderingCanvas();
		if (!useCtrlForPanning) {
			canvas.addEventListener("contextmenu", this._onContextMenu, false);
		}
		canvas.addEventListener(eventPrefix + "down", this._onPointerDown, false);
		canvas.addEventListener(eventPrefix + "up", this._onPointerUp, false);
		canvas.addEventListener(eventPrefix + "out", this._onPointerUp, false);
		canvas.addEventListener(eventPrefix + "move", this._onPointerMove, false);
		canvas.addEventListener("mousemove", this._onMouseMove, false);
		/*canvas.addEventListener("MSPointerDown", this._onGestureStart, false);
		canvas.addEventListener("MSGestureChange", this._onGesture, false);*/
		canvas.addEventListener('mousewheel', this._wheel, false);
		canvas.addEventListener('DOMMouseScroll', this._wheel, false);
		
		com.babylonhx.tools.Tools.RegisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);
		#else
		#if !mobile
		this.getScene().getEngine().keyDown.push(_onKeyDown);
		this.getScene().getEngine().keyUp.push(_onKeyUp);
		this.getScene().getEngine().mouseDown.push(_onPointerDown);
		this.getScene().getEngine().mouseUp.push(_onPointerUp);
		this.getScene().getEngine().mouseMove.push(_onMouseMove);
		this.getScene().getEngine().mouseWheel.push(_wheel);
		#else
		this.getScene().getEngine().touchDown.push(_onPointerDown);
		this.getScene().getEngine().touchUp.push(_onPointerUp);
		this.getScene().getEngine().touchMove.push(_onPointerMove);
		#end
		#end
	}
	
	override public function detachControl() {
		#if purejs
		var canvas = this.getScene().getEngine().getRenderingCanvas();
		canvas.removeEventListener("contextmenu", this._onContextMenu, false);
		canvas.removeEventListener(eventPrefix + "down", this._onPointerDown, false);
		canvas.removeEventListener(eventPrefix + "up", this._onPointerUp, false);
		canvas.removeEventListener(eventPrefix + "out", this._onPointerUp, false);
		canvas.removeEventListener(eventPrefix + "move", this._onPointerMove, false);
		canvas.removeEventListener("mousemove", this._onMouseMove, false);
		/*canvas.addEventListener("MSPointerDown", this._onGestureStart, false);
		canvas.addEventListener("MSGestureChange", this._onGesture, false);*/
		canvas.removeEventListener('mousewheel', this._wheel, false);
		canvas.removeEventListener('DOMMouseScroll', this._wheel, false);
		
		com.babylonhx.tools.Tools.UnregisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);
		#else
		#if !mobile
		this.getScene().getEngine().keyDown.remove(_onKeyDown);
		this.getScene().getEngine().keyUp.remove(_onKeyUp);
		this.getScene().getEngine().mouseDown.remove(_onPointerDown);
		this.getScene().getEngine().mouseUp.remove(_onPointerUp);
		this.getScene().getEngine().mouseMove.remove(_onMouseMove);
		this.getScene().getEngine().mouseWheel.remove(_wheel);
		#else
		this.getScene().getEngine().touchDown.remove(_onPointerDown);
		this.getScene().getEngine().touchUp.remove(_onPointerUp);
		this.getScene().getEngine().touchMove.remove(_onPointerMove);
		#end
		#end
		
		this._attachedElement = null;
		
		if (this._reset != null) {
			this._reset();
		}
	}
	
	override public function _checkInputs() {
		//if (async) collision inspection was triggered, don't update the camera's position - until the collision callback was called.
		if (this._collisionTriggered) {
			return;
		}
		
		// Keyboard
		for (index in 0...this._keys.length) {
			var keyCode = this._keys[index];
			if (this.keysLeft.indexOf(keyCode) != -1) {
				this.inertialAlphaOffset -= 0.01;
			} 
			else if (this.keysUp.indexOf(keyCode) != -1) {
				this.inertialBetaOffset -= 0.01;
			} 
			else if (this.keysRight.indexOf(keyCode) != -1) {
				this.inertialAlphaOffset += 0.01;
			} 
			else if (this.keysDown.indexOf(keyCode) != -1) {
				this.inertialBetaOffset += 0.01;
			}
		}			
		
		// Inertia
		if (this.inertialAlphaOffset != 0 || this.inertialBetaOffset != 0 || this.inertialRadiusOffset != 0) {
			this.alpha += this.beta <= 0 ? -this.inertialAlphaOffset : this.inertialAlphaOffset;
			this.beta += this.inertialBetaOffset;
			this.radius -= this.inertialRadiusOffset;
			this.inertialAlphaOffset *= this.inertia;
			this.inertialBetaOffset *= this.inertia;
			this.inertialRadiusOffset *= this.inertia;
			if (Math.abs(this.inertialAlphaOffset) < Tools.Epsilon) {
				this.inertialAlphaOffset = 0;
			}
			if (Math.abs(this.inertialBetaOffset) < Tools.Epsilon) {
				this.inertialBetaOffset = 0;
			}
			if (Math.abs(this.inertialRadiusOffset) < Tools.Epsilon) {
				this.inertialRadiusOffset = 0;
			}
		}
		
		// Panning inertia
		if (this.inertialPanningX != 0 || this.inertialPanningY != 0) {
			if (this._localDirection == null) {
				this._localDirection = Vector3.Zero();
				this._transformedDirection = Vector3.Zero();
			}
			
			this.inertialPanningX *= this.inertia;
			this.inertialPanningY *= this.inertia;
			
			if (Math.abs(this.inertialPanningX) < Tools.Epsilon) {
				this.inertialPanningX = 0;
			}
			if (Math.abs(this.inertialPanningY) < Tools.Epsilon) {
				this.inertialPanningY = 0;
			}
			
			this._localDirection.copyFromFloats(this.inertialPanningX, this.inertialPanningY, 0);
			this._viewMatrix.invertToRef(this._cameraTransformMatrix);
			Vector3.TransformNormalToRef(this._localDirection, this._cameraTransformMatrix, this._transformedDirection);
			if (this.target.getAbsolutePosition() != null) {
                this.target.addInPlace(this._transformedDirection);
            }
		}
		
		// Limits
		this._checkLimits();
		
		super._checkInputs();
	}
	
	private function _checkLimits() {
		if (this.lowerBetaLimit == null) {
			if (this.allowUpsideDown && this.beta > Math.PI) {
				this.beta = this.beta - (2 * Math.PI);
			}
		} 
		else {
			if (this.beta < this.lowerBetaLimit) {
				this.beta = this.lowerBetaLimit;
			}
		}
		
		if (this.upperBetaLimit == null) {
			if (this.allowUpsideDown && this.beta < -Math.PI) {
				this.beta = this.beta + (2 * Math.PI);
			}
		} 
		else {
			if (this.beta > this.upperBetaLimit) {
				this.beta = this.upperBetaLimit;
			}
		}
		
		if (this.lowerAlphaLimit != null && this.alpha < this.lowerAlphaLimit) {
			this.alpha = this.lowerAlphaLimit;
		}
		if (this.upperAlphaLimit != null && this.alpha > this.upperAlphaLimit) {
			this.alpha = this.upperAlphaLimit;
		}
		
		if (this.lowerRadiusLimit != null && this.radius < this.lowerRadiusLimit) {
			this.radius = this.lowerRadiusLimit;
		}
		if (this.upperRadiusLimit != null && this.radius > this.upperRadiusLimit) {
			this.radius = this.upperRadiusLimit;
		}
	}
	
	public function rebuildAnglesAndRadius() {
		var radiusv3 = this.position.subtract(this._getTargetPosition());
		this.radius = radiusv3.length();
		
		if (this.radius == 0) {
			this.radius = 0.0001; // Just to avoid division by zero
		}
		
		// Alpha
		this.alpha = Math.acos(radiusv3.x / Math.sqrt(Math.pow(radiusv3.x, 2) + Math.pow(radiusv3.z, 2)));
		
		if (radiusv3.z < 0) {
			this.alpha = 2 * Math.PI - this.alpha;
		}
		
		// Beta
		this.beta = Math.acos(radiusv3.y / this.radius);
		
		this._checkLimits();
	}

	public function setPosition(position:Vector3) {
		if (this.position.equals(position)) {
            return;
        }
		
		this.position = position;
		
		this.rebuildAnglesAndRadius();
	}
	
	override public function setTarget(target:Dynamic/*AbstractMesh | Vector3*/, toBoundingCenter:Bool = false, allowSamePosition:Bool = false) {
		if (Std.is(target, AbstractMesh)) {
			if (toBoundingCenter){
				this._targetBoundingCenter = cast(target, AbstractMesh).getBoundingInfo().boundingBox.centerWorld.clone();
			} 
			else {
				this._targetBoundingCenter = null;
			}
			this._targetHost = cast target;
			this._target = this._getTargetPosition();
			
			this.onMeshTargetChangedObservable.notifyObservers(this._targetHost);
		} 
		else {
			var newTarget:Vector3 = cast target;
			var currentTarget = this._getTargetPosition();
			if (currentTarget != null && !allowSamePosition && currentTarget.equals(newTarget)) {
			    return;
			}
			this._target = newTarget;
			this._targetBoundingCenter = null;
			this.onMeshTargetChangedObservable.notifyObservers(null);
		}
		
		this.rebuildAnglesAndRadius();
	}

	override public function _getViewMatrix_default():Matrix {
		// Compute
		var cosa = Math.cos(this.alpha);
		var sina = Math.sin(this.alpha);
		var cosb = Math.cos(this.beta);
		var sinb = Math.sin(this.beta);
		
		if (sinb == 0) {
			sinb = 0.0001;
		}
		
		var target = this._getTargetPosition();
		
		target.addToRef(new Vector3(this.radius * cosa * sinb, this.radius * cosb, this.radius * sina * sinb), this._newPosition);
		
		if (this.getScene().collisionsEnabled && this.checkCollisions) {
			this._collider.radius = this.collisionRadius;
			this._newPosition.subtractToRef(this.position, this._collisionVelocity);
			this._collisionTriggered = true;
			this.getScene().collisionCoordinator.getNewPosition(this.position, this._collisionVelocity, this._collider, 3, null, this._onCollisionPositionChange, this.uniqueId);
		} 
		else {
			this.position.copyFrom(this._newPosition);
			
			var up = this.upVector;
			if (this.allowUpsideDown && this.beta < 0) {
				up = up.clone();
				up = up.negate();
			}
			
			if (this.getScene().useRightHandedSystem) {
				Matrix.LookAtRHToRef(this.position, target, up, this._viewMatrix);
			}  
			else {
				Matrix.LookAtLHToRef(this.position, target, up, this._viewMatrix);
			}
			this._viewMatrix.m[12] += this.targetScreenOffset.x;
			this._viewMatrix.m[13] += this.targetScreenOffset.y;
		}
		
		this._currentTarget = target;
		
		return this._viewMatrix;
	}
	
	private function _onCollisionPositionChange(collisionId:Int, newPosition:Vector3, collidedMesh:AbstractMesh = null) {
		if (this.getScene().workerCollisions && this.checkCollisions) {
			newPosition.multiplyInPlace(this._collider.radius);
		}
		
		if (collidedMesh != null) {
			this._previousPosition.copyFrom(this.position);
		} 
		else {
			this.setPosition(newPosition);
			
			if (this.onCollide != null) {
				this.onCollide(collidedMesh);
			}
		}
		
		// Recompute because of constraints
		var cosa = Math.cos(this.alpha);
		var sina = Math.sin(this.alpha);
		var cosb = Math.cos(this.beta);
		var sinb = Math.sin(this.beta);
		var target = this._getTargetPosition();
		target.addToRef(new Vector3(this.radius * cosa * sinb, this.radius * cosb, this.radius * sina * sinb), this._newPosition);
		this.position.copyFrom(this._newPosition);
		
		var up = this.upVector;
		if (this.allowUpsideDown && this.beta < 0) {
			up = up.clone();
			up = up.negate();
		}
		
		Matrix.LookAtLHToRef(this.position, target, up, this._viewMatrix);
		this._viewMatrix.m[12] += this.targetScreenOffset.x;
		this._viewMatrix.m[13] += this.targetScreenOffset.y;
		
		this._collisionTriggered = false;
	}

	public function zoomOn(?meshes:Array<AbstractMesh>, doNotUpdateMaxZ:Bool = false) {
		meshes = meshes != null ? meshes : this.getScene().meshes;
		
		var minMaxVector = Mesh.MinMax(meshes);
		var distance = Vector3.Distance(minMaxVector.minimum, minMaxVector.maximum);
		
		this.radius = distance * this.zoomOnFactor;
		
		this.focusOn({ min: minMaxVector.minimum, max: minMaxVector.maximum, distance: distance }, doNotUpdateMaxZ);
	}

	public function focusOn(meshesOrMinMaxVectorAndDistance:Dynamic, doNotUpdateMaxZ:Bool = false) {
		var meshesOrMinMaxVector:Dynamic = null;
		var distance:Float = 0;
		
		if (meshesOrMinMaxVectorAndDistance.minimum == null) { // meshes
			meshesOrMinMaxVector = meshesOrMinMaxVectorAndDistance != null ? meshesOrMinMaxVectorAndDistance : this.getScene().meshes;
			meshesOrMinMaxVector = Mesh.MinMax(meshesOrMinMaxVector);
			distance = Vector3.Distance(meshesOrMinMaxVector.minimum, meshesOrMinMaxVector.maximum);
		}
		else { //minMaxVector and distance
			meshesOrMinMaxVector = meshesOrMinMaxVectorAndDistance;
			distance = meshesOrMinMaxVectorAndDistance.distance;
		}
		
		this.target.position = Mesh.Center(meshesOrMinMaxVector);
		
		if (!doNotUpdateMaxZ) {
            this.maxZ = distance * 2;
        }
	}
	
	override public function createRigCamera(name:String, cameraIndex:Int):Camera {
		var alphaShift:Float = 0;
		switch (this.cameraRigMode) {
			case Camera.RIG_MODE_STEREOSCOPIC_ANAGLYPH, 
				 Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_PARALLEL, 
				 Camera.RIG_MODE_STEREOSCOPIC_OVERUNDER,
				 Camera.RIG_MODE_VR:
				alphaShift = this._cameraRigParams.stereoHalfAngle * (cameraIndex == 0 ? 1 : -1);
				
			case Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED:
				alphaShift = this._cameraRigParams.stereoHalfAngle * (cameraIndex == 0 ? -1 : 1);
				
		}
		
		var rigCam = new ArcRotateCamera(name, this.alpha + alphaShift, this.beta, this.radius, this.target, this.getScene());
		rigCam._cameraRigParams = {};
        
		return rigCam;
	}
	
	override public function _updateRigCameras() {
		var camLeft:ArcRotateCamera  = cast this._rigCameras[0];
		var camRight:ArcRotateCamera = cast this._rigCameras[1];
		
		camLeft.beta = camRight.beta = this.beta;
		camLeft.radius = camRight.radius = this.radius;
		
		switch (this.cameraRigMode) {
			case Camera.RIG_MODE_STEREOSCOPIC_ANAGLYPH,
				 Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_PARALLEL,				 
				 Camera.RIG_MODE_STEREOSCOPIC_OVERUNDER, 
				 Camera.RIG_MODE_VR:
				camLeft.alpha = this.alpha - this._cameraRigParams.stereoHalfAngle;
				camRight.alpha = this.alpha + this._cameraRigParams.stereoHalfAngle;
				
			case Camera.RIG_MODE_STEREOSCOPIC_SIDEBYSIDE_CROSSEYED:
				camLeft.alpha  = this.alpha + this._cameraRigParams.stereoHalfAngle;
				camRight.alpha = this.alpha - this._cameraRigParams.stereoHalfAngle;
				
		}
		
		super._updateRigCameras();
	}
	
	override public function serialize():Dynamic {
		var serializationObject = super.serialize();
		
		if (Std.is(this.target, Vector3)) {
			serializationObject.target = this.target.asArray();
		}
		
		if (this.target != null && this.target.id != null) {
			serializationObject.lockedTargetId = this.target.id;
		}
		
		serializationObject.checkCollisions = this.checkCollisions;
		
		serializationObject.alpha = this.alpha;
		serializationObject.beta = this.beta;
		serializationObject.radius = this.radius;
		
		return serializationObject;
	}
	
}
