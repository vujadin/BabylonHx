package com.babylonhx.behaviors.cameras;

import com.babylonhx.animations.easing.BackEase;
import com.babylonhx.animations.easing.EasingFunction;
import com.babylonhx.animations.Animatable;
import com.babylonhx.animations.Animation;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.Tools;
import com.babylonhx.animations.easing.ExponentialEase;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Quaternion;

/**
 * ...
 * @author Krtolica Vujadin
 */
class FramingBehavior implements Behavior<ArcRotateCamera> {
	
	// Statics

	/**
	 * The camera can move all the way towards the mesh.
	 */
	public static var IgnoreBoundsSizeMode:Int = 0;

	/**
	 * The camera is not allowed to zoom closer to the mesh than the point at which the adjusted bounding sphere touches the frustum sides
	 */
	public static var FitFrustumSidesMode:Int = 1;
	
	
	public var name(get, never):String;
	inline private function get_name():String {
		return "Framing";
	}

	private var _mode:Int = FramingBehavior.IgnoreBoundsSizeMode;
	private var _radiusScale:Float = 1.0;
	private var _positionY:Float = 0;
	private var _defaultElevation:Float = 0.3;
	private var _elevationReturnTime:Float = 1500;
	private var _elevationReturnWaitTime:Float = 1000;
	private var _zoomStopsAnimation:Bool = false;
	private var _framingTime:Float = 1500;
	
	/**
	 * The easing function used by animations
	 */
	public static var _EasingFunction:ExponentialEase = new ExponentialEase();
	
	/**
	 * The easing mode used by animations
	 */
	public static var EasingMode:Int = EasingFunction.EASINGMODE_EASEINOUT;
	

	public var mode(get, set):Int;
	/**
	 * Sets the current mode used by the behavior
	 */
	inline private function set_mode(mode:Int):Int {
		return this._mode = mode;
	}
	/**
	 * Gets current mode used by the behavior.
	 */
	inline private function get_mode():Int {
		return this._mode;
	}
	
	public var radiusScale(get, set):Float;
	/**
	 * Sets the radius of the camera relative to the target's bounding box.
	 */
	inline private function set_radiusScale(radius:Float):Float {
		return this._radiusScale = radius;
	}
	/**
	 * Gets the radius of the camera relative to the target's bounding box.
	 */
	inline private function get_radiusScale():Float {
		return this._radiusScale;
	}

	public var positionY(get, set):Float;
	/**
	 * Sets the Y offset of the target mesh from the camera's focus.
	 */
	inline private function set_positionY(positionY:Float):Float {
		return this._positionY = positionY;
	}
	/**
	 * Sets the flag that indicates if user zooming should stop animation.
	 */
	inline private function get_positionY():Float {
		return this._positionY;
	}

	public var defaultElevation(get, set):Float;
	/**
	* Sets the angle above/below the horizontal plane to return to when the return to default elevation idle
	* behaviour is triggered, in radians.
	*/
	inline private function set_defaultElevation(elevation:Float):Float {
		return this._defaultElevation = elevation;
	}
	/**
	* Gets the angle above/below the horizontal plane to return to when the return to default elevation idle
	* behaviour is triggered, in radians.
	*/
	inline private function get_defaultElevation():Float {
		return this._defaultElevation;
	}

	public var elevationReturnTime(get, set):Float;
	/**
	 * Sets the time (in milliseconds) taken to return to the default beta position.
	 * Negative value indicates camera should not return to default.
	 */
	inline private function set_elevationReturnTime(speed:Float):Float {
		return this._elevationReturnTime = speed;
	}
	/**
	 * Gets the time (in milliseconds) taken to return to the default beta position.
	 * Negative value indicates camera should not return to default.
	 */
	inline private function get_elevationReturnTime():Float {
		return this._elevationReturnTime;
	}

	public var elevationReturnWaitTime(get, set):Float;
	/**
	 * Sets the delay (in milliseconds) taken before the camera returns to the default beta position.
	 */
	inline private function set_elevationReturnWaitTime(time:Float):Float {
		return this._elevationReturnWaitTime = time;
	}
	/**
	 * Gets the delay (in milliseconds) taken before the camera returns to the default beta position.
	 */
	inline private function get_elevationReturnWaitTime():Float {
		return this._elevationReturnWaitTime;
	}

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
	
	public var framingTime(get, set):Float;
	/**
	 * Sets the transition time when framing the model, in milliseconds
	*/
	inline private function set_framingTime(time:Float):Float {
		return this._framingTime = time;
	}
	/**
	 * Gets the transition time when framing the model, in milliseconds
	*/
	inline private function get_framingTime():Float {
		return this._framingTime;
	}        
	
	// Default behavior functions
	private var _onPrePointerObservableObserver:Observer<PointerInfoPre>;
	private var _onAfterCheckInputsObserver:Observer<Camera>;
	private var _onMeshTargetChangedObserver:Observer<AbstractMesh>;
	private var _attachedCamera:ArcRotateCamera;
	private var _isPointerDown:Bool = false;
	private var _lastInteractionTime:Float = Math.NEGATIVE_INFINITY;

	public function attach(camera:ArcRotateCamera) {
		this._attachedCamera = camera;
		var scene = this._attachedCamera.getScene();
		
		FramingBehavior._EasingFunction.setEasingMode(FramingBehavior.EasingMode);
		
		this._onPrePointerObservableObserver = scene.onPrePointerObservable.add(function(pointerInfoPre:PointerInfoPre, _) {
			if (pointerInfoPre.type == PointerEventTypes.POINTERDOWN) {
				this._isPointerDown = true;
				return;
			}
			
			if (pointerInfoPre.type == PointerEventTypes.POINTERUP) {
				this._isPointerDown = false;
			}
		});
		
		this._onMeshTargetChangedObserver = camera.onMeshTargetChangedObservable.add(function(mesh:AbstractMesh, _) {
			if (mesh != null) {
				this.zoomOnMesh(mesh);
			}
		});
		
		this._onAfterCheckInputsObserver = camera.onAfterCheckInputsObservable.add(function(_, _) {      
			// Stop the animation if there is user interaction and the animation should stop for this interaction
			this._applyUserInteraction();
			
			// Maintain the camera above the ground. If the user pulls the camera beneath the ground plane, lift it
			// back to the default position after a given timeout
			this._maintainCameraAboveGround();                
		});
	}
	
	public function detach(camera: ArcRotateCamera) {
		var scene = this._attachedCamera.getScene();
		
		scene.onPrePointerObservable.remove(this._onPrePointerObservableObserver);
		camera.onAfterCheckInputsObservable.remove(this._onAfterCheckInputsObserver);
		camera.onMeshTargetChangedObservable.remove(this._onMeshTargetChangedObserver);
	}

	// Framing control
	private var _animatables:Array<Animatable> = [];
	private var _betaIsAnimating:Bool = false;
	private var _betaTransition:Animation;
	private var _radiusTransition:Animation;
	private var _vectorTransition:Animation;
	private var _lastFrameRadius:Float = 0;
	
	
	public function new() { }
	
	/**
	 * Targets the given mesh and updates zoom level accordingly.
	 * @param mesh  The mesh to target.
	 * @param radius Optional. If a cached radius position already exists, overrides default.
	 * @param applyToLowerLimit Optional. Indicates if the calculated target radius should be applied to the
	 *		camera's lower radius limit too.
	 * @param framingPositionY Position on mesh to center camera focus where 0 corresponds bottom of its bounding box and 1, the top
	 * @param focusOnOriginXZ Determines if the camera should focus on 0 in the X and Z axis instead of the mesh
	 */
	public function zoomOnMesh(mesh:AbstractMesh, radius:Float = null, applyToLowerLimit:Bool = false, framingPositionY:Float = null, focusOnOriginXZ:Bool = true) {
		if (framingPositionY == null) {
			framingPositionY = this._positionY;
		}
		
		// sets the radius and lower radius bounds
		mesh.computeWorldMatrix(true);
		if (radius == null) {
			// Small delta ensures camera is not always at lower zoom limit.
			var delta = 0.1;
			if (this._mode == FramingBehavior.FitFrustumSidesMode) {
				var position = this._calculateLowerRadiusFromModelBoundingSphere(mesh);
				this._attachedCamera.lowerRadiusLimit = position - delta;
				radius = position;
			} 
			else if (this._mode == FramingBehavior.IgnoreBoundsSizeMode) {
				radius = this._calculateLowerRadiusFromModelBoundingSphere(mesh);
			}
		}
		
		var zoomTarget:Vector3 = null;
		var zoomTargetY:Float = 0;
		
		var modelWorldPosition = new Vector3(0, 0, 0);
		var modelWorldScale = new Vector3(0, 0, 0);
		
		mesh.getWorldMatrix().decompose(modelWorldScale, new Quaternion(), modelWorldPosition);
		
		//find target by interpolating from bottom of bounding box in world-space to top via framingPositionY
		var bottom = modelWorldPosition.y + mesh.getBoundingInfo().minimum.y;
		var top = modelWorldPosition.y + mesh.getBoundingInfo().maximum.y;
		zoomTargetY = bottom + (top - bottom) * framingPositionY;
		
		if (applyToLowerLimit) {
			this._attachedCamera.lowerRadiusLimit = radius;
		}
		
		if (focusOnOriginXZ) {	
			zoomTarget = new Vector3(0, zoomTargetY, 0);
		} 
		else {
			zoomTarget = new Vector3(modelWorldPosition.x, zoomTargetY, modelWorldPosition.z);
		}
		
		if (this._vectorTransition == null) {
			this._vectorTransition = Animation.CreateAnimation("target", Animation.ANIMATIONTYPE_VECTOR3, 60, FramingBehavior._EasingFunction);
		}
		
		this._animatables.push(Animation.TransitionTo("target", zoomTarget, this._attachedCamera, this._attachedCamera.getScene(), 
								60, this._vectorTransition, this._framingTime));
			
		// transition to new radius
		if (this._radiusTransition == null) {
			this._radiusTransition = Animation.CreateAnimation("radius", Animation.ANIMATIONTYPE_FLOAT, 60, FramingBehavior._EasingFunction);
		}
		
		this._animatables.push(Animation.TransitionTo("radius", radius, this._attachedCamera, this._attachedCamera.getScene(), 
								60, this._radiusTransition, this._framingTime));
	}	
	
	/**
	 * Calculates the lowest radius for the camera based on the bounding box of the mesh.
	 * @param mesh The mesh on which to base the calculation. mesh boundingInfo used to estimate necessary
	 *			  frustum width.
	 * @param framingRadius An additional factor to add to the return camera radius.
	 * @return The minimum distance from the primary mesh's center point at which the camera must be kept in order
	 *		 to fully enclose the mesh in the viewing frustum.
	 */
	private function _calculateLowerRadiusFromModelBoundingSphere(mesh:AbstractMesh):Float {
		var boxVectorGlobalDiagonal = mesh.getBoundingInfo().diagonalLength;
		var frustumSlope:Vector2 = this._getFrustumSlope();
		
		// Formula for setting distance
		// (Good explanation: http://stackoverflow.com/questions/2866350/move-camera-to-fit-3d-scene)
		var radiusWithoutFraming = boxVectorGlobalDiagonal * 0.5;
		
		// Horizon distance
		var radius = radiusWithoutFraming * this._radiusScale;
		var distanceForHorizontalFrustum = radius * Math.sqrt(1.0 + 1.0 / (frustumSlope.x * frustumSlope.x));
		var distanceForVerticalFrustum = radius * Math.sqrt(1.0 + 1.0 / (frustumSlope.y * frustumSlope.y));
		var distance = Math.max(distanceForHorizontalFrustum, distanceForVerticalFrustum);
		var camera = this._attachedCamera;
		
		if (camera.lowerRadiusLimit != null && this._mode == FramingBehavior.IgnoreBoundsSizeMode) {
			// Don't exceed the requested limit
			distance = distance < camera.lowerRadiusLimit ? camera.lowerRadiusLimit : distance;
		}
		
		// Don't exceed the upper radius limit
		if (camera.upperRadiusLimit != null) {
			distance = distance > camera.upperRadiusLimit ? camera.upperRadiusLimit : distance;
		}
		
		return distance;
	}		

	/**
	 * Keeps the camera above the ground plane. If the user pulls the camera below the ground plane, the camera
	 * is automatically returned to its default position (expected to be above ground plane). 
	 */
	private function _maintainCameraAboveGround() {
		var timeSinceInteraction = Tools.Now() - this._lastInteractionTime;
		var defaultBeta = Math.PI * 0.5 - this._defaultElevation;
		var limitBeta = Math.PI * 0.5;
		
		// Bring the camera back up if below the ground plane
		if (!this._betaIsAnimating && this._attachedCamera.beta > limitBeta && timeSinceInteraction >= this._elevationReturnWaitTime) {
			this._betaIsAnimating = true;
			
			//Transition to new position
			this.stopAllAnimations();
			
			if (this._betaTransition == null) {
				this._betaTransition = Animation.CreateAnimation("beta", Animation.ANIMATIONTYPE_FLOAT, 60, FramingBehavior._EasingFunction);
			}
			
			this._animatables.push(Animation.TransitionTo("beta", defaultBeta, this._attachedCamera, this._attachedCamera.getScene(), 60,
				this._betaTransition, this._elevationReturnTime, 
				function() {
					this._clearAnimationLocks();
					this.stopAllAnimations();
				}));
		}
	}        

	/**
	 * Returns the frustum slope based on the canvas ratio and camera FOV
	 * @returns The frustum slope represented as a Vector2 with X and Y slopes
	 */
	private function _getFrustumSlope():Vector2 {
		// Calculate the viewport ratio
		// Aspect Ratio is Height/Width.
		var camera = this._attachedCamera;
		var engine = camera.getScene().getEngine();
		var aspectRatio = engine.getAspectRatio(camera);
		
		// Camera FOV is the vertical field of view (top-bottom) in radians.
		// Slope of the frustum top/bottom planes in view space, relative to the forward vector.
		var frustumSlopeY = Math.tan(camera.fov / 2);
		
		// Slope of the frustum left/right planes in view space, relative to the forward vector.
		// Provides the amount that one side (e.g. left) of the frustum gets wider for every unit
		// along the forward vector.
		var frustumSlopeX = frustumSlopeY / aspectRatio;
		
		return new Vector2(frustumSlopeX, frustumSlopeY);
	}		

	/**
	 * Removes all animation locks. Allows new animations to be added to any of the arcCamera properties.
	 */
	private function _clearAnimationLocks() {
		this._betaIsAnimating = false;
	}

	/**
	 *  Applies any current user interaction to the camera. Takes into account maximum alpha rotation.
	 */          
	private function _applyUserInteraction() {
		if (this._userIsMoving()) {
			this._lastInteractionTime = Tools.Now();
			this.stopAllAnimations();				
			this._clearAnimationLocks();
		}
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
