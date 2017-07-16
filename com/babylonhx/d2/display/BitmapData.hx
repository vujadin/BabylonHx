package com.babylonhx.d2.display;

import com.babylonhx.d2.events.EventDispatcher;
import com.babylonhx.d2.geom.Rectangle;
import com.babylonhx.d2.geom.Point;

import com.babylonhx.utils.Image;

import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLFramebuffer;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;
import lime.utils.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BitmapData {
	
	static private var _fbo:GLFramebuffer;
	
	public var width:Int;
	public var height:Int;
	public var rect:Rectangle;
	
	public var _rwidth:Int;
	public var _rheight:Int;
	public var _rrect:Rectangle;
	public var _texture:GLTexture;
	public var _tcBuffer:GLBuffer;
	public var _vBuffer:GLBuffer;
	
	public var _dirty:Bool;
	private var _gpuAllocated:Bool;
	public var _buffer:UInt8Array;
	private var _ubuffer:UInt32Array;


	public function new(img:Image) {
		// public
		this.width = 0;							// size of texture
		this.height = 0;
		this.rect = new Rectangle();						
		
		// private
		this._rwidth  = 0;						// real size of bitmap in memory (power of two)
		this._rheight = 0;
		this._rrect   = null;
		this._texture = null;
		this._tcBuffer = null;					//	texture coordinates buffer
		this._vBuffer  = null;					//	four vertices of bitmap
		this._dirty  = true;					
		this._gpuAllocated = false;
		this._buffer  = null;					//  Uint8 container for texture
		this._ubuffer = null;					//  Uint32 container for texture

		if (img != null) {
			this._initFromImg(img, img.width, img.height);
		}
	}
	
	/* public */
	
	static public function empty(w:Int, h:Int, fc:Int = 0x00000000):BitmapData {
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
	
	public function cleanPixels(rect:Rectangle) {
		var _w = Std.int(rect.width);
		var _h = Std.int(rect.height);
		var _x = Std.int(rect.x);
		var _y = Std.int(rect.y);
		for (i in 0..._h) {
			for (j in 0..._w) {
				_ubuffer[Std.int(((i + _y) * this.width) + _x + j)] = 0x00000000;
			}
		}			
	}
	
	public function copyPixels(sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point) {
		var tr = new Rectangle(destPoint.x, destPoint.y, sourceRect.width, sourceRect.height);
		var sr = sourceRect;
		
		var tcc = this._ubuffer;		
		var scc = sourceBitmapData._ubuffer;
		
		var height = Std.int(sr.height);
		var width = Std.int(sr.width);
		
		for (i in 0...height) {
			for (j in 0...width) {
				tcc[Std.int(((i + tr.y) * this.width) + tr.x + j)] = scc[Std.int(((i + sr.y) * sourceBitmapData.width) + sr.x + j)];
			}
		}
		this._dirty = true;
	}
	
	public function draw(dobj:DisplayObject) {
		var stage = dobj.stage;
        var Gl = stage.Gl;
		if (this._dirty) {
			this._syncWithGPU(stage);
		}
		this._setTexAsFB(stage);
		
		stage._setTEX(null);
		dobj._render();
		
		var buff = this._buffer;
		var r = this.rect;
		Gl.readPixels(cast r.x, cast r.y, cast r.width, cast r.height, GL.RGBA, GL.UNSIGNED_BYTE, buff);
		stage._setFramebuffer(null, stage.stageWidth, stage.stageHeight, false);
		
		stage._setTEX(this._texture);
		Gl.generateMipmap(GL.TEXTURE_2D);
	}
	
	
	/* private */
	
	public function _syncWithGPU(st:Stage) {
		var r = this.rect;
		var buff = this._buffer;
		var Gl = st.Gl;
		
		if (!this._gpuAllocated) {
			var w = r.width;
			var h = r.height;
			var xsc = w / this._rwidth;
			var ysc = h / this._rheight;
			
			this._texture = Gl.createTexture();
			this._tcBuffer = Gl.createBuffer();		//	texture coordinates buffer
			this._vBuffer  = Gl.createBuffer();		//	four vertices of bitmap
			
			st._setBF(this._tcBuffer);
			Gl.bufferData(GL.ARRAY_BUFFER, #if cpp 8, #end new Float32Array([0, 0, xsc, 0, 0, ysc, xsc, ysc]), GL.STATIC_DRAW);
			
			st._setBF(this._vBuffer);
			Gl.bufferData(GL.ARRAY_BUFFER, #if cpp 12, #end new Float32Array([0, 0, 0, w, 0, 0, 0, h, 0, w, h, 0]), GL.STATIC_DRAW);
			
			var ebuff = new UInt8Array(this._rwidth * this._rheight * 4);
			var ebuff32 = new UInt32Array(ebuff.buffer);
			for (i in 0...ebuff32.length) {
				ebuff32[i] = 0x00ffffff;
			}
			
			st._setTEX(this._texture);
			Gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, this._rwidth, this._rheight, 0, GL.RGBA, GL.UNSIGNED_BYTE, ebuff);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
			Gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
			this._gpuAllocated = true;
		}
		
		st._setTEX(this._texture);
		Gl.texSubImage2D(GL.TEXTURE_2D, 0, cast r.x, cast r.y, cast r.width, cast r.height,  GL.RGBA, GL.UNSIGNED_BYTE, buff);
		Gl.generateMipmap(GL.TEXTURE_2D);
		this._dirty = false;
	}
	
	private function _setTexAsFB(st:Stage) {
		var Gl = st.Gl;
		if(BitmapData._fbo == null) {
			BitmapData._fbo = Gl.createFramebuffer();
			var rbo = Gl.createRenderbuffer();
			Gl.bindRenderbuffer(GL.RENDERBUFFER, rbo);
			Gl.bindFramebuffer(GL.FRAMEBUFFER, BitmapData._fbo);
			Gl.framebufferRenderbuffer(GL.FRAMEBUFFER, GL.DEPTH_ATTACHMENT, GL.RENDERBUFFER, rbo);
		}
		
		st._setFramebuffer(BitmapData._fbo, this._rwidth, this._rheight, true);
		Gl.framebufferTexture2D(GL.FRAMEBUFFER, GL.COLOR_ATTACHMENT0, GL.TEXTURE_2D, this._texture, 0);
	}
	
	private function _initFromImg(img:Image, w:Int, h:Int, fc:Int = 0x000000) {
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
