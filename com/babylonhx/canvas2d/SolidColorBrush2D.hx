package com.babylonhx.canvas2d;

import com.babylonhx.math.Color4;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This classs implements a Brush that will be drawn with a uniform solid color 
 * (i.e. the same color everywhere in the content where the brush is assigned to).
 */
class SolidColorBrush2D extends LockableBase implements IBrush2D {
	
	private var _color:Color4;
	public var color(get, set):Color4;
	
	
	public function new(color:Color4, lock:Bool = false) {
		super();
		
		this._color = color;
		
		if (lock) {
			this.lock();
		}
	}

	public function isTransparent():Bool {
		return this._color != null && this._color.a < 1.0;
	}

	/**
	 * The color used by this instance to render
	 * @returns the color object. Note that it's not a clone of the actual object stored in the instance 
	 * so you MUST NOT modify it, otherwise unexpected behavior might occurs.
	 */
	private function get_color():Color4 {
		return this._color;
	}

	private function set_color(value:Color4) {
		if (this.isLocked()) {
			return;
		}
		
		this._color = value;
	}

	/**
	 * Return a unique identifier of the instance, which is simply the hexadecimal representation (CSS Style) of the solid color.
	 */
	public function toString():String {
		return this._color.toHexString();
	}
	
}
	