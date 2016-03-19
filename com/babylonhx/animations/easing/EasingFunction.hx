package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.EasingFunction') class EasingFunction implements IEasingFunction {
	
	//Statics
	public static inline var EASINGMODE_EASEIN:Int = 0;
	public static inline var EASINGMODE_EASEOUT:Int = 1;
	public static inline var EASINGMODE_EASEINOUT:Int = 2;

	// Properties
	private var _easingMode:Int = EasingFunction.EASINGMODE_EASEIN;
	
	
	public function new() {
		
	}

	public function setEasingMode(easingMode:Int) {
		var n = Math.min(Math.max(easingMode, 0), 2);
		this._easingMode = cast n;
	}
	public function getEasingMode():Int {
		return this._easingMode;
	}

	public function easeInCore(gradient:Float):Float {
		throw('You must implement this method');
	}

	public function ease(gradient:Float):Float {
		switch (this._easingMode) {
			case EasingFunction.EASINGMODE_EASEIN:
				return this.easeInCore(gradient);
				
			case EasingFunction.EASINGMODE_EASEOUT:
				return (1 - this.easeInCore(1 - gradient));
		}
		
		if (gradient >= 0.5) {
			return (((1 - this.easeInCore((1 - gradient) * 2)) * 0.5) + 0.5);
		}
		
		return (this.easeInCore(gradient * 2) * 0.5);
	}

}
