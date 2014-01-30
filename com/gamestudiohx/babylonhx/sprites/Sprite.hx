package com.gamestudiohx.babylonhx.sprites;

import com.gamestudiohx.babylonhx.tools.math.Color4;
import com.gamestudiohx.babylonhx.tools.math.Vector3;
import flash.display.Bitmap;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Sprite {

	public var name:String;
	public var color:Color4;

	public var position:Vector3;
	public var size:Float;
	public var angle:Float;
	public var cellIndex:Float;
	public var invertU:Bool;
	public var invertV:Bool;
	public var disposeWhenFinishedAnimating:Bool;
	
	private var _manager:SpriteManager;
	private var _animationStarted:Bool;
    private var _loopAnimation:Bool;
    private var _fromIndex:Float;
    private var _toIndex:Float;
    private var _delay:Float;
    private var _direction:Int;
	private var _time:Float;
	private var _frameCount:Int;

	public function new(name:String, manager:SpriteManager) {
		this.name = name;
        this._manager = manager;

        this._manager.sprites.push(this);

        this.position = Vector3.Zero();
        this.color = new Color4(1.0, 1.0, 1.0, 1.0);

        this._frameCount = 0;
		_direction = 1;
	}
	

	public function playAnimation(from:Float, to:Float, loop:Bool, delay:Float) {
		this._fromIndex = from;
        this._toIndex = to;
        this._loopAnimation = loop;
        this._delay = delay;
        this._animationStarted = true;

        this._direction = from < to ? 1 : -1;

        this.cellIndex = from;
        this._time = 0;
	}
	
	public function stopAnimation() {
		this._animationStarted = false;
	}
	
	public function animate(deltaTime:Float) {
		if (this._animationStarted) {
			this._time += deltaTime;
			if (this._time > this._delay) {
				this._time = this._time % this._delay;
				this.cellIndex += this._direction;
				if (this.cellIndex == this._toIndex) {
					if (this._loopAnimation) {
						this.cellIndex = this._fromIndex;
					} else {
						this._animationStarted = false;
						if (this.disposeWhenFinishedAnimating) {
							this.dispose();
						}
					}
				}
			}
		}
	}
	
	public function dispose() {
		for (i in 0...this._manager.sprites.length) {
            if (this._manager.sprites[i] == this) {
                this._manager.sprites.splice(i, 1);
            }
        }
	}
		
}
