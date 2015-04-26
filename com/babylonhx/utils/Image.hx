package com.babylonhx.utils;

import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Image {
	

	public var data:UInt8Array;
	public var dirty:Bool = true;
	public var height:Int = 0;
	public var offsetX:Int = 0;
	public var offsetY:Int = 0;
	//public var powerOfTwo (get, set):Bool;
	//public var premultiplied (get, set):Bool;
	//public var rect (get, null):Rectangle;
	//public var src (get, set):Dynamic;
	public var transparent:Bool = false;
	public var width:Int = 0;
	public var x:Float = 0;
	public var y:Float = 0;
	
	

	public function new(data:UInt8Array, width:Int, height:Int) {
		this.width = width;
		this.height = height;
		if(data != null){
			this.data = data;
		}else{
			this.data = new UInt8Array (width * height * 4);
		}
	}
	
}
