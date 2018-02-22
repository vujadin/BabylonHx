package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * A class serves as a medium between the observable and its observers
 */
class EventState/*<T>*/ {
	
	/**
     * An Observer can set this property to true to prevent subsequent observers of being notified
     */
	public var skipNextObservers:Bool;
	
	/**
     * Get the mask value that were used to trigger the event corresponding to this EventState object
     */
	public var mask:Int;
	
	/**
	 * The object that originally notified the event
	 */
	//public var target:T = null;

	/**
	 * The current object in the bubbling phase
	 */
	//public var currentTarget:T = null;

	/**
	 * This will be populated with the return value of the last function that was executed.
	 * If it is the first function in the callback chain it will be the event data.
	 */
	public var lastReturnValue:Dynamic = null;
	
	
	/**
	 * Create a new EventState
	 * @param mask defines the mask associated with this state
	 * @param skipNextObservers defines a flag which will instruct the observable to skip following observers when set to true
	 * @param target defines the original target of the state
	 * @param currentTarget defines the current target of the state
	 */
	inline public function new(mask:Int, skipNextObservers:Bool = false/*, ?target:T, ?currentTarget:T*/) {
		this.initalize(mask, skipNextObservers);
	}
	
	/**
	 * Initialize the current event state
	 * @param mask defines the mask associated with this state
	 * @param skipNextObservers defines a flag which will instruct the observable to skip following observers when set to true
	 * @param target defines the original target of the state
	 * @param currentTarget defines the current target of the state
	 * @returns the current event state
	 */
	inline public function initalize(mask:Int, skipNextObservers:Bool = false/*, ?target:T, ?currentTarget:T*/):EventState/*<T>*/ {
        this.mask = mask;
        this.skipNextObservers = skipNextObservers;
		//this.target = target;
		//this.currentTarget = currentTarget;
		
		return this;
    }
	
}
