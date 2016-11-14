package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class WaterSurface {
	
	var stage:Stage;
	var s:Sprite;
	static var n = 40;
	var clicked = false;
	var calm = 0.0;
	var rad = Math.round(n / 12);
	
	var h:Array<Float> = [];  // buffers for heights
	var v:Array<Float> = [];  // buffers for velocities
	var vrt:Array<Float> = [];  // vertices
	var ind:Array<Int> = [];  // indices
	

	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		Start();
	}
	
	function Start() {
		Tools.LoadImage("assets/img/winter2.png", function(img) {
			var bg = new Bitmap(new BitmapData(img));
			bg.scaleX = bg.scaleY = stage.stageHeight / 512;
			stage.addChild(bg);
			
			calm = stage.stageHeight * 0.6;
			
			s = new Sprite();
			stage.addChild(s);
			stage.addEventListener(Event.ENTER_FRAME, onEF);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
			stage.addEventListener(MouseEvent.MOUSE_UP  , onMU);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMM);
			initWaves(stage.stageWidth, stage.stageHeight);
		});
	}
	
	function initWaves(wi:Int, hi:Int) {
		var step = wi / (n - 1);
		for (i in 0...n) {
			h.push(calm); 
			v.push(0);
		}
		for (i in 0...n) {
			vrt.push(i * step);
			vrt.push(calm);
			vrt.push(i * step);
			vrt.push(hi);
		}
		for (i in 0...n - 1) {
			ind.push(cast 2 * i);
			ind.push(cast 2 * i + 1);
			ind.push(cast 2 * i + 2);
			ind.push(cast 2 * i + 1);
			ind.push(cast 2 * i + 2);
			ind.push(cast 2 * i + 3);
		}
	}
	
	function onEF(e:Event) {
		for (i in 0...n) {
			// computing velocity from neighbouring heights
			v[i] += ((he(i - 1) + he(i + 1)) + calm) / 3 - h[i];
			v[i] *= 0.98;	// damping
			h[i] += v[i] * 0.05;
			vrt[i * 4 + 1] = h[i];
		}
		s.graphics.clear();
		s.graphics.beginFill(0x4466aa, 0.5);
		s.graphics.drawTriangles(vrt, ind);
	}
	
	function he(i:Int) { 
		return h[(i + n) % n];
	}	// "cycled" access to array 'h'
	
	function onMD(_) { 
		clicked = true; 
		onMM(_); 
	}
	function onMU(_) { 
		clicked = false; 
	}
	function onMM(_) {
		var i = Math.round(n * stage.mouseX / stage.stageWidth);
		if (clicked) {
			if (i > rad && i < n - rad) {
				pushAt(i);
			}
		}
	}
	
	function pushAt(i:Int) {
		for (j in -rad...rad) {
			h[i + j] += Math.cos(j * Math.PI * 0.5 / rad) * 15;
		}
	}
	
}
