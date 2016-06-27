package com.babylonhx.loading.plugins.ctmfileloader.lzma;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LiteralDecoder {
	
	public var _coders:Array<Decoder2>;
	public var _numPrevBits:Int;
	public var _numPosBits:Int;
	public var _posMask:Int;
	

	public function new() {
		
	}
	
	public function create(numPosBits:Int, numPrevBits:Int) {
		if (this._coders != null && (this._numPrevBits == numPrevBits) && (this._numPosBits == numPosBits)) {
			return;
		}
		
		this._numPosBits = numPosBits;
		this._posMask = (1 << numPosBits) - 1;
		this._numPrevBits = numPrevBits;
		
		this._coders = [];
		
		var i = 1 << (this._numPrevBits + this._numPosBits);
		while (i-- > 0) {
			this._coders[i] = new Decoder2();
		}
	}
	
	public function init() {
		var i:Int = 1 << (this._numPrevBits + this._numPosBits);
		while (i-- > 0) {
			this._coders[i].init();
		}
	}
	
	public function getDecoder(pos:Int, prevByte:Int):Decoder2 {
		return this._coders[((pos & this._posMask) << this._numPrevBits)
			+ ((prevByte & 0xff) >>> (8 - this._numPrevBits))];
	}
	
}
