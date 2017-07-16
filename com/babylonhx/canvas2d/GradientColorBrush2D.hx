package com.babylonhx.canvas2d;

import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */

class GradientColorBrush2D extends LockableBase implements IBrush2D {
	
	private var _color1:Color4;
	private var _color2:Color4;
	private var _translation:Vector2;
	private var _rotation:Float;
	private var _scale:Float;
	
	public var color1(get, set):Color4;
	public var color2(get, set):Color4;
	public var translation(get, set):Vector2;
	public var rotation(get, set):Float;
	public var scale(get, set):Float;
	
	
	public function new(color1:Color4, color2:Color4, translation:Vector2 = Vector2.Zero(), rotation:Float = 0, scale:Float = 1, lock:Bool = false) {
		super();
		
		this._color1 = color1;
		this._color2 = color2;
		this._translation = translation;
		this._rotation = rotation;
		this._scale = scale;
		
		if (lock) {
			this.lock();
		}
	}

	public function isTransparent():Bool {
		return (this._color1 != null && this._color1.a < 1.0) || (this._color2 != null && this._color2.a < 1.0);
	}

	private function get_color1():Color4 {
		return this._color1;
	}

	private function set_color1(value:Color4):Color4 {
		if (this.isLocked()) {
			return null;
		}
		
		this._color1 = value;
		
		return value;
	}

	private function get_color2():Color4 {
		return this._color2;
	}

	private function set_color2(value:Color4):Color4 {
		if (this.isLocked()) {
			return null;
		}
		
		this._color2 = value;
		
		return value;
	}

	private function get_translation():Vector2 {
		return this._translation;
	}

	private function set_translation(value:Vector2):Vector2 {
		if (this.isLocked()) {
			return null;
		}
		
		this._translation = value;
		
		return value;
	}

	private function get_rotation():Float {
		return this._rotation;
	}

	private function set_rotation(value:Float):Float {
		if (this.isLocked()) {
			return 0;
		}
		
		this._rotation = value;
		
		return value;
	}

	private function get_scale():Float {
		return this._scale;
	}

	private function set_scale(value:Float):Float {
		if (this.isLocked()) {
			return 0;
		}
		
		this._scale = value;
		
		return value;
	}

	public function toString():String {
		return "C1:$this._color1;C2:$this._color2;T:$this._translation.toString();R:$this._rotation;S:$this._scale;";
	}

	public static function BuildKey(color1:Color4, color2:Color4, translation:Vector2, rotation:Float, scale:Float):String {
		return "C1:$color1;C2:$color2;T:$translation.toString();R:$rotation;S:$scale;";
	}

}
	