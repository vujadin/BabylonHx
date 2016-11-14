package samples.demos2D;

import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

import haxe.Json;
import lime.Assets;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Real3D {
	
	var stage:Stage;
	var s:Sprite;
	
	
	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		
		var ww = Json.parse(Assets.getText("assets/werewolf.json"));
		
		s = new Sprite();  
		stage.addChild(s); 
		s.x = stage.stageWidth / 2; 
		s.y = stage.stageHeight / 2; 
		s.z = 1500;
		
		stage.addEventListener(Event.RESIZE, function(_) {
			s.x = stage.stageWidth / 2; 
			s.y = stage.stageHeight / 2; 
		});
		
		var wolf = new Sprite();  
		s.addChild(wolf);
		wolf.scaleY = -1; 
		wolf.y = 85;
		
		Tools.LoadImage("assets/img/werewolf.jpg", function(img) {			
			wolf.graphics.beginBitmapFill(new BitmapData(img));
			wolf.graphics.drawTriangles3D(ww.vertices, ww.indices, ww.uvt);
			stage.addEventListener(Event.ENTER_FRAME, onEF);
		});
	}
	
	function onEF(_) { 
		s.rotationY += 0.01 * (stage.mouseX - s.x);
		s.scaleX = s.scaleY = s.scaleZ = 1 + stage.mouseY * 0.1; 
	}
	
	
}
