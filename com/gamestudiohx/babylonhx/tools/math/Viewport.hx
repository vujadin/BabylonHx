package com.gamestudiohx.babylonhx.tools.math;

import com.gamestudiohx.babylonhx.Engine;


/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class Viewport {
	
	public var width:Float;
	public var height:Float;
	public var x:Float;
	public var y:Float;

	public function new(x:Float, y:Float, width:Float, height:Float) {
		this.width = width;
        this.height = height;
        this.x = x;
        this.y = y;
	}
	
	inline public function toGlobal(engine:Engine):Viewport {
        var width = engine.getRenderWidth() * engine.getHardwareScalingLevel();
        var height = engine.getRenderHeight() * engine.getHardwareScalingLevel();
        return new Viewport(this.x * width, this.y * height, this.width * width, this.height * height);
    }
	
}
