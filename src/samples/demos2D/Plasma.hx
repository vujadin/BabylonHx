package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.utils.typedarray.UInt8Array;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Plasma {
	
	var stage:Stage;
	var bd:BitmapData;
	var time = 0;
	var a = 1;
	var b = 2;
	var c = 1;
	var d = 1;
	var e = 1;
	var w = 400;
	var h = 256;
	
	// precomputed sine table, -127 .. 127
	var sin:UInt8Array = new UInt8Array(512);

	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		
		Start();
	}
	
	function Start() {
		bd = BitmapData.empty(w, h, 0xff000000);
		
		for (i in 0...512) {
			sin[i] = Std.int(Math.sin(2 * Math.PI / 512 * i) * 127 + 127);
		}
		
		var bm = new Bitmap(bd);
		bm.scaleX = stage.stageWidth / w;
		bm.scaleY = stage.stageHeight / h;
		stage.addChild(bm);
		
		stage.addEventListener(Event.ENTER_FRAME, onEF);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
	}
	
	function onEF(_) { 
		drawPlasma(); 
		time++; 
	}
	
	function drawPlasma() {
		var hh = h * 0.5 +10 * d - 400;
		var hw = w * 0.5 +10 * e-400;
		var fr = time << 2;
		var i3 = 1 / 3;
		var am = a - 1, bm = b - 1, es = e << 2;
		for (y in 0...h) {	// rows
			for (x in 0...w) {	// columns
				var di = Math.floor( Math.sqrt((hh - y) * (hh - y) + (hw - x) * (hw - x)) );
				var hi = Std.int((sin[(x * b + fr) & 511] + sin[(di * a + fr * b) & 511] + sin[359 - (y * a + x * b + fr) & 511]) * i3);
				
				var re = sin[((hi << am) + d)  & 511];
				var gr = sin[((hi << bm) + es) & 511];
				var bl = sin[ (hi << bm)     & 511];
				bd.setPixel(x, y, (re << 16 | gr << 8 | bl));
			}
		}
	}
	
	function onMD(_) { 
		a = rand(4); 
		b = rand(4); 
		c = rand(8); 
		d = rand(180); 
		e = rand(180); 
	}
	
	inline function rand(n:Int)  { 
		return 1 + Math.floor(Math.random() * n);
	}
	
}
