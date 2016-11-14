package samples.demos2D;

import com.babylonhx.d2.display.Bitmap;
import com.babylonhx.d2.display.BitmapData;
import com.babylonhx.d2.display.BlendMode;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.tools.Tools;
import com.babylonhx.Scene;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2BodyDef;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2FixtureDef;
import box2D.dynamics.B2World;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2CircleShape;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Physics {
	
	var world:B2World;
	var bodies:Array<B2Body> = [];	// instances of b2Body (from Box2D)
	var actors:Array<Sprite> = [];	// instances of Bitmap (from IvanK)
	var up:B2Vec2;
	

	public function new(scene:Scene) {
		var stage = scene.stage2D;
		stage.addEventListener(Event.ENTER_FRAME, onEF);
		
		Tools.LoadImage("assets/img/bigball.png", function(ballImg) {
			Tools.LoadImage("assets/img/box.jpg", function(boxImg) {		
				world = new B2World(new B2Vec2(0, 10),  true);
				up = new B2Vec2(0, -5);
				
				var bxFixDef	= new B2FixtureDef();	
				bxFixDef.shape	= new B2PolygonShape();
				var blFixDef	= new B2FixtureDef();	
				blFixDef.shape	= new B2CircleShape();
				bxFixDef.density	= blFixDef.density = 1;
				
				var bodyDef = new B2BodyDef();
				bodyDef.type = B2Body.b2_staticBody;
				
				// create ground
				untyped bxFixDef.shape.setAsBox(10, 1);
				bodyDef.position.set(9, stage.stageHeight / 100 + 1);
				world.createBody(bodyDef).createFixture(bxFixDef);
				
				untyped bxFixDef.shape.setAsBox(1, 100);
				// left wall
				bodyDef.position.set(-1, 3);
				world.createBody(bodyDef).createFixture(bxFixDef);
				// right wall
				bodyDef.position.set(stage.stageWidth / 100 + 1, 3);
				world.createBody(bodyDef).createFixture(bxFixDef);
				
				// both images are 200 x 200 px
				var bxBD = new BitmapData(boxImg);
				var blBD = new BitmapData(ballImg);
				
				// let's add 25 boxes and 25 balls!
				bodyDef.type = B2Body.b2_dynamicBody;
				for (i in 0...50) {
					var hw = 0.1 + Math.random() * 0.45;	// "half width"
					var hh = 0.1 + Math.random() * 0.45;	// "half height"
					
					untyped bxFixDef.shape.setAsBox(hw, hh);
					untyped blFixDef.shape.setRadius(hw);
					bodyDef.position.set(Math.random() * 7, -5 + Math.random() * 5);
					
					var body = world.createBody(bodyDef);
					if (i < 25) {
						body.createFixture(bxFixDef);	// box
					}
					else {
						body.createFixture(blFixDef);	// ball
					}
					bodies.push(body);
					
					var bm = new Bitmap(i < 25 ? bxBD : blBD);  
					bm.x = bm.y = -100;
					var actor = new Sprite();  
					actor.addChild(bm);
					if (i < 25) { 
						actor.scaleX = hw;  
						actor.scaleY = hh; 
					}
					else { 
						actor.scaleX = actor.scaleY = hw;      
					}
					
					actor.addEventListener(MouseEvent.MOUSE_MOVE, Jump);	
					stage.addChild(actor);
					actors.push(actor);
				}
			});
		});
	}
	
	function onEF(e) {
		world.step(1 / 60,  3,  3);
		world.clearForces();
		
		for (i in 0...actors.length) {
			var body  = bodies[i];
			var actor = actors [i];
			var p = body.getPosition();
			actor.x = p.x * 100;	// updating actor
			actor.y = p.y * 100;
			actor.rotation = body.getAngle() * 180 / Math.PI;
		}
	}
	
	function Jump(e) {
		var a = e.currentTarget;	// current actor
		var i = actors.indexOf(a);
		//  cursor might be over ball bitmap, but not over a real ball
		if (i >= 25 && Math.sqrt(a.mouseX * a.mouseX + a.mouseY * a.mouseY) > 100) {
			return;
		}
		
		bodies[i].applyImpulse(up, bodies[i].getWorldCenter());
	}

	
}
