package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This class implement a typical dictionary using a string as key and the generic type T as value.
 * The underlying implementation relies on an associative array to ensure the best performances.
 * The value can be anything including 'null' but except 'undefined'
 */
class StringDictionary<T> {
	
	private var _count:Int = 0;
	private var _data:Map<String, T>;
	
	
	public function new() {
		this._data = new Map<String, T>();
	}
	

	/**
	 * This will clear this dictionary and copy the content from the 'source' one.
	 * If the T value is a custom object, it won't be copied/cloned, the same object will be used
	 * @param source the dictionary to take the content from and copy to this dictionary
	 */
	public function copyFrom(source:StringDictionary<T>) {
		this.clear();
		for (key in source.keys()) {
			this.add(key, source.get(key));
		}
	}
	
	inline public function keys():Iterator<String> {
		return this._data.keys();
	}

	/**
	 * Get a value based from its key
	 * @param key the given key to get the matching value from
	 * @return the value if found, otherwise undefined is returned
	 */
	public function get(key:String):T {
		var val = this._data[key];
		if (val != null) {
			return val;
		}
		
		return null;
	}

	/**
	 * Get a value from its key or add it if it doesn't exist.
	 * This method will ensure you that a given key/data will be present in the dictionary.
	 * @param key the given key to get the matching value from
	 * @param factory the factory that will create the value if the key is not present in the dictionary.
	 * The factory will only be invoked if there's no data for the given key.
	 * @return the value corresponding to the key.
	 */
	public function getOrAddWithFactory(key:String, factory:String->T):T {
		var val = this.get(key);
		if (val != null) {
			return val;
		}
		
		val = factory(key);
		if (val != null) {
			this.add(key, val);
		}
		
		return val;
	}

	/**
	 * Get a value from its key if present in the dictionary otherwise add it
	 * @param key the key to get the value from
	 * @param val if there's no such key/value pair in the dictionary add it with this value
	 * @return the value corresponding to the key
	 */
	public function getOrAdd(key:String, val:T):T {
		var curVal = this.get(key);
		if (curVal != null) {
			return curVal;
		}
		
		this.add(key, val);
		
		return val;
	}

	/**
	 * Check if there's a given key in the dictionary
	 * @param key the key to check for
	 * @return true if the key is present, false otherwise
	 */
	inline public function contains(key:String):Bool {
		return this._data.exists(key);
	}

	/**
	 * Add a new key and its corresponding value
	 * @param key the key to add
	 * @param value the value corresponding to the key
	 * @return true if the operation completed successfully, false if we couldn't insert the key/value because there was already this key in the dictionary
	 */
	public function add(key:String, value:T):Bool {
		if (this._data.exists(key)) {
			return false;
		}
		
		this._data[key] = value;
		++this._count;
		
		return true;
	}


	public function set(key:String, value:T):Bool {
		if (!this._data.exists(key)) {
			return false;
		}
		
		this._data[key] = value;
		
		return true;
	}

	/**
	 * Get the element of the given key and remove it from the dictionary
	 * @param key
	 */
	public function getAndRemove(key:String):T {
		var val = this.get(key);
		if (val != null) {
			this._data[key] = null;
			this._data.remove(key);
			--this._count;
			
			return val;
		}
		
		return null;
	}

	/**
	 * Remove a key/value from the dictionary.
	 * @param key the key to remove
	 * @return true if the item was successfully deleted, false if no item with such key exist in the dictionary
	 */
	public function remove(key:String):Bool {
		if (this.contains(key)) {
			this._data[key] = null;
			this._data.remove(key);
			--this._count;
			
			return true;
		}
		
		return false;
	}

	/**
	 * Clear the whole content of the dictionary
	 */
	public function clear() {
		this._data = new Map();
		this._count = 0;
	}

	public var count(get, never):Int;
	private function get_count():Int {
		return this._count;
	}

	/**
	 * Execute a callback on each key/val of the dictionary.
	 * Note that you can remove any element in this dictionary in the callback implementation
	 * @param callback the callback to execute on a given key/value pair
	 */
	public function forEach(callback:String->T->Void) {
		for (cur in this._data.keys()) {
			var val = this._data[cur];
			callback(cur, val);
		}
	}

	/**
	 * Execute a callback on every occurrence of the dictionary until it returns a valid TRes object.
	 * If the callback returns null or undefined the method will iterate to the next key/value pair
	 * Note that you can remove any element in this dictionary in the callback implementation
	 * @param callback the callback to execute, if it return a valid T instanced object the enumeration will stop and the object will be returned
	 */
	public function first(callback:String->T->Dynamic):Dynamic {
		for (cur in this._data.keys()) {
			var val = this._data[cur];
			var res = callback(cur, val);
			if (res != null) {
				return res;
			}
		}
		
		return null;
	}
	
}
