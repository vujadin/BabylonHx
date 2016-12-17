package com.babylonhx.d2.display;

import com.babylonhx.d2.display.Stage;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.GLBuffer;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt16Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*
	Basic container for triangles.
*/
class Tgs {	
	
	public var color:Float32Array;
	public var bdata:BitmapData;
	public var name:String;
	
	public var useTex:Bool;
	public var dirtyUVT:Bool;
	public var emptyUVT:Bool;
	public var useIndex:Bool;
	
	public var ind:UInt16Array;
	public var uvt:Float32Array;
	public var vrt:Float32Array;
	
	public var ibuf:GLBuffer;
	public var vbuf:GLBuffer;
	public var tbuf:GLBuffer;

    public var stage:Stage;
	
	public static var _delTgs:Map<String, Array<Tgs>> = new Map();
	public static var _delNum:Int = 0;
	
	
	public function new(stage:Stage, vrt:Array<Float>, ind:Array<Int>, ?uvt:Array<Float>, ?color:Float32Array, ?bdata:BitmapData) {
		this.stage = stage;
        this.color = color;
		this.bdata = bdata;
		this.name = "t_" + vrt.length + "_" + ind.length;
		
		this.useTex   = (bdata != null);
		this.dirtyUVT = true;
		this.emptyUVT = (uvt == null);
		this.useIndex = vrt.length / 3 <= 65536;	// use index array for drawing triangles

        var Gl = stage.Gl;
		if(this.useIndex) {
			this.ind = new UInt16Array (ind);
			this.vrt = new Float32Array(vrt);
			if (uvt != null) {
				this.uvt = new Float32Array(uvt);
			}
			else {
				this.uvt = new Float32Array(Std.int(vrt.length * 2 / 3));
			}
			
			this.ibuf = Gl.createBuffer();
            this.stage._setEBF(this.ibuf);
            Gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, this.ind, GL.STATIC_DRAW);   //TODO mio
		}
		else {
			this.vrt = new Float32Array(ind.length * 3);
			Tgs.unwrapF32(ind, vrt, 3, this.vrt); 
			
			this.uvt = new Float32Array(ind.length * 2);
			if (uvt != null) {
				Tgs.unwrapF32(ind, uvt, 2, this.uvt); 
			}
		}
		
		this.vbuf = Gl.createBuffer();
        this.stage._setBF(this.vbuf);
        Gl.bufferData(GL.ARRAY_BUFFER, this.vrt, GL.STATIC_DRAW);
		
		this.tbuf = Gl.createBuffer();
        this.stage._setBF(this.tbuf);
        Gl.bufferData(GL.ARRAY_BUFFER, this.uvt, GL.STATIC_DRAW);
	}
	
	public function Set(stage:Stage, vrt:Array<Float>, ind:Array<Int>, uvt:Array<Float>, color:Float32Array, ?bdata:BitmapData) {
        this.stage = stage;
		this.color = color;
		this.bdata = bdata;
		
		this.useTex   = (bdata != null);
		this.dirtyUVT = true;
		this.emptyUVT = (uvt == null);
		//this.useIndex = vrt.length/3 <= 65536;	// use index array for drawing triangles

        var Gl = stage.Gl;
		if(this.useIndex) {
			var il = ind.length;
			var vl = vrt.length;
			for (i in 0...il) {
				this.ind[i] = ind[i];
			}
			for (i in 0...vl) {
				this.vrt[i] = vrt[i];
			}
			if (uvt != null) {
				for (i in 0...uvt.length) {
					this.uvt[i] = uvt[i];
				}
			}

            this.stage._setEBF(this.ibuf);
            Gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, this.ind, GL.STATIC_DRAW);
			
		}
		else {
			Tgs.unwrapF32(ind, vrt, 3, this.vrt);
			if (uvt != null) {
				Tgs.unwrapF32(ind, uvt, 2, this.uvt);
			}
		}

        this.stage._setBF(this.vbuf);
        Gl.bufferData(GL.ARRAY_BUFFER, this.vrt, GL.STATIC_DRAW);

        this.stage._setBF(this.tbuf);
        Gl.bufferData(GL.ARRAY_BUFFER, this.uvt, GL.STATIC_DRAW);
	}
	
	public function render() {
		if (this.useTex) {
			var bd = this.bdata;
			
			if (bd._dirty) {
				bd._syncWithGPU(this.stage);
			}
			
			if (this.dirtyUVT) {
				this.dirtyUVT = false;
				if (this.emptyUVT) {
					this.emptyUVT = false;
					var cw = 1 / bd._rwidth;
					var ch = 1 / bd._rheight;
					for (i in 0...this.uvt.length) {
						if (this.vrt.length > (3 * i + 1)) {
							this.uvt[2 * i] = cw * this.vrt[3 * i]; 
							this.uvt[2 * i + 1] = ch * this.vrt[3 * i + 1];
						}
					}
				}
				else if(bd.width != bd._rwidth || bd.height != bd._rheight) {
					var cw = bd.width / bd._rwidth;
					var ch = bd.height / bd._rheight;
					
					for (i in 0...this.uvt.length) {
						this.uvt[2 * i] *= cw; 
						this.uvt[2 * i + 1] *= ch; 
					}
				}

                this.stage._setBF(this.tbuf);
				this.stage.Gl.bufferSubData(GL.ARRAY_BUFFER, 0, this.uvt);
			}

            this.stage._setUT(1);
            this.stage._setTEX(bd._texture);
		}
		else {
            this.stage._setUT(0);
            this.stage.Gl.uniform4fv(this.stage._sprg.color, this.color);
		}

        this.stage._setTC(this.tbuf);
        this.stage._setVC(this.vbuf);
		
		if (this.useIndex) {
            this.stage._setEBF(this.ibuf);
            this.stage.Gl.drawElements(GL.TRIANGLES, this.ind.length, GL.UNSIGNED_SHORT, 0);	// druhý parametr - počet indexů
		}
		else {
            this.stage.Gl.drawArrays(GL.TRIANGLES, 0, Std.int(this.vrt.length / 3));
		}
	}
	
	inline static public function unwrapF32(ind:Array<Int>, crd:Array<Float>, cpi:Int, ncrd:Float32Array) {
		var il = ind.length;
		for (i in 0...il) {
			for (j in 0...cpi) {
				ncrd[i * cpi + j] = crd[ind[i] * cpi + j];
			}
		}
	}
	
	static public function _makeTgs(stage:Stage, vrt:Array<Float>, ind:Array<Int>, ?uvt:Array<Float>, ?color:Float32Array, ?bdata:BitmapData):Tgs {
		var name = "t_" + vrt.length + "_" + ind.length;
		var arr = Tgs._delTgs[name];
		if (arr == null || arr.length == 0) {
			return new Tgs(stage, vrt, ind, uvt, color, bdata);
		}
		
		var t = arr.pop();
		Graphics._delNum--;
		t.Set(stage, vrt, ind, uvt, color, bdata);
		
		return t;
	}
	
	static public function _freeTgs(tgs:Tgs) {
		var arr:Array<Tgs> = Tgs._delTgs[tgs.name];
		if (arr == null) {
			arr = [];
		}
		arr.push(tgs);
		Tgs._delNum++;
		Tgs._delTgs[tgs.name] = arr;
	}
	
}
