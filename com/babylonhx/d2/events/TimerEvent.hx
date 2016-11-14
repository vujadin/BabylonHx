package com.babylonhx.d2.events;

/**
 * ...
 * @author Krtolica Vujadin
 */
class TimerEvent extends Event {	
	
	public static inline var TIMER:String = "timer";
	public static inline var TIMER_COMPLETE:String = "timerComplete";
	
	
	public function new (type:String, bubbles:Bool = false) {		
		super (type, bubbles);		
	}	
	
	public override function clone():Event {		
		var event = new TimerEvent(type, bubbles);
		event.target = target;
		event.currentTarget = currentTarget;
		
		return event;		
	}	
	
}
