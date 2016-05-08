package com.babylonhx.loading.plugins.ctmfileloader.lzma;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BitTreeDecoder {
	
	public var _models:Array<Int>;
	public var _numBitLevels:Int;
	

	public function new(numBitLevels:Int) {
		this._models = [];
		this._numBitLevels = numBitLevels;
	}
	
	public function init() {
		LZMA.initBitModels(this._models, 1 << this._numBitLevels);
	}
	
	public function decode(rangeDecoder:RangeDecoder):Int { 
		var m = 1;
		var i = this._numBitLevels;
		
		while (i-- > 0) {
			m = (m << 1) | rangeDecoder.decodeBit(this._models, m);
		}
		
		return m - (1 << this._numBitLevels);
	}
	
	public function reverseDecode(rangeDecoder:RangeDecoder):Int {
		var m:Int = 1;
		var symbol:Int = 0;
		var bit:Int = 0;
		
		for (i in 0...this._numBitLevels) {
			bit = rangeDecoder.decodeBit(this._models, m);
			m = (m << 1) | bit;
			symbol |= bit << i;
		}
		
		return symbol;
	}
	
}
