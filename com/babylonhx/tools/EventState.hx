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
     * An Observer can set this property to true to prevent subsequent observers of being notified
     */
	public var skipNextObservers:Bool;
	/**
     * Get the mask value that were used to trigger the event corresponding to this EventState object
     */
	public var mask:Int;
	
	
	/**
	 * If the callback of a given Observer set this member to true the following observers will be ignored
	 */
	inline public function new(mask:Int, skipNextObservers:Bool = false) {
		this.skipNextObservers = skipNextObservers;
		this.mask = mask;
	}
	
}
