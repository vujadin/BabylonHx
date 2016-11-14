//===========================================================
//=========================================================//
//						-=ANTHEM=-
//	file: .as
//
//	copyright: Matthew Bush 2007
//
//	notes:
//
//=========================================================//
//===========================================================
package samples.demos2D.box2Dtests;

//===========================================================
// Input class
//===========================================================
import com.babylonhx.d2.display.*;
import com.babylonhx.d2.events.*;


class Input {

	//======================
	// member data
	//======================
	// key text array
	static public var ascii:Array<String> = new Array();
	static private var keyState:Array<Float> = new Array() ;
	private var keyArr:Array<UInt> = new Array();
	var arr2d = new Array<Array<UInt>>();
	
	private var keyBuffer:Array<Array<Int>> = new Array();
	static private var bufferSize:Int;
	
	// last key pressed
	static public var lastKey:Int = 0;
	static public var timeSinceLastKey:UInt = 0;
	
	// mouse states
	public static var mouseDown:Bool = false;
	static public var mouseReleased:Bool = false;
	static public var mousePressed:Bool = false;
	static public var mouseOver:Bool = false;
	static public var mouseX:Float = 0;
	public static var mouseY:Float = 0;
	static public var mouseOffsetX:Float = 0;
	static public var mouseOffsetY:Float = 0;
	static public var mouseDragX:Float = 0;
	static public var mouseDragY:Float = 0;
	static public var mouse:Sprite = new Sprite();
	
	// stage
	static public var m_stageMc;		
	//======================
	// constructor
	//======================
	public function new(stageMc:Sprite) {		
		m_stageMc = stageMc;
		
		// add key listeners
		stageMc.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		stageMc.stage.addEventListener(KeyboardEvent.KEY_UP, keyRelease);		
		
		// mouse listeners
		stageMc.stage.addEventListener(MouseEvent.MOUSE_DOWN, mousePress);
		stageMc.stage.addEventListener(MouseEvent.CLICK, this.mouseRelease);
		stageMc.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMove);
		
		mouse.graphics.lineStyle(0.1, 0, 100);
		mouse.graphics.moveTo(0,0);
		mouse.graphics.lineTo(0,0.1);
		
	}
	
	public function update() {			
		// update used keys
		for (i in 0...keyArr.length){
			if (keyState[keyArr[i]] != 0){
				keyState[keyArr[i]]++;
			}
		}
		
		// update buffer
		for (j in 0...bufferSize){
			keyBuffer[j][1]++;
		}
		
		// end mouse release
		mouseReleased = false;
		mousePressed = false;
		mouseOver = false;
		
	}		
	
	public function mousePress(e:MouseEvent) {
		mousePressed = true;
		mouseDown = true;
		mouseDragX = 0;
		mouseDragY = 0;
	}		
	
	public function mouseRelease(e:MouseEvent) {
		mouseDown = false;
		mouseReleased = true;
		//trace("I am realeased");
	}		
	
	public function mouseLeave(e:Event) {
		mouseReleased = mouseDown;
		mouseDown = false;
	}		
	
	public function mouseMove(e:MouseEvent) {		
		mouseX = e.movementX;
		mouseY = e.movementY;
		
		// Store offset
		mouseOffsetX = mouseX - mouse.x;
		mouseOffsetY = mouseY - mouse.y;
		// Update drag
		if (mouseDown) {
			mouseDragX += mouseOffsetX;
			mouseDragY += mouseOffsetY;
		}
		mouse.x = mouseX;
		mouse.y = mouseY;
	}		
	
	//======================
	// getKeyHold
	//======================
	public function getKeyHold(k:Int):Int {
		return Std.int(Math.max(0, keyState[k]));
	}		
	
	//======================
	// isKeyDown
	//======================
	static public function isKeyDown(k:Int):Bool {
		return (keyState[k] > 0);
	}		
	
	//======================
	//  isKeyPressed
	//======================
	static public function isKeyPressed(k:Int):Bool {
		timeSinceLastKey = 0;
		return (keyState[k] == 1);
	}
	
	//======================
	//  isKeyReleased
	//======================
	static public function isKeyReleased(k:Int):Bool{
		return (keyState[k] == -1);
	}
	
	//======================
	// isKeyInBuffer
	//======================
	public function isKeyInBuffer(k:Int, i:Int, t:Int):Bool{
		return (keyBuffer[i][0] == k && keyBuffer[i][1] <= t);
	}		
	
	//======================
	// keyPress function
	//======================
	public function keyPress(e:KeyboardEvent) {		
		// set keyState
		keyState[e.keyCode] = Math.max(keyState[e.keyCode], 1);		
		// last key (for key config)
		lastKey = e.keyCode;			
	}
	
	public function keyRelease(e:KeyboardEvent) {
		keyState[e.keyCode] = -1;
		var i:Int = bufferSize-1;
		while (i > 0) {
			keyBuffer[i] = keyBuffer[i - 1];
			i--;
		}
		keyBuffer[0] = [e.keyCode, 0];
	}
	
}
