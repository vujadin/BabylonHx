package com.babylonhx.loading.plugins.ctmfileloader;

import com.babylonhx.utils.typedarray.ArrayBufferView;
import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMInterleavedStream {
	
	public var data:UInt8Array;
	public var offset:Int;
	public var count:Int;
	public var len:Int;
	
	public function new(data:ArrayBufferView, count:Int) {
		this.data = new UInt8Array(data.buffer, data.byteOffset, data.byteLength);
		this.offset = CTM.isLittleEndian() ? 3 : 0;
		this.count = Std.int(count * 4);
		this.len = this.data.length;
	}
	
	public function writeByte(value:UInt) {
		this.data[this.offset] = value;
	  
		this.offset += this.count;
		if (this.offset >= this.len) {	  
			this.offset -= this.len - 4;
			if (this.offset >= this.count) {			
				this.offset -= this.count + (CTM.isLittleEndian() ? 1 : -1);
			}
		}
	}
	
}
