package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * A class serves as a medium between the observable and its observers
 */
class EventState {
	
	/**
	 * If the callback of a given Observer set this member to true the following observers will be ignored
	 */
	public var skipNextObservers:Bool;
	
	
	public function new() {
		this.skipNextObservers = false;
	}
	
}
