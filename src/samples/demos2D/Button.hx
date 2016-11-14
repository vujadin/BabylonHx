package samples.demos2D;

import com.babylonhx.d2.display.Sprite;
import com.babylonhx.d2.text.TextField;
import com.babylonhx.d2.events.MouseEvent;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Button extends Sprite {
	
	public var name:String;
	public var bg:Sprite;

	
	public function new(name:String, font:String = "", size:Int = 25)	{
		super();
		
		this.buttonMode = true;
		this.mouseChildren = false;
		this.name = name;
		
		var t = new TextField(name, font);
		t.scaleX = t.scaleY = 3;
		t.x = Math.round(size / 3);  
		t.y = Math.round(size / 7);
		
		var bw = (t.width * 2) + 2 * t.x;
		var bh = (t.height * 2) + 2 * t.y;
		
		this.graphics.beginFill(0x00ddff);
		this.graphics.drawRoundRect(0, 0, bw, bh, bh / 3, bh / 3);
		
		this.bg = new Sprite();		// bg is a layer with dark blue rectangle
		this.bg.graphics.beginFill(0x0066dd);
		this.bg.graphics.drawRoundRect(0, 0, bw, bh, bh / 3, bh / 3);
		this.addChild(this.bg);	
		
		this.addChild(t);
		
		this.addEventListener(MouseEvent.MOUSE_OVER, this.onMOv);
		this.addEventListener(MouseEvent.MOUSE_OUT , this.onMOu);
	}

	//	methods
	function onMOv(e) { 
		e.target.bg.visible = false; 
	}
	
	function onMOu(e) { 
		e.target.bg.visible = true; 
	}
	
}
