package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The Observable class is a simple implementation of the Observable pattern.
 * There's one slight particularity though: a given Observable can notify its observer using a particular mask value, 
 * only the Observers registered with this mask value will be notified.
 * This enable a more fine grained execution without having to rely on multiple different Observable objects.
 * For instance you may have a given Observable that have four different types of notifications: 
 * Move (mask = 0x01), Stop (mask = 0x02), Turn Right (mask = 0X04), Turn Left (mask = 0X08).
 * A given observer can register itself with only Move and Stop (mask = 0x03), then it will only be notified when 
 * one of these two occurs and will never be for Turn Left/Right.
 */
class Observable<T> {	
	
	private var _observers:Array<Observer<T>> = [];
	
	private var _eventState:EventState<T>;
	
	private var _onObserverAdded:Observer<T>->Void;
	
	
	/**
	 * Creates a new observable
	 * @param onObserverAdded defines a callback to call when a new observer is added
	 */
	public function new(?onObserverAdded:Observer<T>->Void) {
		this._eventState = new EventState(0);
		
		if (onObserverAdded != null) {
			this._onObserverAdded = onObserverAdded;
		}
	}

	/**
	 * Create a new Observer with the specified callback
	 * @param callback the callback that will be executed for that Observer
	 * @param mask the mask used to filter observers
	 * @param insertFirst if true the callback will be inserted at the first position, hence executed before the others ones. If false (default behavior) the callback will be inserted at the last position, executed after all the others already present.
	 * @param scope optional scope for the callback to be called from
	 * @param unregisterOnFirstCall defines if the observer as to be unregistered after the next notification
	 * @returns the new observer created for the callback
	 */
	public function add(callback:T->Null<EventState<T>>->Void, mask:Int = -1, insertFirst:Bool = false, scope:Dynamic = null, unregisterOnFirstCall:Bool = false):Observer<T> {
		if (callback == null) {
			return null;
		}
		
		var observer = new Observer(callback, mask, scope);
		observer.unregisterOnNextCall = unregisterOnFirstCall;
		
		if (insertFirst) {
            this._observers.unshift(observer);
        } 
		else {
            this._observers.push(observer);
        }
		
		if (this._onObserverAdded != null) {
			this._onObserverAdded(observer);
		}
		
		return observer;
	}

	/**
	 * Remove an Observer from the Observable object
	 * @param observer the instance of the Observer to remove
	 * @returns false if it doesn't belong to this Observable
	 */
	public function remove(observer:Observer<T>):Bool {
		if (observer == null) {
			return false;
		}
		
		var index = this._observers.indexOf(observer);
		
		if (index != -1) {
			this._observers.splice(index, 1);
			
			return true;
		}
		
		return false;
	}

	/**
	 * Remove a callback from the Observable object
	 * @param callback the callback to remove
	 * @param scope optional scope. If used only the callbacks with this scope will be removed
	 * @returns false if it doesn't belong to this Observable
	 */
	public function removeCallback(callback:T->Null<EventState<T>>->Void, ?scope:Dynamic):Bool {
		for (index in 0...this._observers.length) {
			if (this._observers[index].callback == callback&& (scope == null || scope == this._observers[index].scope)) {
				this._observers.splice(index, 1);				
				return true;
			}
		}
		
		return false;
	}
	
	private function _deferUnregister(observer:Observer<T>) {
		observer.unregisterOnNextCall = false;
		observer._willBeUnregistered = true;
		Tools.SetImmediate(function() {
			this.remove(observer);
		});
	}

	/**
	 * Notify all Observers by calling their respective callback with the given data
	 * Will return true if all observers were executed, false if an observer set skipNextObservers to true, then prevent the subsequent ones to execute
	 * @param eventData defines the data to send to all observers
	 * @param mask defines the mask of the current notification (observers with incompatible mask (ie mask & observer.mask === 0) will not be notified)
	 * @param target defines the original target of the state
	 * @param currentTarget defines the current target of the state
	 * @returns false if the complete observer chain was not processed (because one observer set the skipNextObservers to true)
	 */
	public function notifyObservers(eventData:T, mask:Int = -1, ?target:T, ?currentTarget:T):Bool {
		if (this._observers.length == 0) {
			return true;
		}
		
		var state = this._eventState;
		state.mask = mask;
		state.target = target;
		state.currentTarget = currentTarget;
		state.skipNextObservers = false;
		state.lastReturnValue = eventData;
		
		for (obs in this._observers) {
			if (obs._willBeUnregistered) {
				continue;
			}
			
			if (obs.mask & mask != 0) {
				// VK TODO:
				//if (obs.scope != null) {
				//	state.lastReturnValue = obs.callback(obs.scope, cast eventData/*, state]*/);	// VK: this is not right...
				//} 
				//else {
				//	state.lastReturnValue = obs.callback(eventData, cast state);
				//}
				
				if (obs.unregisterOnNextCall) {
					this._deferUnregister(obs);
				}
			}
			if (state.skipNextObservers) {
				return false;
			}
		}
		return true;
	}
	
	/**
	 * Notify a specific observer
	 * @param observer defines the observer to notify
	 * @param eventData defines the data to be sent to each callback
	 * @param mask is used to filter observers defaults to -1
	 */
	public function notifyObserver(observer:Observer<T>, eventData:T, mask:Int = -1) {
		var state = this._eventState;
		state.mask = mask;
		state.skipNextObservers = false;
		
		observer.callback(eventData, state);
	} 
	
	/**
	 * Gets a boolean indicating if the observable has at least one observer
	 * @returns true is the Observable has at least one Observer registered
	 */
	public function hasObservers():Bool {
		return this._observers.length > 0;
	}

	/**
	* Clear the list of observers
	*/
	public function clear() {
		this._observers = [];
		this._onObserverAdded = null;
	}
	
	/*
	* Clone the current observable
	*/
	public function clone():Observable<T> {
		var result = new Observable<T>();
		
		result._observers = this._observers.slice(0);
		
		return result;
	}
	
	/**
	 * Does this observable handles observer registered with a given mask
	 * @param mask defines the mask to be tested
	 * @return whether or not one observer registered with the given mask is handeled 
	 */
	public function hasSpecificMask(mask:Int = -1):Bool {
		for (obs in this._observers) {
			if ((obs.mask & mask != 0) && obs.mask == mask) {
				return true;
			}
		}
		return false;
	}
	
}
