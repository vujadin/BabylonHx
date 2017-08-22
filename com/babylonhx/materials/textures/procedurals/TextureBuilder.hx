package com.babylonhx.materials.textures.procedurals;

import com.babylonhx.Scene;
import com.babylonhx.utils.Image;
import com.babylonhx.math.RGBA;

import lime.utils.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

// port of http://ainc.de/ Texture Editor
class TextureBuilder {

	// table used for shift operations
	static var powtab:Array<Int> = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512];

	static var matrix:Array<Array<Float>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0]];

	static public inline var PI:Float = 3.1415926535897932384626433832795;

	public var MAX_LAYERS:Int = 5;
	public var TEMPL:Int = 5;
	public var MAX_TEXTURE_SIZE:Int = 1024;
	public var MAX_STUFF:Int = 100;
	public var MAX_PARAM:Int = 10;
	public var DO_NOTHING:Int = 0xffff;

	var layers:Array<Array<RGBA>> = [];

	var seedValue:Int = 0;
	var layerSizeX:Int = 0;
	var layerSizeY:Int = 0;
	var SXtimeSY:Int = 0;
	var andLayerSizeX:Int = 0;
	var andLayerSizeY:Int = 0;

	public function new(sizeX:Int, sizeY:Int) {
		SXtimeSY = Std.int(sizeX * sizeY);
		
		for (i in 0...this.MAX_LAYERS + 1) {		
			this.layers[i] = [];
			for (x in 0...SXtimeSY) {
				this.layers[i][x] = RGBA.White;
			}		
		}		
		
		this.layerSizeX = sizeX;
		this.layerSizeY = sizeY;
		this.andLayerSizeX = sizeX - 1;
		this.andLayerSizeY = sizeY - 1;
	}

	public function setLayer(layer:Int, image:Image) {
		for (i in 0...layerSizeX) {
			for (j in 0...layerSizeY) {
				layers[layer][i + j * layerSizeX] = cast image.getPixelAt(i, j);
			}
		}
	}

	public function generateTexture(layer:Int, scene:Scene, name:String):Texture {
		var data = new UInt8Array(layerSizeX * layerSizeY * 4);
		var index:Int = 0;
		
		for (x in 0...SXtimeSY) {
			index = 4 * x;
			data[index]     = this.layers[layer][x].r;
			data[index + 1] = this.layers[layer][x].g;
			data[index + 2] = this.layers[layer][x].b;
			data[index + 3] = this.layers[layer][x].a;
		}	
		
		var img = new Image(data, layerSizeX, layerSizeY);
		var ret = Texture.fromImage(img, scene);
		
		return ret;
	}

	inline function myRandom(from:Int = 0, to:Int = 100000):Int {
		return from + Math.floor(((to - from + 1) * Math.random()));
	}

	function cosineInterpolate(v:Array<RGBA>, x:Float, y:Float):RGBA {
		var f1:Float;
		var f2:Float;
		var mf1:Float;
		var mf2:Float;
		var g0:Float;
		var g1:Float;
		var g2:Float;
		var g3:Float;
		var color = RGBA.White;
		mf1 = (1 - Math.cos(x * Math.PI)) * 0.5;
		mf2 = (1 - Math.cos(y * Math.PI)) * 0.5;
		f1 = 1 - mf1;
		f2 = 1 - mf2;
		g0 = f1 * f2;
		g1 = mf1 * f2;
		g2 = f1 * mf2;
		g3 = mf1 * mf2;
		
		color.r = trunc(v[0].r * g0 + v[1].r * g1 + v[2].r * g2 + v[3].r * g3);
		color.g = trunc(v[0].g * g0 + v[1].g * g1 + v[2].g * g2 + v[3].g * g3);
		color.b = trunc(v[0].b * g0 + v[1].b * g1 + v[2].b * g2 + v[3].b * g3);
		
		return color;
	}

	inline public function fmod(a:Float, b:Float):Float {
		var x = Math.floor(a / b);
		
		return a - b * x;
	}

	inline function lshift(a:Int, shift:Int):Int {
		// logical shift left
		if (shift > 7) {
			a = 0; // if shifting more than 15 bits to the left, value is always zero
		} 
		else {
			a *= powtab[shift];
		}
		
		return a;
	}

	inline function rshift(a:Int, shift:Int):Int {
		// logical shift right (unsigned)
		if (shift > 7) {
			a = 0; // more than 15, becomes zero
		} 
		else {
			a = Std.int(a / powtab[shift]);
		}
		
		return a;
	}

	static var c:Int = 0;
	inline function or(a:Int, b:Int):Int {
		// OR (|)
		c = 0;
		for (x in 0...7 + 1) {
			c += c;
			if (a < 0) {
				c += 1;
			} 
			else if (b < 0) {
				c += 1;
			}
			a += a;
			b += b;
		}
		
		return c;
	}

	function byteLow(i:Float):Int {
		return Std.int(i % 256);
	}

	private function hsv2rgb(hsv:Array<Float>, rgb:Array<Float>) {
		var f:Float = 0;
		var p:Float = 0;
		var q:Float = 0;
		var t:Float = 0;
		var i:Int = 0;
		
		while (hsv[0] < 0) {
			hsv[0] += 360;
		}
		while (hsv[0] >= 360) {
			hsv[0] -= 360;
		}
		
		if (hsv[1] == 0) {
			rgb[0] = hsv[2];
			rgb[1] = hsv[2];
			rgb[2] = hsv[2];
		}
		else {
			hsv[0] /= 60;
			i = Std.int(byteLow(hsv[0]));
			f = fmod(hsv[0], 1);
			f = (hsv[0] - i);
			p = hsv[2] * (1 - hsv[1]);
			q = hsv[2] * (1 - (hsv[1] * f));
			t = hsv[2] * (1 - (hsv[1] * (1 - f)));
			switch(i) {
				case 0:	
					rgb[0] = hsv[2]; rgb[1] = t; rgb[2] = p; 
				case 1:	
					rgb[0] = q; rgb[1] = hsv[2]; rgb[2] = p;
				case 2:	
					rgb[0] = p; rgb[1] = hsv[2]; rgb[2] = t;
				case 3:	
					rgb[0] = p; rgb[1] = q; rgb[2] = hsv[2];
				case 4:	
					rgb[0] = t; rgb[1] = p; rgb[2] = hsv[2];
				case 5:	
					rgb[0] = hsv[2]; rgb[1] = p; rgb[2] = q;
			}
		}
	}

	private function rgb2hsv(rgb:Array<Float>, hsv:Array<Float>) { // h:Float, s:Float, v:Float) {
		var maxR:Float = 0;
		var maxG:Float = 0;
		var maxB:Float = 0;
		var delta:Float = 0;
		var mx = Math.max(rgb[0], Math.max(rgb[1], rgb[2]));
		var mn = Math.min(rgb[0], Math.min(rgb[1], rgb[2]));
		
		hsv[2] = mx;
		hsv[1] = 0;
		
		if (mx != 0) {
			hsv[1] = (mx - mn) / mx;
		}
		if (hsv[1] == 0) {
			hsv[0] =- 1;
		}
		else {
			delta = mx - mn;
			maxR = mx - rgb[0];
			maxG = mx - rgb[1];
			maxB = mx - rgb[2];
			if (rgb[0] == mx) {
				hsv[0] = (maxB - maxG) / delta;
			}
			else {
				if (rgb[1] == mx) {
					hsv[0] = 2 + (maxR - maxB) / delta;
				}
				else {
					hsv[0] = 4 + (maxG - maxR) / delta;
				}
			}
			hsv[0] *= 60;
			while (hsv[0] < 0) {
				hsv[0] += 360;
			}
			while (hsv[0] >= 360) {
				hsv[0] -= 360;
			}
		}
	}

	private function getBilerPixel(l:Int, x:Float, y:Float):RGBA {
		var corner:Array<RGBA> = [RGBA.White, RGBA.White, RGBA.White, RGBA.White];
		var xi:Int = 0;
		var yi:Int = 0;
		var xip:Int = 0;
		var xip1:Int = 0;
		var yip:Int = 0;
		var yip1:Int = 0;
		
		xi = Std.int(x);
		yi = Std.int(y);
		xip = xi & this.andLayerSizeX;
		xip1 = (xi + 1) & this.andLayerSizeX;
		yip1 = ((yi + 1) & this.andLayerSizeY) * this.layerSizeX;
		yip = (yi & this.andLayerSizeY) * this.layerSizeX;
		
		corner[0] = this.layers[l][xip + yip];
		corner[1] = this.layers[l][xip1 + yip];
		corner[2] = this.layers[l][xip + yip1];
		corner[3] = this.layers[l][xip1 + yip1];
		
		return cosineInterpolate(corner, (x - xi), (y - yi));
	}

	public function subPlasma(l:Int, dist:Int, seed:Int, amplitude:Int, rgb:Bool):TextureBuilder {
		var x:Int = 0;
		var y:Int = 0;
		var offset:Int = 0;
		var offset2:Int = 0;
		var corner:Array<RGBA> = [RGBA.White, RGBA.White, RGBA.White, RGBA.White];
		var oodist:Float = 0;
		
		if (seed != 0) {
			this.seedValue = seed;
		}
		
		while (y < this.layerSizeY) {
			x = 0;
			while (x < this.layerSizeX) {
				offset = y * this.layerSizeX + x;
				this.layers[l][offset].r = this.layers[l][offset].g = this.layers[l][offset].b = byteLow(myRandom()) & (amplitude - 1);
				if (rgb) {
					this.layers[l][offset].g = byteLow(myRandom()) & (amplitude - 1);
					this.layers[l][offset].b = byteLow(myRandom()) & (amplitude - 1);
				}
				
				x += dist;
			}
			
			y += dist;
		}
		
		if (dist < 1) {
			return this;
		}
		
		oodist = 1 / dist;
		
		y = 0;
		while (y < this.layerSizeY) {
			offset = y * this.layerSizeX;
			offset2 = ((y + dist) & this.andLayerSizeY) * this.layerSizeX;
			x = 0;
			while (x < this.layerSizeX) {
				corner[0] = this.layers[l][x + offset];
				corner[1] = this.layers[l][((x + dist) & this.andLayerSizeX) + offset];
				corner[2] = this.layers[l][x + offset2];
				corner[3] = this.layers[l][((x + dist) & this.andLayerSizeX) + offset2];
				for (b in 0...dist) {
					for (a in 0...dist) {
						this.layers[l][x + a + (y + b) * this.layerSizeX] = cosineInterpolate(corner, oodist * a, oodist * b);
					}
				}
				
				x += dist;
			}
			
			y += dist;
		}
		
		return this;
	}

	var traced = false;
	function getPixel(l:Int, wrap:Int, x:Int, y:Int):Int {
		var in32 = this.layers[l];
		if (x < 0) x = (wrap != 0 ? (x + layerSizeX) : 0);
		if (y < 0) y = (wrap != 0 ? (y + layerSizeY) : 0);
		if (x >= layerSizeX) x = (wrap != 0 ? (x - layerSizeX) : (layerSizeX - 1));
		if (y >= layerSizeY) y = (wrap != 0 ? (y - layerSizeY) : (layerSizeY - 1));
		var idx = x + y * layerSizeX;
		
		return trunc((in32[idx + 0].val + in32[idx + 1].val + in32[idx + 2].val) / 768);
	}

	public function gradientMapLayer(s:Int, d:Int, wrap:Int, extrusion:Float = 2.0) {
		var x:Int = 0;
		var y:Int = 0;
		var out32 = this.layers[d];
		
		for(y in 0...layerSizeY) {
			for(x in 0...layerSizeX) {
				var center = getPixel(s, wrap, x, y);
				var up = getPixel(s, wrap, x, y - 1);
				var down = getPixel(s, wrap, x, y + 1);
				var left = getPixel(s, wrap, x - 1, y);
				var right = getPixel(s, wrap, x + 1, y);
				var upleft = getPixel(s, wrap, x - 1, y - 1);
				var upright = getPixel(s, wrap, x + 1, y - 1);
				var downleft = getPixel(s, wrap, x - 1, y + 1);
				var downright = getPixel(s, wrap, x + 1, y + 1);
				
				var vert = (down - up) * 2.0 + downright + downleft - upright - upleft;
				var horiz = (right - left) * 2.0 + upright + downright - upleft - downleft;
				var depth = 1.0 / extrusion;
				var scale = 127.0 / Math.sqrt(vert * vert + horiz * horiz + depth * depth);
				
				var r = trunc(128 - horiz * scale);
				var g = trunc(128 + vert * scale);
				var b = trunc(128 + depth * scale);
				
				var idx = trunc(x + y * layerSizeX);
				out32[idx].r = b;
				out32[idx].g = g;
				out32[idx].b = r;
				out32[idx].a = 255;
			}
		}
	}

	public function sobelLayer(s:Int, d:Int, strength:Float = 2.5, level:Float = 7, type:Int = 0) {
		var src = layers[s];
		var dst = layers[d];
		
		var w = layerSizeX;
		var h = layerSizeY;
		
		var max_size = w * h * 4;
		
		var tl:Float = 0, l:Float = 0, bl:Float = 0, t:Float = 0, b:Float = 0, tr:Float = 0;
		var r:Float = 0, br:Float = 0, dX:Float = 0, dY:Float = 0, dZ:Float = 0, l:Float = 0;
		
		// blue value of normal map
		strength = Math.max(strength, 0.0001);
		var dZ = 1.0 / strength * (1.0 + Math.pow(2.0, level)); // very costly operation!
		var dZ2 = dZ * dZ;
		
		var wm4 = w * 4;
		for (y in 0...h) {
			for (x in 0...w) {
				var dstOff = x * y;// (y * w + x) * 4;
				
				// very costly operation!
				if (x == 0 || x == w - 1 || y == 0 || y == h - 1) {
					tl = src[(dstOff - 4 - wm4) % (max_size)];   // top left  
					l  = src[(dstOff - 4      ) % (max_size)];   // left  
					bl = src[(dstOff - 4 + wm4) % (max_size)];   // bottom left  
					t  = src[(dstOff - wm4    ) % (max_size)];   // top  
					b  = src[(dstOff + wm4    ) % (max_size)];   // bottom  
					tr = src[(dstOff + 4 - wm4) % (max_size)];   // top right  
					r  = src[(dstOff + 4      ) % (max_size)];   // right  
					br = src[(dstOff + 4 + wm4) % (max_size)];   // bottom right  
				}
				else {
					tl = src[(dstOff - 4 - wm4)];   // top left
					l  = src[(dstOff - 4      )];   // left
					bl = src[(dstOff - 4 + wm4)];   // bottom left
					t  = src[(dstOff - wm4    )];   // top
					b  = src[(dstOff + wm4    )];   // bottom
					tr = src[(dstOff + 4 - wm4)];   // top right
					r  = src[(dstOff + 4      )];   // right
					br = src[(dstOff + 4 + wm4)];   // bottom right
				}
				
				// sobel
				if (type == 0) { // "sobel"
					dX = tl + l * 2 + bl - tr - r * 2 - br;
					dY = tl + t * 2 + tr - bl - b * 2 - br;
				}
				// scharr
				else if (type == 1) {
					dX = tl * 3.0 + l * 10.0 + bl * 3.0 - tr * 3.0 - r * 10.0 - br * 3.0;
					dY = tl * 3.0 + t * 10.0 + tr * 3.0 - bl * 3.0 - b * 10.0 - br * 3.0;
				}
				
				l = Math.sqrt((dX * dX) + (dY * dY) + dZ2);
				
				dst[dstOff].r = Math.floor((dX / l * 0.5 + 0.5) * 255.0); 		// red
				dst[dstOff].g = Math.floor((dY / l * 0.5 + 0.5) * 255.0); 		// green
				dst[dstOff].b = Math.floor(dZ / l * 255.0); 					// blue
				//dst[dstOff+3] = src[dstOff+3];
			}
		}
		
		return this;
	}

	public function sinePlasma(l:Int, dx:Float,  dy:Float, amplitude:Float) {
		amplitude /= 256;
		for (y in 0...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				this.layers[l][x + y * this.layerSizeX].r = 
					this.layers[l][x + y * this.layerSizeX].g = 
						this.layers[l][x + y * this.layerSizeX].b = Std.int((63.5 * Math.sin(dx * x) + 127 + 63.5 * Math.sin(dy * y)) * amplitude);
			}
		}
		
		return this;
	}

	public function perlinNoise(l:Int, dist:Int, seed:Int, amplitude:Int, persistence:Int, octaves:Int, rgb:Bool) {
		var r:Int = 0;
		
		this.subPlasma(l, dist, seed, 1, rgb);
		for (i in 0...octaves - 2) {
			amplitude = (amplitude * persistence) >> 8;
			if (amplitude <= 0) {
				break;
			}
			dist = dist >> 1;
			if (dist <= 0) {
				break;
			}
			this.subPlasma(this.TEMPL, dist, 0, amplitude, rgb);
			for (v in 0...SXtimeSY) {
				r = this.layers[l][v].r + this.layers[this.TEMPL][v].r;
				if (r > 255) {
					this.layers[l][v].r = 255;
				}
				else {
					this.layers[l][v].r = r;
				}
				r = this.layers[l][v].g + this.layers[this.TEMPL][v].g;
				if (r > 255) {
					this.layers[l][v].g = 255;
				} 
				else {
					this.layers[l][v].g = r;
				}
				r = this.layers[l][v].b + this.layers[this.TEMPL][v].b;
				if (r > 255) {
					this.layers[l][v].b = 255;
				}
				else {
					this.layers[l][v].b = r;
				}
			}
		}
		
		return this;
	}

	public function particle(l:Int, f:Float) {
		var r:Int = 0;
		var nx:Float = 0;
		var ny:Float = 0;
		var offset:Int = 0;
		f *= 180;
		for (y in 0...this.layerSizeY) {
			ny = y / (this.layerSizeY >> 1) - 1;
			for (x in 0...this.layerSizeX) {
				offset = Std.int(y * this.layerSizeX + x);
				nx = x / (this.layerSizeX >> 1) - 1;
				r = Std.int(255 - f * Math.sqrt(nx * nx + ny * ny));
				if (r < 0) {
					r = 0;
				}
				if (r > 255) {
					r = 255;
				}
				this.layers[l][offset].r = this.layers[l][offset].g = this.layers[l][offset].b = (r);
			}
		}
		
		return this;
	}

	public function colorLayer(l:Int, r:Int, g:Int, b:Int) {
		var color = RGBA.White;
		color.r = r; color.g = g; color.b = b;
		for (v in 0...SXtimeSY) {
			this.layers[l][v] = color;
		}
		
		return this;
	}

	public function checkerBoardLayer(l:Int, dx:Int, dy:Int, r1:Int, g1:Int, b1:Int, r2:Int, g2:Int, b2:Int) {
		var col1 = RGBA.White;
		var col2 = RGBA.White;
		col1.r = r1; col1.g = g1; col1.b = b1;
		col2.r = r2; col2.g = g2; col2.b = b2;
		for (y in 0...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				if ((Std.int(y / dy) & 1) ^ (Std.int(x / dx) & 1) != 0) {
					this.layers[l][Std.int(y * this.layerSizeX + x)] = col1;
				}
				else {
					this.layers[l][Std.int(y * this.layerSizeX + x)] = col2;
				}
			}
		}
		
		return this;
	}

	public function blobsLayer(l:Int, seed:Int, amount:Int, rgb:Bool) {
		var blobX:Array<Float> = [];
		var blobY:Array<Float> = [];
		var blobR:Array<Float> = [];
		var blobG:Array<Float> = [];
		var blobB:Array<Float> = [];
		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;
		var sd:Float = 0;
		var d:Float = 0;
		var oosize:Float = 0;
		var rx:Float = 0;
		var ry:Float = 0;
		var offset:Int = 0;
		
		this.seedValue = seed;
		
		for (v in 0...amount) {
			blobX[v] = byteLow(byteLow(myRandom()) & this.andLayerSizeX);
			blobY[v] = byteLow(byteLow(myRandom()) & this.andLayerSizeY);
			blobR[v] = (byteLow(myRandom() & 255) / 255 + 0.1) * 150;
			if (rgb == true) {
				blobG[v] = (byteLow(byteLow(myRandom()) & 255) / 255 + 0.1) * 150;
				blobB[v] = (byteLow(byteLow(myRandom()) & 255) / 255 + 0.1) * 150;
			}
		}
		
		oosize = 3 / SXtimeSY;
		for (y in 0...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				offset = y * this.layerSizeX + x;
				r = g = b = 0;
				for (v in 0...amount) {
					rx = blobX[v] - x;
					ry = blobY[v] - y;
					d = oosize * (rx * rx + ry * ry);
					sd = d * d;
					d = -0.444444 * sd * d + 1.888888 * sd -2.444444 * d + 1;
					r += d * blobR[v];
					g += d * blobG[v];		// needn't be calculated if not rgb, but we do it for memory optimization (spares one if statement)
					b += d * blobB[v];		// needn't be calculated if not rgb, but we do it for memory optimization (spares one if statement)
				}
				
				if (r < 0) {
					r = 0;
				}
				if (r > 255) {
					r = 255;
				}
				this.layers[l][offset].r = this.layers[l][offset].g = this.layers[l][offset].b = byteLow(r);
				if (rgb) {
					if (g < 0) {
						g = 0;
					}
					if (g > 255) {
						g = 255;
					}
					this.layers[l][offset].g = byteLow(g);
					if (b < 0) {
						b = 0;
					}
					if (b > 255) {
						b = 255;
					}
					this.layers[l][offset].b = byteLow(b);
				}
			}
		}
		
		return this;
	}

	public function scaleLayerRGB(src:Int, dest:Int, r:Float, g:Float, b:Float) {
		var tr:Int = 0;
		var tg:Int = 0;
		var tb:Int = 0;
		
		for (v in 0...SXtimeSY) {
			tr = Std.int(this.layers[src][v].r * r);
			tg = Std.int(this.layers[src][v].g * g);
			tb = Std.int(this.layers[src][v].b * b);
			
			if (tr >= 255) { 
				this.layers[dest][v].r = 255; 
			}
			else if (tr <= 0) {
				this.layers[dest][v].r = 0; 
			}
			else {
				this.layers[dest][v].r = tr;
			}
			if (tg >= 255) {
				this.layers[dest][v].g = 255;
			}
			else if (tg <= 0) {
				 this.layers[dest][v].g = 0;
			} 
			else {
				this.layers[dest][v].g = tg;
			}
			if (tb >= 255) {
				this.layers[dest][v].b = 255;
			} 
			else if (tb <= 0) {
				this.layers[dest][v].b = 0;
			}
			else {
				this.layers[dest][v].b = tb;
			}
		}
		
		return this;
	}

	public function scaleLayerHSV(src:Int, dest:Int, h:Float, s:Float, v:Float) {
		var hsv:Array<Float> = [0, 0, 0];
		var rgb:Array<Float> = [0, 0, 0];
		
		for (k in 0...SXtimeSY) {
			rgb2hsv([this.layers[src][k].r, this.layers[src][k].g, this.layers[src][k].b], hsv);			
			hsv[0] *= h;
			hsv[1] *= s;
			hsv[2] *= v;
			if (hsv[1] > 1) {
				hsv[1] = 1;
			} 
			else if (hsv[1] < 0) {
				hsv[1] = 0;
			}
			if (hsv[2] > 255) {
				hsv[2] = 255;
			} 
			else if (hsv[2] < 0) {
				hsv[2] = 0;
			}
			hsv2rgb(hsv, rgb);
			this.layers[dest][k].r = byteLow(rgb[0]);
			this.layers[dest][k].g = byteLow(rgb[1]);
			this.layers[dest][k].b = byteLow(rgb[2]);
		}
		
		return this;
	}

	public function adjustLayerRGB(src:Int, dest:Int, r:Float, g:Float, b:Float) {
		var tr:Int = 0;
		var tg:Int = 0;
		var tb:Int = 0;
		
		for (v in 0...SXtimeSY) {
			tr = Std.int(this.layers[src][v].r + r);
			tg = Std.int(this.layers[src][v].g + g);
			tb = Std.int(this.layers[src][v].b + b);
			
			if (tr >= 255) {
				this.layers[dest][v].r = 255;
			} 
			else if (tr <= 0) {
				this.layers[dest][v].r = 0;
			} 
			else {
				this.layers[dest][v].r = tr;
			}
			if (tg >= 255) {
				this.layers[dest][v].g = 255;
			} 
			else if (tg <= 0) {
				this.layers[dest][v].g = 0;
			} 
			else {
				this.layers[dest][v].g = tg;
			}
			if (tb >= 255) {
				this.layers[dest][v].b = 255;
			} 
			else if (tb <= 0) {
				this.layers[dest][v].b = 0;
			} 
			else {
				this.layers[dest][v].b = tb;
			}
		}
		
		return this;
	}

	public function adjustLayerHSV(src:Int, dest:Int, h:Float, s:Float, v:Float) {
		var hsv:Array<Float> = [0, 0, 0];
		var rgb:Array<Float> = [0, 0, 0];
		
		for (k in 0...SXtimeSY) {
			rgb2hsv([this.layers[src][k].r, this.layers[src][k].g, this.layers[src][k].b], hsv);
			hsv[0] += h;
			hsv[1] += s;
			hsv[2] += v;
			if (hsv[1] > 1) {
				hsv[1] = 1;
			} 
			else if (hsv[1] < 0) {
				hsv[1] = 0;
			}
			if (hsv[2] > 255) {
				hsv[2] = 255;
			} 
			else if (hsv[2] < 0) {
				hsv[2] = 0;
			}
			hsv2rgb(hsv, rgb);
			this.layers[dest][k].r = byteLow(rgb[0]);
			this.layers[dest][k].g = byteLow(rgb[1]);
			this.layers[dest][k].b = byteLow(rgb[2]);
		}
		
		return this;
	}

	public function sineLayerRGB(src:Int, dest:Int, r:Float, g:Float, b:Float) {
		r *= Math.PI;
		g *= Math.PI;
		b *= Math.PI;
		for (v in 0...SXtimeSY) {
			this.layers[dest][v].r = Std.int(127.5 * (Math.sin(r * this.layers[src][v].r) + 1));
			this.layers[dest][v].g = Std.int(127.5 * (Math.sin(g * this.layers[src][v].g) + 1));
			this.layers[dest][v].b = Std.int(127.5 * (Math.sin(b * this.layers[src][v].b) + 1));
		}
		
		return this;
	}

	public function equalizeRGB(src:Int, dest:Int) {
		var histogramR:Array<Float> = [];
		var histogramG:Array<Float> = [];
		var histogramB:Array<Float> = [];
		var sumR:Float = 0;
		var sumG:Float = 0;
		var sumB:Float = 0;
		var pDiv:Float = 0;
		
		for (v in 0...SXtimeSY) {
			histogramR[v] = 0;
			histogramG[v] = 0;
			histogramB[v] = 0;
		} 
		
		for (v in 0...SXtimeSY) {
			histogramR[this.layers[src][v].r]++;
			histogramG[this.layers[src][v].g]++;
			histogramB[this.layers[src][v].b]++;
		}
		
		sumR = sumG = sumB = 0;
		pDiv = 255 / SXtimeSY;
		for (v in 0...256) {			
			sumR += histogramR[v] * pDiv;
			histogramR[v] = (sumR);
			sumG += histogramG[v] * pDiv;
			histogramG[v] = (sumG);
			sumB += histogramB[v] * pDiv;
			histogramB[v] = (sumB);
		}
		
		for (v in 0...SXtimeSY) {
			this.layers[dest][v].r = trunc(histogramR[this.layers[src][v].r]);
			this.layers[dest][v].g = trunc(histogramG[this.layers[src][v].g]);
			this.layers[dest][v].b = trunc(histogramB[this.layers[src][v].b]);
		}
		
		return this;
	}

	public function stretchRGB(src:Int, dest:Int) {
		var histogramR:Array<Float> = [];
		var histogramG:Array<Float> = [];
		var histogramB:Array<Float> = [];
		var sumR:Float = 0;
		var sumG:Float = 0;
		var sumB:Float = 0;
		var pDivR:Float = 0;
		var pDivG:Float = 0;
		var pDivB:Float = 0;
		var minR:Int = 0;
		var minG:Int = 0;
		var minB:Int = 0;
		var maxR:Int = 0;
		var maxG:Int = 0;
		var maxB:Int = 0;
		
		for (v in 0...SXtimeSY) {
			histogramR[v] = 0;
			histogramG[v] = 0;
			histogramB[v] = 0;
		} 
		
		for (v in 0...SXtimeSY) {
			histogramR[this.layers[src][v].r]++;
			histogramG[this.layers[src][v].g]++;
			histogramB[this.layers[src][v].b]++;
		}
		
		minR = minG = minB = -1;
		maxR = maxG = maxB = 0;
		for (v in 0...256) {
			if (histogramR[v] != 0) { maxR = v; if (minR == -1) minR = v; }
			if (histogramG[v] != 0) { maxG = v; if (minG == -1) minG = v; }
			if (histogramB[v] != 0) { maxB = v; if (minB == -1) minB = v; }
		}
		
		sumR = minR; sumG = minG; sumB = minB;
		pDivR = (maxR - minR) / SXtimeSY;
		pDivG = (maxG - minG) / SXtimeSY;
		pDivB = (maxB - minB) / SXtimeSY;
		for (v in 0...256) {
			sumR += histogramR[v] * pDivR;
			histogramR[v] = (sumR);
			sumG += histogramG[v] * pDivG;
			histogramG[v] = (sumG);
			sumB += histogramB[v] * pDivB;
			histogramB[v] = (sumB);
		}
		
		for (v in 0...SXtimeSY) {
			this.layers[dest][v].r = trunc(histogramR[this.layers[src][v].r]);
			this.layers[dest][v].g = trunc(histogramG[this.layers[src][v].g]);
			this.layers[dest][v].b = trunc(histogramB[this.layers[src][v].b]);
		}
		
		return this;
	}

	public function invertLayer(src:Int, dest:Int) {
		for (v in 0...SXtimeSY) {
			this.layers[dest][v].r = 255 - this.layers[src][v].r;
			this.layers[dest][v].g = 255 - this.layers[src][v].g;
			this.layers[dest][v].b = 255 - this.layers[src][v].b;
			//this.layers[dest][v].a=~this.layers[src][v].a;
		}
		
		return this;
	}

	public function matrixLayer(src:Int, dest:Int, abs:Bool, matrix:Array<Array<Float>>) {
		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;
		var offset:Int = 0;
		
		this.copyTemp(src);
		
		for (y in 0...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				r = g = b = 0;
				for (my in 0...3) {
					for (mx in 0...3) {
						offset = ((x - 1 + mx) & this.andLayerSizeX) + ((y - 1 + my) & this.andLayerSizeY) * this.layerSizeX;
						r += matrix[mx][my] * this.layers[this.TEMPL][offset].r;
						g += matrix[mx][my] * this.layers[this.TEMPL][offset].g;
						b += matrix[mx][my] * this.layers[this.TEMPL][offset].b;
					}
				}
				
				if (abs == true) {
					r = Math.abs(r);
					g = Math.abs(g);
					b = Math.abs(b);
				}
				
				if (r < 0) {
					r = 0;
				} 
				else if (r > 255) {
					r = 255;
				}
				if (g < 0) {
					g = 0;
				} 
				else if (g > 255) {
					g = 255;
				}
				if (b < 0) {
					b = 0;
				} 
				else if (b > 255) {
					b = 255;
				}
				
				untyped this.layers[dest][x + y * this.layerSizeX].r = r;
				untyped this.layers[dest][x + y * this.layerSizeX].g = g;
				untyped this.layers[dest][x + y * this.layerSizeX].b = b;
			}
		}
		
		return this;
	}

	public function embossLayer(src:Int, dest:Int) {
		var r1:Int = 0;
		var g1:Int = 0;
		var b1:Int = 0;
		var r2:Int = 0;
		var g2:Int = 0;
		var b2:Int = 0;
		var offset:Int = 0;
		var offsetxm1:Int = 0;
		var offsetxp1:Int = 0;
		var offsetym1:Int = 0;
		var offsetyp1:Int = 0;
		
		this.copyTemp(src);
		
		for (y in 0...this.layerSizeY) {
			offsetym1 = trunc((byteLow(y - 1) & this.andLayerSizeY) * this.layerSizeX);
			offset = trunc(y * this.layerSizeX);
			offsetyp1 = trunc((byteLow(y + 1) & this.andLayerSizeY) * this.layerSizeX);
			for (x in 0...this.layerSizeX) {
				offsetxm1 = (byteLow(x - 1) & this.andLayerSizeX);
				offsetxp1 = (byteLow(x + 1) & this.andLayerSizeX);
				r1 = 128
					-this.layers[this.TEMPL][offsetxm1 + offsetym1].r
					-this.layers[this.TEMPL][offsetxm1 + offset].r
					-this.layers[this.TEMPL][offsetxm1 + offsetyp1].r
					+this.layers[this.TEMPL][offsetxp1 + offsetym1].r
					+this.layers[this.TEMPL][offsetxp1 + offset].r
					+this.layers[this.TEMPL][offsetxp1 + offsetyp1].r;
				g1 = 128
					-this.layers[this.TEMPL][offsetxm1 + offsetym1].g
					-this.layers[this.TEMPL][offsetxm1 + offset].g
					-this.layers[this.TEMPL][offsetxm1 + offsetyp1].g
					+this.layers[this.TEMPL][offsetxp1 + offsetym1].g
					+this.layers[this.TEMPL][offsetxp1 + offset].g
					+this.layers[this.TEMPL][offsetxp1 + offsetyp1].g;
				b1 = 128
					-this.layers[this.TEMPL][offsetxm1 + offsetym1].b
					-this.layers[this.TEMPL][offsetxm1 + offset].b
					-this.layers[this.TEMPL][offsetxm1 + offsetyp1].b
					+this.layers[this.TEMPL][offsetxp1 + offsetym1].b
					+this.layers[this.TEMPL][offsetxp1 + offset].b
					+this.layers[this.TEMPL][offsetxp1 + offsetyp1].b;
				r2 = 128
					-this.layers[this.TEMPL][offsetym1 + offsetxm1].r
					-this.layers[this.TEMPL][offsetym1 + x].r
					-this.layers[this.TEMPL][offsetym1 + offsetxp1].r
					+this.layers[this.TEMPL][offsetyp1 + offsetxm1].r
					+this.layers[this.TEMPL][offsetyp1 + x].r
					+this.layers[this.TEMPL][offsetyp1 + offsetxp1].r;
				g2 = 128
					-this.layers[this.TEMPL][offsetym1 + offsetxm1].g
					-this.layers[this.TEMPL][offsetym1 + x].g
					-this.layers[this.TEMPL][offsetym1 + offsetxp1].g
					+this.layers[this.TEMPL][offsetyp1 + offsetxm1].g
					+this.layers[this.TEMPL][offsetyp1 + x].g
					+this.layers[this.TEMPL][offsetyp1 + offsetxp1].g;
				b2 = 128
					-this.layers[this.TEMPL][offsetym1 + offsetxm1].b
					-this.layers[this.TEMPL][offsetym1 + x].b
					-this.layers[this.TEMPL][offsetym1 + offsetxp1].b
					+this.layers[this.TEMPL][offsetyp1 + offsetxm1].b
					+this.layers[this.TEMPL][offsetyp1 + x].b
					+this.layers[this.TEMPL][offsetyp1 + offsetxp1].b;
				r1 = trunc(Math.sqrt(r1 * r1 + r2 * r2));
				g1 = trunc(Math.sqrt(g1 * g1 + g2 * g2));
				b1 = trunc(Math.sqrt(b1 * b1 + b2 * b2));
				if (r1 > 255) r1 = 255;
				if (g1 > 255) g1 = 255;
				if (b1 > 255) b1 = 255;
				this.layers[dest][x + offset].r = r1;
				this.layers[dest][x + offset].g = g1;
				this.layers[dest][x + offset].b = b1;
			}
		}
		
		return this;
	}

	public function woodLayer(src:Int, dest:Int, b:Int) {
		var bm8 = 8 - b;
		for (v in 0...SXtimeSY) {			
			this.layers[dest][v].r = byteLow((lshift(this.layers[src][v].r, b)) | (rshift(this.layers[src][v].r, bm8)));
			this.layers[dest][v].g = byteLow((lshift(this.layers[src][v].g, b)) | (rshift(this.layers[src][v].g, bm8)));
			this.layers[dest][v].b = byteLow((lshift(this.layers[src][v].b, b)) | (rshift(this.layers[src][v].b, bm8)));			
		}
		
		return this;
	}

	public function blurLayer(src:Int, dest:Int) {
		matrix[0][0] = 0.0625; matrix[1][0] = 0.125; matrix[2][0] = 0.0625;
		matrix[0][1] = 0.125;  matrix[1][1] = 0.25;  matrix[2][1] = 0.125;
		matrix[0][2] = 0.0625; matrix[1][2] = 0.125; matrix[2][2] = 0.0625;
		
		this.matrixLayer(src, dest, false, matrix);
		
		return this;
	}

	public function edgeHLayer(src:Int, dest:Int) {
		matrix[0][0] = 2;  matrix[1][0] = 4;  matrix[2][0] = 2;
		matrix[0][1] = 0;  matrix[1][1] = 0;  matrix[2][1] = 0;
		matrix[0][2] = -2; matrix[1][2] = -4; matrix[2][2] = -2;
		
		this.matrixLayer(src, dest, true, matrix);
		
		return this;
	}

	public function edgeVLayer(src:Int, dest:Int) {
		matrix[0][0] = 2; matrix[1][0] = 0; matrix[2][0] = -2;
		matrix[0][1] = 4; matrix[1][1] = 0; matrix[2][1] = -4;
		matrix[0][2] = 2; matrix[1][2] = 0; matrix[2][2] = -2;
		
		this.matrixLayer(src, dest, true, matrix);
		
		return this;
	}

	public function sharpenLayer(src:Int, dest:Int) {
		matrix[0][0] = -0.125; matrix[1][0] = -0.25; matrix[2][0] = -0.125;
		matrix[0][1] = -0.25;  matrix[1][1] = 2.5;   matrix[2][1] = -0.25;
		matrix[0][2] = -0.125; matrix[1][2] = -0.25; matrix[2][2] = -0.125;
		
		this.matrixLayer(src, dest, false, matrix);
		
		return this;
	}

	public function motionBlur(src:Int, dest:Int, s:Int) {
		var sq:Int = 0;
		var ts:Int = 0;
		var r:Int = 0;
		var g:Int = 0;
		var b:Int = 0;
		var offset:Int = 0;
		var offset2:Int = 0;
		
		this.copyTemp(src);
		
		sq = (s + 1) * (s + 1);
		for (y in 0...this.layerSizeY) {
			offset = y * this.layerSizeX;
			for (x in 0...this.layerSizeX) {
				r = g = b = 0;
				for (t in -s...s + 1) {
					offset2 = offset + (byteLow(x + t) & this.andLayerSizeX);
					ts = trunc(s + 1 - Math.abs(t));
					r += trunc(this.layers[this.TEMPL][offset2].r * ts);
					g += trunc(this.layers[this.TEMPL][offset2].g * ts);
					b += trunc(this.layers[this.TEMPL][offset2].b * ts);
				}
				this.layers[dest][offset + x].r = trunc(r / sq);
				this.layers[dest][offset + x].g = trunc(g / sq);
				this.layers[dest][offset + x].b = trunc(b / sq);
			}
		}
		
		return this;
	}

	public function makeTilable(src:Int, dest:Int, s:Float) {
		var offset:Int = 0;
		var offset2:Int = 0;
		var sx:Float = 0;
		var sy:Float = 0;
		var sq:Float = 0;
		var sr:Float = 0;
		var sd:Float = 0;
		var srm:Float = 0;
		
		this.copyTemp(src);
		
		s = this.layerSizeX / 2 - s;
		sq = (s * s);
		sd = (this.layerSizeX / 2) * (this.layerSizeY / 2) - sq;
		if (sd != 0) {
			sd = 0.75 / sd;
		}
		else {
			sd = 75000;
		}
		for (y in 0...this.layerSizeY) {
			offset = y * this.layerSizeX;
			offset2 = (this.layerSizeY - 1 - y) * this.layerSizeX;
			sy = (y - this.layerSizeY / 2);
			sy = (sy * sy);
			for (x in 0...this.layerSizeX) {
				sx = (x - this.layerSizeX / 2);
				sr = sx * sx + sy - sq;
				if (sr > 0) {
					sr *= sd;
					if (sr > 0.75) {
						sr = 0.25;
						srm = 0.25;
					} 
					else {
						srm = 1 - sr;
						sr /= 3;
					}
					this.layers[dest][offset + x].r =
						trunc(this.layers[this.TEMPL][offset + x].r * srm + 
							(this.layers[this.TEMPL][offset + this.layerSizeX - 1 - x].r + 
								this.layers[this.TEMPL][offset2 + this.layerSizeX - 1 - x].r + this.layers[this.TEMPL][offset2 + x].r) * sr);
					this.layers[dest][offset + x].g = 
						trunc(this.layers[this.TEMPL][offset + x].g * srm + 
							(this.layers[this.TEMPL][offset + this.layerSizeX - 1 - x].g + 
								this.layers[this.TEMPL][offset2 + this.layerSizeX - 1 - x].g + this.layers[this.TEMPL][offset2 + x].g) * sr);
					this.layers[dest][offset + x].b = 
						trunc(this.layers[this.TEMPL][offset + x].b * srm + 
							(this.layers[this.TEMPL][offset + this.layerSizeX - 1 - x].b + 
								this.layers[this.TEMPL][offset2 + this.layerSizeX - 1 - x].b + this.layers[this.TEMPL][offset2 + x].b) * sr);
				}
			}
		}
		
		return this;
	}

	private function median(v:Array<Int>):Int {
		var a:Array<Int> = [];
		var i:Int = 0;
		var j:Int = 0;
		var last:Int = 0;
		
		for (i in 0...9) {
			last = 4;
			j = 4;
			while (j >= 0) {
				if (a[j] <= v[i]) {
					last = j;
				}
				
				--j;
			}
			j = 3;
			while (j >= last) {
				a[j + 1] = a[j];
				
				--j;
			}
			a[last] = v[i];
		}
		
		return a[4];
	}

	public function medianLayer(src:Int, dest:Int) {
		var offset:Array<Int> = [];
		var colors:Array<Int> = [];
		
		this.copyTemp(src);
		
		for (y in 0...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				for (i in 0...9) {
					offset[i] = trunc((trunc(x - 1 + (i % 3)) & this.andLayerSizeX) + (trunc(y - 1 + (i / 3)) & this.andLayerSizeY) * this.layerSizeX);
				}
				for (i in 0...9) {
					colors[i] = this.layers[this.TEMPL][offset[i]].r;
				}
				this.layers[dest][offset[4]].r = median(colors);
				for (i in 0...9) {
					colors[i] = this.layers[this.TEMPL][offset[i]].g;
				}
				this.layers[dest][offset[4]].g = median(colors);
				for (i in 0...9) {
					colors[i] = this.layers[this.TEMPL][offset[i]].b;
				}
				this.layers[dest][offset[4]].b = median(colors);
			}
		}
		
		return this;
	}

	inline function copyTemp(src:Int) {
		for (x in 0...SXtimeSY) {			
			this.layers[TEMPL][x] = this.layers[src][x];			
		}
	}

	public function erodeLayer(src:Int, dest:Int) {
		var offset:Int = 0;
		var offsetym1:Int = 0;
		var offsetyp1:Int = 0;
		var offsetxm1:Int = 0;
		var offsetxp1:Int = 0;
		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;
		
		this.copyTemp(src);		
		
		for (y in 0...this.layerSizeY) {
			offset= y * this.layerSizeX;
			offsetym1 = byteLow((y - 1) & this.andLayerSizeY) * this.layerSizeX;
			offsetyp1 = byteLow((y + 1) & this.andLayerSizeY) * this.layerSizeX;
			for (x in 0...this.layerSizeX) {
				offsetxm1 = byteLow(x - 1) & this.andLayerSizeX;
				offsetxp1 = byteLow(x + 1) & this.andLayerSizeX;
				
				r =	Math.min(this.layers[this.TEMPL][offsetym1 + offsetxm1].r,
					Math.min(this.layers[this.TEMPL][offsetym1 + x].r,
					Math.min(this.layers[this.TEMPL][offsetym1 + offsetxp1].r,
					Math.min(this.layers[this.TEMPL][offset + offsetxm1].r,
					Math.min(this.layers[this.TEMPL][offset + x].r,
					Math.min(this.layers[this.TEMPL][offset + offsetxp1].r,
					Math.min(this.layers[this.TEMPL][offsetyp1 + offsetxm1].r,
					Math.min(this.layers[this.TEMPL][offsetyp1 + x].r,
					this.layers[this.TEMPL][offsetyp1 + offsetxp1].r))))))));
				g =	Math.min(this.layers[this.TEMPL][offsetym1 + offsetxm1].g,
					Math.min(this.layers[this.TEMPL][offsetym1 + x].g,
					Math.min(this.layers[this.TEMPL][offsetym1 + offsetxp1].g,
					Math.min(this.layers[this.TEMPL][offset + offsetxm1].g,
					Math.min(this.layers[this.TEMPL][offset + x].g,
					Math.min(this.layers[this.TEMPL][offset + offsetxp1].g,
					Math.min(this.layers[this.TEMPL][offsetyp1 + offsetxm1].g,
					Math.min(this.layers[this.TEMPL][offsetyp1 + x].g,
					this.layers[this.TEMPL][offsetyp1 + offsetxp1].g))))))));
				b =	Math.min(this.layers[this.TEMPL][offsetym1 + offsetxm1].b,
					Math.min(this.layers[this.TEMPL][offsetym1 + x].b,
					Math.min(this.layers[this.TEMPL][offsetym1 + offsetxp1].b,
					Math.min(this.layers[this.TEMPL][offset + offsetxm1].b,
					Math.min(this.layers[this.TEMPL][offset + x].b,
					Math.min(this.layers[this.TEMPL][offset + offsetxp1].b,
					Math.min(this.layers[this.TEMPL][offsetyp1 + offsetxm1].b,
					Math.min(this.layers[this.TEMPL][offsetyp1 + x].b,
					this.layers[this.TEMPL][offsetyp1 + offsetxp1].b))))))));
					
				this.layers[dest][offset + x].r = trunc(r);
				this.layers[dest][offset + x].g = trunc(g);
				this.layers[dest][offset + x].b = trunc(b);
			}
		}
		
		return this;
	}

	public function dilateLayer(src:Int, dest:Int) {
		var offset:Int = 0;
		var offsetym1:Int = 0;
		var offsetyp1:Int = 0;
		var offsetxm1:Int = 0;
		var offsetxp1:Int = 0;
		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;
		
		this.copyTemp(src);
		
		for (y in 0...this.layerSizeY) {
			offset = y * this.layerSizeX;
			offsetym1 = trunc((byteLow(y - 1) & this.andLayerSizeY) * this.layerSizeX);
			offsetyp1 = trunc((byteLow(y + 1) & this.andLayerSizeY) * this.layerSizeX);
			for (x in 0...this.layerSizeX) {
				offsetxm1 = byteLow(x - 1) & this.andLayerSizeX;
				offsetxp1 = byteLow(x + 1) & this.andLayerSizeX;
				
				r =	Math.max(this.layers[this.TEMPL][offsetym1 + offsetxm1].r,
					Math.max(this.layers[this.TEMPL][offsetym1 + x].r,
					Math.max(this.layers[this.TEMPL][offsetym1 + offsetxp1].r,
					Math.max(this.layers[this.TEMPL][offset + offsetxm1].r,
					Math.max(this.layers[this.TEMPL][offset + x].r,
					Math.max(this.layers[this.TEMPL][offset + offsetxp1].r,
					Math.max(this.layers[this.TEMPL][offsetyp1 + offsetxm1].r,
					Math.max(this.layers[this.TEMPL][offsetyp1 + x].r,
					this.layers[this.TEMPL][offsetyp1 + offsetxp1].r))))))));
				g =	Math.max(this.layers[this.TEMPL][offsetym1 + offsetxm1].g,
					Math.max(this.layers[this.TEMPL][offsetym1 + x].g,
					Math.max(this.layers[this.TEMPL][offsetym1 + offsetxp1].g,
					Math.max(this.layers[this.TEMPL][offset + offsetxm1].g,
					Math.max(this.layers[this.TEMPL][offset + x].g,
					Math.max(this.layers[this.TEMPL][offset + offsetxp1].g,
					Math.max(this.layers[this.TEMPL][offsetyp1 + offsetxm1].g,
					Math.max(this.layers[this.TEMPL][offsetyp1 + x].g,
					this.layers[this.TEMPL][offsetyp1 + offsetxp1].g))))))));
				b =	Math.max(this.layers[this.TEMPL][offsetym1 + offsetxm1].b,
					Math.max(this.layers[this.TEMPL][offsetym1 + x].b,
					Math.max(this.layers[this.TEMPL][offsetym1 + offsetxp1].b,
					Math.max(this.layers[this.TEMPL][offset + offsetxm1].b,
					Math.max(this.layers[this.TEMPL][offset + x].b,
					Math.max(this.layers[this.TEMPL][offset + offsetxp1].b,
					Math.max(this.layers[this.TEMPL][offsetyp1 + offsetxm1].b,
					Math.max(this.layers[this.TEMPL][offsetyp1 + x].b,
					this.layers[this.TEMPL][offsetyp1 + offsetxp1].b))))))));
				this.layers[dest][offset + x].r = trunc(r);
				this.layers[dest][offset + x].g = trunc(g);
				this.layers[dest][offset + x].b = trunc(b);
			}
		}
		
		return this;
	}

	public function sineDistort(src:Int, dest:Int, dx:Float, depthX:Float, dy:Float, depthY:Float) {
		this.copyTemp(src);
		
		for (y in 0...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				this.layers[dest][trunc(x + y * this.layerSizeX)] = this.getBilerPixel(this.TEMPL, Math.sin(dx * y) * depthX + x, Math.sin(dy * x) * depthY + y);
			}
		}
		
		return this;
	}

	public function twirlLayer(src:Int, dest:Int, rot:Float, scale:Float) {
		var ooscale:Float = 0;
		var a:Float = 0;
		var b:Float = 0;
		var d:Float = 0;
		var winkel:Float = 0;
		var cw:Float = 0;
		var sw:Float = 0;
		var na:Float = 0;
		var nb:Float = 0;
		var ina:Int = 0;
		var inb:Int = 0;
		var inbp:Int = 0;
		var inap1:Int = 0;
		var inbp1:Int = 0;
		var corner:Array<RGBA> = [RGBA.White, RGBA.White, RGBA.White, RGBA.White];
		
		this.copyTemp(src);
		
		ooscale = 1 / (scale * Math.sqrt(2 * SXtimeSY));
		for (y in 0...this.layerSizeY) {
			b = (y - this.layerSizeY / 2);
			for (x in 0...this.layerSizeX) {
				a = (x - this.layerSizeX / 2);
				d = -Math.sqrt(a * a + b * b) + this.layerSizeX / 2;
				if (d <= 0) {
					na = (ina = x);
					nb = (inb = y);
				} 
				else {
					winkel = rot * d * d * ooscale;
					cw = Math.cos(winkel);
					sw = Math.sin(winkel);
					na = a * cw - b * sw + this.layerSizeX / 2;
					nb = a * sw + b * cw + this.layerSizeY / 2;
					ina = trunc(na);
					inb = trunc(nb);
				}
				inbp = trunc((inb & this.andLayerSizeY) * this.layerSizeX);
				inbp1 = trunc(((inb + 1) & this.andLayerSizeY) * this.layerSizeX);
				inap1 = (ina + 1) & this.andLayerSizeX;
				corner[0] = this.layers[this.TEMPL][(ina & this.andLayerSizeX) + inbp];
				corner[1] = this.layers[this.TEMPL][inap1 + inbp];
				corner[2] = this.layers[this.TEMPL][(ina & this.andLayerSizeX) + inbp1];
				corner[3] = this.layers[this.TEMPL][inap1 + inbp1];
				this.layers[dest][trunc(x + y * this.layerSizeX)] = cosineInterpolate(corner, na - ina, nb - inb);
			}
		}
		
		return this;
	}

	public function tileLayer(src:Int, dest:Int) {
		var offset:Int = 0;
		var offset2:Int = 0;
		var offset3:Int = 0;
		
		this.copyTemp(src);
		
		for (y in 0...this.layerSizeY) {
			offset = y * this.layerSizeX;
			offset2 = ((y * 2) & this.andLayerSizeY) * this.layerSizeX;
			for (x in 0...this.layerSizeX) {
				offset3 = ((x * 2) & this.andLayerSizeX) + offset2;
				this.layers[dest][x + offset].r = 
					(this.layers[this.TEMPL][offset3].r + 
						this.layers[this.TEMPL][offset3 + 1].r + 
							this.layers[this.TEMPL][offset3 + this.layerSizeX].r + this.layers[this.TEMPL][offset3 + this.layerSizeX + 1].r) >> 2;
				this.layers[dest][x + offset].g = 
					(this.layers[this.TEMPL][offset3].g + 
						this.layers[this.TEMPL][offset3 + 1].g + 
							this.layers[this.TEMPL][offset3 + this.layerSizeX].g + this.layers[this.TEMPL][offset3 + this.layerSizeX + 1].g) >> 2;
				this.layers[dest][x + offset].b = 
					(this.layers[this.TEMPL][offset3].b + 
						this.layers[this.TEMPL][offset3 + 1].b + 
							this.layers[this.TEMPL][offset3 + this.layerSizeX].b + this.layers[this.TEMPL][offset3 + this.layerSizeX + 1].b) >> 2;
			}
		}
		
		return this;
	}

	public function noiseDistort(src:Int, dest:Int, seed:Int, radius:Int) {
		var dx:Int = 0;
		var dy:Int = 0;
		
		this.copyTemp(src);
		
		this.seedValue = seed;
		radius = 16 - radius;
		var offset:Int = 0;
		for (y in 0...this.layerSizeY) {
			offset = y * this.layerSizeX;
			for (x in 0...this.layerSizeX) {				
				dx = (myRandom(0, 32767) - 32767) >> radius;
				dy = (myRandom(0, 32767) - 32767) >> radius;
				this.layers[dest][x + y * this.layerSizeX] = 
					this.layers[this.TEMPL][((x + dx) & this.andLayerSizeX) + ((y + dy) & this.andLayerSizeY) * this.layerSizeX];
			}
		}
		
		return this;
	}

	public function moveDistort(src:Int, dest:Int, dx:Int, dy:Int) {
		this.copyTemp(src);
		for (y in 0...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				this.layers[dest][x + y * this.layerSizeX] = 
					this.layers[this.TEMPL][(byteLow(x + dx) & this.andLayerSizeX) + (byteLow(y + dy) & this.andLayerSizeY) * this.layerSizeX];
			}
		}
		
		return this;
	}

	inline function move(src:Int, inds:Int, dest:Int, indd:Int, size:Int) {
		for (x in 0...size) {
			this.layers[dest][indd++] = this.layers[src][inds++];
		}
	}

	public function MirrorCorner(c0:Int, dest:Int) {
		var xc:Int = 0;
		var yc:Int = 0;
		var offset:Int = 0;
		
		switch (c0) {
			case 0: 
				for (yc in 0...Std.int(this.layerSizeY / 2) - 1) {
					offset = trunc(yc * this.layerSizeX);
					for (xc in 0...trunc(this.layerSizeX / 2) - 1) {
						this.layers[dest][offset + (this.layerSizeX - 1 - xc)] = this.layers[dest][offset + xc];
					}				
				}
				
			case 1: 
				for (yc in 0...Std.int(this.layerSizeY / 2)) {
					this.move(
						dest, 
						trunc(yc * this.layerSizeX + (this.layerSizeX / 2)), 
						dest, 
						trunc((this.layerSizeY - 1 - yc) * this.layerSizeX + (this.layerSizeX / 2)), 
						trunc(this.layerSizeX / 2)
					);
				}
				
			case 2: 
				for (yc in 0...Std.int(this.layerSizeY / 2) - 1) {
					offset = trunc(yc + (this.layerSizeY / 2) * this.layerSizeX);
					for (xc in 0...Std.int(this.layerSizeX / 2) - 1) {
						this.layers[dest][offset + xc] = this.layers[dest][offset + (this.layerSizeX  - xc)];
					}
				}
							
			case 3: 
				for (yc in 0...Std.int(this.layerSizeY / 2) - 1) {
					this.move(
						dest, 
						trunc((this.layerSizeY - 1 - yc) * this.layerSizeX), 
						dest, 
						trunc(yc * this.layerSizeX), 
						trunc(this.layerSizeX / 2)
					);
				}					
		}
		
		return this;
	}

	public function kaleidLayer(src:Int, dest:Int, corner:Int) {
		corner = corner - 1;
		
		for (y in 0...Std.int(this.layerSizeY / 2) - 1) {
			this.MirrorCorner(corner, dest);
			this.MirrorCorner((corner + 1) % 4, dest);
			this.MirrorCorner((corner + 2) % 4, dest);
		}
		
		return this;		
	}

	public function tunnelDistort(src:Int, dest:Int, f:Float) {
		var ina:Int = 0;
		var inb:Int = 0;
		var inap1:Int = 0;
		var inbp:Int = 0;
		var inbp1:Int = 0;
		var a:Float = 0;
		var b:Float = 0;
		var na:Float = 0;
		var nb:Float = 0;
		var corner:Array<RGBA> = [RGBA.White, RGBA.White, RGBA.White, RGBA.White];		
		
		var arct:Float = 0;
		var lsd2p:Float = 0;
		
		this.copyTemp(src);
		
		var lsd2p = this.layerSizeX / (2 * Math.PI);
		for (y in 0...this.layerSizeY) {
			b = -0.5 * this.layerSizeY + y;
			for (x in 0...this.layerSizeX) {
				a = -0.5 * this.layerSizeX + x;
				if (a != 0) {
					a = 1 / a;
					arct = Math.atan(b * a);
					if (a > 0) {
						na = lsd2p * arct + this.layerSizeX / 2;
					}
					else {
						na = lsd2p * arct;
					}
					nb = Math.abs(Math.cos(arct) * f * a);
					ina = trunc(na);
					inb = trunc(nb);
					inap1 = (ina + 1) & this.andLayerSizeX;
					inbp = (inb & this.andLayerSizeY) * this.layerSizeX;
					inbp1 = trunc(((inb + 1) & this.andLayerSizeY) * this.layerSizeX);
					corner[0] = this.layers[this.TEMPL][(ina & this.andLayerSizeX) + inbp];
					corner[1] = this.layers[this.TEMPL][inap1 + inbp];
					corner[2] = this.layers[this.TEMPL][(ina & this.andLayerSizeX) + inbp1];
					corner[3] = this.layers[this.TEMPL][inap1 + inbp1];
				}
				this.layers[dest][trunc(x + y * this.layerSizeX)] = cosineInterpolate(corner, na - ina, nb - inb);
			} 
		}
		
		return this;
	}

	public function sculptureLayer(src:Int, dest:Int) {
		var ipi:Float = 255.0 / (2.0 * 3.1415926536);
		var offset:Int = 0;
		var offsetym1:Int = 0;
		var offsetyp1:Int = 0;
		var offsetxm1:Int = 0;
		var offsetxp1:Int = 0;
		var r1:Int = 0;
		var r2:Int = 0;
		var g1:Int = 0;
		var g2:Int = 0;
		var b1:Int = 0;
		var b2:Int = 0;
		var a:Float = 0;
		
		this.copyTemp(src);
		
		for (y in 0...this.layerSizeY) {
			offset = y * this.layerSizeX;
			offsetym1 = Std.int(((y - 1) & this.andLayerSizeY) * this.layerSizeX);
			offsetyp1 = Std.int(((y + 1) & this.andLayerSizeY) * this.layerSizeX);
			for (x in 0...this.layerSizeX) {
				offsetxm1 = ((x - 1) & this.andLayerSizeX);
				offsetxp1 = ((x + 1) & this.andLayerSizeX);
				
				r1 = this.layers[this.TEMPL][offsetxm1 + offsetym1].r
					+ 2 * this.layers[this.TEMPL][offsetxm1 + offset].r
					+ this.layers[this.TEMPL][offsetxm1 + offsetyp1].r
					- this.layers[this.TEMPL][offsetxp1 + offsetym1].r
					- 2 * this.layers[this.TEMPL][offsetxp1 + offset].r
					-this.layers[this.TEMPL][offsetxp1 + offsetyp1].r;
				r2 = this.layers[this.TEMPL][offsetym1 + offsetxm1].r
					+ 2 * this.layers[this.TEMPL][offsetym1 + x].r
					+ this.layers[this.TEMPL][offsetym1 + offsetxp1].r
					- this.layers[this.TEMPL][offsetyp1 + offsetxm1].r
					- 2 * this.layers[this.TEMPL][offsetyp1 + x].r
					- this.layers[this.TEMPL][offsetyp1 + offsetxp1].r;
					
				g1 = this.layers[this.TEMPL][offsetxm1 + offsetym1].g
					+ 2 * this.layers[this.TEMPL][offsetxm1 + offset].g
					+ this.layers[this.TEMPL][offsetxm1 + offsetyp1].g
					- this.layers[this.TEMPL][offsetxp1 + offsetym1].g
					- 2 * this.layers[this.TEMPL][offsetxp1 + offset].g
					- this.layers[this.TEMPL][offsetxp1 + offsetyp1].g;
				g2 = this.layers[this.TEMPL][offsetym1 + offsetxm1].g
					+ 2 * this.layers[this.TEMPL][offsetym1 + x].g
					+ this.layers[this.TEMPL][offsetym1 + offsetxp1].g
					- this.layers[this.TEMPL][offsetyp1 + offsetxm1].g
					- 2 * this.layers[this.TEMPL][offsetyp1 + x].g
					- this.layers[this.TEMPL][offsetyp1 + offsetxp1].g;
					
				b1 = this.layers[this.TEMPL][offsetxm1 + offsetym1].b
					+ 2 * this.layers[this.TEMPL][offsetxm1 + offset].b
					+ this.layers[this.TEMPL][offsetxm1 + offsetyp1].b
					- this.layers[this.TEMPL][offsetxp1 + offsetym1].b
					- 2 * this.layers[this.TEMPL][offsetxp1 + offset].b
					- this.layers[this.TEMPL][offsetxp1 + offsetyp1].b;
				b2= this.layers[this.TEMPL][offsetym1 + offsetxm1].b
					+ 2 * this.layers[this.TEMPL][offsetym1 + x].b
					+ this.layers[this.TEMPL][offsetym1 + offsetxp1].b
					- this.layers[this.TEMPL][offsetyp1 + offsetxm1].b
					- 2 * this.layers[this.TEMPL][offsetyp1 + x].b
					- this.layers[this.TEMPL][offsetyp1 + offsetxp1].b;
					
				if (r1 == 0) {
					if (r2 > 0) {
						this.layers[dest][x + offset].r = 196;
					}
					else if (r2 == 0) {
						this.layers[dest][x + offset].r = 128;
					}
					else {
						this.layers[dest][x + offset].r = 64;
					}
				}
				else {
					a = Math.atan(r2 / r1);
					if (r1 > 0) {
						this.layers[dest][x + offset].r = trunc(a * ipi + 127.5);
					}
					else {
						this.layers[dest][x + offset].r = trunc(a * ipi);
					}
				}
				
				if (g1 == 0) {
					if (g2 > 0) {
						this.layers[dest][x + offset].g = 196;
					}
					else if (g2 == 0) {
						this.layers[dest][x + offset].g = 128;
					}
					else {
						this.layers[dest][x + offset].g = 64;
					}
				}
				else {
					a = Math.atan(g2 / g1);
					if (g1 > 0) {
						this.layers[dest][x + offset].g = trunc(a * ipi + 127.5);
					}
					else {
						this.layers[dest][x + offset].g = trunc(a * ipi);
					}
				}
				
				if (b1 == 0) {
					if (b2 > 0) {
						this.layers[dest][x + offset].b = 196;
					}
					else if (b2 == 0) {
						this.layers[dest][x + offset].b = 128;
					}
					else {
						this.layers[dest][x + offset].b = 64;
					}
				}
				else {
					a = Math.atan(b2 / b1);
					if (b1 > 0) {
						this.layers[dest][x + offset].b = trunc(a * ipi + 127.5);
					}
					else {
						this.layers[dest][x + offset].b = trunc(a * ipi);
					}
				}
			} 
		}
		
		return this;
	}

	inline function trunc(n:Float):Int {
		return Math.floor(n);
	}
	
	public function mapDistort(src:Int, dist:Int, dest:Int, xd:Float, yd:Float) {
		var offset:Int = 0;
		var v:Float = 0;
		
		this.copyTemp(src);
		
		for (y in 0...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				offset = trunc(y * this.layerSizeX + x);
				v = Math.max(this.layers[dist][offset].r, Math.max(this.layers[dist][offset].g, this.layers[dist][offset].b));
				this.layers[dest][offset] = this.getBilerPixel(this.TEMPL, xd * v + x, yd * v + y);
			}
		}
		
		return this;
	}

	public function addLayers(src1:Int, src2:Int, dest:Int, perc1:Float, perc2:Float) {
		var r:Int = 0;
		var g:Int = 0;
		var b:Int = 0;
		
		for (v in 0...SXtimeSY) {
			r = Std.int(this.layers[src1][v].r * perc1 + this.layers[src2][v].r * perc2);
			g = Std.int(this.layers[src1][v].g * perc1 + this.layers[src2][v].g * perc2);
			b = Std.int(this.layers[src1][v].b * perc1 + this.layers[src2][v].b * perc2);
			if (r > 255) {
				r = 255;
			} 
			else if (r < 0) {
				r = 0;
			}
			if (g > 255) {
				g=255;
			} 
			else if (g < 0) {
				g = 0;
			}
			if (b > 255) {
				b = 255;
			} 
			else if (b < 0) {
				b = 0;
			}
			this.layers[dest][v].r = r;
			this.layers[dest][v].g = g;
			this.layers[dest][v].b = b;
		}
		
		return this;
	}

	public function mulLayers(src1:Int, src2:Int, dest:Int, perc1:Float, perc2:Float) {
		var r:Int = 0;
		var g:Int = 0;
		var b:Int = 0;
		
		var perc = perc1 * perc2 / 255;
		for (v in 0...SXtimeSY) {
			r = Std.int(this.layers[src1][v].r * this.layers[src2][v].r * perc);
			g = Std.int(this.layers[src1][v].g * this.layers[src2][v].g * perc);
			b = Std.int(this.layers[src1][v].b * this.layers[src2][v].b * perc);
			if (r > 255) {
				r = 255;
			} 
			else if (r < 0) {
				r = 0;
			}
			if (g > 255) {
				g = 255;
			} 
			else if (g < 0) {
				g = 0;
			}
			if (b > 255) {
				b = 255;
			} 
			else if (b < 0) {
				b = 0;
			}
			this.layers[dest][v].r = r;
			this.layers[dest][v].g = g;
			this.layers[dest][v].b = b;
		}
		
		return this;
	}

	public function xorLayers(src1:Int, src2:Int, dest:Int) {
		var r:Int = 0;
		var g:Int = 0;
		var b:Int = 0;
		
		for (v in 0...SXtimeSY) {
			r = this.layers[src1][v].r ^ this.layers[src2][v].r;
			g = this.layers[src1][v].g ^ this.layers[src2][v].g;
			b = this.layers[src1][v].b ^ this.layers[src2][v].b;
			if (r > 255) {
				r = 255;
			} 
			else if (r < 0) {
				r = 0;
			}
			if (g > 255) {
				g = 255;
			} 
			else if (g < 0) {
				g = 0;
			}
			if (b > 255) {
				b = 255;
			} 
			else if (b < 0) {
				b = 0;
			}
			this.layers[dest][v].r = r;
			this.layers[dest][v].g = g;
			this.layers[dest][v].b = b;
		}
		
		return this;
	}

	public function andLayers(src1:Int, src2:Int, dest:Int) {
		var r:Int = 0;
		var g:Int = 0;
		var b:Int = 0;
		
		for (v in 0...SXtimeSY) {
			r = this.layers[src1][v].r & this.layers[src2][v].r;
			g = this.layers[src1][v].g & this.layers[src2][v].g;
			b = this.layers[src1][v].b & this.layers[src2][v].b;
			if (r > 255) {
				r = 255;
			} 
			else if (r < 0) {
				r = 0;
			}
			if (g > 255) {
				g = 255;
			} 
			else if (g < 0) {
				g = 0;
			}
			if (b > 255) {
				b = 255;
			} 
			else if (b < 0) {
				b = 0;
			}
			this.layers[dest][v].r = r;
			this.layers[dest][v].g = g;
			this.layers[dest][v].b = b;
		}
		
		return this;
	}

	public function orLayers(src1:Int, src2:Int, dest:Int) {
		var r:Int = 0;
		var g:Int = 0;
		var b:Int = 0;
		
		for (v in 0...SXtimeSY) {
			r = this.layers[src1][v].r | this.layers[src2][v].r;
			g = this.layers[src1][v].g | this.layers[src2][v].g;
			b = this.layers[src1][v].b | this.layers[src2][v].b;
			if (r > 255) {
				r = 255;
			} 
			else if (r < 0) {
				r = 0;
			}
			if (g > 255) {
				g = 255;
			} 
			else if (g < 0) {
				g = 0;
			}
			if (b > 255) {
				b = 255;
			} 
			else if (b < 0) {
				b = 0;
			}
			this.layers[dest][v].r = r;
			this.layers[dest][v].g = g;
			this.layers[dest][v].b = b;
		}
	}

	public function randCombineLayers(src1:Int, src2:Int, dest:Int) {
		for (v in 0...SXtimeSY) {
			this.layers[dest][v].r = myRandom() & 1 != 0 ? this.layers[src1][v].r : this.layers[src2][v].r;
			this.layers[dest][v].g = myRandom() & 1 != 0 ? this.layers[src1][v].g : this.layers[src2][v].g;
			this.layers[dest][v].b = myRandom() & 1 != 0 ? this.layers[src1][v].b : this.layers[src2][v].b;
		}
		
		return this;
	}

	public function maxCombineLayers(src1:Int, src2:Int, dest:Int) {
		for (v in 0...SXtimeSY) {
			this.layers[dest][v].r = Std.int(Math.max(this.layers[src1][v].r, this.layers[src2][v].r));
			this.layers[dest][v].g = Std.int(Math.max(this.layers[src1][v].g, this.layers[src2][v].g));
			this.layers[dest][v].b = Std.int(Math.max(this.layers[src1][v].b, this.layers[src2][v].b));
		}
		
		return this;
	}

	public function minCombineLayers(src1:Int, src2:Int, dest:Int) {
		for (v in 0...SXtimeSY) {
			this.layers[dest][v].r = Std.int(Math.min(this.layers[src1][v].r, this.layers[src2][v].r));
			this.layers[dest][v].g = Std.int(Math.min(this.layers[src1][v].g, this.layers[src2][v].g));
			this.layers[dest][v].b = Std.int(Math.min(this.layers[src1][v].b, this.layers[src2][v].b));
		}
		
		return this;
	}

	public function cellMachine(l:Int, seed:Int, rule:Int) {
		var x:Int = 0;
		var y:Int = 0;
		var base_off:Int = 0;
		var m:Int = 0;
		var c = RGBA.White;
		
		this.seedValue = seed;
			
		c.r = 255; c.g = 255; c.b = 255;
		
		for (x in 0...this.layerSizeX) {
			if (((myRandom()) >> 100) == 0) {
				this.layers[l][x] = c;
			}
		}
		
		base_off = 0;
		for (y in 1...this.layerSizeY) {
			for (x in 0...this.layerSizeX) {
				if (this.layers[l][((x - 1) & this.andLayerSizeX) + base_off].r != 0) {
					m = 1;
				}
				else {
					m = 0;
				}
				if (this.layers[l][x + base_off].r != 0) {	
					m = m | 2;
				}
				
				if (this.layers[l][((x + 1) & this.andLayerSizeX) + base_off].r != 0) {
					m = m | 4;
				}
				
				if (((1 << m) & rule) != 0) {
					this.layers[l][x + base_off + this.layerSizeX].r = c.r;
					this.layers[l][x + base_off + this.layerSizeX].g = c.g;
					this.layers[l][x + base_off + this.layerSizeX].b = c.b;
				}
			}
			
			base_off=base_off + this.layerSizeX;
		}
		
		return this;
	}

	public function sepiaLayer(l:Int, dest:Int, type:Int) {
		var xy:Int = 0;
		
		switch(type) {
			case 0:
				var avg = 0;
				
				for (v in 0...SXtimeSY) {
					avg = Std.int(0.3 * layers[l][v].r + 0.59 * layers[l][v].g + 0.11 * layers[l][v].b);
					layers[dest][v].r = avg + 100;
					layers[dest][v].g = avg + 50;
					layers[dest][v].b = avg;
				}
				
			case 1:
				for (v in 0...SXtimeSY) {
					layers[dest][v].r = Std.int((layers[l][v].r * 0.393 + layers[l][v].g * 0.769 + layers[l][v].b * 0.189 ) / 1.351);
					layers[dest][v].g = Std.int((layers[l][v].r * 0.349 + layers[l][v].g * 0.686 + layers[l][v].b * 0.168 ) / 1.203);
					layers[dest][v].b = Std.int((layers[l][v].r * 0.272 + layers[l][v].g * 0.534 + layers[l][v].b * 0.131 ) / 2.140);
				}
		}
		
		return this;
	}

	public function gammaLayer(src:Int, dest:Int, factor:Float = 0.5) {
		var s = layers[src];
		var d = layers[dest];
		
		for (v in 0...SXtimeSY) {
			d[v].r = Std.int(Math.pow(s[v].r / 255, factor) * 255);
			d[v].g = Std.int(Math.pow(s[v].g / 255, factor) * 255);
			d[v].b = Std.int(Math.pow(s[v].b / 255, factor) * 255);
		}
		
		return this;
	}

	// colorTo = "grb", "bgr", "gbr", "rbg", "brg"
	public function swapColors(src:Int, dest:Int, colorTo:String) {
		var s = layers[src];
		var d = layers[dest];
		var r = 0;
		var g = 0;
		var b = 0;
		
		switch (colorTo) {
			case "brg":				
				for (v in 0...SXtimeSY) {
					r = s[v].r;
					g = s[v].g;
					b = s[v].b;
					d[v].r = b;
					d[v].g = r;
					d[v].b = g;
				}
				
			case "rbg":
				for (v in 0...SXtimeSY) {
					g = s[v].b;
					b = s[v].g;
					d[v].g = g;
					d[v].b = b;
				}
				
			case "gbr":				
				for (v in 0...SXtimeSY) {
					r = s[v].r;
					g = s[v].g;
					b = s[v].b;
					d[v].r = g;
					d[v].g = b;
					d[v].b = r;
				}
				
			case "grb":				
				for (v in 0...SXtimeSY) {
					r = s[v].r;
					g = s[v].g;
					b = s[v].b;
					d[v].r = g;
					d[v].g = r;
					d[v].b = b;
				}
				
			case "bgr":				
				for (v in 0...SXtimeSY) {
					r = s[v].r;
					g = s[v].g;
					b = s[v].b;
					d[v].r = b;
					d[v].g = g;
					d[v].b = r;
				}
		}
		
		return this;
	}

}
