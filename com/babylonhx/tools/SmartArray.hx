package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SmartArray') class SmartArray<T> {
	
	private static var _GlobalId:Int = 0;
	
	public var data:Array<T>;
	public var length:Int = 0;
	
	public var __smartArrayFlags:Array<Int>;

	private var _id:Int;
	private var _duplicateId:Int = 0;
	

	public function new(capacity:Int = 256) {
		this.data = new Array<T>();
		this._id = SmartArray._GlobalId++;
	}

	inline public function push(value:T):Void {
		this.data[this.length++] = value;
		//trace(value);
		if (untyped value.__smartArrayFlags == null) {
			untyped value.__smartArrayFlags = [];
		}
		
		untyped value.__smartArrayFlags[this._id] = this._duplicateId;
	}

	public function pushNoDuplicate(value:T) {
		if(untyped value.__smartArrayFlags != null && value.__smartArrayFlags[this._id] == this._duplicateId) {
			return;
		}
		
		this.push(value);
	}

	inline public function sort(compareFn:T->T->Int) {
		this.data.sort(compareFn);
	}

	inline public function reset():Void {
		this.length = 0;
		this._duplicateId++;
	}

	inline public function concatArray(array:Array<T>) {
		if (array.length != 0) {		
			for (index in 0...array.length) {
				this.data[this.length++] = array[index];
			}
		}
	}
	
	inline public function concatSmartArray(array:SmartArray<T>) {
		if (array.length != 0) {
			for (index in 0...array.length) {
				this.data[this.length++] = array.data[index];
			}
		}
	}

	inline public function concatArrayWithNoDuplicate(array:Array<T>) {
		if (array.length != 0) {			
			for (index in 0...array.length) {
				var item = array[index];
				this.pushNoDuplicate(item);
			}
		}
	}
	
	inline public function concatSmartArrayWithNoDuplicate(array:SmartArray<T>) {
		if (array.length != 0) {
			for (index in 0...array.length) {
				var item = array.data[index];
				this.pushNoDuplicate(item);
			}
		}
	}

	public function indexOf(value:T):Int {
		var position = this.data.indexOf(value);
		
		if (position >= this.length) {
			return -1;
		}
		
		return position;
	}

}
