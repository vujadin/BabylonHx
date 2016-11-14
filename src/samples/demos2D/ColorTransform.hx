package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.utils.Image;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ColorTransform {	
	
	var cmat:Int = 0;
	var	mats:Array<Float32Array> = [
		new Float32Array([	// identity
			1,0,0,0,0,
			0,1,0,0,0,
			0,0,1,0,0,
			0,0,0,1,0,
			0,0,0,0,1
		]), 
		new Float32Array([	// more contrast
			1.5,0,0,0,0,
			0,1.5,0,0,0,
			0,0,1.5,0,0,
			0,0,0,1,0,
			-0.16,-0.16,-0.16,0,1
		]),
		new Float32Array([	// grayscale
			.3,.3,.3, 0, 0,
			.6,.6,.6, 0, 0,
			.1,.1,.1, 0, 0,
			 0, 0, 0, 1, 0,
			 0, 0, 0, 0, 1
		]),	
		new Float32Array([	// sepia
			.393,.349,.272,0,0,
			.769,.686,.534,0,0,
			.189,.168,.131,0,0,
			0,0,0,1,0,
			0,0,0,0,1
		]),
		new Float32Array([	// swap colors
			0,0,1,0,0,
			1,0,0,0,0,
			0,1,0,0,0,
			0,0,0,1,0,
			0,0,0,0,1
		]),
		new Float32Array([	// invert colors
			-1, 0, 0, 0, 0,
			 0,-1, 0, 0, 0,
			 0, 0,-1, 0, 0,
			 0, 0, 0, 1, 0,
			 1, 1, 1, 0, 1
		])
	];
	
	var stage:Stage;
	

	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		Start();
	}
	
	function Start() {
		Tools.LoadImage("assets/img/winter.jpg", function(img) {
			stage.addChild(new Bitmap(new BitmapData(img)));
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
		});
	}
	
	function onMD(e:Event) {
		cmat = Std.int((cmat + 1) % mats.length);
		stage.transform.colorTransform = mats[cmat];
	}
	
}
