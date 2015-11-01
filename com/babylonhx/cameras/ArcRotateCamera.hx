package com.babylonhx.cameras;

import com.babylonhx.collisions.Collider;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.tools.Tools;
import com.babylonhx.utils.Keycodes;


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
	public var lowerBetaLimit:Float = 0.01;
	public var upperBetaLimit:Float = Math.PI;
	public var lowerRadiusLimit:Null<Float> = null;
	public var upperRadiusLimit:Null<Float> = null;
	public var angularSensibility:Float = 1000.0;
	public var wheelPrecision:Float = 3.0;
	public var pinchPrecision:Float = 2.0;
	public var panningSensibility:Float = 0.1;
	
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
	private var _onKeyDown:Dynamic;
	private var _onKeyUp:Dynamic;
	private var _onLostFocus:Void->Void;
	//public var _reset:Void->Void;
	private var _onGestureStart:Dynamic;
	private var _onGesture:Dynamic;
    private var _MSGestureHandler:Dynamic;
	
	// Panning
	private var _localDirection:Vector3;
	private var _transformedDirection:Vector3;
	private var _isRightClick:Bool = false;
	private var _isCtrlPushed:Bool = false;
	private var _lastPanningPosition:Vector2 = new Vector2(0, 0);

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
		
	public var alpha:Float;
	public var beta:Float;
	public var radius:Float;
	public var target:Dynamic;
	

	public function new(name:String, alpha:Float, beta:Float, radius:Float, target:Dynamic, scene:Scene) {
		super(name, Vector3.Zero(), scene);
		
		this.alpha = alpha;
		this.beta = beta;
		this.radius = radius;
		this.target = target != null ? (target.position != null ? target.position.clone() : target.clone()) : Vector3.Zero();
				
		this.getViewMatrix();	
	}

	public function _getTargetPosition():Vector3 {
		return this.target.position != null ? this.target.position : this.target;
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

	// Synchronized
	override public function _isSynchronizedViewMatrix():Bool {
		if (!super._isSynchronizedViewMatrix())
			return false;
			
		return this._cache.target.equals(this._getTargetPosition())
			&& this._cache.alpha == this.alpha
			&& this._cache.beta == this.beta
			&& this._cache.radius == this.radius
			&& this._cache.targetScreenOffset.equals(this.targetScreenOffset);
	}

	// Methods
	override public function attachControl(?element:Dynamic, noPreventDefault:Bool = false, useCtrlForPanning:Bool = true) {
		#if purejs
		var cacheSoloPointer:Dynamic; // cache pointer object for better perf on camera rotation
		var previousPinchDistance:Float = 0.0;
		var pointers:com.babylonhx.tools.SmartCollection = new com.babylonhx.tools.SmartCollection();
		#else
		var previousPosition:Dynamic = null;
		var pointerId:Int = -1;
		#end
		
		if (this._attachedElement != null) {
			return;
		}
		this._attachedElement = element;
		
		var engine = this.getEngine();
		
		if (this._onPointerDown == null) {
			
		#if purejs
			this._onPointerDown = function(evt:Dynamic) {
				// Manage panning
				this._isRightClick = evt.button == 2 ? true : false;
				this._lastPanningPosition.x = evt.clientX;
				this._lastPanningPosition.y = evt.clientY;
				
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
							if (this._localDirection == null) {
								this._localDirection = Vector3.Zero();
								this._transformedDirection = Vector3.Zero();
							}
							
							var diffx = (evt.clientX - this._lastPanningPosition.x) * this.panningSensibility;
							var diffy = (evt.clientY - this._lastPanningPosition.y) * this.panningSensibility;
							
							this._localDirection.copyFromFloats(-diffx, diffy, 0);
							this._viewMatrix.invertToRef(this._cameraTransformMatrix);
							Vector3.TransformNormalToRef(this._localDirection, this._cameraTransformMatrix, this._transformedDirection);
							this.target.addInPlace(this._transformedDirection);
							
							this._lastPanningPosition.x = evt.clientX;
							this._lastPanningPosition.y = evt.clientY;
						} 
						else {
							var offsetX = evt.clientX - cacheSoloPointer.x;
							var offsetY = evt.clientY - cacheSoloPointer.y;
							this.inertialAlphaOffset -= offsetX / this.angularSensibility;
							this.inertialBetaOffset -= offsetY / this.angularSensibility;
							cacheSoloPointer.x = evt.clientX;
							cacheSoloPointer.y = evt.clientY;
						}
						
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
							this.inertialRadiusOffset += (pinchSquaredDistance - previousPinchDistance) / (this.pinchPrecision * this.wheelPrecision * this.angularSensibility * direction);
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
				
				this.inertialAlphaOffset -= offsetX / this.angularSensibility;
				this.inertialBetaOffset -= offsetY / this.angularSensibility;
				
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
				
				this.inertialAlphaOffset -= offsetX / this.angularSensibility;
				this.inertialBetaOffset -= offsetY / this.angularSensibility;	
				
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
		if (!useCtrlForPanning) {
			Engine.app.addEventListener("contextmenu", this._onContextMenu, false);
		}
		Engine.app.addEventListener(eventPrefix + "down", this._onPointerDown, false);
		Engine.app.addEventListener(eventPrefix + "up", this._onPointerUp, false);
		Engine.app.addEventListener(eventPrefix + "out", this._onPointerUp, false);
		Engine.app.addEventListener(eventPrefix + "move", this._onPointerMove, false);
		Engine.app.addEventListener("mousemove", this._onMouseMove, false);
		/*Engine.app.addEventListener("MSPointerDown", this._onGestureStart, false);
		Engine.app.addEventListener("MSGestureChange", this._onGesture, false);*/
		Engine.app.addEventListener('mousewheel', this._wheel, false);
		Engine.app.addEventListener('DOMMouseScroll', this._wheel, false);
				
		Tools.RegisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);
		#else
		Engine.keyDown.push(_onKeyDown);
		Engine.keyUp.push(_onKeyUp);
		Engine.mouseDown.push(_onPointerDown);
		Engine.mouseUp.push(_onPointerUp);
		Engine.mouseMove.push(_onMouseMove);
		Engine.mouseWheel.push(_wheel);	
		#end
	}
	
	override public function detachControl(?element:Dynamic) {
		if (this._attachedElement != element) {
			return;
		}
		
		#if purejs
		Engine.app.removeEventListener("contextmenu", this._onContextMenu, false);
		Engine.app.removeEventListener(eventPrefix + "down", this._onPointerDown, false);
		Engine.app.removeEventListener(eventPrefix + "up", this._onPointerUp, false);
		Engine.app.removeEventListener(eventPrefix + "out", this._onPointerUp, false);
		Engine.app.removeEventListener(eventPrefix + "move", this._onPointerMove, false);
		Engine.app.removeEventListener("mousemove", this._onMouseMove, false);
		/*Engine.app.addEventListener("MSPointerDown", this._onGestureStart, false);
		Engine.app.addEventListener("MSGestureChange", this._onGesture, false);*/
		Engine.app.removeEventListener('mousewheel', this._wheel, false);
		Engine.app.removeEventListener('DOMMouseScroll', this._wheel, false);
				
		Tools.UnregisterTopRootEvents([
			{ name: "keydown", handler: this._onKeyDown },
			{ name: "keyup", handler: this._onKeyUp },
			{ name: "blur", handler: this._onLostFocus }
		]);
		#else
		Engine.keyDown.remove(_onKeyDown);
		Engine.keyUp.remove(_onKeyUp);
		Engine.mouseDown.remove(_onPointerDown);
		Engine.mouseUp.remove(_onPointerUp);
		Engine.mouseMove.remove(_onMouseMove);
		Engine.mouseWheel.remove(_wheel);
		#end
				
		this._attachedElement = null;
		
		if (this._reset != null) {
			this._reset();
		}
	}

	override public function _update() {
		// Keyboard
		for (index in 0...this._keys.length) {
			var keyCode = this._keys[index];
			
			if (this.keysLeft.indexOf(keyCode) != -1) {
				this.inertialAlphaOffset -= 0.01;
			} else if (this.keysUp.indexOf(keyCode) != -1) {
				this.inertialBetaOffset -= 0.01;
			} else if (this.keysRight.indexOf(keyCode) != -1) {
				this.inertialAlphaOffset += 0.01;
			} else if (this.keysDown.indexOf(keyCode) != -1) {
				this.inertialBetaOffset += 0.01;
			}
		}
		
		// Inertia
		if (this.inertialAlphaOffset != 0 || this.inertialBetaOffset != 0 || this.inertialRadiusOffset != 0) {
			this.alpha += this.inertialAlphaOffset;
			this.beta += this.inertialBetaOffset;
			this.radius -= this.inertialRadiusOffset;
			
			this.inertialAlphaOffset *= this.inertia;
			this.inertialBetaOffset *= this.inertia;
			this.inertialRadiusOffset *= this.inertia;
			
			if (Math.abs(this.inertialAlphaOffset) < Engine.Epsilon)
				this.inertialAlphaOffset = 0;
				
			if (Math.abs(this.inertialBetaOffset) < Engine.Epsilon)
				this.inertialBetaOffset = 0;
				
			if (Math.abs(this.inertialRadiusOffset) < Engine.Epsilon)
				this.inertialRadiusOffset = 0;
		}
		
		// Limits
		if (this.lowerAlphaLimit != null && this.alpha < this.lowerAlphaLimit) {
			this.alpha = this.lowerAlphaLimit;
		}
		if (this.upperAlphaLimit != null && this.alpha > this.upperAlphaLimit) {
			this.alpha = this.upperAlphaLimit;
		}
		if (this.beta < this.lowerBetaLimit) {
			this.beta = this.lowerBetaLimit;
		}
		if (this.beta > this.upperBetaLimit) {
			this.beta = this.upperBetaLimit;
		}
		if (this.lowerRadiusLimit != null && this.radius < this.lowerRadiusLimit) {
			this.radius = this.lowerRadiusLimit;
		}
		if (this.upperRadiusLimit != null && this.radius > this.upperRadiusLimit) {
			this.radius = this.upperRadiusLimit;
		}
	}

	public function setPosition(position:Vector3) {
		if (this.position.equals(position)) {
            return;
        }
		
		var radiusv3 = position.subtract(this._getTargetPosition());
		this.radius = radiusv3.length();
		
		// Alpha
		this.alpha = Math.acos(radiusv3.x / Math.sqrt(Math.pow(radiusv3.x, 2) + Math.pow(radiusv3.z, 2)));
		
		if (radiusv3.z < 0) {
			this.alpha = 2 * Math.PI - this.alpha;
		}
		
		// Beta
		this.beta = Math.acos(radiusv3.y / this.radius);		
	}

	override public function _getViewMatrix_default():Matrix {
		// Compute
		var cosa = Math.cos(this.alpha);
		var sina = Math.sin(this.alpha);
		var cosb = Math.cos(this.beta);
		var sinb = Math.sin(this.beta);
		
		var target = this._getTargetPosition();
		
		target.addToRef(new Vector3(this.radius * cosa * sinb, this.radius * cosb, this.radius * sina * sinb), this.position);
		
		if (this.checkCollisions) {
			this._collider.radius = this.collisionRadius;
			this.position.subtractToRef(this._previousPosition, this._collisionVelocity);
			
			this.getScene()._getNewPosition(this._previousPosition, this._collisionVelocity, this._collider, 3, this._newPosition);
			
			if (!this._newPosition.equalsWithEpsilon(this.position)) {
				this.position.copyFrom(this._previousPosition);
				
				this.alpha = this._previousAlpha;
				this.beta = this._previousBeta;
				this.radius = this._previousRadius;
				
				if (this.onCollide != null) {
					this.onCollide(this._collider.collidedMesh);
				}
			}
		}
		
		Matrix.LookAtLHToRef(this.position, target, this.upVector, this._viewMatrix);
		
		this._previousAlpha = this.alpha;
		this._previousBeta = this.beta;
		this._previousRadius = this.radius;
		this._previousPosition.copyFrom(this.position);
		
		this._viewMatrix.m[12] += this.targetScreenOffset.x;
		this._viewMatrix.m[13] += this.targetScreenOffset.y;
					
		return this._viewMatrix;
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
	
}
