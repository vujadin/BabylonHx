package com.babylonhx.animations;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Animatable') class Animatable {
	
	private var _localDelayOffset:Float = -1;
	private var _pausedDelay:Float = -1;
	private var _runtimeAnimations:Array<RuntimeAnimation> = [];
	private var _paused:Bool = false;
	private var _scene:Scene;
	
	public var animationStarted:Bool = false;

	public var target:Dynamic;
	public var fromFrame:Int;
	public var toFrame:Int;
	public var loopAnimation:Bool;
	public var speedRatio:Float;
	public var onAnimationEnd:Void->Void;
	
	

	public function new(scene:Scene, target:Dynamic, fromFrame:Int = 0, toFrame:Int = 100, loopAnimation:Bool = false, speedRatio:Float = 1.0, onAnimationEnd:Void->Void = null, animations:Array<Animation> = null) {
		this.target = target;
		this.fromFrame = fromFrame;
		this.toFrame = toFrame;
		this.loopAnimation = loopAnimation;
		this.speedRatio = speedRatio;
		this.onAnimationEnd = onAnimationEnd;
		
		if (animations != null) {
			this.appendAnimations(target, animations);
		}
		
		this._scene = scene;
		scene._activeAnimatables.push(this);
	}
	
	// Methods
	inline public function getAnimations():Array<RuntimeAnimation> {
		return this._runtimeAnimations;
	}

	public function appendAnimations(target:Dynamic, animations:Array<Animation>) {
		for (index in 0...animations.length) {
			var animation = animations[index];
			
			this._runtimeAnimations.push(new RuntimeAnimation(target, animation));    
		}            
	}

	public function getAnimationByTargetProperty(property:String):Animation {
		var runtimeAnimations = this._runtimeAnimations;
		
		for (index in 0...runtimeAnimations.length) {
			if (runtimeAnimations[index].animation.targetProperty == property) {
				return runtimeAnimations[index].animation;
			}
		}
		
		return null;
	}
	
	public function getRuntimeAnimationByTargetProperty(property:String):RuntimeAnimation {
        var runtimeAnimations = this._runtimeAnimations;
		
        for (index in 0...runtimeAnimations.length) {
            if (runtimeAnimations[index].animation.targetProperty == property) {
                return runtimeAnimations[index];
            }
        }
		
		return null;
    }
	
	public function reset() {
		var runtimeAnimations = this._runtimeAnimations;
		
		for (index in 0...runtimeAnimations.length) {
			runtimeAnimations[index].reset();
		}
		
		this._localDelayOffset = -1;
		this._pausedDelay = -1;
	}
	
	public function enableBlending(blendingSpeed:Float) {
		var runtimeAnimations = this._runtimeAnimations;
		
		for (index in 0...runtimeAnimations.length) {
			runtimeAnimations[index].animation.enableBlending = true;
			runtimeAnimations[index].animation.blendingSpeed = blendingSpeed;
		}
	}

	public function disableBlending() {
		var runtimeAnimations = this._runtimeAnimations;
		
		for (index in 0...runtimeAnimations.length) {
			runtimeAnimations[index].animation.enableBlending = false;
		}
	}
	
	public function goToFrame(frame:Int) {
		var runtimeAnimations = this._runtimeAnimations;
		
		if (runtimeAnimations[0] != null) {
            var fps = runtimeAnimations[0].animation.framePerSecond;
            var currentFrame = runtimeAnimations[0].currentFrame;
            var adjustTime = frame - currentFrame;
            var delay = adjustTime * 1000 / fps;
            this._localDelayOffset -= delay;
        }
		
		for (index in 0...runtimeAnimations.length) {
			runtimeAnimations[index].goToFrame(frame);
		}
	}

	inline public function pause() {
		this._paused = true;
	}

	inline public function restart() {
		this._paused = false;
	}

	public function stop(?animationName:String) {
		if (animationName != null) {
			var idx = this._scene._activeAnimatables.indexOf(this);
			
			if (idx > -1) {
				var runtimeAnimations = this._runtimeAnimations;
				
				var index = runtimeAnimations.length - 1;
				while (index >= 0) {
					if (Std.is(animationName, String) && runtimeAnimations[index].animation.name != animationName) {
						continue;
					}
					
					runtimeAnimations[index].reset();
					runtimeAnimations.splice(index, 1);
					
					index--;
				}
				
				if (runtimeAnimations.length == 0) {
					this._scene._activeAnimatables.splice(idx, 1);
					
					if (this.onAnimationEnd != null) {
						this.onAnimationEnd();
					}
				}
			}
		} 
		else {
			var index = this._scene._activeAnimatables.indexOf(this);
			
			if (index > -1) {
				this._scene._activeAnimatables.splice(index, 1);
				var runtimeAnimations = this._runtimeAnimations;
				
				for (index in 0...runtimeAnimations.length) {
					runtimeAnimations[index].reset();
				}
				
				if (this.onAnimationEnd != null) {
					this.onAnimationEnd();
				}
			}
		}
	}

	public function _animate(delay:Float):Bool {
		if (this._paused) {
			this.animationStarted = false;
			if (this._pausedDelay == -1) {
				this._pausedDelay = delay;
			}
			
			return true;
		}
		
		if (this._localDelayOffset == -1) {
			this._localDelayOffset = delay;
		} 
		else if (this._pausedDelay != -1) {
			this._localDelayOffset += delay - this._pausedDelay;
			this._pausedDelay = -1;
		}
		
		// Animating
		var running = false;
		var runtimeAnimations = this._runtimeAnimations;
		
		for (index in 0...runtimeAnimations.length) {
			var animation = runtimeAnimations[index];
			var isRunning = animation.animate(delay - this._localDelayOffset, this.fromFrame, this.toFrame, this.loopAnimation, this.speedRatio);
			running = running || isRunning;
		}
		
		this.animationStarted = running;
		
		if (!running) {
			// Remove from active animatables
			var index = this._scene._activeAnimatables.indexOf(this);
			this._scene._activeAnimatables.splice(index, 1);
			
			// Dispose all runtime animations
            for (index in 0...runtimeAnimations.length) {
                runtimeAnimations[index].dispose();
            }
		}
		
		if (!running && this.onAnimationEnd != null) {
			this.onAnimationEnd();
			this.onAnimationEnd = null;
		}
		
		return running;
	}
	
}
