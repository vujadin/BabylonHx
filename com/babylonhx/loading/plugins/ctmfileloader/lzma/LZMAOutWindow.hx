package com.babylonhx.loading.plugins.ctmfileloader.lzma;

import com.babylonhx.loading.plugins.ctmfileloader.CTMInterleavedStream;
import haxe.io.BytesInput;


/**
 * ...
 * @author Krtolica Vujadin
 */
class LZMAOutWindow {
	
	public var _windowSize:Int;
	public var _pos:Int;
	public var _streamPos:Int;
	public var _stream:CTMInterleavedStream;
	public var _buffer:Array<Int>;
	

	public function new() {
		this._windowSize = 0;
	}
	
	public function create(windowSize:Int) {
		if ((this._buffer == null) || (this._windowSize != windowSize)) {
			this._buffer = [];
		}
		
		this._windowSize = windowSize;
		this._pos = 0;
		this._streamPos = 0;
	}
	
	public function flush() {
		var size = this._pos - this._streamPos;
		if (size != 0) {
			while (size-- > 0) {
				this._stream.writeByte(this._buffer[this._streamPos++]);
			}
			if (this._pos >= this._windowSize) {
				this._pos = 0;
			}
			this._streamPos = this._pos;
		}
	}
	
	public function releaseStream() {
		this.flush();
		this._stream = null;
	}
	
	public function setStream(stream:CTMInterleavedStream) {
		this.releaseStream();
		this._stream = stream;
	}
	
	public function init(solid:Bool = false){
		if (!solid) {
			this._streamPos = 0;
			this._pos = 0;
		}
	}
	
	public function copyBlock(distance:Int, len:Int) {
		var pos = this._pos - distance - 1;
		if (pos < 0) {
			pos += this._windowSize;
		}
		while (len-- > 0) {
			if (pos >= this._windowSize){
				pos = 0;
			}
			this._buffer[this._pos++] = this._buffer[pos++];
			if (this._pos >= this._windowSize) {
				this.flush();
			}
		}
	}
	
	public function putByte(b:Int) {
		this._buffer[this._pos++] = b;
		if (this._pos >= this._windowSize) {
			this.flush();
		}
	}
	
	public function getByte(distance:Int):Int {
		var pos = this._pos - distance - 1;
		if (pos < 0) {
			pos += this._windowSize;
		}
		
		return this._buffer[pos];
	}
	
}
