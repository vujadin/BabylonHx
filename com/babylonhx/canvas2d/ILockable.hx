package com.babylonhx.canvas2d;

/**
 * @author Krtolica Vujadin
 */

/**
 * This interface is used to implement a lockable instance pattern.
 * Classes that implements it may be locked at any time, making their content immutable from now on.
 * You also can query if a given instance is locked or not.
 * This allow instances to be shared among several 'consumers'.
 */
interface ILockable {
	
	/**
	 * Query the lock state
	 * @returns returns true if the object is locked and immutable, false if it's not
	 */
	function isLocked():Bool;

	/**
	 * A call to this method will definitely lock the instance, making its content immutable
	 * @returns the previous lock state of the object. so if true is returned the object  were already locked and this method does nothing, if false is returned it means the object wasn't locked and this call locked it for good.
	 */
	function lock():Bool;
	
}
	