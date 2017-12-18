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
	

	public function new(capacity:Int = 256) {
		this.data = new Array<T>();
		this._id = SmartArray._GlobalId++;
	}

	public function push(value:T):Void {
		this.data[this.length++] = value;
	}
	
	public function forEach(func:T->Void) {
		for (index in 0...this.length) {
			func(this.data[index]);
		}
	}

	inline public function sort(compareFn:T->T->Int) {
		this.data.sort(compareFn);
	}

	public function reset():Void {
		this.length = 0;
	}
	
	public function dispose() {
		this.reset();
		
		if (this.data != null) {
            this.data.splice(0, this.data.length);
            this.data = [];
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

	inline public function indexOf(value:T):Int {
		var position = this.data.indexOf(value);
		
		if (position >= this.length) {
			return -1;
		}
		
		return position;
	}

}
