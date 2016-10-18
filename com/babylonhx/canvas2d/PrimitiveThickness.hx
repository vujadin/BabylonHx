package com.babylonhx.canvas2d;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector4;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Define a thickness toward every edges of a Primitive to allow margin and padding.
 * The thickness can be expressed as pixels, percentages, inherit the value of the parent primitive or be auto.
 */
class PrimitiveThickness {
	
	/**
	 * Get/set the top thickness. Possible values are: 'auto', 'inherit', 'XX%' for percentage, 'XXpx' or 'XX' for pixels.
	 */
	public var top(get , set):String;
	private function get_top():String {
		return this._getStringValue(0);
	}
	private function set_top(value:String):String {
		this._setStringValue(value, 0, true);
		return value;
	}

	/**
	 * Get/set the left thickness. Possible values are: 'auto', 'inherit', 'XX%' for percentage, 'XXpx' or 'XX' for pixels.
	 */
	public var left(get, set):String;
	private function get_left():String {
		return this._getStringValue(1);
	}
	private function set_left(value:String):String {
		this._setStringValue(value, 1, true);
		return value;
	}

	/**
	 * Get/set the right thickness. Possible values are: 'auto', 'inherit', 'XX%' for percentage, 'XXpx' or 'XX' for pixels.
	 */
	public var right(get, set):String;
	private function get_right():String {
		return this._getStringValue(2);
	}
	private function set_right(value:String):String {
		this._setStringValue(value, 2, true);
		return value;
	}

	/**
	 * Get/set the bottom thickness. Possible values are: 'auto', 'inherit', 'XX%' for percentage, 'XXpx' or 'XX' for pixels.
	 */
	public var bottom(get, set):String;
	private function get_bottom():String {
		return this._getStringValue(3);
	}
	private function set_bottom(value:String):String {
		this._setStringValue(value, 3, true);
		return value;
	}

	/**
	 * Get/set the top thickness in pixel.
	 */
	public var topPixels(get, set):Int;
	private function get_topPixels():Int {
		return this._pixels[0];
	}
	private function set_topPixels(value:Int):Int {
		this._setPixels(value, 0, true);
		return value;
	}

	/**
	 * Get/set the left thickness in pixel.
	 */
	public var leftPixels(get, set):Int;
	private function get_leftPixels():Int {
		return this._pixels[1];
	}
	private function set_leftPixels(value:Int):Int {
		this._setPixels(value, 1, true);
		return value;
	}

	/**
	 * Get/set the right thickness in pixel.
	 */
	public var rightPixels(get, set):Int;
	private function get_rightPixels():Int {
		return this._pixels[2];
	}
	private function set_rightPixels(value:Int):Int {
		this._setPixels(value, 2, true);
		return value;
	}

	/**
	 * Get/set the bottom thickness in pixel.
	 */
	public var bottomPixels(get, set):Int;
	private function get_bottomPixels():Int {
		return this._pixels[3];
	}
	private function set_bottomPixels(value:Int):Int {
		this._setPixels(value, 3, true);
		return value;
	}

	/**
	 * Get/set the top thickness in percentage.
	 * The get will return a valid value only if the edge type is percentage.
	 * The Set will change the edge mode if needed
	 */
	public var tpoPercentage(get, set):Float;
	private function get_topPercentage():Float {
		return this._percentages[0];
	}
	private function set_topPercentage(value:Float):Float {
		this._setPercentage(value, 0, true);
		return value;
	}
	
	/**
	 * Get/set the left thickness in percentage.
	 * The get will return a valid value only if the edge mode is percentage.
	 * The Set will change the edge mode if needed
	 */
	public var leftPercentage(get, set):Float;
	private function get_leftPercentage():Float {
		return this._percentages[1];
	}
	private function set_leftPercentage(value:Float):Float {
		this._setPercentage(value, 1, true);
		return value;
	}
	
	/**
	 * Get/set the right thickness in percentage.
	 * The get will return a valid value only if the edge mode is percentage.
	 * The Set will change the edge mode if needed
	 */
	public var rightPercentage(get, set):Float;
	private function get_rightPercentage():Float {
		return this._percentages[2];
	}
	private function set_rightPercentage(value:Float):Float {
		this._setPercentage(value, 2, true);
		return value;
	}
	
	/**
	 * Get/set the bottom thickness in percentage.
	 * The get will return a valid value only if the edge mode is percentage.
	 * The Set will change the edge mode if needed
	 */
	public var bottomPercentage(get, set):Float;
	private function get_bottomPercentage():Float {
		return this._percentages[3];
	}
	private function set_bottomPercentage(value:Float):Float {
		this._setPercentage(value, 3, true);
		return value;
	}

	/**
	 * Get/set the top mode. The setter shouldn't be used, other setters with value should be preferred
	 */
	public var topMode(get, set):Int;
	private function get_topMode():Int {
		return this._getType(0, false);
	}
	private function set_topMode(mode:Int):Int {
		this._setType(0, mode);
		return mode;
	}

	/**
	 * Get/set the left mode. The setter shouldn't be used, other setters with value should be preferred
	 */
	public var leftMode(get, set):Int;
	private function get_leftMode():Int {
		return this._getType(1, false);
	}
	private function set_leftMode(mode:Int):Int {
		this._setType(1, mode);
		return mode;
	}

	/**
	 * Get/set the right mode. The setter shouldn't be used, other setters with value should be preferred
	 */
	public var rightMode(get, set):Int;
	private function get_rightMode():Int {
		return this._getType(2, false);
	}
	private function set_rightMode(mode:Int):Int {
		this._setType(2, mode);
		return mode;
	}

	/**
	 * Get/set the bottom mode. The setter shouldn't be used, other setters with value should be preferred
	 */
	public var bottomMode(get, set):Int;
	private function get_bottomMode():Int {
		return this._getType(3, false);
	}
	private function set_bottomMode(mode:Int) {
		this._setType(3, mode);
	}

	private var _parentAccess:Void->PrimitiveThickness;
	private var _changedCallback:Void->Void;
	private var _pixels:Array<Int>;
	private var _percentages:Array<Int>;     // Percentages are in fact stored in a normalized range [0;1] with a 0.01 precision
	private var _flags:Int;

	public static inline var Auto:Int = 0x1;
	public static inline var Inherit:Int = 0x2;
	public static inline var Percentage:Int = 0x4;
	public static inline var Pixel:Int = 0x8;
	

	public function new(parentAccess:Void->PrimitiveThickness, changedCallback:Void->Void) {
		this._parentAccess = parentAccess;
		this._changedCallback = changedCallback;
		this._pixels = [];
		this._percentages = [];
		this._setType(0, PrimitiveThickness.Auto);
		this._setType(1, PrimitiveThickness.Auto);
		this._setType(2, PrimitiveThickness.Auto);
		this._setType(3, PrimitiveThickness.Auto);
		this._pixels[0] = 0;
		this._pixels[1] = 0;
		this._pixels[2] = 0;
		this._pixels[3] = 0;
	}

	/**
	 * Set the thickness from a string value
	 * @param thickness format is "top: <value>, left:<value>, right:<value>, bottom:<value>" or "<value>" (same for all edges) 
	 * each are optional, auto will be set if it's omitted.
	 * Values are: 'auto', 'inherit', 'XX%' for percentage, 'XXpx' or 'XX' for pixels.
	 */
	public function fromString(thickness:String) {
		this._clear();
		
		var m = StringTools.trim(thickness).split(",");
		
		// Special case, one value to apply to all edges
		if (m.length == 1 && thickness.indexOf(":") == -1) {
			this._setStringValue(m[0], 0, false);
			this._setStringValue(m[0], 1, false);
			this._setStringValue(m[0], 2, false);
			this._setStringValue(m[0], 3, false);
			
			this._changedCallback();
			return;
		}
		
		var res = false;
		for (cm in m) {
			res = this._extractString(cm, false) || res;
		}
		
		if (!res) {
			throw "Can't parse the string to create a PrimitiveMargin object, format must be: 'top:<value>, left:<value>, right:<value>, bottom:<value>";
		}
		
		// Check the margin that weren't set and set them in auto
		if ((this._flags & 0x000F) == 0) {
			this._flags |= PrimitiveThickness.Pixel << 0;
		}
		if ((this._flags & 0x00F0) == 0) {
			this._flags |= PrimitiveThickness.Pixel << 4;
		}
		if ((this._flags & 0x0F00) == 0) {
			this._flags |= PrimitiveThickness.Pixel << 8;
		}
		if ((this._flags & 0xF000) == 0) {
			this._flags |= PrimitiveThickness.Pixel << 12;
		}
		
		this._changedCallback();
	}

	/**
	 * Set the thickness from multiple string
	 * Possible values are: 'auto', 'inherit', 'XX%' for percentage, 'XXpx' or 'XX' for pixels.
	 * @param top the top thickness to set
	 * @param left the left thickness to set
	 * @param right the right thickness to set
	 * @param bottom the bottom thickness to set
	 */
	public function fromStrings(top:String, left:String, right:String, bottom:String):PrimitiveThickness {
		this._clear();
		
		this._setStringValue(top, 0, false);
		this._setStringValue(left, 1, false);
		this._setStringValue(right, 2, false);
		this._setStringValue(bottom, 3, false);
		this._changedCallback();
		
		return this;
	}

	/**
	 * Set the thickness from pixel values
	 * @param top the top thickness in pixels to set
	 * @param left the left thickness in pixels to set
	 * @param right the right thickness in pixels to set
	 * @param bottom the bottom thickness in pixels to set
	 */
	public function fromPixels(top:Int, left:Int, right:Int, bottom:Int):PrimitiveThickness {
		this._clear();
		
		this._pixels[0] = top;
		this._pixels[1] = left;
		this._pixels[2] = right;
		this._pixels[3] = bottom;
		this._changedCallback();
		
		return this;
	}

	/**
	 * Apply the same pixel value to all edges
	 * @param margin the value to set, in pixels.
	 */
	public function fromUniformPixels(margin:Int):PrimitiveThickness {
		this._clear();
		
		this._pixels[0] = margin;
		this._pixels[1] = margin;
		this._pixels[2] = margin;
		this._pixels[3] = margin;
		this._changedCallback();
		
		return this;
	}

	/**
	 * Set all edges in auto
	 */
	inline public function auto():PrimitiveThickness {
		this._clear();
		
		this._flags = (PrimitiveThickness.Auto << 0) | (PrimitiveThickness.Auto << 4) | (PrimitiveThickness.Auto << 8) | (PrimitiveThickness.Auto << 12);
		this._pixels[0] = 0;
		this._pixels[1] = 0;
		this._pixels[2] = 0;
		this._pixels[3] = 0;
		this._changedCallback();
		
		return this;
	}

	inline private function _clear() {
		this._flags = 0;
		this._pixels[0] = 0;
		this._pixels[1] = 0;
		this._pixels[2] = 0;
		this._pixels[3] = 0;
		this._percentages[0] = null;
		this._percentages[1] = null;
		this._percentages[2] = null;
		this._percentages[3] = null;
	}

	private function _extractString(value:String, emitChanged:Bool):Bool {
		var v = StringTools.trim(value).toLowerCase();
		
		if (v.indexOf("top:") == 0) {
			v = StringTools.trim(v.substr(4));
			return this._setStringValue(v, 0, emitChanged);
		}
		
		if (v.indexOf("left:") == 0) {
			v = StringTools.trim(v.substr(5));
			return this._setStringValue(v, 1, emitChanged);
		}
		
		if (v.indexOf("right:") == 0) {
			v = StringTools.trim(v.substr(6));
			return this._setStringValue(v, 2, emitChanged);
		}
		
		if (v.indexOf("bottom:") == 0) {
			v = StringTools.trim(v.substr(7));
			return this._setStringValue(v, 3, emitChanged);
		}
		
		return false;
	}

	private function _setStringValue(value:String, index:Int, emitChanged:Bool):Bool {
		// Check for auto
		var v = StringTools.trim(value).toLowerCase();
		if (v == "auto") {
			if (this._isType(index, PrimitiveThickness.Auto)) {
				return true;
			}
			this._setType(index, PrimitiveThickness.Auto);
			this._pixels[index] = 0;
			if (emitChanged) {
				this._changedCallback();
			}
		}
		else if (v == "inherit") {
			if (this._isType(index, PrimitiveThickness.Inherit)) {
				return true;
			}
			this._setType(index, PrimitiveThickness.Inherit);
			this._pixels[index] = null;
			if (emitChanged) {
				this._changedCallback();
			}
		} 
		else {
			var pI = v.indexOf("%");
			
			// Check for percentage
			if (pI != -1) {
				var n = v.substr(0, pI);
				var number = Math.round(Number(n)) / 100; // Normalize the percentage to [0;1] with a 0.01 precision
				if (this._isType(index, PrimitiveThickness.Percentage) && (this._percentages[index] == number)) {
					return true;
				}
				
				this._setType(index, PrimitiveThickness.Percentage);
				
				if (Math.isNaN(number)) {
					return false;
				}
				this._percentages[index] = number;
				
				if (emitChanged) {
					this._changedCallback();
				}
				
				return true;
			}
			
			// Check for pixel
			var n:String = "";
			pI = v.indexOf("px");
			if (pI != -1) {
				n = v.substr(0, pI).trim();
			} 
			else {
				n = v;
			}
			var number = Std.parseInt(n);
			if (this._isType(index, PrimitiveThickness.Pixel) && (this._pixels[index] == number)) {
				return true;
			}
			if (Math.isNaN(number)) {
				return false;
			}
			this._pixels[index] = number;
			this._setType(index, PrimitiveThickness.Pixel);
			if (emitChanged) {
				this._changedCallback();
			}
			
			return true;
		}
	}

	private function _setPixels(value:Int, index:Int, emitChanged:Bool) {
		// Round the value because, well, it's the thing to do! Otherwise we'll have sub-pixel stuff, and the no change comparison just below will almost never work for PrimitiveThickness values inside a hierarchy of Primitives
		value = Math.round(value);
		
		if (this._isType(index, PrimitiveThickness.Pixel) && this._pixels[index] == value) {
			return;
		}
		this._setType(index, PrimitiveThickness.Pixel);
		this._pixels[index] = value;
		
		if (emitChanged) {
			this._changedCallback();
		}
	}

	private function _setPercentage(value:Float, index:Int, emitChanged:Bool) {
		// Clip Value to bounds
		value = Math.min(1, value);
		value = Math.max(0, value);
		value = Math.round(value * 100) / 100;  // 0.01 precision
		
		if (this._isType(index, PrimitiveThickness.Percentage) && this._percentages[index] == value) {
			return;
		}
		this._setType(index, PrimitiveThickness.Percentage);
		this._percentages[index] = value;
		
		if (emitChanged) {
			this._changedCallback();
		}
	}

	private function _getStringValue(index:Int):String {
		var f = (this._flags >> (index * 4)) & 0xF;
		switch (f) {
			case PrimitiveThickness.Auto:
				return "auto";
				
			case PrimitiveThickness.Pixel:
				return this._pixels[index] + 'px';
				
			case PrimitiveThickness.Percentage:
				
				return (this._percentages[index] * 100) + '%';
			case PrimitiveThickness.Inherit:
				return "inherit";
		}
		
		return "";
	}

	private function _isType(index:Int, type:Int):Bool {
		var f = (this._flags >> (index * 4)) & 0xF;
		return f == type;
	}

	private function _getType(index:Int, processInherit:Bool):Int {
		var t = (this._flags >> (index * 4)) & 0xF;
		if (processInherit && (t == PrimitiveThickness.Inherit)) {
			var p = this._parentAccess();
			if (p) {
				return p._getType(index, true);
			}
			
			return PrimitiveThickness.Auto;
		}
		
		return t;
	}

	private function _setType(index:Int, type:Int) {
		this._flags &= ~(0xF << (index * 4));
		this._flags |= type << (index * 4);
	}

	public function setTop(value:Dynamic) {
		if (Std.is(value, String)) {
			this._setStringValue(value, 0, true);
		} 
		else {
			this.topPixels = value;
		}
	}

	public function setLeft(value:Dynamic) {
		if (Std.is(value, String)) {
			this._setStringValue(value, 1, true);
		} 
		else {
			this.leftPixels = value;
		}
	}

	public function setRight(value:Dynamic) {
		if (Std.is(value, String)) {
			this._setStringValue(value, 2, true);
		} 
		else {
			this.rightPixels = value;
		}
	}

	public function setBottom(value:Dynamic) {
		if (Std.is(value, String)) {
			this._setStringValue(value, 3, true);
		} 
		else {
			this.bottomPixels = value;
		}
	}

	private function _computePixels(index:Int, sourceArea:Size, emitChanged:Bool) {
		var type = this._getType(index, false);
		
		if (type == PrimitiveThickness.Inherit) {
			this._parentAccess()._computePixels(index, sourceArea, emitChanged);
			return;
		}
		
		if (type != PrimitiveThickness.Percentage) {
			return;
		}
		
		var pixels = Std.int(((index == 0 || index == 3) ? sourceArea.height : sourceArea.width) * this._percentages[index]);
		this._pixels[index] = pixels;
		
		if (emitChanged) {
			this._changedCallback();
		}
	}

	/**
	 * Compute the positioning/size of an area considering the thickness of this object and a given alignment
	 * @param sourceArea the source area
	 * @param contentSize the content size to position/resize
	 * @param alignment the alignment setting
	 * @param dstOffset the position of the content, x, y, z, w are left, bottom, right, top
	 * @param dstArea the new size of the content
	 */
	public function computeWithAlignment(sourceArea:Size, contentSize:Size, alignment:PrimitiveAlignment, dstOffset:Vector4, dstArea:Size, computeLayoutArea:Bool = false) {
		// Fetch some data
		var topType = this._getType(0, true);
		var leftType = this._getType(1, true);
		var rightType = this._getType(2, true);
		var bottomType = this._getType(3, true);
		var hasWidth = contentSize != null && (contentSize.width != null);
		var hasHeight = contentSize != null && (contentSize.height != null);
		var width = hasWidth ? contentSize.width : 0;
		var height = hasHeight ? contentSize.height : 0;
		var isTopAuto = topType == PrimitiveThickness.Auto;
		var isLeftAuto = leftType == PrimitiveThickness.Auto;
		var isRightAuto = rightType == PrimitiveThickness.Auto;
		var isBottomAuto = bottomType == PrimitiveThickness.Auto;
		
		switch (alignment.horizontal) {
			case PrimitiveAlignment.AlignLeft:
				if (isLeftAuto) {
					dstOffset.x = 0;
				} 
				else {
					this._computePixels(1, sourceArea, true);
					dstOffset.x = this.leftPixels;
				}
				dstArea.width = width;
				if (computeLayoutArea) {
					dstArea.width += this.leftPixels;
				}
				dstOffset.z = sourceArea.width - (dstOffset.x + width);
			
			case PrimitiveAlignment.AlignRight:
				if (isRightAuto) {
					dstOffset.x = Math.round(sourceArea.width - width);
				} 
				else {
					this._computePixels(2, sourceArea, true);
					dstOffset.x = Math.round(sourceArea.width - (width + this.rightPixels));
				}
				if (computeLayoutArea) {
                    dstArea.width += this.rightPixels;
                }
                dstOffset.z = this.rightPixels;
				dstArea.width = width;
			
			case PrimitiveAlignment.AlignStretch:
				if (isLeftAuto) {
					dstOffset.x = 0;
				} 
				else {
					this._computePixels(1, sourceArea, true);
					dstOffset.x = this.leftPixels;
				}
				
				var right = 0;
				if (!isRightAuto) {
					this._computePixels(2, sourceArea, true);
					right = this.rightPixels;
				}
				dstArea.width = sourceArea.width - (dstOffset.x + right);
				dstOffset.z = this.rightPixels;
			
			case PrimitiveAlignment.AlignCenter:
				if (!isLeftAuto) {
					this._computePixels(1, sourceArea, true);
				}
				if (!isRightAuto) {
					this._computePixels(2, sourceArea, true);
				}
				
				var offset = (isLeftAuto ? 0 : this.leftPixels) - (isRightAuto ? 0 : this.rightPixels);
				dstOffset.x = Math.round(((sourceArea.width - width) / 2) + offset);
				dstArea.width = width;
				dstOffset.z = sourceArea.width - (dstOffset.x + width);
		}
		
		switch (alignment.vertical) {
			case PrimitiveAlignment.AlignTop:
				if (isTopAuto) {
					dstOffset.y = sourceArea.height - height;
				} 
				else {
					this._computePixels(0, sourceArea, true);
					dstOffset.y = Math.round(sourceArea.height - (height + this.topPixels));
				}
				dstArea.height = height;
				if (computeLayoutArea) {
                    dstArea.height += this.topPixels;
                }
                dstOffset.w = this.topPixels;
			
			case PrimitiveAlignment.AlignBottom:
				if (isBottomAuto) {
					dstOffset.y = 0;
				} 
				else {
					this._computePixels(3, sourceArea, true);
					dstOffset.y = this.bottomPixels;
				}
				dstArea.height = height;
				if (computeLayoutArea) {
                    dstArea.height += this.bottomPixels;
                }
                dstOffset.w = sourceArea.height - (dstOffset.y + height);
			
			case PrimitiveAlignment.AlignStretch:
				if (isBottomAuto) {
					dstOffset.y = 0;
				} 
				else {
					this._computePixels(3, sourceArea, true);
					dstOffset.y = this.bottomPixels;
				}
				
				var top = 0;
				if (!isTopAuto) {
					this._computePixels(0, sourceArea, true);
					top = this.topPixels;
				}
				dstArea.height = sourceArea.height - (dstOffset.y + top);
				dstOffset.w = this.topPixels;
			
			case PrimitiveAlignment.AlignCenter:
				if (!isTopAuto) {
					this._computePixels(0, sourceArea, true);
				}
				if (!isBottomAuto) {
					this._computePixels(3, sourceArea, true);
				}
				
				var offset = (isBottomAuto ? 0 : this.bottomPixels) - (isTopAuto ? 0 : this.topPixels);
				dstOffset.y = Math.round(((sourceArea.height - height) / 2) + offset);
				dstArea.height = height;
				dstOffset.w = sourceArea.height - (dstOffset.y + height);
		}
	}

	/**
	 * Compute an area and its position considering this thickness properties based on a given source area
	 * @param sourceArea the source area
	 * @param dstOffset the position of the resulting area
	 * @param dstArea the size of the resulting area
	 */
	public function compute(sourceArea:Size, dstOffset:Vector2, dstArea:Size) {
		this._computePixels(0, sourceArea, true);
		this._computePixels(1, sourceArea, true);
		this._computePixels(2, sourceArea, true);
		this._computePixels(3, sourceArea, true);
		
		dstOffset.x = this.leftPixels;
		dstArea.width = sourceArea.width - (dstOffset.x + this.rightPixels);
		
		dstOffset.y = this.bottomPixels;
		dstArea.height = sourceArea.height - (dstOffset.y + this.topPixels);
	}

	/**
	 * Compute an area considering this thickness properties based on a given source area
	 * @param sourceArea the source area
	 * @param result the resulting area
	 */
	public function computeArea(sourceArea:Size, result:Size) {
		this._computePixels(0, sourceArea, true);
		this._computePixels(1, sourceArea, true);
		this._computePixels(2, sourceArea, true);
		this._computePixels(3, sourceArea, true);
		
		result.width = this.leftPixels + sourceArea.width + this.rightPixels;
		result.height = this.bottomPixels + sourceArea.height + this.topPixels;
	}

	public function enlarge(sourceArea:Size, dstOffset:Vector2, enlargedArea:Size) {
		this._computePixels(0, sourceArea, true);
		this._computePixels(1, sourceArea, true);
		this._computePixels(2, sourceArea, true);
		this._computePixels(3, sourceArea, true);
		
		dstOffset.x = this.leftPixels;
		enlargedArea.width = sourceArea.width + (dstOffset.x + this.rightPixels);
		
		dstOffset.y = this.bottomPixels;
		enlargedArea.height = sourceArea.height + (dstOffset.y + this.topPixels);
	}
	
}
