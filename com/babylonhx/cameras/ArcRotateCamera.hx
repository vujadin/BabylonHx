package com.babylonhx.cameras;

import com.babylonhx.collisions.Collider;
import com.babylonhx.math.Axis;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;

import com.babylonhx.utils.Keycodes;


/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ArcRotateCamera') class ArcRotateCamera extends Camera {
	
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
	public var wheelPrecision:Float = 5.0;
	public var keysUp:Array<Int> = [Keycodes.up];
	public var keysDown:Array<Int> = [Keycodes.down];
	public var keysLeft:Array<Int> = [Keycodes.left];
	public var keysRight:Array<Int> = [Keycodes.right];
	public var zoomOnFactor:Float = 1;
	public var targetScreenOffset:Vector2 = Vector2.Zero();
	
	
	private var _keys:Array<Int> = [];
	private var _viewMatrix = new Matrix();
	private var _attachedElement:Dynamic;

	private var _onMouseDown:Dynamic;
	private var _onMouseUp:Dynamic;
	private var _onMouseMove:Dynamic;
	private var _wheel:Dynamic;
	private var _onKeyDown:Dynamic;
	private var _onKeyUp:Dynamic;
	private var _onLostFocus:Void->Void;
	private var _reset:Void->Void;

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
	
	private var _mouseButtonPressed:Int = 0;

	// Pinch
	// value for pinch step scaling
	// set to 20 by default
	public var pinchPrecision:Float = 20;
	// Event for pinch
	private var _touchStart:Dynamic->Void;
	private var _touchMove:Dynamic->Void;
	private var _touchEnd:Dynamic->Void;
	// Method for pinch
	private var _pinchStart:Dynamic->Void;
	private var _pinchMove:Dynamic->Void;
	private var _pinchEnd:Dynamic->Void;
	
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
	override public function attachControl(?element:Dynamic, ?noPreventDefault:Bool) {
		var previousPosition:Dynamic = null;
		var pointerId:Int = -1;
		
		if (this._attachedElement != null) {
			return;
		}
		this._attachedElement = element;
		
		var engine = this.getEngine();
		
		if (this._onMouseDown == null) {
			this._onMouseDown = function(x:Float, y:Float, button:Int) {
				_mouseButtonPressed = button;
				previousPosition = {
					x: x,
					y: y
				};
			};
			
			this._onMouseUp = function(x:Float, y:Float, button:Int) {
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
				
				if(_mouseButtonPressed != 2) {
					this.inertialAlphaOffset -= offsetX / this.angularSensibility;
					this.inertialBetaOffset -= offsetY / this.angularSensibility;					
				} 
				else {
					this.target.x += offsetX / 10;
					this.target.y += offsetY / 10;
				}
				
				previousPosition = {
					x: x, 
					y: y
                };
			};
			
			this._wheel = function(delta:Float) {
				var _delta = delta / wheelPrecision;
				
                this.inertialRadiusOffset += _delta;
			};
			
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
				pointerId = 0;
			};
			
			this._reset = function() {
				this._keys = [];
				this.inertialAlphaOffset = 0;
				this.inertialBetaOffset = 0;
				this.inertialRadiusOffset = 0;
				previousPosition = null;
				pointerId = 0;
			};
			
		}
		
		Engine.keyDown.push(_onKeyDown);
		Engine.keyUp.push(_onKeyUp);
		Engine.mouseDown.push(_onMouseDown);
		Engine.mouseUp.push(_onMouseUp);
		Engine.mouseMove.push(_onMouseMove);
		Engine.mouseWheel.push(_wheel);	
	}
	
	override public function detachControl(?element:Dynamic) {
		if (this._attachedElement != element) {
			return;
		}
		
		Engine.keyDown.remove(_onKeyDown);
		Engine.keyUp.remove(_onKeyUp);
		Engine.mouseDown.remove(_onMouseDown);
		Engine.mouseUp.remove(_onMouseUp);
		Engine.mouseMove.remove(_onMouseMove);
		Engine.mouseWheel.remove(_wheel);
				
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

	override public function _getViewMatrix():Matrix {
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

	public function zoomOn(?meshes:Array<AbstractMesh>) {
		meshes = meshes != null ? meshes : this.getScene().meshes;
		
		var minMaxVector = Mesh.MinMax(meshes);
		var distance = Vector3.Distance(minMaxVector.minimum, minMaxVector.maximum);
		
		this.radius = distance * this.zoomOnFactor;
		
		this.focusOn({ min: minMaxVector.minimum, max: minMaxVector.maximum, distance: distance });
	}

	public function focusOn(meshesOrMinMaxVectorAndDistance:Dynamic) {
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
		
		this.maxZ = distance * 2;
	}
	
}
