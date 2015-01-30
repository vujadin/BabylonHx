package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

class QuarticEase extends EasingFunction {
	
	override public function easeInCore(gradient:Float):Float {
		return (gradient * gradient * gradient * gradient);
	}
	
}
