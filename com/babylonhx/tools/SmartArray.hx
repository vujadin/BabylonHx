package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SmartArray') class SmartArray<T:ISmartArrayCompatible> {
	
	private static var _GlobalId:Int = 0;
	
	public var data:Array<T>;
	public var length:Int = 0;

	private var _id:Int;
	private var _duplicateId:Int = 0;
	

	public function new(capacity:Int = 256) {
		this.data = new Array<T>();
		this._id = SmartArray._GlobalId++;
	}

	inline public function push(value:T):Void {
		this.data[this.length++] = value;
		value.__smartArrayFlags[this._id] = this._duplicateId;
	}

	public function pushNoDuplicate(value:T):Bool {
		if(value.__smartArrayFlags[this._id] == this._duplicateId) {
			return false;
		}
		
		this.push(value);
		
		return true;
	}

	inline public function sort(compareFn:T->T->Int) {
		this.data.sort(compareFn);
	}

	inline public function reset():Void {
		this.length = 0;
		this._duplicateId++;
	}
	
	public function dispose() {
		this.reset();
		this.data.splice(0, this.data.length);
		
		if (this.data != null) {
            this.data.splice(0, this.data.length);
            this.data = null;
        }
	}

	inline public function concatArray(array:Array<T>) {
		for (index in 0...array.length) {
			this.data[this.length++] = array[index];
		}
	}
	
	inline public function concatSmartArray(array:SmartArray<T>) {
		for (index in 0...array.length) {
			this.data[this.length++] = array.data[index];
		}
	}

	inline public function concatArrayWithNoDuplicate(array:Array<T>) {
		for (index in 0...array.length) {
			var item = array[index];
			this.pushNoDuplicate(item);
		}
	}
	
	inline public function concatSmartArrayWithNoDuplicate(array:SmartArray<T>) {
		for (index in 0...array.length) {
			var item = array.data[index];
			this.pushNoDuplicate(item);
		}
	}

	inline public function indexOf(value:T):Int {
		var position = this.data.indexOf(value);
		
		return (position >= this.length) ? -1 : position;
	}

}
