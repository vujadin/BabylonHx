package;

import lime.app.Application;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.app.Config;
import lime.math.Vector2;
import lime.graphics.RenderContext;
import openfl.display.Stage;
import openfl.display.Sprite;
import openfl.events.Event;
import com.babylonhx.Engine;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 * openFL is dependent upon this currently
 * https://github.com/openfl/openfl/pull/641 
 */

class MainOpenfl extends Application {
	
	var scene:Scene;
	var engine:Engine;
	private var targetPoint:Vector2;
	private var moveDown:Bool;
	private var moveLeft:Bool;
	private var moveRight:Bool;
	private var moveUp:Bool;
	private var square:Sprite;
	private var _stage:Stage;
	private var _stageFL:Stage;
	private var _babylonSprite:Sprite;
	private var _context:RenderContext;


	public override function create (config:Config):Void {
		
		super.create (config);
		_stage = new Stage (config.width, config.height, 0xFFFFFFFF);
		_stage.addEventListener(Event.RESIZE, resize);
		addModule(_stage);
		_babylonSprite = new Sprite();
		_stage.addChild(_babylonSprite);
		engine = new Engine(_babylonSprite, false);	
		scene = new Scene(engine);
		engine.width = this.window.width;
		engine.height = this.window.height;
		new samples.PostprocessBloom(scene);
        createSquares();

	}

	public function resize(e){
		engine.width = this.window.width;
		engine.height = this.window.height;
	}
	
	public function new() {
		super();		
	}

	public function createSquares(){
		square = new Sprite ();
		var fpsContainer = new Sprite ();

		var fill = new Sprite ();
		fill.graphics.beginFill (0xBFFF00);
		fill.graphics.drawRect (0, 0, 100, 100);
		fill.x = -50;
		fill.y = -50;
		square.addChild (fill);
		
		square.x = window.width / 2;
		square.y = window.height / 2;

		_stage.addChild (square);

	}
	
	public override function onKeyDown (key:KeyCode, modifier:KeyModifier):Void {
		
		switch (key) {
			
			case LEFT: moveLeft = true;
			case RIGHT: moveRight = true;
			case UP: moveUp = true;
			case DOWN: moveDown = true;
			default:
			
		}
		
	}
	
	
	public override function onKeyUp (key:KeyCode, modifier:KeyModifier):Void {
		
		switch (key) {
			
			case LEFT: moveLeft = false;
			case RIGHT: moveRight = false;
			case UP: moveUp = false;
			case DOWN: moveDown = false;
			default:
			
		};
		
	}
	
	
	public override function onMouseDown (x:Float, y:Float, button:Int):Void {
		
		if (targetPoint == null) {
			
			targetPoint = new Vector2 ();
			
		}
		
		targetPoint.x = x;
		targetPoint.y = y;
		
	}
	
	
	public override function onMouseMove (x:Float, y:Float):Void {
		
		if (targetPoint != null) {
			
			targetPoint.x = x;
			targetPoint.y = y;
			
		}
		
	}
	
	
	public override function onMouseUp (x:Float, y:Float, button:Int):Void {
		
		targetPoint = null;
		
	}
	
	
	public override function onTouchEnd (x:Float, y:Float, id:Int):Void {
		
		targetPoint = null;
		
	}
	
	
	public override function onTouchMove (x:Float, y:Float, button:Int):Void {
		
		if (targetPoint != null) {
			
			targetPoint.x = x;
			targetPoint.y = y;
			
		}
		
	}
	
	
	public override function onTouchStart (x:Float, y:Float, id:Int):Void {
		
		if (targetPoint == null) {
			
			targetPoint = new Vector2 ();
			
		}
		
		targetPoint.x = x;
		targetPoint.y = y;
		
	}
	


	public override function update (deltaTime:Int):Void {
		if(engine != null) 
		engine._renderLoop();


		if (moveLeft) square.x -= (0.6 * deltaTime);
		if (moveRight) square.x += (0.6 * deltaTime);
		if (moveUp) square.y -= (0.6 * deltaTime);
		if (moveDown) square.y += (0.6 * deltaTime);
		
		if (targetPoint != null) {
			
			square.x += (targetPoint.x - square.x) * (deltaTime / 300);
			square.y += (targetPoint.y - square.y) * (deltaTime / 300);
			
		}
		
		
		
	}

	
}
