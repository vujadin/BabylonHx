package com.gamestudiohx.babylonhx.cameras;

import com.gamestudiohx.babylonhx.collisions.Collider;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.mesh.Mesh;
import com.gamestudiohx.babylonhx.Scene;
import com.gamestudiohx.babylonhx.tools.math.Vector2;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.tools.Tools;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.Lib;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class FreeCamera extends Camera {
	
	public var cameraDirection:Vector3;
	public var cameraRotation:Vector2;
	public var rotation:Vector3;
	public var ellipsoid:Vector3;
		
	public var _attachedCanvas:DisplayObject;
	
	public var _keys:Array<Int>;
	public var keysUp:Array<Int>;
	public var keysDown:Array<Int>;
	public var keysLeft:Array<Int>;
	public var keysRight:Array<Int>;
	
	public var _collider:Collider;
	public var _needMoveForGravity:Bool;
	
	public var _currentTarget:Vector3;
	public var _viewMatrix:Matrix;
	public var _camMatrix:Matrix;
	public var _cameraTransformMatrix:Matrix;
	public var _cameraRotationMatrix:Matrix;
	public var _referencePoint:Vector3;
	public var _transformedReferencePoint:Vector3;
	public var _oldPosition:Vector3;
	public var _diffPosition:Vector3;
	public var _newPosition:Vector3;
	public var _lookAtTemp:Matrix;
	public var _tempMatrix:Matrix;
	
	public var _localDirection:Vector3;
	public var _transformedDirection:Vector3;
	
	public var speed:Float = 2.0;
    public var checkCollisions:Bool = false;
    public var applyGravity:Bool = false;
    public var noRotationConstraint:Bool = false;
    public var angularSensibility:Float = 2000.0;
    public var lockedTarget:Dynamic = null;
    public var onCollide:Mesh->Void = null;
	
	public var _onMouseDown:MouseEvent->Void;
	public var _onMouseUp:MouseEvent->Void;
	public var _onMouseOut:MouseEvent->Void;
	public var _onMouseMove:MouseEvent->Void;
	
	public var _onKeyDown:KeyboardEvent->Void;
	public var _onKeyUp:KeyboardEvent->Void;
	public var _onLostFocus:Void->Void;
	public var _reset:Void->Void;
	
	public var _waitingParentId:String;
	public var _waitingLockedTargetId:String;
	
	

	public function new(name:String, position:Vector3, scene:Scene) {
		super(name, position, scene);
				
		this.cameraDirection = new Vector3(0, 0, 0);
        this.cameraRotation = new Vector2(0, 0);
        this.rotation = new Vector3(0, 0, 0);
        this.ellipsoid = new Vector3(0.5, 1, 0.5);

        this._keys = [];
        this.keysUp = [38];
        this.keysDown = [40];
        this.keysLeft = [37];
        this.keysRight = [39];

        // Collisions
        this._collider = new Collider();
        this._needMoveForGravity = true;

        // Internals
        this._currentTarget = Vector3.Zero();
        this._viewMatrix = Matrix.Zero();
        this._camMatrix = Matrix.Zero();
        this._cameraTransformMatrix = Matrix.Zero();
        this._cameraRotationMatrix = Matrix.Zero();
        this._referencePoint = Vector3.Zero();
        this._transformedReferencePoint = Vector3.Zero();
        this._oldPosition = Vector3.Zero();
        this._diffPosition = Vector3.Zero();
        this._newPosition = Vector3.Zero();
        this._lookAtTemp = Matrix.Zero();
        this._tempMatrix = Matrix.Zero();
		
		this._cache = { 
			parent: null,
			lockedTarget: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),
			rotation: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),
			position: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),
			upVector: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),

			mode: null,
			minZ: null,
			maxZ: null,

			fov: null,
			aspectRatio: null,

			orthoLeft: null,
			orthoRight: null,
			orthoBottom: null,
			orthoTop: null,
			renderWidth: null,
			renderHeight: null
		}
	}
	
	public function _getLockedTargetPosition():Vector3 {
		var ret:Vector3 = null;
        if (this.lockedTarget != null) {
            ret = Std.is(this.lockedTarget, Vector3) ? this.lockedTarget : this.lockedTarget.position;
        }
        return ret;
    }
	
	override public function _updateCache(ignoreParentClass:Bool = true) {
        if (!ignoreParentClass)
            super._updateCache(ignoreParentClass);

        var lockedTargetPosition = this._getLockedTargetPosition();
        if (lockedTargetPosition == null) {
            this._cache.lockedTarget = null;
        }
        else {
            if (this._cache.lockedTarget == null)
                this._cache.lockedTarget = lockedTargetPosition.clone();
            else
                this._cache.lockedTarget.copyFrom(lockedTargetPosition);
        }

        this._cache.rotation.copyFrom(this.rotation);
    }
	
	override public function _isSynchronizedViewMatrix():Bool {
        if (!super._isSynchronizedViewMatrix()) {
            return false;
        }

        var lockedTargetPosition:Vector3 = this._getLockedTargetPosition();
		var _t:Bool = lockedTargetPosition != null;

        return (this._cache.lockedTarget != null ? this._cache.lockedTarget.equals(lockedTargetPosition) : !_t)
            && this._cache.rotation.equals(this.rotation);
    }
	
	inline public function _computeLocalCameraSpeed():Float {
		return this.speed * (Tools.GetDeltaTime() / (Tools.GetFps() * 10.0));
    }
	
	public function setTarget(target:Vector3) {
        this.upVector.normalize();
        
        Matrix.LookAtLHToRef(this.position, target, this.upVector, this._camMatrix);
        this._camMatrix.invert();

        this.rotation.x = Math.atan(this._camMatrix.m[6] / this._camMatrix.m[10]);

        var vDir:Vector3 = target.subtract(this.position);

        if (vDir.x >= 0.0) {
            this.rotation.y = (-Math.atan(vDir.z / vDir.x) + Math.PI / 2.0);
        } else {
            this.rotation.y = (-Math.atan(vDir.z / vDir.x) - Math.PI / 2.0);
        }

        this.rotation.z = -Math.acos(Vector3.Dot(new Vector3(0, 1.0, 0), this.upVector));

        if (Math.isNaN(this.rotation.x))
            this.rotation.x = 0;

        if (Math.isNaN(this.rotation.y))
            this.rotation.y = 0;

        if (Math.isNaN(this.rotation.z))
            this.rotation.z = 0;
    }
	
	override public function attachControl(canvas:DisplayObject, noPreventDefault:Bool = false) {
        var previousPosition:Dynamic = null;
        var engine:Engine = this._scene.getEngine();
        
        if (this._attachedCanvas != null) {
            return;
        }
        this._attachedCanvas = canvas;

        if (this._onMouseDown == null) {
            this._onMouseDown = function (evt:MouseEvent) {
                previousPosition = {
                    x: this._attachedCanvas.mouseX,
                    y: this._attachedCanvas.mouseY
                };
            };

            this._onMouseUp = function (evt:MouseEvent) {
                previousPosition = null;
            };

            this._onMouseOut = function (evt:MouseEvent) {
                previousPosition = null;
                this._keys = [];
            };

            this._onMouseMove = function (evt:MouseEvent) {
                if (previousPosition == null && !engine.isPointerLock) {
                    return;
                }

                var offsetX:Float = 0;
                var offsetY:Float = 0;

                if (!engine.isPointerLock) {
                    offsetX = this._attachedCanvas.mouseX - previousPosition.x;
                    offsetY = this._attachedCanvas.mouseY - previousPosition.y;
                } 

                this.cameraRotation.y += offsetX / this.angularSensibility;
                this.cameraRotation.x += offsetY / this.angularSensibility;

                previousPosition = {
                    x: this._attachedCanvas.mouseX,
                    y: this._attachedCanvas.mouseY
                };
            };

            this._onKeyDown = function (evt:KeyboardEvent) {
                if (Lambda.indexOf(this.keysUp, evt.keyCode) != -1 ||
                    Lambda.indexOf(this.keysDown, evt.keyCode) != -1 ||
                    Lambda.indexOf(this.keysLeft, evt.keyCode) != -1 ||
                    Lambda.indexOf(this.keysRight, evt.keyCode) != -1) {
                    var index = Lambda.indexOf(this._keys, evt.keyCode);

                    if (index == -1) {
                        this._keys.push(evt.keyCode);
                    }
                    /*if (!noPreventDefault) {
                        evt.preventDefault();
                    }*/
                }
            };

            this._onKeyUp = function (evt:KeyboardEvent) {
                if (Lambda.indexOf(this.keysUp, evt.keyCode) != -1 ||
                    Lambda.indexOf(this.keysDown, evt.keyCode) != -1 ||
                    Lambda.indexOf(this.keysLeft, evt.keyCode) != -1 ||
                    Lambda.indexOf(this.keysRight, evt.keyCode) != -1) {
                    var index = Lambda.indexOf(this._keys, evt.keyCode);

                    if (index >= 0) {
                        this._keys.splice(index, 1);
                    }
                    /*if (!noPreventDefault) {
                        evt.preventDefault();
                    }*/
                }
            };

            this._onLostFocus = function () {
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
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_OUT, this._onMouseOut, false);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, this._onMouseMove, false);
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, this._onKeyDown, false);
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, this._onKeyUp, false);
        //window.addEventListener("blur", this._onLostFocus, false);
    }
	
	override public function detachControl(canvas:DisplayObject) {
        if (this._attachedCanvas != canvas) {
            return;
        }

        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, this._onMouseDown);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, this._onMouseUp);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_OUT, this._onMouseOut);
        Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this._onMouseMove);
        Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this._onKeyDown);
        Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, this._onKeyUp);
        //window.removeEventListener("blur", this._onLostFocus);
        
        this._attachedCanvas = null;
        if (this._reset != null) {
            this._reset();
        }
    }
	
	inline public function _collideWithWorld(velocity:Vector3) {
        this.position.subtractFromFloatsToRef(0, this.ellipsoid.y, 0, this._oldPosition);
        this._collider.radius = this.ellipsoid;

        this._scene._getNewPosition(this._oldPosition, velocity, this._collider, 3, this._newPosition);
        this._newPosition.subtractToRef(this._oldPosition, this._diffPosition);

        if (this._diffPosition.length() > Engine.collisionsEpsilon) {
            this.position.addInPlace(this._diffPosition);
            if (this.onCollide != null) {
                this.onCollide(this._collider.collidedMesh);
            }
        }
    }
	
	inline public function _checkInputs() {
        if (this._localDirection == null) {
            this._localDirection = Vector3.Zero();
            this._transformedDirection = Vector3.Zero();
        }

        // Keyboard
        for (index in 0...this._keys.length) {
            var keyCode = this._keys[index];
            var speed:Float = this._computeLocalCameraSpeed();

            if (Lambda.indexOf(this.keysLeft, keyCode) != -1) {
                this._localDirection.copyFromFloats(-speed, 0, 0);
            } else if (Lambda.indexOf(this.keysUp, keyCode) != -1) {
                this._localDirection.copyFromFloats(0, 0, speed);
            } else if (Lambda.indexOf(this.keysRight, keyCode) != -1) {
                this._localDirection.copyFromFloats(speed, 0, 0);
            } else if (Lambda.indexOf(this.keysDown, keyCode) != -1) {
                this._localDirection.copyFromFloats(0, 0, -speed);
            }

            this.getViewMatrix().invertToRef(this._cameraTransformMatrix);
            Vector3.TransformNormalToRef(this._localDirection, this._cameraTransformMatrix, this._transformedDirection);
            this.cameraDirection.addInPlace(this._transformedDirection);
        }
    }
	
	override inline public function _update() {
        this._checkInputs();

        var needToMove = this._needMoveForGravity || Math.abs(this.cameraDirection.x) > 0 || Math.abs(this.cameraDirection.y) > 0 || Math.abs(this.cameraDirection.z) > 0;
        var needToRotate = Math.abs(this.cameraRotation.x) > 0 || Math.abs(this.cameraRotation.y) > 0;

        // Move
        if (needToMove) {
            if (this.checkCollisions && this._scene.collisionsEnabled) {
                this._collideWithWorld(this.cameraDirection);

                if (this.applyGravity) {
                    var oldPosition = this.position;
                    this._collideWithWorld(this._scene.gravity);
                    this._needMoveForGravity = (Vector3.DistanceSquared(oldPosition, this.position) != 0);
                }
            } else {
                this.position.addInPlace(this.cameraDirection);
            }
        }

        // Rotate
        if (needToRotate) {
            this.rotation.x += this.cameraRotation.x;
            this.rotation.y += this.cameraRotation.y;

            if (!this.noRotationConstraint) {
                var limit = (Math.PI / 2) * 0.95;

                if (this.rotation.x > limit)
                    this.rotation.x = limit;
                if (this.rotation.x < -limit)
                    this.rotation.x = -limit;
            }
        }

        // Inertia
        if (needToMove) {
            if (Math.abs(this.cameraDirection.x) < Engine.epsilon)
                this.cameraDirection.x = 0;

            if (Math.abs(this.cameraDirection.y) < Engine.epsilon)
                this.cameraDirection.y = 0;

            if (Math.abs(this.cameraDirection.z) < Engine.epsilon)
                this.cameraDirection.z = 0;

            this.cameraDirection.scaleInPlace(this.inertia);
        }
        if (needToRotate) {
            if (Math.abs(this.cameraRotation.x) < Engine.epsilon)
                this.cameraRotation.x = 0;

            if (Math.abs(this.cameraRotation.y) < Engine.epsilon)
                this.cameraRotation.y = 0;

            this.cameraRotation.scaleInPlace(this.inertia);
        }
    }
	
	override inline public function _getViewMatrix():Matrix {
        Vector3.FromFloatsToRef(0, 0, 1, this._referencePoint);

        if (this.lockedTarget == null) {
            // Compute
            if (this.upVector.x != 0 || this.upVector.y != 1.0 || this.upVector.z != 0) {
                Matrix.LookAtLHToRef(Vector3.Zero(), this._referencePoint, this.upVector, this._lookAtTemp);
                Matrix.RotationYawPitchRollToRef(this.rotation.y, this.rotation.x, this.rotation.z, this._cameraRotationMatrix);

                this._lookAtTemp.multiplyToRef(this._cameraRotationMatrix, this._tempMatrix);
                this._lookAtTemp.invert();
                this._tempMatrix.multiplyToRef(this._lookAtTemp, this._cameraRotationMatrix);
            } else {
                Matrix.RotationYawPitchRollToRef(this.rotation.y, this.rotation.x, this.rotation.z, this._cameraRotationMatrix);
            }

            Vector3.TransformCoordinatesToRef(this._referencePoint, this._cameraRotationMatrix, this._transformedReferencePoint);

            // Computing target and final matrix
            this.position.addToRef(this._transformedReferencePoint, this._currentTarget);
        } else {
            this._currentTarget.copyFrom(this._getLockedTargetPosition());
        }
        
        Matrix.LookAtLHToRef(this.position, this._currentTarget, this.upVector, this._viewMatrix);
        return this._viewMatrix;
    }
	
}