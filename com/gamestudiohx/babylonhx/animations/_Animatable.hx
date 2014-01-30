package com.gamestudiohx.babylonhx.animations;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class _Animatable {
	
	public var target:Dynamic;
    public var animationStarted:Bool;
    public var loopAnimation:Bool;
    public var fromFrame:Float;
    public var toFrame:Float;
    public var speedRatio:Float;
	public var onAnimationEnd:Void->Void;
	
	private var _localDelayOffset:Float = -1;
	

	public function new(target:Dynamic = null, from:Float = 0, to:Float = 100, loop:Bool = false, speedRatio:Float = 1.0, onAnimationEnd:Void->Void = null) {
		this.target = target;
        this.fromFrame = from;
        this.toFrame = to;
        this.loopAnimation = loop;
        this.speedRatio = speedRatio;
        this.onAnimationEnd = onAnimationEnd;
		
		this.animationStarted = false;
	}
	
	inline public function _animate(delay:Float):Bool {
		if (this._localDelayOffset == -1) {
            this._localDelayOffset = delay;
        }

        // Animating
        var running:Bool = false;
        var animations:Array<Animation> = this.target.animations;
        for (index in 0...animations.length) {
            var isRunning:Bool = animations[index].animate(this.target, delay - this._localDelayOffset, this.fromFrame, this.toFrame, this.loopAnimation, this.speedRatio);
            running = running || isRunning;            
        }

        if (!running && this.onAnimationEnd != null) {
            this.onAnimationEnd();
        }

        return running;
	}
	
}
