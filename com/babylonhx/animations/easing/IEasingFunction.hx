package com.babylonhx.animations.easing;

/**
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.IEasingFunction') interface IEasingFunction {
	
	function ease(gradient:Float):Float;
	
}