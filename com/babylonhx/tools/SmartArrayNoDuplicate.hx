package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SmartArrayNoDuplicate<T:ISmartArrayCompatible> extends SmartArray<T> {
	
	private var _duplicateId:Int = 0;
	
	
	public function new(capacity:Int) {
		super(capacity);
	}
	
	override public function push(value:T) {
		super.push(value);
		
		value.__smartArrayFlags[this._id] = this._duplicateId;
	}

	public function pushNoDuplicate(value:T):Bool {
		if (value.__smartArrayFlags[this._id] == this._duplicateId) {
			return false;
		}
		this.push(value);
		return true;
	}

	override public function reset() {
		super.reset();
		this._duplicateId++;
	}

	public function concatArrayWithNoDuplicate(array:Array<T>) {
		if (array.length == 0) {
			return;
		}
		
		for (index in 0...array.length) {
			var item = array[index];
			this.pushNoDuplicate(item);
		}
	}
	
	public function concatSmartArrayWithNoDuplicate(array:SmartArray<T>) {
		if (array.length == 0) {
			return;
		}
		
		for (index in 0...array.length) {
			var item = array.data[index];
			this.pushNoDuplicate(item);
		}
	}
	
}
