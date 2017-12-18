package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Represent a list of observers registered to multiple Observables object.
 */
class MultiObserver<T> {
	
	private var _observers:Array<Observer<T>>;
	private var _observables:Array<Observable<T>>;
	
	
	public function new() {
		
	}
	
	public function dispose() {
		for (index in 0...this._observers.length) {
			this._observables[index].remove(this._observers[index]);
		}
		
		this._observers = null;
		this._observables = null;
	}

	public static function Watch<T>(observables:Array<Observable<T>>, callback:T->EventState->Void, mask:Int = -1, scope:Dynamic = null):MultiObserver<T> {
		var result = new MultiObserver<T>();
		
		result._observers = [];
		result._observables = observables;
		
		for (observable in observables) {
			result._observers.push(observable.add(callback, mask, false, scope));
		}
		
		return result;
	}
	
}
