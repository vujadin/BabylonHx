package samples.demos2D;

import com.babylonhx.display.Sprite;
import com.babylonhx.events.Event;
import com.babylonhx.events.KeyboardEvent;
import com.babylonhx.events.MouseEvent;
import com.babylonhx.geom.Point;
import com.babylonhx.utils.Keycodes;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Flipr {

	public function new() {
		
	}
	
}

class View extends Sprite {
	
	public var model:Model;
	public var book:Sprite;
	
	
	public function new(a:Model) {
		super();
		
		this.model = a;
		this.book = new Sprite;
		this.addChild(this.book);
		a = this.w = this.model.width;
		var b = this.h = this.model.height;
		this.pts = {
			temp: new Point,
			dir: new Point,
			m1: new Point
		};
		var c = new Sprite;
		c.graphics.beginFill(13421772, 1);
		c.graphics.drawTriangles([-a - 35, b / 2, - a - 20, b / 2 - 20, - a - 20, b / 2 + 20, a + 35, b / 2, a + 20, b / 2 + 20, a + 20, b / 2 - 20], [0, 1, 2, 3, 4, 5]);
		this.book.addChild(c);
		this.tw = a;
		this.th = b;
		this.iw = 1 / a;
		this.ih = 1 / b;
		var c = this.rx = a / this.tw,
			d = this.ry = b / this.th;
		this.lvrt = [-a, 0, 0, 0, - a, b,
		0, b];
		this.rvrt = [0, 0, a, 0, 0, b, a, b];
		this.ind = [0, 1, 2, 1, 2, 3];
		this.uvt = [0, 0, c, 0, 0, d, c, d];
		this.cVrt = [0, 0, a, 0, 0, b, a, b];
		this.cUvt = [0, 0, 0, 0, 0, 0, 0, 0];
		this.oVrt = [0, 0, a, 0, 0, b, a, b];
		this.oUvt = [0, 0, 0, 0, 0, 0, 0, 0];
		this.rVrt = [0, 0, a, 0, 0, b, a, b, 0, 0];
		this.rUvt = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		this.rInd = [0, 1, 2, 1, 2, 3, 1, 3, 4];
		this.zero = new Point(0, 0);
		this.rTop = new Point(a, 0);
		this.mBottom = new Point(0, b);
		this.rBottom = new Point(a, b);
		a = new TextFormat("Trebuchet MS", 18, 12303291, !0);
		b = this.officBTN = new TextField;
		b.buttonMode = !0;
		b.setTextFormat(a);
		b.text = "made with Flipr";
		b.width = b.textWidth;
		b.height = b.textHeight;
		b.addEventListener(MouseEvent.MOUSE_DOWN, function(a) {
			window.open("http://flipr.ivank.net", "_blank")
		})
	}
	View.prototype = new Sprite;
	View.prototype.resize = function(a, b) {
		var c = Math.sqrt(this.model.width * this.model.width + this.model.height * this.model.height);
		this.book.scaleX = this.book.scaleY = .99 * Math.min(a / (2 * this.model.width), b / c);
		this.book.x = .5 * a;
		this.book.y = .5 * (b - c * this.book.scaleX) + this.book.scaleX * (c - this.model.height);
		this.officBTN.x = a - this.officBTN.getRect(this).width - 15;
		this.officBTN.y = b - this.officBTN.getRect(this).height - 15
	};
	View.prototype.drawBook = function(a, b) {
		var c = this.model;
		this.book.graphics.clear();
		if (null == a) 2 <= c.current && this.drawPage(1), c.current < c.numOfPages && this.drawPage(2);
		else if (0 == b && c.current < c.numOfPages && this.drawPage(2), 1 == b && 2 <= c.current && this.drawPage(1), !(0 == b && 2 > c.current || 1 == b && c.current >= c.numOfPages)) {
			var d = this.cVrt,
				l = this.cUvt,
				g = this.oVrt,
				m = this.oUvt,
				f = this.rVrt,
				n = this.rUvt,
				e = this.model.width,
				k = this.model.height;
			a = a.clone();
			Geom.limit(a, e, 0, k);
			0 == b && (a.x *= -1);
			if (-4 <= a.x - e && -4 <= a.y - k) 2 <= c.current && this.drawPage(1), c.current < c.numOfPages && this.drawPage(2);
			else {
				d[2] = d[6] = e;
				d[3] = 0;
				d[7] = k;
				var k = Geom.mid(a, this.rBottom),
					p = this.pts.dir;
				p.x = k.y - a.y;
				p.y = a.x - k.x;
				var q = this.pts.m1;
				q.x = k.x + p.x;
				q.y = k.y + p.y;
				var h = this.pts.temp,
					t = !1,
					r = h,
					t = Geom.lineIsc(k, q, this.mBottom, this.rBottom, r);
				if (!t || 0 > r.x) r = this.mBottom;
				d[4] = f[6] = r.x;
				d[5] = f[7] = r.y;
				(t = Geom.lineIsc(k, q, this.rTop, this.rBottom, h)) && 0 < h.y ? (d[0] = d[2] = h.x, d[1] = d[3] = h.y, f[2] = e, f[3] = 0, f[8] = h.x, f[9] = h.y) : (d[2] = e, d[3] = 0, Geom.lineIsc(k, q, this.zero, this.rTop,
				h), d[0] = h.x, d[1] = h.y, f[2] = f[8] = h.x, f[3] = f[9] = h.y);
				this.toTex(d, l);
				this.toTex(f, n);
				for (e = 0; e < g.length; e++) g[e] = d[e], m[e] = l[e];
				0 == b && (this.Transform(f, 0, - 1), this.Transform(n, - this.rx, - 1));
				e = this.model.images[this.model.current + (0 == b ? -1 : 0)];
				this.book.graphics.beginBitmapFill(e);
				this.book.graphics.drawTriangles(f, this.rInd, n);
				0 == b && 2 == c.current || 1 == b && c.current == c.numOfPages - 2 || (0 == b && (this.Transform(d, 0, - 1), this.Transform(l, - this.rx, - 1)), e = this.model.images[this.model.current + (0 == b ? -3 : 2)], this.book.graphics.beginBitmapFill(e),
				this.book.graphics.drawTriangles(d, this.ind, l));
				h.x = g[2];
				h.y = g[3];
				c = Geom.mirror(h, k, p);
				d = Geom.mirror(this.rBottom, k, p);
				g[2] = c.x;
				g[3] = c.y;
				g[6] = d.x;
				g[7] = d.y;
				this.Transform(m, - this.rx, - 1);
				0 == b && (this.Transform(g, 0, - 1), this.Transform(m, - this.rx, - 1));
				e = this.model.images[this.model.current + (0 == b ? -2 : 1)];
				this.book.graphics.beginBitmapFill(e);
				this.book.graphics.drawTriangles(g, this.ind, m)
			}
		}
	};
	View.prototype.toTex = function(a, b) {
		for (var c = 0; c < a.length; c += 2) b[c] = this.rx * a[c] * this.iw, b[c + 1] = this.ry * a[c + 1] * this.ih
	};
	View.prototype.Transform = function(a, b, c) {
		for (var d = 0; d < a.length; d += 2) a[d] = c * (a[d] + b)
	};
	View.prototype.drawPage = function(a) {
		var b = this.model,
			c = this.book.graphics;
		c.beginBitmapFill(b.images[b.current - 2 + a]);
		2 > a ? c.drawTriangles(this.lvrt, this.ind, this.uvt) : c.drawTriangles(this.rvrt, this.ind, this.uvt)
	};
	View.prototype.nhpot = function(a) {
		--a;
		for (var b = 1; 32 > b; b <<= 1) a |= a >> b;
		return a + 1
	};
	
}

class Controller {
	
	static public var cur:Controller;
	
	public var model:Model;
	public var view:View;
	
	public var m:Point;
	public var p:Point;
	public var tp:Point;
	
	public var finishing:Bool;
	public var movePage:Bool;
	
	
	public function new(a, b) {
		Controller.cur = this;
		this.model = a;
		this.view = b;
		this.start = 0;
		this.finishing = this.movePage = false;
		this.m = new Point(0, 0);
		this.p = new Point(0, 0);
		this.tp = new Point(a.width, a.height);
		this.view.drawBook(null);
		this.view.addEventListener2(Event.ADDED_TO_STAGE, this.onATS, this)
	}
	
	public function onATS(a) {
		a = this.view.stage;
		a.addEventListener2(MouseEvent.MOUSE_DOWN, this.viewMD, this);
		a.addEventListener2(MouseEvent.MOUSE_UP, this.viewMU, this);
		a.addEventListener2(MouseEvent.MOUSE_MOVE, this.viewMM, this);
		a.addEventListener2(KeyboardEvent.KEY_DOWN, this.onKD, this);
		a.addEventListener2(Event.ENTER_FRAME, this.viewEF, this)
	}
	
	public function resize(a, b) {
		this.view.resize(a, b)
	}
	
	public function onKD(a) {
		if (Keycodes.left == a.keyCode) {
			this.flipBack();
		}
		if (Keycodes.right == a.keyCode) {
			this.flipFront()
		}
	}
	
	public function finishFlip() {
		if (this.finishing) {
			var a = this.p;
			this.finishing = false;
			if (0 > a.x && 1 == this.start) {
				this.model.FlipForward();
			}
			if (0 < a.x && 0 == this.start) {
				this.model.FlipBack();
			}
			
			this.view.drawBook(null, 0)
		}
	}
	
	public function viewMD(a) {
		a = this.model;
		this.m.setTo(this.view.book.mouseX, this.view.book.mouseY);
		Math.abs(this.m.x) > a.width ? (0 > this.m.x && this.flipBack(), 0 < this.m.x && this.flipFront()) : (this.finishFlip(), this.start = 0 > this.m.x ? 0 : 1, this.movePage = !0, this.viewMM(null))
	}
	
	public function flipFront() {
		var a = this.model;
		this.finishFlip();
		a.current < a.numOfPages - 1 && (this.tp.x = -this.model.width, this.start = 1, this.finishing = !0);
		this.p.y = .5 * a.height;
		this.p.x = -this.tp.x
	}
	
	public function flipBack() {
		var a = this.model;
		this.finishFlip();
		0 < a.current && (this.tp.x = this.model.width, this.start = 0, this.finishing = !0);
		this.p.y = .5 * a.height;
		this.p.x = -this.tp.x
	}
	
	public function viewMU(a) {
		if (this.movePage) {
			this.finishing = true;
			this.p.x = this.m.x;
			this.p.y = this.m.y;
			this.tp.x = 0 < this.m.x ? this.model.width : -this.model.width;
		}
		
		this.movePage = false;
	}
	
	public function viewMM(a:Point) {
		a = this.m;
		a.x = this.view.book.mouseX;
		a.y = Math.min(this.view.book.mouseY, this.model.height);
		if (this.movePage) {
			this.view.drawBook(a, this.start)
		}
	}
	
	public function viewEF(a:Point) {
		a = this.p;
		var b = this.tp;
		if (this.finishing) {
			a.x = (5 * a.x + b.x) / 6;
			a.y = (5 * a.y + b.y) / 6;
			this.view.drawBook(a, this.start);
			if (3 > Point.distance(a, b)) {
				this.finishFlip();
			}
		}
	}
	
}

class Geom {
	
	static public function limit(a:Point, b:Point, c:Float, d:Float) {
        var l = a.x - c;
        var g = a.y - d;
        var m = Math.sqrt(l * l + g * g);
        var f = b / m;
        if (m > b) {
			a.x = c + l * f;
			a.y = d + g * f;
		}
    }
    
	static public function mid(a:Point, b:Point):Point {
        return new Point(.5 * (a.x + b.x), .5 * (a.y + b.y))
    }
	
    static public function mirror(a:Point, b:Point, c:Point):Point {
        if (0 == c.x) {
			return new Point(b.x - (a.x - b.x), a.y);
		}
        var cc = c.y / c.x;
        var bb = b.y - c * b.x;
        var d = (a.x + (a.y - bb) * cc) / (1 + cc * cc);
		
        return new Point(2 * d - a.x, 2 * d * cc - a.y + 2 * bb)
    }
	
    static public function lineIsc(a:Point, b:Point, c:Point, d:Point, l:Point):Bool {
        var g = a.x - b.x;
        var m = c.x - d.x;
        var f = a.y - b.y;
        var n = c.y - d.y;
        var e = g * n - f * m;
		
        if (0 == e) {
			return false;
		}
		
        var aa = a.x * b.y - a.y * b.x;
        var cc = c.x * d.y - c.y * d.x;
        l.x = (aa * m - g * cc) / e;
        l.y = (aa * n - f * cc) / e;
		
        return true;
    }
	
}
