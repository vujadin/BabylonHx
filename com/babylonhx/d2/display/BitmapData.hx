package com.babylonhx.d2.display;

import com.babylonhx.d2.events.EventDispatcher;
import com.babylonhx.d2.geom.Rectangle;

import com.babylonhx.utils.Image;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.GLBuffer;
import com.babylonhx.utils.GL.GLTexture;
import com.babylonhx.utils.GL.GLFramebuffer;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt32Array;
import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BitmapData {
	
	static private var _fbo:GLFramebuffer;
	
	public var width:Int;
	public var height:Int;
	public var rect:Rectangle;
	public var loader:EventDispatcher;
	
	public var _rwidth:Int;
	public var _rheight:Int;
	public var _rrect:Rectangle;
	public var _texture:GLTexture;
	public var _tcBuffer:GLBuffer;
	public var _vBuffer:GLBuffer;
	public var _loaded:Bool;
	
	public var _dirty:Bool;
	private var _gpuAllocated:Bool;
	private var _buffer:UInt8Array;
	private var _ubuffer:UInt32Array;
	

	public function new(img:Image) {
		// public
		this.width = 0;							// size of texture
		this.height = 0;
		this.rect = new Rectangle();						
		this.loader = new EventDispatcher();
		//this.loader.bitmapData = this;
		//this.loader.bytesLoaded = 0;
		//this.loader.bytesTotal = 0;
		
		// private
		this._rwidth  = 0;						// real size of bitmap in memory (power of two)
		this._rheight = 0;
		this._rrect   = null;
		this._texture = null;
		this._tcBuffer = null;					//	texture coordinates buffer
		this._vBuffer  = null;					//	four vertices of bitmap
		this._loaded = true;
		this._dirty  = true;					
		this._gpuAllocated = false;
		this._buffer  = null;					//  Uint8 container for texture
		this._ubuffer = null;					//  Uint32 container for texture
		
		if (img != null) {
			this._initFromImg(img, img.width, img.height);
		}
		
		/*
		this._opEv = new Event(Event.OPEN);
		this._pgEv = new Event(Event.PROGRESS);
		this._cpEv = new Event(Event.COMPLETE);
		
		this._opEv.target = this._pgEv.target = this._cpEv.target = this.loader;
		*/
		
		/*if (imgURL == null) {
			return;
		}
		
		var img = document.createElement("img");
		img.crossOrigin = "Anonymous";
		img.onload		= function(e){ this._initFromImg(img, img.width, img.height); var ev = new Event(Event.COMPLETE); this.loader.dispatchEvent(ev);}.bind(this);
		img.src 		= imgURL;*/
	}
	
	/* public */
	
	static public function empty(w:Int, h:Int, fc:Int = 0xffffffff):BitmapData {
		var bd = new BitmapData(null);
		bd._initFromImg(null, w, h, fc);
		
		return bd;
	}
	
	public function setPixel(x:Int, y:Int, color:Int) { 
		var i = y * this.width + x;
		var b = this._ubuffer;
		b[i] = (b[i] & 0xff000000) + color;
		this._dirty = true;
	}
	
	public function setPixel32(x:Int, y:Int, color:Int) { 
		var i = y * this.width + x;
		this._ubuffer[i] = color;
		this._dirty = true;
	}
	
	public function setPixels(r:Rectangle, buff:UInt8Array) {
		this._copyRectBuff(buff, r, this._buffer, this.rect);
		this._dirty = true;
	}
	
	public function getPixel(x:Int, y:Int):Int { 
		var i = y * this.width + x;
		
		return this._ubuffer[i] & 0xffffff;
	}
	
	public function getPixel32(x:Int, y:Int):Int { 
		var i = y * this.width + x;
		
		return this._ubuffer[i];
	}
	
	public function getPixels(r:Rectangle, ?buff:UInt8Array):UInt8Array {
		if (buff == null) {
			buff = new UInt8Array(Std.int(r.width * r.height * 4));
		}
		this._copyRectBuff(this._buffer, this.rect, buff, r);
		
		return buff;
	}
	
	public function draw(dobj:DisplayObject) {
		if (this._dirty) {
			this._syncWithGPU();
		}
		this._setTexAsFB();
		Stage._setTEX(null);
		dobj._render(Stage._main);
		
		var buff = this._buffer;
		var r = this.rect;
		GL.readPixels(cast r.x, cast r.y, cast r.width, cast r.height, GL.RGBA, GL.UNSIGNED_BYTE, buff);
		Stage._main._setFramebuffer(null, Stage._main.stageWidth, Stage._main.stageHeight, false);
		
		Stage._setTEX(this._texture);
		GL.generateMipmap(GL.TEXTURE_2D);
	}
	
	
	/* private */
	
	public function _syncWithGPU() {
		var r = this.rect;
		var buff = this._buffer;
		
		if (!this._gpuAllocated) {
			var w = r.width;
			var h = r.height;
			var xsc = w / this._rwidth;
			var ysc = h / this._rheight;
			
			this._texture = GL.createTexture();
			this._tcBuffer = GL.createBuffer();		//	texture coordinates buffer
			this._vBuffer  = GL.createBuffer();		//	four vertices of bitmap
			
			Stage._setBF(this._tcBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array([0, 0, xsc, 0, 0, ysc, xsc, ysc]), GL.STATIC_DRAW);
			
			Stage._setBF(this._vBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, new Float32Array([0, 0, 0, w, 0, 0, 0, h, 0, w, h, 0]), GL.STATIC_DRAW);
			
			var ebuff = new UInt8Array(this._rwidth * this._rheight * 4);
			var ebuff32 = new UInt32Array(ebuff.buffer);
			for (i in 0...ebuff32.length) {
				ebuff32[i] = 0x00ffffff;
			}
			
			Stage._setTEX(this._texture);
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, 
						this._rwidth, this._rheight, 0, GL.RGBA, 
						GL.UNSIGNED_BYTE, ebuff);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
			this._gpuAllocated = true;
		}
		
		Stage._setTEX(this._texture);
		GL.texSubImage2D(GL.TEXTURE_2D, 0, cast r.x, cast r.y, cast r.width, cast r.height,  GL.RGBA, GL.UNSIGNED_BYTE, buff);
		GL.generateMipmap(GL.TEXTURE_2D);
		this._dirty = false;
	}
	
	private function _setTexAsFB() {
		if(BitmapData._fbo == null) {
			BitmapData._fbo = GL.createFramebuffer();
			var rbo = GL.createRenderbuffer();
			GL.bindRenderbuffer(GL.RENDERBUFFER, rbo);
			GL.bindFramebuffer(GL.FRAMEBUFFER, BitmapData._fbo);
			GL.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, rbo);
		}
		
		Stage._main._setFramebuffer(BitmapData._fbo, this._rwidth, this._rheight, true);
		GL.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, this._texture, 0);
	}
	
	private function _initFromImg(img:Image, w:Int, h:Int, fc:Int = 0x000000) {
		this._loaded = true;
		this.width  = w;		// image width
		this.height = h;		// image.height
		this.rect = new Rectangle(0, 0, w, h);
		this._rwidth  = BitmapData._nhpot(w);	// width - power of Two
		this._rheight = BitmapData._nhpot(h);	// height - power of Two
		this._rrect = new Rectangle(0, 0, this._rwidth, this._rheight);
		
		var image:Image = null;
		if (img == null) {
			image = new Image(null, w, h);
		}
		else {
			image = img;
		}
		
		this._buffer = image.data;		
		this._ubuffer = new UInt32Array(this._buffer.buffer);	// another ArrayBufferView for the same buffer4
		
		if (img == null) {
			for (i in 0...this._ubuffer.length) {
				this._ubuffer[i] = fc;
			}
		}
	}
	
	private function _copyRectBuff(scc:UInt8Array, sr:Rectangle, tcc:UInt8Array, tr:Rectangle) {	// from buffer, from rect, to buffer, to rect
		var sc = new UInt32Array(scc.buffer);
		var tc = new UInt32Array(tcc.buffer);
		var ar = sr.intersection(tr);
		var sl = Math.max(0, ar.x - sr.x);
		var tl = Math.max(0, ar.x - tr.x);
		var st = Math.max(0, ar.y - sr.y);
		var tt = Math.max(0, ar.y - tr.y);
		var w = Std.int(ar.width);
		var h = Std.int(ar.height);
		
		for (i in 0...h) {
			var sind = Std.int((st + i) * sr.width + sl);
			var tind = Std.int((tt + i) * tr.width + tl);
			for (j in 0...w) {
				tc[tind++] = sc[cast sind++];
			}
		}
	}
	
	/*BitmapData._canv = document.createElement("canvas");
	BitmapData._ctx = BitmapData._canv.getContext("2d");*/

	inline static private function _ipot(x:Int):Bool {
		return (x & (x - 1)) == 0;
	}
	
	inline static private function _nhpot(x:Int):Int {
		--x;
		var i:Int = 1;
		while (i < 32) {
			x = x | x >> i;
			i <<= 1;
		}
		
		return x + 1;
	}
	
}
