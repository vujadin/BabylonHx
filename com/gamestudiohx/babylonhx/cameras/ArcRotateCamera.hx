package com.gamestudiohx.babylonhx.cameras;

import com.gamestudiohx.babylonhx.tools.math.Vector3;
import com.gamestudiohx.babylonhx.tools.math.Matrix;
import com.gamestudiohx.babylonhx.Engine;
import com.gamestudiohx.babylonhx.Scene;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

/*typedef BabylonArcRotateCameraCache = {
	alpha: Null<Float>,
	beta: Null<Float>,
	radius: Null<Float>,
	target: Null<Dynamic>
}*/

class ArcRotateCamera extends Camera {

	public var alpha:Float;
	public var beta:Float;
	public var radius:Float;
	public var target:Vector3;

	public var _keys:Array<Int>;
	public var keysUp:Array<Int>;
	public var keysDown:Array<Int>;
	public var keysLeft:Array<Int>;
	public var keysRight:Array<Int>;
	public var _viewMatrix:Matrix;
	
	public var _attachedCanvas:DisplayObject;
	
	public var _onMouseDown:MouseEvent->Void;
	public var _onMouseUp:MouseEvent->Void;
	public var _onMouseOut:MouseEvent->Void;
	public var _onMouseMove:MouseEvent->Void;
	public var _wheel:MouseEvent->Void;
	
	public var _onKeyDown:KeyboardEvent->Void;
	public var _onKeyUp:KeyboardEvent->Void;
	public var _onLostFocus:Void->Void;
	public var _reset:Void->Void;
	

	public function new(name:String, alpha:Float, beta:Float, radius:Float, target:Vector3, scene:Scene) {
		super(name, Vector3.Zero(), scene);
		
		this.alpha = alpha;
        this.beta = beta;
        this.radius = radius;
        this.target = target;
		        
        this._keys = [];
        this.keysUp = [38];
        this.keysDown = [40];
        this.keysLeft = [37];
        this.keysRight = [39];

        this._viewMatrix = new Matrix();

        this.getViewMatrix();
		
		this._cache = {
			parent: null,
			target: new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY),
			alpha: null,
			beta: null,
			radius: null,
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
		};
	}

	public var inertialAlphaOffset:Float = 0;
	public var inertialBetaOffset:Float = 0;
	public var inertialRadiusOffset:Float = 0;
	public var lowerAlphaLimit:Null<Float> = null;
	public var upperAlphaLimit:Null<Float> = null;
	public var lowerBetaLimit:Null<Float> = 0.01;
	public var upperBetaLimit:Null<Float> = 3.141592653589; // Math.PI;
	public var lowerRadiusLimit:Null<Float> = null;
	public var upperRadiusLimit:Null<Float> = null;
	public var angularSensibility:Float = 1000.0;
	
	override public function _initCache() {
        this._cache.target = new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        this._cache.alpha = null;
        this._cache.beta = null;
        this._cache.radius = null;
    }
	
	override public function _updateCache(ignoreParentClass:Bool = true) {
        if (!ignoreParentClass)
            super._updateCache(ignoreParentClass);

        this._cache.target.copyFrom(this._getTargetPosition());
        this._cache.alpha = this.alpha;
        this._cache.beta = this.beta;
        this._cache.radius = this.radius;
    }
	
	public function _getTargetPosition():Vector3 {
        //return Std.is(this.target, Vector3) ? this.target : this.target.position;
		return this.target;
    }
	
	override public function _isSynchronizedViewMatrix():Bool {
        if (!super._isSynchronizedViewMatrix())
            return false;

        return this._cache.target.equals(this._getTargetPosition())
            && this._cache.alpha == this.alpha
            && this._cache.beta == this.beta
            && this._cache.radius == this.radius;
    }
		
	public function setPosition(position:Vector3) {
		var radiusv3 = position.subtract(Reflect.field(this.target, "position") != null ? Reflect.field(this.target, "position") : this.target);
        this.radius = radiusv3.length();

        this.alpha = Math.atan(radiusv3.z / radiusv3.x);
        this.beta = Math.acos(radiusv3.y / this.radius);
	}
	
	override public function attachControl(canvas:DisplayObject, noPreventDefault:Bool = false) {
		var previousPosition:Dynamic = null;      

        if (this._attachedCanvas != null) {
            return;
        }
        this._attachedCanvas = canvas;

        var engine:Engine = this._scene.getEngine();
		
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
				
                this.inertialAlphaOffset -= offsetX / this.angularSensibility;
                this.inertialBetaOffset -= offsetY / this.angularSensibility;

                previousPosition = {
                    x: this._attachedCanvas.mouseX,
                    y: this._attachedCanvas.mouseY
                };                
            };
			
			this._wheel = function(event:MouseEvent) {
                var delta = event.delta / 3;
                
                this.inertialRadiusOffset += delta;
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
                }
            };

            this._onLostFocus = function () {
                this._keys = [];
            };

            this._reset = function () {
                this._keys = [];
                this.inertialAlphaOffset = 0;
                this.inertialBetaOffset = 0;
                previousPosition = null;
            };
        }
		
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, this._onMouseDown, false);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, this._onMouseUp, false);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_OUT, this._onMouseOut, false);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, this._onMouseMove, false);
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, this._onKeyDown, false);
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, this._onKeyUp, false);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, this._wheel, false);
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
	
	override public function _update() {
		// Keyboard
        for (index in 0...this._keys.length) {
            var keyCode = this._keys[index];

            if (Lambda.indexOf(this.keysLeft, keyCode) != -1) {
                this.inertialAlphaOffset -= 0.01;
            } else if (Lambda.indexOf(this.keysUp, keyCode) != -1) {
                this.inertialBetaOffset -= 0.01;
            } else if (Lambda.indexOf(this.keysRight, keyCode) != -1) {
                this.inertialAlphaOffset += 0.01;
            } else if (Lambda.indexOf(this.keysDown, keyCode) != -1) {
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

            if (Math.abs(this.inertialAlphaOffset) < Engine.epsilon)
                this.inertialAlphaOffset = 0;

            if (Math.abs(this.inertialBetaOffset) < Engine.epsilon)
                this.inertialBetaOffset = 0;

            if (Math.abs(this.inertialRadiusOffset) < Engine.epsilon)
                this.inertialRadiusOffset = 0;
        }

        // Limits
        if (this.lowerAlphaLimit != null && this.alpha < this.lowerAlphaLimit) {
            this.alpha = this.lowerAlphaLimit;
        }
        if (this.upperAlphaLimit != null && this.alpha > this.upperAlphaLimit) {
            this.alpha = this.upperAlphaLimit;
        }
        if (this.lowerBetaLimit != null && this.beta < this.lowerBetaLimit) {
            this.beta = this.lowerBetaLimit;
        }
        if (this.upperBetaLimit != null && this.beta > this.upperBetaLimit) {
            this.beta = this.upperBetaLimit;
        }
        if (this.lowerRadiusLimit != null && this.radius < this.lowerRadiusLimit) {
            this.radius = this.lowerRadiusLimit;
        }
        if (this.upperRadiusLimit != null && this.radius > this.upperRadiusLimit) {
            this.radius = this.upperRadiusLimit;
        }
	}
	
	override inline public function _getViewMatrix() {        
        var cosa = Math.cos(this.alpha);
        var sina = Math.sin(this.alpha);
        var cosb = Math.cos(this.beta);
        var sinb = Math.sin(this.beta);

        var target = this._getTargetPosition();

        target.addToRef(new Vector3(this.radius * cosa * sinb, this.radius * cosb, this.radius * sina * sinb), this.position);
        Matrix.LookAtLHToRef(this.position, target, this.upVector, this._viewMatrix);

        return this._viewMatrix;
    }
	
}