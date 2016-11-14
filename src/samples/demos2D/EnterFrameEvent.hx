package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.geom.Point;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class EnterFrameEvent {
	
	var balls = [];	// balls
	var dirs  = [];	// directions
	var stage:Stage;

	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		
		Start(stage);
	}	
	
	function Start(stage:Stage) {			
		Tools.LoadImage("assets/img/ball.png", function(ballImg) {
			var bd = new BitmapData(ballImg);
			for (i in 0...100) {
				var b = new Bitmap(bd);
				b.x = Math.random() * 900;
				b.y = Math.random() * 500;
				balls.push(b);
				dirs .push(new Point(2 + Math.random() * 8, 2 + Math.random() * 8));
				stage.addChild(b);
			}
			
			stage.addEventListener(Event.ENTER_FRAME, onEF);
		});
	}
	
	function onEF(_) {
		var w = stage.stageWidth - 100;
		var h = stage.stageHeight - 100;
		for(i in 0...balls.length) {
			var b = balls[i];
			var d = dirs[i];
			b.x += d.x;	 
			b.y += d.y;
			if (b.x < 0) {
				d.x = Math.abs(d.x);  
			}
			if (b.x > w) {
				d.x = -Math.abs(d.x);
			}
			if (b.y < 0) {
				d.y = Math.abs(d.y);  
			}
			if (b.y > h) {
				d.y = -Math.abs(d.y);
			}
		}
	}
	
}
