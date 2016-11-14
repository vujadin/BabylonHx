package samples.demos2D;

import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Pseudo3D {
	
	/*
		That's how 3D was made before Flash Player 11.
		It is just a demonstration of Graphics.drawTriangles(...),
		for real 3D use a another librariy.
	*/

	var stage:Stage;
	var s:Sprite;
	var bd:BitmapData;
	var vrt:Array<Float>;
	var ind:Array<Int>;
	var uvt:Array<Float>;
	var n:Int = 20;  // number of segments
	var zoom:Float = 0;
	var nn = 0;
	
	
	public function new(scene:Scene) {
		this.stage = scene.stage2D;
		nn = n + 1;
		Start();
	}
	
	function Start() {
		Tools.LoadImage("assets/img/earth.jpg", function(earthImg) {
			bd    = new BitmapData(earthImg);
			s     = new Sprite();
			s.x = stage.stageWidth / 2;  
			s.y = stage.stageHeight / 2;
			stage.addChild(s);
			
			stage.addEventListener(Event.RESIZE, function(_) {
				s.x = stage.stageWidth / 2; 
				s.y = stage.stageHeight / 2; 
			});
			
			vrt = []; ind = []; uvt = [];
			var lat:Float = 0;
			var lon:Float = 0;
			var x:Float = 0;
			var y:Float = 0;
			var z:Float = 0;
			var p:Float = 0;
			
			for (i in 0...n + 1) {        // rows
				for (j in 0...n + 1) {    // cols
					lat = -Math.PI / 2 + i * Math.PI / n;
					lon =  Math.PI   + j * Math.PI / n;
					x = Math.cos(lat) * Math.cos(lon);
					y = Math.sin(lat);
					z = Math.cos(lat) * Math.sin(lon);
					p = 9 / (8 + z);            // perspective
					vrt.push(p * x);
					vrt.push(p * y);
					uvt.push(0.5 * j / n);
					uvt.push(i / n);
					if (i < n && j < n) {       // 6 indices for 2 triangles
					   ind.push(nn * i + j);
					   ind.push(nn * i + j + 1);
					   ind.push(nn * (i + 1) + j);
					   ind.push(nn * i + j + 1);
					   ind.push(nn * (i + 1) + j);
					   ind.push(nn * (i + 1) + j + 1);
					}
				}
			}
			
			Tools.LoadImage("assets/img/shade.png", function(shadeImg) {			
				// static shading layer
				var sh = new Sprite();  
				s.addChild(sh);
				sh.graphics.beginBitmapFill(new BitmapData(shadeImg));
				sh.graphics.drawTriangles(vrt, ind, uvt);
				
				stage.addEventListener(Event.ENTER_FRAME, onEF);
			});
		});
	}
	
	var ii:Int = 0;
	function onEF(_) {
		s.scaleX = s.scaleY = zoom = (3 * zoom + 50 + stage.mouseY) * 0.25;
		var vel = 0.00005 * (stage.mouseX - s.x);
		ii = 0;
		while (ii < uvt.length) {
			uvt[ii] += vel;  // shifting X coordinate
			ii += 2;
		}
		
		s.graphics.clear();
		s.graphics.beginBitmapFill(bd);
		s.graphics.drawTriangles(vrt, ind, uvt);
	}
	
	
}
