package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.KeyboardEvent;
import com.babylonhx.tools.Tools;
import com.babylonhx.utils.Keycodes;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class KeyboardEvents {	

	var stage:Stage;
	var car:Sprite;
	var angle:Float = 0;
	var speed:Float = 0;
	var l:Bool;
	var r:Bool;
	var u:Bool;
	var d:Bool;
	
	
	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		
		Tools.LoadImage("assets/img/car.png", function(img) {			
			// car			
			car = new Sprite(); 
			car.x = stage.stageWidth / 2;
			car.y = stage.stageHeight / 2;
			var cb = new Bitmap(new BitmapData(img));
			cb.x = -123; 
			cb.y = -50; 
			car.addChild(cb);
			stage.addChild(car);
			
			// events
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKD);
			stage.addEventListener(KeyboardEvent.KEY_UP  , onKU);
			stage.addEventListener(Event.ENTER_FRAME     , onEF);
		});
	}
	
	function onKD(e) { 
		if (e.keyCode == Keycodes.left) l = true;
		if (e.keyCode == Keycodes.up) u = true;
		if (e.keyCode == Keycodes.right) r = true;
		if (e.keyCode == Keycodes.down) d = true;
	}
	
	function onKU(e) {
		if (e.keyCode == Keycodes.left) l = false;
		if (e.keyCode == Keycodes.up) u = false;
		if (e.keyCode == Keycodes.right) r = false;
		if (e.keyCode == Keycodes.down) d = false;
	}
	
	function onEF(e) {
		speed *= 0.9;
		if (u) {
			speed += 1 + speed * 0.06;
		}
		if (d) {
			speed -= 1;
		}
		
		if (r) {
			angle += speed * 0.003;
		}
		if (l) {
			angle -= speed * 0.003;
		}
		
		car.rotation = angle * 180 / Math.PI;
		car.x += Math.cos(angle) * speed;
		car.y += Math.sin(angle) * speed;
	}	
	
}
