package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Observable<T> {
	
	private var _observers:Array<Observer<T>>;
	
	
	public function new() {
		_observers = [];
	}

	/**
	 * Create a new Observer with the specified callback
	 * @param callback the callback that will be executed for that Observer
	 */
	public function add(callback:T->Void): Observer<T> {
		var observer = new Observer(callback);
		
		this._observers.push(observer);
		
		return observer;
	}

	/**
	 * Remove an Observer from the Observable object
	 * @param observer the instance of the Observer to remove. If it doesn't belong to this Observable, false will be returned.
	 */
	public function remove(observer:Observer<T>):Bool {
		var index = this._observers.indexOf(observer);
		
		if (index != -1) {
			this._observers.splice(index, 1);
			
			return true;
		}
		
		return false;
	}

	/**
	 * Remove a callback from the Observable object
	 * @param callback the callback to remove. If it doesn't belong to this Observable, false will be returned.
	*/
	public function removeCallback(callback:T->Void):Bool {
		for (index in 0...this._observers.length) {
			if (this._observers[index].callback == callback) {
				this._observers.splice(index, 1);
				
				return true;
			}
		}
		
		return false;
	}

	/**
	 * Notify all Observers by calling their respective callback with the given data
	 * @param eventData
	 */
	public function notifyObservers(eventData:T) {
		for (observer in this._observers) {
			observer.callback(eventData);
		}
	}

	/**
	* Clear the list of observers
	*/
	public function clear() {
		this._observers = [];
	}
	
}
