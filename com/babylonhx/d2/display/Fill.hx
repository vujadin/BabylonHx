package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Rectangle;

import lime.utils.Float32Array;


/**
 * ...
 * @author Krtolica Vujadin
 */

/*
	Fill represents a drawable element.
*/
class Fill {

	public var type:Int;
	public var color:Float32Array;
	public var bdata:BitmapData;
	
	public var lines:Array<Line>;
	public var lineTGS:Array<Tgs>;
	
	public var dirty:Bool;
	
	public var tgs:Tgs;
	
	
	public function new(begin:Int, conf:Dynamic) {
		// type: 0 - none, 1 - color, 2 - bitmap;
		this.type = conf.ftype;
		this.color = conf.fcolor;
		this.bdata = conf.fbdata;
		
		this.lines = [new Line(begin, conf)];
		this.lineTGS = [];
		
		this.dirty = true;
		
		this.tgs = null;
	}
	
	public function Build(st:Stage, ps:Array<Float>, rect:Rectangle) {
		var tvrt:Array<Float> = [];
		var tind:Array<Int> = [];
		
		var lTGS:Array<Dynamic> = [];	// array of { vrt:[], ind:[], color:[] }
		
		var cline:Dynamic = null;
		var lwidth:Float = -1;
		var lcolor:Float32Array = null;
		
		for (l in 0...this.lines.length) {
			var line = this.lines[l];
			if (line.begin == line.end) {
				continue;
			}
			
			var lbeg = line.begin * 2;
			var lend = line.end * 2;
			
			var firstEqLast = (ps[lbeg] == ps[lend] && ps[lbeg + 1] == ps[lend + 1]);
			if (firstEqLast) {
				lend -= 2;
			}
			
			if (line.width > 0) {
				if (cline == null || line.width != lwidth || !Graphics.equalColor(lcolor, line.color)) {
					cline = { vrt:[], ind:[], color:line.color };
					lTGS.push(cline);
					lwidth = line.width;
					lcolor = line.color;
				}
				Line.GetTriangles(ps, lbeg, lend, line, (this.type != 0 || firstEqLast), cline.ind, cline.vrt);
			}
			
			if (this.type != 0 && lend - lbeg > 2) {
				var vts = ps.slice(line.begin * 2, line.end * 2 + 2);
				if (firstEqLast) { 
					vts.pop(); 
					vts.pop(); 
				}
				if (PolyK.GetArea(vts) < 0) {
					vts = PolyK.Reverse(vts);
				}
				
				var vnum = Std.int(tvrt.length / 3);
				var ind = PolyK.Triangulate(vts);
				
				for (i in 0...ind.length) {
					tind.push(ind[i] + vnum);
				}
				
				for (i in 0...Std.int(vts.length / 2)) {
					tvrt.push(vts[2 * i]);
					tvrt.push(vts[2 * i + 1]);
					tvrt.push(0);
				}
			}
		}
		
		for (i in 0...lTGS.length) { 
			this.lineTGS.push(Tgs._makeTgs(st, lTGS[i].vrt, lTGS[i].ind, null, lTGS[i].color));
		}
		
		if (tvrt.length > 0) {
			this.tgs = Tgs._makeTgs(st, tvrt, tind, null, this.color, this.bdata);
		}
	}
	
	public function isEmpty():Bool {
		if (this.lines.length == 0) {
			return true;
		}
		
		return this.lines[0].isEmpty();
	}
	
	public function render(st:Stage, ps:Array<Float>, rect:Rectangle) {
		if (this.dirty) { 
			this.Build(st, ps, rect);
			this.dirty = false; 
		}
		if (this.tgs != null) {
			this.tgs.render();
		}
		for (i in 0...this.lineTGS.length) {
			this.lineTGS[i].render();
		}
	}
	
	static public function updateRect(vts:Array<Float>, rect:Rectangle) {
		var minx = Math.POSITIVE_INFINITY;
		var miny = Math.POSITIVE_INFINITY;
		var maxx = Math.NEGATIVE_INFINITY;
		var maxy = Math.NEGATIVE_INFINITY;
		
		if (!rect.isEmpty()) { 
			minx = rect.x; 
			miny = rect.y; 
			maxx = rect.x + rect.width; 
			maxy = rect.y + rect.height;  
		}
		
		var i:Int = 0;
		while (i < vts.length) {
			minx = Math.min(minx, vts[i  ]);
			miny = Math.min(miny, vts[i + 1]);
			maxx = Math.max(maxx, vts[i  ]);
			maxy = Math.max(maxy, vts[i + 1]);
			
			i += 2;
		}
		
		rect.x = minx;  
		rect.y = miny; 
		rect.width = maxx - minx;  
		rect.height = maxy - miny;
	}
	
}
