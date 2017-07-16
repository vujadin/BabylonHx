package com.babylonhx.tools;

import haxe.ds.ObjectMap;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.SmartCollection') class SmartCollection {

	public var count:Int = 0;
	public var items:ObjectMap<Dynamic, Dynamic>;
	
	private var _keys:Array<Dynamic>;
	private var _initialCapacity:Int;
	
	
	public function new(capacity:Int = 10) {
		this._initialCapacity = capacity;    
		this.items = new ObjectMap();
		this._keys = [];
	}

	public function add(key:Dynamic, item:Dynamic):Int {        
		if (this.items.get(key) != null) {
			return -1;
		}
		this.items.set(key, item);
		
		//literal keys are always strings, but we keep source type of key in _keys array
		this._keys[this.count++] = key;
		/*if (this.count > this._keys.length) {
			this._keys.length *= 2;
		}*/
		
		return this.count;
	}
 
	public function remove(key:Dynamic):Int {
		if (this.items.get(key) == null) {
			return -1;
		}
		
		return this.removeItemOfIndex(this.indexOf(key));
	}

	public function removeItemOfIndex(index:Int):Int {
		if (index < this.count && index > -1) {
			this.items.set(this._keys[index], null);
			this.items.remove(this._keys[index]);
				
			//here, shifting by hand is better optimised than .splice
			while (index < this.count) { 
			   this._keys[index] = this._keys[index + 1];
			   index++;
			}
		}
		else { 
			return -1; 
		}
		
		return --this.count;
	}
	
	public function indexOf(key:Dynamic):Int {
		for (i in 0...this.count) {
			if (this._keys[i] == key) { 
				return i; 
			}
		}
		
		return -1;
	}
	
	public function item(key:Dynamic):Dynamic {
		if (key != null) {
			return this.items.get(key);
		}
		return null;
	}

	public function getAllKeys():Array<Dynamic> {
		if (this.count > 0) {
			var keys:Array<Dynamic> = [];
			for (i in 0...this.count) {
				keys[i] = this._keys[i];
			}
			
			return keys;
		} 
			
		return null;
	}
	
	public function getKeyByIndex(index:Int):Dynamic {
		if (index < this.count && index > -1) {
			return this._keys[index];
		}
		
		return null;
	}

	public function getItemByIndex(index:Int):Dynamic {
		if (index < this.count && index > -1) {
			return this.items.get(this._keys[index]);
		}
		
		return null;
	}

	public function empty() {
		if (this.count > 0) {
			this.count = 0;
			this.items = new ObjectMap();
			this._keys = [];
		}
	}
	
	public function forEach(block:Dynamic->Void) {
		var key:String;
		for (key in this.items) {
			if (this.items.exists(key)) {
				block(this.items.get(key));
			}
		}
	}
	
}
