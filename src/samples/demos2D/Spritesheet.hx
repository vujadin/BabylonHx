package samples.demos2D;

import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Spritesheet {

	public function new(scene:Scene) {		
		Tools.LoadImage("assets/img/bV7mgky2.png", function(img) {
			var boom = new MBitmap(new BitmapData(img), 6, 5);
			scene.stage2D.addChild(boom);  
			boom.scaleX = boom.scaleY = 2;  
			boom.play();
			
			Tools.LoadImage("assets/img/capguy-walk2.png", function(img) {
				var guy = new MBitmap(new BitmapData(img), 1, 8);
				scene.stage2D.addChild(guy);  
				guy.x = 400;  
				guy.y = 150;  
				guy.stepTime = 6;  
				guy.play();
			});
		});
	}
	
}

class MBitmap extends Sprite {
	
	public var bitmapData:BitmapData;
	public var totalFrames:Int;
	public var currentFrame:Int;
	public var isPlaying:Bool;
	public var stepTime:Float;
	
	private var _rows:Int;
	private var _cols:Int;
	private var _frames:Array<com.babylonhx.d2.display.Graphics>;
	private var _time:Int;
	
	private var _from:Int;
	private var _to:Int;
	private var _times:Int;
	private var _ltime:Int;
	
	
	public function new(bd:BitmapData, rows:Int, cols:Int) {
		super();
		
		// public
		this.bitmapData = bd;
		this.totalFrames = Std.int(rows * cols);
		this.currentFrame = 0;
		this.isPlaying = false;
		this.stepTime = 1; // use it to slow down the animation
		
		// private
		this._rows = rows;  
		this._cols = cols;
		this._frames = [];
		this._time = 0; 
		
		this._from = 0; 
		this._to = 0; 
		this._times = 0; 
		this._ltime = 0; 
		
		this._init();
	}
	
	private function _init() {
		var fx = 1 / this._cols;
		var fy = 1 / this._rows;
		var w = this.bitmapData.width * fx;
		var h = this.bitmapData.height * fy;
		
		for (y in 0...this._rows) {
			for (x in 0...this._cols) {
				var gr = new com.babylonhx.d2.display.Graphics();
				gr.beginBitmapFill(this.bitmapData);
				gr.drawTriangles(
					[0, 0, w, 0, 0, h, w, h], 
					[0, 1, 2, 1, 2, 3],
					[x * fx, y * fy, (x + 1) * fx, y * fy, x * fx, (y + 1) * fy, (x + 1) * fx, (y + 1) * fy ]
				);
				this._frames.push(gr);
			}
		}
		this.graphics = this._frames[this.currentFrame];
	}
	
	private function _setFrame(k:Int) {
		k = k % this.totalFrames;  
		this.currentFrame = k;
		if (this.bitmapData.width > 0) {
			this.graphics = this._frames[k];
		}
	}
	
	public function nextFrame() { 
		var nf = this.currentFrame + 1;
		if (nf > this._to) { 
			nf = this._from;  
			this._ltime++; 
		}
		this._setFrame(nf); 
	}
	
	public function gotoAndStop(k:Int) { 
		this._setFrame(k); 
		this.stop(); 
	}
	
	public function gotoAndPlay(k:Int) { 
		this._setFrame(k); 
		this.play(); 
	}
	
	public function loop(from:Int, to:Int, ?times:Int) { 
		if (times == null) {
			times = Std.int(Math.POSITIVE_INFINITY);
		}
		if (this.currentFrame < from || this.currentFrame > to) {
			this._setFrame(from);
		}
		this.isPlaying = true; 
		this._from = from;  
		this._to = to;  
		this._times = times;  
		this._ltime = 0;
		this.addEventListener2(Event.ENTER_FRAME, this._ef, this); 
	}
	
	public function play() {  
		this.loop(0, this.totalFrames - 1);
	}
	
	public function stop() { 
		if (this.isPlaying) {
			this.removeEventListener(Event.ENTER_FRAME, this._ef);
		}
		
		this.isPlaying = false;
	}
	
	private function _ef(_) { 
		if (this._time++ % this.stepTime != 0) {
			return;
		}
		this.nextFrame();
		if (this._ltime == this._times) {
			//this.stop();
		}
	}
	
}
