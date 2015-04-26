package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SineEase') class SineEase extends EasingFunction {
	
	override public function easeInCore(gradient:Float):Float {
		return (1.0 - Math.sin((Math.PI / 2) * (1.0 - gradient)));
	}
	
}
	