package com.babylonhx.d2.events;

/**
 * ...
 * @author Krtolica Vujadin
 */
class AccelerometerEvent extends Event {	
	
	public static inline var UPDATE:String = "update";
	
	public var accelerationX:Float;
	public var accelerationY:Float;
	public var accelerationZ:Float;
	public var timestamp:Float;
	
	
	public function new(type:String, bubbles:Bool = false, timestamp:Float = 0, accelerationX:Float = 0, accelerationY:Float = 0, accelerationZ:Float = 0) {		
		super (type, bubbles, cancelable);
		
		this.timestamp = timestamp;
		this.accelerationX = accelerationX;
		this.accelerationY = accelerationY;
		this.accelerationZ = accelerationZ;		
	}	
	
	public override function clone():Event {		
		var event = new AccelerometerEvent(type, bubbles, cancelable, timestamp, accelerationX, accelerationY, accelerationZ);
		event.target = target;
		event.currentTarget = currentTarget;
		
		return event;		
	}
	
}
