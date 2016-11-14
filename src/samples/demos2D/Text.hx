package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.text.TextField;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Text {

	public function new(scene:Scene) {
		var tf = new TextField("All characters in BabylonHx built-in font:\n\n!\"#$%&'()*+,-./0123456789:;<=>?@\nABCDEFGHIJKLMNOPQRSTUVWXYZ\n[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", "", 800, 120);
		tf.x = 10;
		tf.y = 200;
		scene.stage2D.addChild(tf);
	}
	
}
