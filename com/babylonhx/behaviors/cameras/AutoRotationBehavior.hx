package com.babylonhx.behaviors.cameras;

import com.babylonhx.animations.easing.BackEase;
import com.babylonhx.animations.easing.EasingFunction;
import com.babylonhx.events.PointerInfoPre;
import com.babylonhx.events.PointerEventTypes;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class AutoRotationBehavior implements Behavior<ArcRotateCamera> {
	
	public var name(get, never):String;
	inline private function get_name():String {
		return "AutoRotation";
	}

	private var _zoomStopsAnimation:Bool = false;
	private var _idleRotationSpeed:Float = 0.05;
	private var _idleRotationWaitTime:Float = 2000;
	private var _idleRotationSpinupTime:Float = 2000;  

	public var zoomStopsAnimation(get, set):Bool;
	/**
	* Sets the flag that indicates if user zooming should stop model animation.
	*/
	inline private function set_zoomStopsAnimation(flag:Bool):Bool {
		return this._zoomStopsAnimation = flag;
	}
	/**
	* Gets the flag that indicates if user zooming should stop model animation.
	*/
	inline private function get_zoomStopsAnimation():Bool {
		return this._zoomStopsAnimation;
	}       
	
	public var idleRotationSpeed(get, set):Float;
	/**
	* Sets the default speed at which the camera rotates around the model.
	*/
	inline private function set_idleRotationSpeed(speed:Float):Float {
		return this._idleRotationSpeed = speed;
	}
	/**
	* Gets the default speed at which the camera rotates around the model.
	*/
	inline private function get_idleRotationSpeed():Float {
		return this._idleRotationSpeed;
	}

	public var idleRotationWaitTime(get, set):Float;
	/**
	* Sets the time (in milliseconds) to wait after user interaction before the camera starts rotating.
	*/
	inline private function set_idleRotationWaitTime(time:Float):Float {
		return this._idleRotationWaitTime = time;
	}
	/**
	* Gets the time (milliseconds) to wait after user interaction before the camera starts rotating.
	*/
	inline private function get_idleRotationWaitTime():Float {
		return this._idleRotationWaitTime;
	}

	public var idleRotationSpinupTime(get, set):Float;
	/**
	* Sets the time (milliseconds) to take to spin up to the full idle rotation speed.
	*/
	inline private function set_idleRotationSpinupTime(time:Float):Float {
		return this._idleRotationSpinupTime = time;
	}
	/**
	* Gets the time (milliseconds) to take to spin up to the full idle rotation speed.
	*/
	inline private function get_idleRotationSpinupTime():Float {
		return this._idleRotationSpinupTime;
	}
	
	/**
	 * Gets a value indicating if the camera is currently rotating because of this behavior
	 */
	public var rotationInProgress(get, never):Bool;
	private inline function get_rotationInProgress():Bool {
		return Math.abs(this._cameraRotationSpeed) > 0;
	}
	
	// Default behavior functions
	private var _onPrePointerObservableObserver:Observer<PointerInfoPre>;
	private var _onAfterCheckInputsObserver:Observer<Camera>;
	private var _attachedCamera:ArcRotateCamera;
	private var _isPointerDown:Bool = false;
	private var _lastFrameTime:Float = 0;
	private var _lastInteractionTime:Float = Math.NEGATIVE_INFINITY;
	private var _cameraRotationSpeed:Float = 0;
	

	public function new() {
		
	}

	public function attach(camera:ArcRotateCamera) {
		this._attachedCamera = camera;
		var scene = this._attachedCamera.getScene();
		
		this._onPrePointerObservableObserver = scene.onPrePointerObservable.add(function(pointerInfoPre:PointerInfoPre, _) {
			if (pointerInfoPre.type == PointerEventTypes.POINTERDOWN) {
				this._isPointerDown = true;
				return;
			}
			
			if (pointerInfoPre.type == PointerEventTypes.POINTERUP) {
				this._isPointerDown = false;
			}
		});
		
		this._onAfterCheckInputsObserver = camera.onAfterCheckInputsObservable.add(function(_, _) {      
			var now = Tools.Now();
			var dt:Float = 16;
			dt =  now - this._lastFrameTime;
			this._lastFrameTime = now;
			
			// Stop the animation if there is user interaction and the animation should stop for this interaction
			this._applyUserInteraction();
			
			var timeToRotation = now - this._lastInteractionTime - this._idleRotationWaitTime;
			var scale = Math.max(Math.min(timeToRotation / (this._idleRotationSpinupTime), 1), 0);
			this._cameraRotationSpeed = this._idleRotationSpeed * scale;
			
			// Step camera rotation by rotation speed
			this._attachedCamera.alpha -= this._cameraRotationSpeed * (dt / 1000);
		});
	}
	
	public function detach() {
		var scene = this._attachedCamera.getScene();
		
		scene.onPrePointerObservable.remove(this._onPrePointerObservableObserver);
		this._attachedCamera.onAfterCheckInputsObservable.remove(this._onAfterCheckInputsObserver);
		this._attachedCamera = null;
	}

	/**
	 * Returns true if user is scrolling. 
	 * @return true if user is scrolling.
	 */
	private function _userIsZooming():Bool {
		return this._attachedCamera.inertialRadiusOffset != 0;
	}   		
	
	private var _lastFrameRadius:Float = 0;
	private function _shouldAnimationStopForInteraction():Bool {
		var zoomHasHitLimit = false;
		if (this._lastFrameRadius == this._attachedCamera.radius && this._attachedCamera.inertialRadiusOffset != 0) {
			zoomHasHitLimit = true;
		}
		
		// Update the record of previous radius - works as an approx. indicator of hitting radius limits
		this._lastFrameRadius = this._attachedCamera.radius;
		return this._zoomStopsAnimation ? zoomHasHitLimit : this._userIsZooming();
	}   		

	/**
	 *  Applies any current user interaction to the camera. Takes into account maximum alpha rotation.
	 */          
	private function _applyUserInteraction() {
		if (this._userIsMoving() && !this._shouldAnimationStopForInteraction()) {
			this._lastInteractionTime = Tools.Now();
		}
	}                

	// Tools
	private function _userIsMoving():Bool {
		return this._attachedCamera.inertialAlphaOffset != 0 ||
			this._attachedCamera.inertialBetaOffset != 0 ||
			this._attachedCamera.inertialRadiusOffset != 0 ||
			this._attachedCamera.inertialPanningX != 0 ||
			this._attachedCamera.inertialPanningY != 0 ||
			this._isPointerDown;
	}
	
}
