package com.babylonhx.animations;

/**
* ...
* @author Krtolica Vujadin
*/

@:expose('BABYLON.Animatable') class Animatable {
	
	private var _localDelayOffset:Float = -1;
	private var _pausedDelay:Float = -1;
	private var _animations = new Array<Animation>();
	private var _paused:Bool = false;
	private var _scene:Scene;

	public var target:Dynamic;
	public var fromFrame:Int;
	public var toFrame:Int;
	public var loopAnimation:Bool;
	public var speedRatio:Float;
	public var onAnimationEnd:Void->Void;
	public var animationStarted:Bool = false;
	

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
	public function appendAnimations(target:Dynamic, animations:Array<Animation>) {
		for (index in 0...animations.length) {
			var animation = animations[index];
			
			animation._target = target;
			this._animations.push(animation);    
		}            
	}

	public function getAnimationByTargetProperty(property:String) {
		var animations = this._animations;
		
		for (index in 0...animations.length) {
			if (animations[index].targetProperty == property) {
				return animations[index];
			}
		}
		
		return null;
	}

	public function pause():Void {
		this._paused = true;
	}

	public function restart():Void {
		this._paused = false;
	}

	public function stop():Void {
		var index = this._scene._activeAnimatables.indexOf(this);
		
		if (index > -1) {
			this._scene._activeAnimatables.splice(index, 1);
		}
		
		if (this.onAnimationEnd != null) {
			this.onAnimationEnd();
		}
	}

	public function _animate(delay:Float):Bool {
		if (this._paused) {
			if (this._pausedDelay == -1) {
				this._pausedDelay = delay;
			}
			return true;
		}
		
		if (this._localDelayOffset == -1) {
			this._localDelayOffset = delay;
		} else if (this._pausedDelay != -1) {
			this._localDelayOffset += delay - this._pausedDelay;
			this._pausedDelay = -1;
		}
		
		// Animating
		var running = false;
		var animations = this._animations;
		
		for (index in 0...animations.length) {
			var animation = animations[index];
			var isRunning = animation.animate(delay - this._localDelayOffset, this.fromFrame, this.toFrame, this.loopAnimation, this.speedRatio);
			running = running || isRunning;
		}
		
		if (!running && this.onAnimationEnd != null) {
			this.onAnimationEnd();
		}
		
		return running;
	}
	
}
