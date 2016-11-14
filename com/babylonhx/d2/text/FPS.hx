package com.babylonhx.d2.text;

import haxe.Timer;
import com.babylonhx.d2.events.Event;

/**
 * ...
 * @author Krtolica Vujadin
 */

// taken from https://github.com/openfl/openfl/blob/develop/openfl/display/FPS.hx
class FPS extends TextField {	
	
	public var currentFPS(default, null):Int;
	
	private var cacheCount:Int;
	private var times:Array<Float>;
	
	
	public function new (x:Float = 10, y:Float = 10) {	
		super("FPS: ", "", 58, 16);
		
		this.x = x;
		this.y = y;
		
		this.graphics.beginFill(0x000000, 0.6);
		this.graphics.drawRect(0, 0, this.width, this.height);
		this.graphics.endFill();
		
		currentFPS = 0;
		mouseEnabled = false;
		
		cacheCount = 0;
		times = [];
		
		addEventListener(Event.ENTER_FRAME, this_onEnterFrame);		
	}
	
	private function this_onEnterFrame(event:Event) {		
		var currentTime = Timer.stamp();
		times.push (currentTime);
		
		while (times[0] < currentTime - 1) {		
			times.shift();			
		}
		
		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		
		if (currentCount != cacheCount) {			
			text = "FPS: " + currentFPS;	
		}
		
		cacheCount = currentCount;		
	}	
	
}
