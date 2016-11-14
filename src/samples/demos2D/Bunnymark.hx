package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Bunnymark {
	
	var gravity = 2;
	var bunnies:Array<Bunny> = [];
	var minX = 0;
	var maxX = 640;
	var minY = 0;
	var maxY = 480;
	var bunnyBD:BitmapData;
	var adding = false;
	var fps = 60.0;
	var time:Float;
	
	var stage:Stage;
	

	public function new(scene:Scene) {	
		this.stage = scene.stage2D;
		
		time = Date.now().getTime();
		
		maxX = stage.stageWidth -  26;
		maxY = stage.stageHeight - 37;
		
		stage.addEventListener(Event.RESIZE, function(_) {
			maxX = stage.stageWidth -  26;
			maxY = stage.stageHeight - 37;
		});
		
		Tools.LoadImage("assets/img/wabbit_alpha.png", function(img) {
			bunnyBD = new BitmapData(img);
			addBunnies(50);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e) { adding = true;  });
			stage.addEventListener(MouseEvent.MOUSE_UP  , function(e) { adding = false; });
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);	
		});
	}
	
	function addBunnies(n:Int) {
		for (i in 0...n) {
			var bunny = new Bunny(bunnyBD);
			bunny.speedX = Math.random() * 10;
			bunny.speedY = Math.random() * 10 - 5;
			stage.addChild(bunny);
			bunnies.push(bunny);
		}
	}
	
	function onEnterFrame(event:Event) {
		if (adding) {
			addBunnies(10);
		}
		
		var ntime = Date.now().getTime();
		fps = 0.97 * fps + 0.03 * 1000 / (ntime-time);
		time = ntime;
		
		for (i in 0...bunnies.length) {
			var bunny = bunnies[i];
			bunny.x += bunny.speedX;
			bunny.y += bunny.speedY;
			bunny.speedY += gravity;
			
			if (bunny.x > maxX) {
				bunny.speedX *= -1;
				bunny.x = maxX;
			}
			else if (bunny.x < minX) {
				bunny.speedX *= -1;
				bunny.x = minX;
			}
			
			if (bunny.y > maxY) {
				bunny.speedY *= -0.8;
				bunny.y = maxY;
				if (Math.random() > 0.5) {
					bunny.speedY -= Math.random() * 12;
				}
			} 
			else if (bunny.y < minY) {
				bunny.speedY = 0;
				bunny.y = minY;
			}
		}
	}
	
}

class Bunny extends Bitmap {
	
	public var speedX:Float;
	public var speedY:Float;
	
	
	public function new(bd:BitmapData) {
		super(bd);
	}
	
}
