package com.babylonhx.d2.display;

import com.babylonhx.d2.geom.Rectangle;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * A basic class for vector drawing
 * 
 * @author Ivan Kuckir
 */
class Graphics {
	
	@:allow(com.babylonhx.d2.display.Tgs)
	private static var _delTgs:Map<String, Array<Tgs>> = new Map();
	@:allow(com.babylonhx.d2.display.Tgs)
	private static var _delNum:Int = 0;
	
	private var _points:Array<Float>;
	
	public var _conf:GraphicsConfig;
	public var _fills:Array<Fill>;
	public var _afills:Array<Dynamic>;
	//private var _lfill:Tgs;
	public var _rect:Rectangle;
	public var _srect:Rectangle;
    public var _stage:Stage;
	

	public function new() {
		this._conf = new GraphicsConfig();
		
		this._conf.ftype = 0;
		this._conf.fbdata = null;
		this._conf.fcolor = null;
		this._conf.lwidth = 0;
		this._conf.lcolor = null;
		
		this._points = [0, 0];
		this._fills  = [];
		this._afills = [];	// _fills + triangles
		//this._lfill = null;	// last fill (Graphics.Fill or Graphics.Tgs)
		this._rect = new Rectangle(0, 0, 0, 0);	// fill rect
		this._srect = new Rectangle(0, 0, 0, 0);	// stroke rect
		
		this._startNewFill();
	}
	
	private function _startNewFill() {	// starting new fill with new line, ending old line
		this._endLine();
		var len = Std.int(this._points.length / 2);
		var fill = new Fill(len - 1, this._conf);
		this._fills.push(fill);
		this._afills.push(fill);
		//this._lfill = fill;
	}
	
	private function _startLine() {
		var len = Std.int(this._points.length / 2);
		var fill = this._fills[this._fills.length - 1];
		var fllen = fill.lines.length;
		
		if (fllen > 0 && fill.lines[fllen - 1].isEmpty()) {
			fill.lines[fllen - 1].Set(len - 1, this._conf);
		}
		else {
			fill.lines.push(new Line(len - 1, this._conf));
		}
	}
	
	private function _endLine()	{	// starting new line in last fill
		if (this._fills.length == 0) {
			return;
		}
		
		var len = Std.int(this._points.length / 2);
		var fill = this._fills[this._fills.length - 1];
		if (fill.lines.length != 0) {
			fill.lines[fill.lines.length - 1].end = len - 1;
		}
	}
	
	/**
	 * Renders a vector content
	 */
	public function _render() {
		this._endLine();
		GL.uniformMatrix4fv(this._stage._sprg.tMatUniform, false, this._stage._mstack.top());
        this._stage._updateCMStack();
		
		for (i in 0...this._afills.length) {
			this._afills[i].render(this._stage, this._points, this._rect);
		}
	}

	public function lineStyle(thickness:Float, color:Int = 0x000000, alpha:Float = 1) {
		this._conf.lwidth = thickness;
		this._conf.lcolor = Graphics.makeColor(color, alpha);
		
		this._endLine();
		this._startLine();
	}
		
	/**
	 * Begin to fill some shape
	 * @param color	color
	 */
	public function beginFill(color:Int = 0x000000, alpha:Float = 1) {
		this._conf.ftype  = 1;
		this._conf.fcolor = Graphics.makeColor(color, alpha);
		this._startNewFill();
	}
	
	inline public function beginBitmapFill(bdata:BitmapData) {
		this._conf.ftype  = 2;
		this._conf.fbdata = bdata;
		this._startNewFill();
	}
		
	/**
	 * End filling some shape
	 */
	inline public function endFill() { 
		this._conf.ftype  = 0;
		this._startNewFill();
	}
		
	/**
	 * Move a "drawing brush" to some position
	 * @param x
	 * @param y
	 */
	inline public function moveTo(x:Float, y:Float) {
		this._endLine();
		this._points.push(x);
		this._points.push(y);
		this._startLine();
	}
		
	/**
	 * Draw a line to some position
	 * @param x
	 * @param y
	 */
	public function lineTo(x2:Float, y2:Float) {
		var ps = this._points;
		if (x2 == ps[ps.length - 2] && y2 == ps[ps.length - 1]) {
			return;
		}
		
		if (ps.length > 0) {
			if (this._conf.ftype > 0) {
				this._rect._unionWL(ps[ps.length - 2], ps[ps.length - 1], x2, y2);
			}
		}
		if (this._conf.lwidth > 0) {
			this._srect._unionWL(ps[ps.length - 2], ps[ps.length - 1], x2, y2);
		}
		
		ps.push(x2);
		ps.push(y2);
	}	
	
	inline public function curveTo(bx:Float, by:Float, cx:Float, cy:Float) {
		var ps = this._points;
		var ax   = ps[ps.length - 2];
		var ay   = ps[ps.length - 1];
		var t = 2 / 3;
		this.cubicCurveTo(ax + t * (bx - ax), ay + t * (by - ay), cx + t * (bx - cx), cy + t * (by - cy), cx, cy);
	}
	
	public function cubicCurveTo(bx:Float, by:Float, cx:Float, cy:Float, dx:Float, dy:Float, parts:Int = 40) {
		/*
				b --- q --- c
			   / 			 \
			  p				  r
			 /				   \
			a					d
		*/
		var ps = this._points;
		var ax   = ps[ps.length - 2];
		var ay = ps[ps.length - 1];
		var tobx = bx - ax, toby = by - ay;  // directions
		var tocx = cx - bx, tocy = cy - by;
		var todx = dx - cx, tody = dy - cy;
		var step = 1 / parts;
		
		for (i in 1...parts) {
			var d = i * step;
			var px = ax + d * tobx,  py = ay + d * toby;
			var qx = bx + d * tocx,  qy = by + d * tocy;
			var rx = cx + d * todx,  ry = cy + d * tody;
			var toqx = qx - px,   toqy = qy - py;
			var torx = rx - qx,   tory = ry - qy;
			
			var sx = px + d * toqx, sy = py + d * toqy;
			var tx = qx + d * torx, ty = qy + d * tory;
			var totx = tx - sx,  toty = ty - sy;
			this.lineTo(sx + d * totx, sy + d * toty);
		}
		
		this.lineTo(dx, dy);
	}
		
	/**
	 * Draw a circle
	 * @param x		X coordinate of a center
	 * @param y		Y coordinate of a center
	 * @param r		radius
	 */
	inline public function drawCircle(x:Float, y:Float, r:Float) {
		this.drawEllipse(x, y, r * 2, r * 2);
	}
	
	/**
	 * Draw an ellipse
	 * @param x		X coordinate of a center
	 * @param y		Y coordinate of a center
	 * @param w		ellipse width
	 * @param h		ellipse height
	 */
	public function drawEllipse(x:Float, y:Float, w:Float, h:Float) {
		var hw = w / 2, hh = h / 2;
		var c = 0.553;
		this.moveTo(x, y - hh);
		
		this.cubicCurveTo(x + c * hw, y - hh,    x + hw, y - c * hh,     x + hw, y, 16);
		this.cubicCurveTo(x + hw, y + c * hh,    x + c * hw, y + hh,     x, y + hh, 16);
		this.cubicCurveTo(x - c * hw, y + hh,    x - hw, y + c * hh,     x - hw, y, 16);
		this.cubicCurveTo(x - hw, y - c * hh,    x - c * hw, y - hh,     x, y - hh, 16);
	}		
	
	inline public function drawRect(x:Float, y:Float, w:Float, h:Float) {
		this.moveTo(x, y);
		this.lineTo(x + w, y);
		this.lineTo(x + w, y + h);
		this.lineTo(x, y + h);
		this.lineTo(x, y);
	}
	
	/**
	 * Draws a rectangle with round corners
	 * @param x		X coordinate of top left corner
	 * @param y		Y coordinate of top left corner
	 * @param w		width
	 * @param h		height
	 */
	public function drawRoundRect(x:Float, y:Float, w:Float, h:Float, ew:Float, eh:Float) {
		var hw = ew / 2, hh = eh / 2;
		var c = 0.553;
		var x0 = x + hw, x1 = x + w - hw;
		var y0 = y + hh, y1 = y + h - hh; 
		
		this.moveTo(x0, y);
		this.lineTo(x1, y);
		this.cubicCurveTo(x1 + c * hw, y,    x + w, y0 - c * hh,   x + w, y0, 16);
		this.lineTo(x+w, y1);
		this.cubicCurveTo(x + w, y1 + c * hh,  x1 + c * hw, y + h,   x1, y + h, 16);
		this.lineTo(x0, y+h);
		this.cubicCurveTo(x0 - c * hw, y + h,  x, y1 + c * hh,     x,  y1 , 16);
		this.lineTo(x, y0);
		this.cubicCurveTo(x, y0-c*hh,    x0-c*hw, y,     x0, y  , 16);
	}
	
	public function drawTriangles(vrt:Array<Float>, ind:Array<Int>, ?uvt:Array<Float>) {
		Fill.updateRect(vrt, this._rect);
		var nvrt:Array<Float> = [];
		
		var i:Int = 0;
		while (i < vrt.length) {
			nvrt.push(vrt[i]);
			nvrt.push(vrt[i + 1]);
			nvrt.push(0);
			i += 2;
		}
		
		var tgs = Tgs._makeTgs(this._stage, nvrt, ind, uvt, this._conf.fcolor, this._conf.fbdata);
		this._afills.push(tgs);
	}
	
	public function drawTriangles3D(vrt:Array<Float>, ind:Array<Int>, uvt:Array<Float>) {
		var tgs = Tgs._makeTgs(this._stage, vrt, ind, uvt, this._conf.fcolor, this._conf.fbdata);
		this._afills.push(tgs);
	}
	
	
	public function clear() {
		this._conf.ftype = 0;
		this._conf.fbdata = null;
		this._conf.fcolor = null;
		this._conf.lwidth = 0;
		
		this._points = [0, 0];
		this._fills  = [];
		for(i in 0...this._afills.length) {
			var f = this._afills[i];
			if (Std.is(f, Fill)) { 
				if (f.tgs != null) {
					Tgs._freeTgs(cast(f, Fill).tgs); 
				}
				for (j in 0...f.lineTGS.length) {
					Tgs._freeTgs(cast(f, Fill).lineTGS[j]);
				}
			}
			else {
				Tgs._freeTgs(cast f);
			}
		}
		
		this._afills = [];	// _fills + triangles
		//this._lfill = null;
		this._rect.setEmpty();
		this._startNewFill();
	}
		
	/**
	 * Returns a bounding rectangle of a vector content
	 * @return	a bounding rectangle
	 */		 
	public function _getLocRect(stks:Bool) {
		if (stks == false) {
			return this._rect;
		}
		else {
			return this._rect.union(this._srect);
		}
	}
	
	inline public function _hits(x:Float, y:Float):Bool {
		return this._rect.contains(x, y);
	}
	
	public static function makeColor(c:Int, a:Float):Float32Array {
		var col = new Float32Array(4);
		col[0] = (c >> 16 & 255) * 0.0039215686;
		col[1] = (c >> 8 & 255) * 0.0039215686;
		col[2] = (c & 255) * 0.0039215686;
		col[3] = a;
		
		return col;
	}	
	
	inline public static function equalColor(a:Float32Array, b:Float32Array):Bool {
		return a[0] == b[0] && a[1] == b[1] && a[2] == b[2] && a[3] == b[3];
	}
	
	inline public static function len(x:Float, y:Float):Float {
		return Math.sqrt(x * x + y * y);
	}
	
}
