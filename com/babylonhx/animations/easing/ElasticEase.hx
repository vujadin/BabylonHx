package com.babylonhx.animations.easing;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.ElasticEase') class ElasticEase extends EasingFunction {
	
	public var oscillations:Float = 3.0;
	public var springiness:Float = 3.0;
	
	
	public function new(oscillations:Float = 3, springiness:Float = 3) {
		super();
		
		this.oscillations = oscillations;
		this.springiness = springiness;
	}

	override public function easeInCore(gradient:Float):Float {
		var num2:Float = 0;
		var num3 = Math.max(0.0, this.oscillations);
		var num = Math.max(0.0, this.springiness);
		
		if (num == 0) {
			num2 = gradient;
		}else {
			num2 = (Math.exp(num * gradient) - 1.0) / (Math.exp(num) - 1.0);
		}
		return (num2 * Math.sin((((Math.PI * 2) * num3) + (Math.PI / 2)) * gradient));
	}
	
}
