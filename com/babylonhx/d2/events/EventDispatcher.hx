package com.babylonhx.d2.events;

import com.babylonhx.d2.display.DisplayObject;

/**
 * ...
 * @author Krtolica Vujadin
 */
class EventDispatcher {
	
	public static var efbc:Array<DisplayObject> = [];	// objects, on which EnterFrame will be broadcasted

	public var lsrs:Map<String, Array<Dynamic>>;
	public var cals:Map<String, Array<EventDispatcher>>;
	
	
	public function new() {
		this.lsrs = new Map();		// hash table for listeners ... Key (Event type) : Array of functions
		this.cals = new Map();		// hash table for objects   ... Key (Event type) : Array of Objects, on which function should be called
	}

	public function hasEventListener(type:String):Bool {
		var fs = this.lsrs[type];		// functions for this event
		if (fs == null) {
			return false;
		}
		
		return (fs.length > 0);
	}

	public function addEventListener(type:String, f:Dynamic) {
		this.addEventListener2(type, f, null);
	}

	public function addEventListener2(type:String, f:Dynamic, o:EventDispatcher) {	// string, function
		if(this.lsrs[type] == null) {
			this.lsrs[type] = [];
			this.cals[type] = [];
		}
		
		this.lsrs[type].push(f);
		this.cals[type].push(o);
		
		if(type == Event.ENTER_FRAME) {
			var arEF = EventDispatcher.efbc;
			if (arEF.indexOf(cast this) < 0) {
				arEF.push(cast this);
			}
		}
	}

	public function removeEventListener(type:String, f:Dynamic) {	// string, function
		var fs = this.lsrs[type];		// functions for this event
		if (fs == null) {
			return;
		}
		var ind = fs.indexOf(f);
		if (ind < 0) {
			return;
		}
		var cs = this.cals[type];
		fs.splice(ind, 1);
		cs.splice(ind, 1);
		
		if (type == Event.ENTER_FRAME && fs.length == 0) {
			/*var arEF = EventDispatcher.efbc;
			arEF.splice(arEF.indexOf(cast this), 1);*/
			EventDispatcher.efbc.remove(cast this);
		}
	}

	public function dispatchEvent(e:Event) {	// Event
		e.currentTarget = cast this;
		if (e.target == null) {
			e.target = cast this;
		}
		
		var fs = this.lsrs[e.type];
		if (fs == null) {
			return;
		}
		var cs = this.cals[e.type];
		for (i in 0...fs.length) {
			if (cs[i] == null) {
				fs[i](e);
			}
			else {
				fs[i](cs[i], e);
			}
		}
	}
	
}
