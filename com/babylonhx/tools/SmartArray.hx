package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.SmartArray') class SmartArray {
	
	private static var _GlobalId:Int = 0;
	
	public var data:Array<Dynamic>;
	public var length:Int = 0;
	
	public var __smartArrayFlags:Array<Int>;

	private var _id:Int;
	private var _duplicateId:Int = 0;
	

	public function new(capacity:Int = 256) {
		this.data = new Array<Dynamic>();
		this._id = SmartArray._GlobalId++;
	}

	inline public function push(value:Dynamic):Void {
		this.data[this.length++] = value;
		//trace(value);
		if (value.__smartArrayFlags == null) {
			value.__smartArrayFlags = [];
		}
		
		value.__smartArrayFlags[this._id] = this._duplicateId;
	}

	public function pushNoDuplicate(value:Dynamic):Void {
		if(value.__smartArrayFlags != null && value.__smartArrayFlags[this._id] == this._duplicateId) {
			return;
		}
		
		this.push(value);
	}

	inline public function sort(compareFn:Dynamic->Dynamic->Int):Void {
		this.data.sort(compareFn);
	}

	inline public function reset():Void {
		this.length = 0;
		this._duplicateId++;
	}

	inline public function concat(array:Dynamic):Void {
		if (array.length != 0) {		
			for (index in 0...array.length) {
				this.data[this.length++] = (array.data != null ? array.data : array)[index];
			}
		}
	}

	inline public function concatWithNoDuplicate(array:Dynamic):Void {
		if (array.length != 0) {
			for (index in 0...array.length) {
				var item = (array.data != null ? array.data : array)[index];
				this.pushNoDuplicate(item);
			}
		}
	}

	public function indexOf(value:Dynamic):Int {
		var position = this.data.indexOf(value);
		
		if (position >= this.length) {
			return -1;
		}
		
		return position;
	}

}
