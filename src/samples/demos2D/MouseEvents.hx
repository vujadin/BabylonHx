package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.DisplayObject;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.d2.geom.Point;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class MouseEvents {
	
	var p:Point = new Point(0, 0);
	var cur:DisplayObject = null;
	var stage:Stage;
	
	
	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		Start();
	}
	
	function Start() {
		Tools.LoadImage("assets/img/ball.png", function(img) {
			var bd = new BitmapData(img);
			for (i in 0...20) {
				var b = new Bitmap(bd);
				b.x = Math.random() * stage.stageWidth;
				b.y = Math.random() * stage.stageHeight;
				b.buttonMode = true;
				b.alpha = 0.7;
				stage.addChild(b);
				
				b.addEventListener(MouseEvent.MOUSE_OVER, onMOv);
				b.addEventListener(MouseEvent.MOUSE_OUT, onMOu);
				b.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
				b.addEventListener(MouseEvent.MOUSE_UP, onMU);
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMM);
		});
	}
	
	function onMOv(e:Event) { 
		e.target.alpha = 1.0;
	}
	
	function onMOu(e:Event) { 
		e.target.alpha = 0.7; 
	}
	
	function onMD(e) { 
		cur = e.target; 
		p.x = cur.mouseX; 
		p.y = cur.mouseY; 
	}
	
	function onMU(e) { 
		cur = null; 
	}
	
	function onMM(e:Event) {
		if (cur == null) {
			return;
		}
		cur.x = stage.mouseX - p.x;
		cur.y = stage.mouseY - p.y;
	}
	
}
