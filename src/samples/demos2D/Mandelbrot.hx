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
class Mandelbrot {

	var stage:Stage;
	var bd:BitmapData;
	var bm:Bitmap;
	var time:Float = 0;
	var down = false;
	var zoom:Float = 1;
	var zoomX:Float = 0;
	var zoomY:Float = 0;
	var w = 400;
	var h = 256;
	
	var sin = new UInt8Array(128);
	
	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		for (i in 0...128) {
			sin[i] = Math.round((Math.sin(2 * Math.PI / 128 * i) * 127 + 127));
		}
		Start();
	}
	
	function Start() {
		bd = BitmapData.empty(w, h, 0xff000000);
		
		bm = new Bitmap(bd);
		bm.scaleX = stage.stageWidth / w;
		bm.scaleY = stage.stageHeight / h;
		stage.addChild(bm);
		
		stage.addEventListener(Event.ENTER_FRAME, function(e) {
			drawMandelbrot(); 
			time++;
		});
		stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e) {
			down = true;
		});
		stage.addEventListener(MouseEvent.MOUSE_UP, function(e) {
			down = false;
		});
	}
	
	function drawMandelbrot() {
		var msx = bm.mouseX / w;
		var msy = bm.mouseY / h;
		var mx = zoomX + msx / zoom;
		var my = zoomY + msy / zoom;
		
		zoom = down ? zoom * 1.05 : Math.max(1, zoom / 1.05);
		var xc = 1 / (w * zoom), yc = 1 / (h * zoom);
		
		zoomX = Math.max(0, Math.min(1 - 1 / zoom, mx - msx / zoom));
		zoomY = Math.max(0, Math.min(1 - 1 / zoom, my - msy / zoom));
		
		for (y in 0...h) {	// rows
			for (x in 0...w) {  // columns
				var cx = -2 + 3 * (zoomX + x * xc);
				var cy = -1 + 2 * (zoomY + y * yc);
				var zx = cx, zy = cy, i = 1;
				
				while (zx * zx + zy * zy < 4 && ++i < 65) {
					var nzx = cx + (zx * zx - zy * zy);
					zy = cy + 2 * zx * zy;  
					zx = nzx;
				}
				var re = sin[((i << 0)+95) & 127];
				var gr = sin[((i << 1)+0)  & 127];
				var bl = sin[((i << 1) + 40) & 127];
				
				bd.setPixel(x, y, (re << 16 | gr << 8 | bl));
			}
		}
	}

	
}
