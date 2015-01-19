package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.CubicEase') class CubicEase extends EasingFunction {
	
	override public function easeInCore(gradient:Float):Float {
		return (gradient * gradient * gradient);
	}
	
}
