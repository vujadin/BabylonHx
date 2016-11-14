package samples.demos2D.box2Dtests;

import box2D.dynamics.B2DebugDraw;

import com.babylonhx.d2.display.Stage;
import com.babylonhx.d2.events.Event;
import com.babylonhx.d2.events.MouseEvent;
import com.babylonhx.d2.events.KeyboardEvent;
import com.babylonhx.d2.display.Sprite;
import com.babylonhx.utils.Keycodes;
import com.babylonhx.Scene;

/**
 * ...
 * @author Najm
 */

class Box2DMain extends Sprite {
	
	var inited:Bool;
	var pressed_count:UInt = 0;
	var test:Dynamic;
	var test_list:Array<Dynamic> = new Array();
	var test_name:Array<String> = new Array();
	var cur_test_ind:Int = 0;
	
	
	public function new(scene:Scene) {
		super();	
		
		this.stage = scene.stage2D;		
		stage.addChild(this);		
		stage.addEventListener(Event.RESIZE, resize);
		
		init();
	}
	
	function resize(e) {
		if (!inited) {
			init();
		}
	}
	
	function init() {
		if (inited) {
			return;
		}
		
		inited = true;
		
 		Global.game_width = stage.stageWidth;
 		Global.game_height = stage.stageHeight;
		
		Global.world_sprite = this;
		
		// take care of mouse & keyboard event
		var input:Input = new Input(this);
		
 		test_list.push(new TestBridge());
		test_name.push("Bridge Test");
		
 		test_list.push(new TestCCD());
		test_name.push("Contious Collision Detection Test");
		
 		test_list.push(new TestCrankGearsPulley());
		test_name.push("Crank Gears Pulley Test");
		
 		test_list.push(new TestRagdoll());
		test_name.push("Rag Doll Test");
		
 		test_list.push(new TestStack());
		test_name.push("Stack Test");
		
 		test_list.push(new TestTheoJansen());
		test_name.push("Theo Jansen Test");
		
		test_list.push(new TestRaycast());
		test_name.push("Ray Cast Test");
		
		test_list.push(new TestOneSidedPlatform());
		test_name.push("One Sided Platform Test");
		
		test_list.push(new TestBreakable());
		test_name.push("Breakable Test");
		
		test_list.push(new TestCompound());
		test_name.push("Compound Test");
		
 		test_list.push(new TestBuoyancy()); //hangs on load
		test_name.push("Buoyancy Test");
		
		// show 1st example
		test = test_list[test_list.length - 1];
		
		addEventListener(Event.ENTER_FRAME,onEnterFrame);
	}
	
	function onEnterFrame(e:Event) {
		test.Update();
		
		if (Input.lastKey == Keycodes.space) {
			Input.lastKey = 0;
			cur_test_ind++;
			if (cur_test_ind == test_list.length) {
				cur_test_ind = 0;
			}
			
			test = test_list[cur_test_ind];
		}
	}
	
}
