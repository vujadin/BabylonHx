package com.babylonhx.canvas2d.engine;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Defines the horizontal and vertical alignment information for a Primitive.
 */
class PrimitiveAlignment {
	
	/**
	 * Alignment is made relative to the left edge of the Primitive. Valid for horizontal alignment only.
	 */
	public static inline var AlignLeft:Int = 1;
	/**
	 * Alignment is made relative to the top edge of the Primitive. Valid for vertical alignment only.
	 */
	public static inline var AlignTop:Int = 1;   // Same as left
	/**
	 * Alignment is made relative to the right edge of the Primitive. Valid for horizontal alignment only.
	 */
	public static inline var AlignRight:Int = 2;
	/**
	 * Alignment is made relative to the bottom edge of the Primitive. Valid for vertical alignment only.
	 */
	public static inline var AlignBottom:Int = 2;   // Same as right
	/**
	 * Alignment is made to center the content from equal distance to the opposite edges of the Primitive
	 */
	public static inline var AlignCenter:Int = 3;
	/**
	 * The content is stretched toward the opposite edges of the Primitive
	 */
	public static inline var AlignStretch:Int = 4;

	private var _changedCallback:Void->Void;
	private var _horizontal:Int;
	private var _vertical:Int;
	
	public var horizontal(get, set):Int;
	public var vertical(get, set):Int;
	
	/**
	 * Get/set the horizontal alignment. Use one of the AlignXXX static properties of this class
	 */
	private function get_horizontal():Int {
		return this._horizontal;
	}
	private function set_horizontal(value:Int):Int {
		if (this._horizontal == value) {
			return value;
		}
		
		this._horizontal = value;
		this._changedCallback();
		
		return value;
	}

	/**
	 * Get/set the vertical alignment. Use one of the AlignXXX static properties of this class
	 */
	private function get_vertical():Int {
		return this._vertical;
	}
	private function set_vertical(value:Int) {
		if (this._vertical == value) {
			return value;
		}
		
		this._vertical = value;
		this._changedCallback();
		
		return value;
	}
	

	public function new(changeCallback:Void->Void) {
		this._changedCallback = changeCallback;
		this._horizontal = PrimitiveAlignment.AlignLeft;
		this._vertical = PrimitiveAlignment.AlignBottom;
	}

	/**
	 * Set the horizontal alignment from a string value.
	 * @param text can be either: 'left','right','center','stretch'
	 */
	public function setHorizontal(text:String) {
		var v = StringTools.trim(text).toLowerCase();
		switch (v) {
			case "left":
				this.horizontal = PrimitiveAlignment.AlignLeft;
				
			case "right":
				this.horizontal = PrimitiveAlignment.AlignRight;
				
			case "center":
				this.horizontal = PrimitiveAlignment.AlignCenter;
				
			case "stretch":
				this.horizontal = PrimitiveAlignment.AlignStretch;
				
		}
	}

	/**
	 * Set the vertical alignment from a string value.
	 * @param text can be either: 'top','bottom','center','stretch'
	 */
	public function setVertical(text:String) {
		var v = StringTools.trim(text).toLocaleLowerCase();
		switch (v) {
			case "top":
				this.vertical = PrimitiveAlignment.AlignTop;
				
			case "bottom":
				this.vertical = PrimitiveAlignment.AlignBottom;
				
			case "center":
				this.vertical = PrimitiveAlignment.AlignCenter;
				
			case "stretch":
				this.vertical = PrimitiveAlignment.AlignStretch;
				
		}
	}

	/**
	 * Set the horizontal and or vertical alignments from a string value.
	 * @param text can be: [<h:|horizontal:><left|right|center|stretch>], [<v:|vertical:><top|bottom|center|stretch>]
	 */
	public function fromString(value:String) {
		var m = StringTools.trim(value).split(",");
		for (v in m) {
			v = StringTools.trim(v.toLowerCase());
			
			// Horizontal
			var i = v.indexOf("h:");
			if (i == -1) {
				i = v.indexOf("horizontal:");
			}
			
			if (i != -1) {
				v = v.substr(v.indexOf(":") + 1);
				this.setHorizontal(v);
				continue;
			}
			
			// Vertical
			i = v.indexOf("v:");
			if (i == -1) {
				i = v.indexOf("vertical:");
			}
			
			if (i != -1) {
				v = v.substr(v.indexOf(":") + 1);
				this.setVertical(v);
				continue;
			}
		}
	}
	
}
