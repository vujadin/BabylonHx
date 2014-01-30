package com.gamestudiohx.babylonhx.tools;

/**
 * Port of BabylonJs project - http://www.babylonjs.com/
 * ...
 * @author Krtolica Vujadin
 */

class SmartArray {
	
	public var data:Array<Dynamic>;
	public var length:Int;

	public function new() {
		this.data = [];
		this.length = 0;
	}
	
	public function push(value:Dynamic) {
		this.data[this.length++] = value;
        
        /*if (this.length > this.data.length) {
            this.data.length *= 2;
        }*/
	}
	
	public function pushNoDuplicate(value:Dynamic) {
		if (Lambda.indexOf(this.data, value) == -1) {
            this.push(value);
        }        
	}
	
	public function sort(compareFn:Dynamic->Dynamic->Int) {
		this.data.sort(compareFn);
	}
	
	public function reset() {
		this.length = 0;
		//this.data = [];
	}
	
	public function concat(array:Dynamic) {		
		// TODO - inspect and fix this
		if (Std.is(array, Array) && array.length != 0) { 
			/*if (this.length + array.length > this.data.length) {
				this.data.length = (this.length + array.length) * 2;
			}*/
			for (index in 0...array.length) {
				this.data[this.length++] = Std.is(array, Array) ? array[index] : array.data[index];// (array.data || array)[index];
			}
		}
	}
	
	public function concatWithNoDuplicate(array:Dynamic) {
		if (Std.is(array, Array) && array.length == 0) {
            return;
        }
        /*if (this.length + array.length > this.data.length) {
            this.data.length = (this.length + array.length) * 2;
        }*/

        for (index in 0...array.length) {
            var item = Std.is(array, Array) ? array[index] : array.data[index];
            var pos = Lambda.indexOf(this.data, item);

            if (pos == -1 || pos >= this.length) {
                this.data[this.length++] = item;
            }
        }
	}
	
	public function indexOf(value:Dynamic):Int {
		var position = Lambda.indexOf(this.data, value);
        
        if (position >= this.length) {
            return -1;
        }

        return position;
	}
		
}
