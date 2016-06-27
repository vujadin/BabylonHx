package com.babylonhx.loading.plugins.ctmfileloader.lzma;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LenDecoder {
	
	public var _choice:Array<Int>;
	public var _lowCoder:Array<BitTreeDecoder>;
	public var _midCoder:Array<BitTreeDecoder>;
	public var _highCoder:BitTreeDecoder;
	public var _numPosStates:Int;
	

	public function new() {
		this._choice = [];
		this._lowCoder = [];
		this._midCoder = [];
		this._highCoder = new BitTreeDecoder(8);
		this._numPosStates = 0;
	}
	
	public function create(numPosStates:Int) {
		while (this._numPosStates < numPosStates) {
			this._lowCoder[this._numPosStates] = new BitTreeDecoder(3);
			this._midCoder[this._numPosStates] = new BitTreeDecoder(3);
			
			++this._numPosStates;
		}
	}
	
	public function init() {
		var i = this._numPosStates;
		LZMA.initBitModels(this._choice, 2);
		while (i-- > 0) {
			this._lowCoder[i].init();
			this._midCoder[i].init();
		}
		this._highCoder.init();
	}
	
	public function decode(rangeDecoder:RangeDecoder, posState:Int):Int {
		if (rangeDecoder.decodeBit(this._choice, 0) == 0){
			return this._lowCoder[posState].decode(rangeDecoder);
		}
		if (rangeDecoder.decodeBit(this._choice, 1) == 0){
			return 8 + this._midCoder[posState].decode(rangeDecoder);
		}
	  
		return 16 + this._highCoder.decode(rangeDecoder);
	}
	
}
