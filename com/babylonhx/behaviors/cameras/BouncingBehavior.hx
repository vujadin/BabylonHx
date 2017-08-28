package com.babylonhx.behaviors.cameras;

import com.babylonhx.animations.easing.BackEase;
import com.babylonhx.animations.easing.EasingFunction;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.tools.Observer;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Add a bouncing effect to an ArcRotateCamera when reaching a specified minimum and maximum radius
 */
class BouncingBehavior implements Behavior<ArcRotateCamera> {

	public var name(get, never):String;
	inline private function get_name():String {
		return "Bouncing";
	}        

	/**
	 * The easing function to use when the camera bounces
	 */
	public var bounceEasingFunction:BackEase = new BackEase(0.3);

	/**
	 * The easing mode to use when the camera bounces
	 */
	public var bounceEasingMode:Int = EasingFunction.EASINGMODE_EASEOUT;   
	
	/**
	 * The duration of the animation, in milliseconds
	 */
	public var transitionDuration:Float = 450;

	/**
	 * Length of the distance animated by the transition when lower radius is reached
	 */
	public var lowerRadiusTransitionRange:Float = 2;     
	
	/**
	 * Length of the distance animated by the transition when upper radius is reached
	 */
	public var upperRadiusTransitionRange:Float = -2;
	
	private var _autoTransitionRange:Bool = false;
	public var autoTransitionRange(get, set):Bool;
	/**
	 * Gets a value indicating if the lowerRadiusTransitionRange and upperRadiusTransitionRange are defined automatically
	 */
	inline private function get_autoTransitionRange():Bool {
		return this._autoTransitionRange;
	}
	/**
	 * Sets a value indicating if the lowerRadiusTransitionRange and upperRadiusTransitionRange are defined automatically
	 * Transition ranges will be set to 5% of the bounding box diagonal in world space
	 */
	private function set_autoTransitionRange(value:Bool):Bool {
		if (this._autoTransitionRange == value) {
			return value;
		}
		
		this._autoTransitionRange = value;
		
		var camera = this._attachedCamera;
		
		if (value) {
			this._onMeshTargetChangedObserver = camera.onMeshTargetChangedObservable.add(function(mesh:AbstractMesh, _) {
				if (mesh == null) {
					return;
				}
				
				mesh.computeWorldMatrix(true);
				var diagonal = mesh.getBoundingInfo().diagonalLength;
				
				this.lowerRadiusTransitionRange = diagonal * 0.05;
				this.upperRadiusTransitionRange = diagonal * 0.05;
			});
		} 
		else if (this._onMeshTargetChangedObserver != null) {
			camera.onMeshTargetChangedObservable.remove(this._onMeshTargetChangedObserver);
			if (this._onMeshTargetChangedObserver != null) {
 				camera.onMeshTargetChangedObservable.remove(this._onMeshTargetChangedObserver);
			}
		}
		
		return value;
	}

	
	// Connection
	private var _attachedCamera:ArcRotateCamera;
	private var _onAfterCheckInputsObserver:Observer<Camera>;
	private var _onMeshTargetChangedObserver:Observer<AbstractMesh>;
	public function attach(camera:ArcRotateCamera) {
		this._attachedCamera = camera;
		this._onAfterCheckInputsObserver = camera.onAfterCheckInputsObservable.add(function(_, _) {
			// Add the bounce animation to the lower radius limit
			if (this._isRadiusAtLimit(this._attachedCamera.lowerRadiusLimit)) {
				this._applyBoundRadiusAnimation(this.lowerRadiusTransitionRange);
			}
			
			// Add the bounce animation to the upper radius limit
			if (this._isRadiusAtLimit(this._attachedCamera.upperRadiusLimit)) {
				this._applyBoundRadiusAnimation(this.upperRadiusTransitionRange);
			}
		});
	}
	
	public function detach() {
		this._attachedCamera.onAfterCheckInputsObservable.remove(this._onAfterCheckInputsObserver);
		if (this._onMeshTargetChangedObserver != null) {
			this._attachedCamera.onMeshTargetChangedObservable.remove(this._onMeshTargetChangedObserver);
		}
		this._attachedCamera = null;
	}

	// Animations
	private var _radiusIsAnimating:Bool = false;
	private var _radiusBounceTransition:Animation = null;
	private var _animatables:Array<Animatable> = [];
	private var _cachedWheelPrecision:Float;
	
	
	public function new() {
		
	}

	/**
	 * Checks if the camera radius is at the specified limit. Takes into account animation locks.
	 * @param radiusLimit The limit to check against.
	 * @return Bool to indicate if at limit.
	 */
	private function _isRadiusAtLimit(radiusLimit:Float):Bool {
		if (this._attachedCamera.radius == radiusLimit && !this._radiusIsAnimating) {
			return true;
		}
		return false;
	}     
	
	/**
	 * Applies an animation to the radius of the camera, extending by the radiusDelta.
	 * @param radiusDelta The delta by which to animate to. Can be negative.
	 */
	private function _applyBoundRadiusAnimation(radiusDelta:Float) {
		if (this._radiusBounceTransition == null) {
			this.bounceEasingFunction.setEasingMode(this.bounceEasingMode);
			this._radiusBounceTransition = Animation.CreateAnimation("radius", Animation.ANIMATIONTYPE_FLOAT, 60, this.bounceEasingFunction);
		}
		// Prevent zoom until bounce has completed
		this._cachedWheelPrecision = this._attachedCamera.wheelPrecision;
		this._attachedCamera.wheelPrecision = Math.POSITIVE_INFINITY;
		this._attachedCamera.inertialRadiusOffset = 0;
		
		// Animate to the radius limit
		this.stopAllAnimations();
		this._radiusIsAnimating = true;
		this._animatables.push(Animation.TransitionTo("radius", this._attachedCamera.radius + radiusDelta, this._attachedCamera, this._attachedCamera.getScene(), 60, this._radiusBounceTransition, this.transitionDuration, function() { this._clearAnimationLocks(); } ));
	}

	/**
	 * Removes all animation locks. Allows new animations to be added to any of the camera properties.
	 */
	private function _clearAnimationLocks() {
		this._radiusIsAnimating = false;
		this._attachedCamera.wheelPrecision = this._cachedWheelPrecision;
	}        
	
	/**
	 * Stops and removes all animations that have been applied to the camera
	 */        
	public function stopAllAnimations() {
		this._attachedCamera.animations = [];
		while (this._animatables.length > 0) {
			this._animatables[0].onAnimationEnd = null;
			this._animatables[0].stop();
			this._animatables.shift();
		}
	}
	
}
