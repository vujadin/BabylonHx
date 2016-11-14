package samples.demos2D;

import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Bezier {

	var stage:Stage;
	var s:Sprite;
	var dragged:Sprite;
	var q1:Dot;
	var q2:Dot;
	var q3:Dot;     // anchors for Quadratic Bézier
	var c1:Dot;
	var c2:Dot;
	var c3:Dot;
	var c4:Dot;     // anchors for Cubic Bézier
	
	
	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		Start();
	}
	
	function Start() {
		s = new Sprite();
		stage.addChild(s);
		
		q1 = new Dot();  q2 = new Dot();  q3 = new Dot();
		c1 = new Dot();  c2 = new Dot();  c3 = new Dot();  c4 = new Dot();
		var ds = [q1, q2, q3, c1, c2, c3, c4];
		for (i in 0...ds.length) {
			ds[i].x = 50 + i * 120;  
			ds[i].y = 200 - 100 * Math.sin(i * 1.7);
			ds[i].addEventListener(MouseEvent.MOUSE_DOWN, onMD);
			s.addChild(ds[i]);
		}
		
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMM);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMU);
		redraw();
	}
	
	function onMD(e:Event) {
		dragged = cast e.target;
	}
	
	function onMU(e:Event) {
		dragged = null;    
	}
	
	function onMM(e:Event) {
		if (dragged == null) {
			return;
		}
		
		dragged.x = stage.mouseX;  
		dragged.y = stage.mouseY;
		redraw();
	}
	
	function redraw() {
		var g = s.graphics;
		
		g.clear();
		g.lineStyle(2, 0x999999);    //  two "skeletons"
		g.moveTo(q1.x, q1.y);
		g.lineTo(q2.x, q2.y);  
		g.lineTo(q3.x, q3.y);
		g.moveTo(c1.x, c1.y);
		g.lineTo(c2.x, c2.y);  
		g.lineTo(c3.x, c3.y);  
		g.lineTo(c4.x, c4.y);
		
		g.lineStyle(7, 0xff9900);    //  two curves
		g.moveTo(q1.x, q1.y);
		g.curveTo(q2.x, q2.y, q3.x, q3.y);
		g.lineStyle(7, 0x00aaff);
		g.moveTo(c1.x, c1.y);
		g.cubicCurveTo(c2.x, c2.y, c3.x, c3.y, c4.x, c4.y);
	}
	
}

class Dot extends Sprite {
	
	public function new() {
		super();
		
		this.graphics.beginFill(0x000000, 0.15);
		this.graphics.drawCircle(0, 0, 13);
		this.graphics.beginFill(0x999999, 1.0);
		this.graphics.drawCircle(0,0, 6);	
		this.buttonMode = true;
	}
	
}
