package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ExponentialEase') class ExponentialEase extends EasingFunction {
	
	public var exponent:Float = 2;
	
	
	public function new(exponent:Float = 2) {
		super();
		
		this.exponent = exponent;
	}

	override public function easeInCore(gradient:Float):Float {
		if (this.exponent <= 0) {
			return gradient;
		}
		
		return ((Math.exp(this.exponent * gradient) - 1.0) / (Math.exp(this.exponent) - 1.0));
	}
	
}
