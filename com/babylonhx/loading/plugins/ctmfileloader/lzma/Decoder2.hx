package com.babylonhx.loading.plugins.ctmfileloader.lzma;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Decoder2 {
	
	public var _decoders:Array<Int>;
	

	public function new() {
		this._decoders = [];
	}
	
	public function init() {
		LZMA.initBitModels(this._decoders, 0x300);
	}
	
	public function decodeNormal(rangeDecoder:RangeDecoder):Int {
		var symbol = 1;
		
		do {
			symbol = (symbol << 1) | rangeDecoder.decodeBit(this._decoders, symbol);
		}
		while (symbol < 0x100);
		
		return symbol & 0xff;
	}
	
	public function decodeWithMatchByte(rangeDecoder:RangeDecoder, matchByte:Int):Int {
		var symbol = 1;
		var matchBit:Int = 0;
		var bit:Int = 0;
		
		do {
			matchBit = (matchByte >> 7) & 1;
			matchByte <<= 1;
			bit = rangeDecoder.decodeBit(this._decoders, ( (1 + matchBit) << 8) + symbol);
			symbol = (symbol << 1) | bit;
			if (matchBit != bit) {
				while(symbol < 0x100){
					symbol = (symbol << 1) | rangeDecoder.decodeBit(this._decoders, symbol);
				}
				
				break;
			}
		}
		while (symbol < 0x100);
		
		return symbol & 0xff;
	}
	
}
