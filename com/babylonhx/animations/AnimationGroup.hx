package com.babylonhx.animations;

import com.babylonhx.tools.Observable;
import com.babylonhx.engine.Engine;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Use this class to create coordinated animations on multiple targets
 */
class AnimationGroup {

	public var name:String;
	private var _scene:Scene;

	private var _targetedAnimations:Array<TargetedAnimation> = [];
	private var _animatables:Array<Animatable> = [];
	private var _from:Int = Std.int(Math.POSITIVE_INFINITY);
	private var _to:Int = Std.int(Math.NEGATIVE_INFINITY);
	private var _isStarted:Bool;
	private var _speedRatio:Float = 1;

	public var onAnimationEndObservable:Observable<TargetedAnimation> = new Observable<TargetedAnimation>();

	/*
	 * Define if the animations are started
	 */
	public var isStarted(get, never):Bool;
	inline function get_isStarted():Bool {
		return this._isStarted;
	}
	
	public var speedRatio(get, set):Float;
	/**
     * Gets or sets the speed ratio to use for all animations
     */
    inline function get_speedRatio():Float {
        return this._speedRatio;
    }
	/**
     * Gets or sets the speed ratio to use for all animations
     */
    function set_speedRatio(value:Float):Float {
        if (this._speedRatio == value) {
            return value;
        }
		
        for (index in 0...this._animatables.length) {
            var animatable = this._animatables[index];
            animatable.speedRatio = this._speedRatio;
        }
		return value;
    }
	
	/**
     * Gets the targeted animations for this animation group
     */
	public var targetedAnimations(get, never):Array<TargetedAnimation>;
    inline function get_targetedAnimations():Array<TargetedAnimation> {
        return this._targetedAnimations;
    }

	
	public function new(name:String, scene:Scene = null) {
		this._scene = scene != null ? scene : Engine.LastCreatedScene;
		
		this._scene.animationGroups.push(this);
	}

	/**
	 * Add an animation (with its target) in the group
	 * @param animation defines the animation we want to add
	 * @param target defines the target of the animation
	 * @returns the {BABYLON.TargetedAnimation} object
	 */
	public function addTargetedAnimation(animation:Animation, target:Dynamic):TargetedAnimation {
		var targetedAnimation = new TargetedAnimation(animation, target);
		
		var keys = animation.getKeys();
		if (this._from > keys[0].frame) {
			this._from = keys[0].frame;
		}
		
		if (this._to < keys[keys.length - 1].frame) {
			this._to = keys[keys.length - 1].frame;
		}
		
		this._targetedAnimations.push(targetedAnimation);
		
		return targetedAnimation;
	}

	/**
	 * This function will normalize every animation in the group to make sure they all go from beginFrame to endFrame
	 * It can add constant keys at begin or end
	 * @param beginFrame defines the new begin frame for all animations. It can't be bigger than the smaller begin frame of all animations
	 * @param endFrame defines the new end frame for all animations. It can't be smaller than the larger end frame of all animations
	 */
	public function normalize(beginFrame:Int, endFrame:Int):AnimationGroup {
		beginFrame = cast Math.min(beginFrame, this._from);
		endFrame = cast Math.min(endFrame, this._to);
		
		for (index in 0...this._targetedAnimations.length) {
			var targetedAnimation = this._targetedAnimations[index];
			var keys = targetedAnimation.animation.getKeys();
			var startKey = keys[0];
			var endKey = keys[keys.length - 1];
			
			if (startKey.frame > beginFrame) {
				var newKey:IAnimationKey = {
					frame: beginFrame,
					value: startKey.value,
					inTangent: startKey.inTangent,
					outTangent: startKey.outTangent,
					interpolation: startKey.interpolation
				};
				keys.insert(0, newKey);
			}
			
			if (endKey.frame < endFrame) {
				var newKey:IAnimationKey = {
					frame: endFrame,
					value: endKey.value,
					inTangent: startKey.outTangent,
					outTangent: startKey.outTangent,
					interpolation: startKey.interpolation
				}
				keys.push(newKey);
			}
		}
		
		return this;
	}

	/**
	 * Start all animations on given targets
	 * @param loop defines if animations must loop
	 * @param speedRatio defines the ratio to apply to animation speed (1 by default)
	 */
	public function start(loop:Bool = false, speedRatio:Float = 1):AnimationGroup {
		if (this._isStarted || this._targetedAnimations.length == 0) {
			return this;
		}
		
		for (index in 0...this._targetedAnimations.length) {
			var targetedAnimation = this._targetedAnimations[index];
			this._animatables.push(this._scene.beginDirectAnimation(targetedAnimation.target, [targetedAnimation.animation], this._from, this._to, loop, speedRatio, function() {
				this.onAnimationEndObservable.notifyObservers(targetedAnimation);
			}));
		}
		
		this._speedRatio = speedRatio;
		
		this._isStarted = true;
		
		return this;
	}

	/**
	 * Pause all animations
	 */
	public function pause():AnimationGroup {
		if (!this._isStarted) {
			return this;
		}
		
		for (index in 0...this._animatables.length) {
			var animatable = this._animatables[index];
			animatable.pause();
		}
		
		return this;
	}

	/**
	 * Play all animations to initial state
	 * This function will start() the animations if they were not started or will restart() them if they were paused
	 */
	public function play(?loop:Bool):AnimationGroup {
		if (this.isStarted) {
			if (loop != null) {
                for (index in 0...this._animatables.length) {
                    var animatable = this._animatables[index];
                    animatable.loopAnimation = loop;
                }
            }
			this.restart();
		} 
		else {
			this.start(loop);
		}
		
		return this;
	}

	/**
	 * Reset all animations to initial state
	 */
	public function reset():AnimationGroup {
		if (!this._isStarted) {
			return this;
		}
		
		for (index in 0...this._animatables.length) {
			var animatable = this._animatables[index];
			animatable.reset();
		}
		
		return this;
	}

	/**
	 * Restart animations from key 0
	 */
	public function restart():AnimationGroup {
		if (!this._isStarted) {
			return this;
		}
		
		for (index in 0...this._animatables.length) {
			var animatable = this._animatables[index];
			animatable.restart();
		}
		
		return this;
	}

	/**
	 * Stop all animations
	 */
	public function stop():AnimationGroup {
		if (!this._isStarted) {
			return this;
		}
		
		for (index in 0...this._animatables.length) {
			var animatable = this._animatables[index];
			animatable.stop();
		}
		
		this._isStarted = false;
		
		return this;
	}

	/**
	 * Dispose all associated resources
	 */
	public function dispose() {
		this._targetedAnimations = [];
		this._animatables = [];
		
		var index = this._scene.animationGroups.indexOf(this);
		
		if (index > -1) {
			this._scene.animationGroups.splice(index, 1);
		}
	}
	
}
