package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CircleEase') class CircleEase extends EasingFunction {
	
	override public function easeInCore(gradient:Float):Float {
		gradient = Math.max(0, Math.min(1, gradient));
		return (1.0 - Math.sqrt(1.0 - (gradient * gradient)));
	}
	
}
