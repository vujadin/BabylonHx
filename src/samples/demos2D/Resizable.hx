package samples.demos2D;

import com.babylonhx.Scene;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.text.TextField;
import com.babylonhx.d2.events.Event;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Resizable {
	
	var stage:Stage;
	var main:Sprite;
	

	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		
		Start();
	}	
	
	function Start() {
		main = new Sprite();
		stage.addChild(main);
		
		draw();
		
		// when stage is resized, "resize" will be called
		stage.addEventListener(Event.RESIZE, resize); 
		
		resize();
	}
	
	function resize(e = null) {
		var w = stage.stageWidth;
		var h = stage.stageHeight; 
		
		var min = Math.min(w, h);
		main.scaleX = main.scaleY = min / 2000;
		main.x = (w - min) / 2;
		main.y = (h - min) / 2;
	}
	
	function draw() {		
		this.main.graphics.beginFill(0xffffff, 0.2);
		this.main.graphics.drawRect(0, 0, 2000, 2000);
		
		TextField.registerFont("assets/fonts/se.fnt", "se");
		
		for(i in 0...5) {
			var b = new Button("Button " + (i + 1), "se", 94);
			this.main.addChild(b);
			b.x = 700;  
			b.y = 900 + 200 * i;
		}
		
		var t1 = new TextField("The main content of the app can be\ninside this square, which is always\ncentered and scaled according to\ndimensions of the Stage.\nTry to resize the window.", "se", 600, 180); 
		/*t1.graphics.beginFill(0x000000, 0.6);
		t1.graphics.drawRect(0, 0, t1.width, t1.height);
		t1.graphics.endFill();*/
		t1.scaleX = t1.scaleY = 3;
		this.main.addChild(t1);  
		t1.x = t1.y = 100;
	}
	
}
