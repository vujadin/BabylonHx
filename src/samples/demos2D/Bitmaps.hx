package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Bitmaps {

	public function new(scene:Scene) {		
		Tools.LoadImage("assets/img/ball.png", function(img) {
			var bd1 = new BitmapData(img);
			var stage = scene.stage2D;
			for (i in 0...50) {
				var b = new Bitmap(bd1);
				b.x = Math.random() * stage.stageWidth;
				b.y = Math.random() * stage.stageHeight;
				b.rotation = Math.random() * 360;
				b.scaleX = b.scaleY = 0.5 + Math.random();
				stage.addChild(b);
				trace(b.width);
			}
		});
	}
	
}
