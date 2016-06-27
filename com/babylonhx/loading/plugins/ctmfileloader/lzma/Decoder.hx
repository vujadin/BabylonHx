package com.babylonhx.loading.plugins.ctmfileloader.lzma;

import com.babylonhx.loading.plugins.ctmfileloader.CTMInterleavedStream;
import haxe.io.BytesInput;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Decoder {
	
	public var _outWindow:LZMAOutWindow;
	public var _rangeDecoder:RangeDecoder;
	public var _isMatchDecoders:Array<Int>;
	public var _isRepDecoders:Array<Int>;
	public var _isRepG0Decoders:Array<Int>;
	public var _isRepG1Decoders:Array<Int>;
	public var _isRepG2Decoders:Array<Int>;
	public var _isRep0LongDecoders:Array<Int>;
	public var _posDecoders:Array<Int>;
	public var _posAlignDecoder:BitTreeDecoder;
	public var _lenDecoder:LenDecoder;
	public var _repLenDecoder:LenDecoder;
	public var _literalDecoder:LiteralDecoder;
	public var _dictionarySize:Int;
	public var _dictionarySizeCheck:Int;
	public var _posStateMask:Int;
	public var _posSlotDecoder:Array<BitTreeDecoder>;
	

	public function new() {
		this._outWindow = new LZMAOutWindow();
		this._rangeDecoder = new RangeDecoder();
		this._isMatchDecoders = [];
		this._isRepDecoders = [];
		this._isRepG0Decoders = [];
		this._isRepG1Decoders = [];
		this._isRepG2Decoders = [];
		this._isRep0LongDecoders = [];
		this._posSlotDecoder = [];
		this._posDecoders = [];
		this._posAlignDecoder = new BitTreeDecoder(4);
		this._lenDecoder = new LenDecoder();
		this._repLenDecoder = new LenDecoder();
		this._literalDecoder = new LiteralDecoder();
		this._dictionarySize = -1;
		this._dictionarySizeCheck = -1;
		
		this._posSlotDecoder[0] = new BitTreeDecoder(6);
		this._posSlotDecoder[1] = new BitTreeDecoder(6);
		this._posSlotDecoder[2] = new BitTreeDecoder(6);
		this._posSlotDecoder[3] = new BitTreeDecoder(6);
	}
	
	public function setDictionarySize(dictionarySize:Int):Bool {
		if (dictionarySize < 0){
			return false;
		}
		
		if (this._dictionarySize != dictionarySize) {
			this._dictionarySize = dictionarySize;
			this._dictionarySizeCheck = cast Math.max(this._dictionarySize, 1);
			this._outWindow.create(cast Math.max(this._dictionarySizeCheck, 4096));
		}
		
		return true;
	}
	
	public function setLcLpPb(lc:Int, lp:Int, pb:Int):Bool {
		var numPosStates = 1 << pb;
		
		if (lc > 8 || lp > 4 || pb > 4) {
			return false;
		}
		
		this._literalDecoder.create(lp, lc);
		
		this._lenDecoder.create(numPosStates);
		this._repLenDecoder.create(numPosStates);
		this._posStateMask = numPosStates - 1;
		
		return true;
	}
	
	public function init() {
		var i = 4;
		
		this._outWindow.init(false);
		
		LZMA.initBitModels(this._isMatchDecoders, 192);
		LZMA.initBitModels(this._isRep0LongDecoders, 192);
		LZMA.initBitModels(this._isRepDecoders, 12);
		LZMA.initBitModels(this._isRepG0Decoders, 12);
		LZMA.initBitModels(this._isRepG1Decoders, 12);
		LZMA.initBitModels(this._isRepG2Decoders, 12);
		LZMA.initBitModels(this._posDecoders, 114);
		
		this._literalDecoder.init();
		
		while (i-- > 0) {
			this._posSlotDecoder[i].init();
		}
		
		this._lenDecoder.init();
		this._repLenDecoder.init();
		this._posAlignDecoder.init();
		this._rangeDecoder.init();
	}
	
	public function decode(inStream:BytesInput, outStream:CTMInterleavedStream, outSize:Int):Bool {
		var state:Int = 0;
		var rep0:Int = 0;
		var rep1:Int = 0;
		var rep2:Int = 0;
		var rep3:Int = 0;
		var nowPos64:Int = 0;
		var prevByte:Int = 0;
		var posState:Int = 0;
		var decoder2:Decoder2;
		var len:Int = 0;
		var distance:Int = 0;
		var posSlot:Int = 0;
		var numDirectBits:Int = 0;
		
		this._rangeDecoder.setStream(inStream);
		this._outWindow.setStream(outStream);
		
		this.init();
		
		while (outSize < 0 || nowPos64 < outSize) {
			posState = nowPos64 & this._posStateMask;
			
			if (this._rangeDecoder.decodeBit(this._isMatchDecoders, (state << 4) + posState) == 0) {
				decoder2 = this._literalDecoder.getDecoder(nowPos64++, prevByte);
				
				if (state >= 7) {
					prevByte = decoder2.decodeWithMatchByte(this._rangeDecoder, this._outWindow.getByte(rep0));
				}
				else {
					prevByte = decoder2.decodeNormal(this._rangeDecoder);
				}
				this._outWindow.putByte(prevByte);
				
				state = state < 4 ? 0: state - (state < 10 ? 3 : 6);
			}
			else {
				if (this._rangeDecoder.decodeBit(this._isRepDecoders, state) == 1) {
					len = 0;
					if (this._rangeDecoder.decodeBit(this._isRepG0Decoders, state) == 0) {
						if (this._rangeDecoder.decodeBit(this._isRep0LongDecoders, (state << 4) + posState) == 0) {
							state = state < 7 ? 9 : 11;
							len = 1;
						}
					}
					else {
						if (this._rangeDecoder.decodeBit(this._isRepG1Decoders, state) == 0) {
							distance = rep1;
						}
						else {
							if (this._rangeDecoder.decodeBit(this._isRepG2Decoders, state) == 0) {
								distance = rep2;
							}
							else {
								distance = rep3;
								rep3 = rep2;
							}
							
							rep2 = rep1;
						}
						
						rep1 = rep0;
						rep0 = distance;
					}
					if (len == 0) {
						len = 2 + this._repLenDecoder.decode(this._rangeDecoder, posState);
						state = state < 7 ? 8 : 11;
					}
				}
				else {
					rep3 = rep2;
					rep2 = rep1;
					rep1 = rep0;
					
					len = 2 + this._lenDecoder.decode(this._rangeDecoder, posState);
					state = state < 7 ? 7 : 10;
					
					posSlot = this._posSlotDecoder[len <= 5 ? len - 2 : 3].decode(this._rangeDecoder);
					if (posSlot >= 4) {
						numDirectBits = (posSlot >> 1) - 1;
						rep0 = (2 | (posSlot & 1)) << numDirectBits;
						
						if (posSlot < 14) {
							rep0 += LZMA.reverseDecode2(this._posDecoders,
								rep0 - posSlot - 1, this._rangeDecoder, numDirectBits);
						}
						else {
							rep0 += this._rangeDecoder.decodeDirectBits(numDirectBits - 4) << 4;
							rep0 += this._posAlignDecoder.reverseDecode(this._rangeDecoder);
							if (rep0 < 0) {
								if (rep0 == -1) {
									break;
								}
								
								return false;
							}
						}
					}
					else {
						rep0 = posSlot;
					}
				}
				
				if (rep0 >= nowPos64 || rep0 >= this._dictionarySizeCheck) {
					return false;
				}
				
				this._outWindow.copyBlock(rep0, len);
				nowPos64 += len;
				prevByte = this._outWindow.getByte(0);
			}
		}
		
		this._outWindow.flush();
		this._outWindow.releaseStream();
		this._rangeDecoder.releaseStream();
		
		return true;
	}
	
	public function setDecoderProperties(properties:BytesInput){
		var value:Int = 0;
		var lc:Int = 0;
		var lp:Int = 0;
		var pb:Int = 0;
		var dictionarySize:Int = 0;
		
		// VK TODO
		/*if (properties.size < 5){
			return false;
		}*/
		
		value = properties.readByte();
		lc = value % 9;
		value = cast ~~(value / 9);
		lp = value % 5;
		pb = cast ~~(value / 5);
		
		if (!this.setLcLpPb(lc, lp, pb)) {
			return false;
		}
		
		dictionarySize = properties.readByte();
		dictionarySize |= properties.readByte() << 8;
		dictionarySize |= properties.readByte() << 16;
		dictionarySize += properties.readByte() * 16777216;
		
		return this.setDictionarySize(dictionarySize);
	}
	
}
