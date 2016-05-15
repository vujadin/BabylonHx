package com.babylonhx.canvas2d;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Base class implemting the ILocable interface.
 * The particularity of this class is to call the protected onLock() method when the instance is about to be locked for good.
 */
class LockableBase implements ILockable {
	
	private var _isLocked:Bool;
	
	
	public function new() { }
	
	public function isLocked():Bool {
		return this._isLocked;
	}

	public function lock():Bool {
		if (this._isLocked) {
			return true;
		}
		
		this.onLock();
		this._isLocked = true;
		
		return false;
	}

	/**
	 * Protected handler that will be called when the instance is about to be locked.
	 */
	private function onLock() {
		//...
	}
	
}
	