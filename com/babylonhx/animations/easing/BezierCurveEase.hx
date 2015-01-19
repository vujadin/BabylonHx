package com.babylonhx.animations.easing;

import com.babylonhx.math.BezierCurve;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.BezierCurveEase') class BezierCurveEase extends EasingFunction {
	
	public var x1:Float = 0;
	public var x2:Float = 1;
	public var y1:Float = 0;
	public var y2:Float = 1;
	
	
	public function new(x1:Float = 0, y1:Float = 0, x2:Float = 1, y2:Float = 1) {
		super();
		this.x1 = x1;
		this.x2 = x2;
		this.y1 = y1;
		this.y2 = y2;
	}

	override public function easeInCore(gradient:Float):Float {
		return BezierCurve.interpolate(gradient, this.x1, this.y1, this.x2, this.y2);
	}
	
}
