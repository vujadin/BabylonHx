package com.babylonhx.loading.plugins.ctmfileloader.lzma;

import haxe.io.BytesInput;

/**
 * ...
 * @author Krtolica Vujadin
 */
class LZMA {

	static public function initBitModels(probs:Array<Int>, len:Int) {
		while (len-- > 0) {
			probs[len] = 1024;
		}
	}
	
	static public function reverseDecode2(models:Array<Int>, startIndex:Int, rangeDecoder:RangeDecoder, numBitLevels:Int):Int {
		var m:Int = 1;
		var symbol:Int = 0;
		var bit:Int = 0;
		
		for (i in 0...numBitLevels) {
			bit = rangeDecoder.decodeBit(models, startIndex + m);
			m = (m << 1) | bit;
			symbol |= bit << i;
		}
	  
		return symbol;
	}
	
	static public function decompress(properties:BytesInput, inStream:BytesInput, outStream:CTMInterleavedStream, outSize:Int):Bool {
		var decoder:Decoder = new Decoder();
		
		if (!decoder.setDecoderProperties(properties)) {
			throw "Incorrect stream properties";
		}
		
		if (!decoder.decode(inStream, outStream, outSize)) {
			throw "Error in data stream";
		}
		
		return true;
	}
	
	static public function decompressFile(inStream:BytesInput, outStream:CTMInterleavedStream):Bool {
		var decoder:Decoder = new Decoder();
		var outSize:Int = 0;
		
		if (!decoder.setDecoderProperties(inStream)) {
			throw "Incorrect stream properties";
		}
		
		outSize = inStream.readByte();
		outSize |= inStream.readByte() << 8;
		outSize |= inStream.readByte() << 16;
		outSize += inStream.readByte() * 16777216;
		
		inStream.readByte();
		inStream.readByte();
		inStream.readByte();
		inStream.readByte();
		
		if (!decoder.decode(inStream, outStream, outSize)) {
			throw "Error in data stream";
		}
		
		return true;
	}
	
}
