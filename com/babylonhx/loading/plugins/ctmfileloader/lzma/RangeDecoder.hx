package com.babylonhx.loading.plugins.ctmfileloader.lzma;

import haxe.io.BytesInput;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RangeDecoder {
	
	public var _stream:BytesInput;
	public var _code:Int;
	public var _range:Int;
	

	public function new() {
		
	}
	
	public function setStream(stream:BytesInput) {
		this._stream = stream;
	}
	
	public function releaseStream() {
		this._stream = null;
	}
	
	public function init() {
		var i = 5;
		
		this._code = 0;
		this._range = -1;
	  
		while (i-- > 0) {
			this._code = (this._code << 8) | this._stream.readByte();
		}
	}
	
	public function decodeDirectBits(numTotalBits:Int):Int {
		var result = 0;
		var i = numTotalBits;
		var t:Int;
		
		while (i-- > 0) {
			this._range >>>= 1;
			t = (this._code - this._range) >>> 31;
			this._code -= this._range & (t - 1);
			result = (result << 1) | (1 - t);
			
			if ((this._range & 0xff000000) == 0) {
				this._code = (this._code << 8) | this._stream.readByte();
				this._range <<= 8;
			}
		}
		
		return result;
	}
	
	public function decodeBit(probs:Array<Int>, index:Int):Int {
		var prob:Int = probs[index];
		var newBound:Int = (this._range >>> 11) * prob;
		
		if ((this._code ^ 0x80000000) < (newBound ^ 0x80000000)) {
			this._range = newBound;
			probs[index] += (2048 - prob) >>> 5;
			if ((this._range & 0xff000000) == 0) {
				this._code = (this._code << 8) | this._stream.readByte();
				this._range <<= 8;
			}
			
			return 0;
		}
		
		this._range -= newBound;
		this._code -= newBound;
		probs[index] -= prob >>> 5;
		if ((this._range & 0xff000000) == 0) {
			this._code = (this._code << 8) | this._stream.readByte();
			this._range <<= 8;
		}
		
		return 1;
	}
	
}
