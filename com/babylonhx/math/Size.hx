package com.babylonhx.math;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Size implements ISize {
	
	public var width:Int;
	public var height:Int;
	
	public var surface(get, never):Float;
	

	public function new(width:Int, height:Int) {
		this.width = width;
		this.height = height;
	}
	
	public function toString():String {
		return "{W: $this.width, H: $this.height}";
	}
	
	public function getClassName():String {
        return "Size";
    }

	public function getHashCode():Float {
        var hash = this.width;
        hash = (hash * 397) ^ this.height;
		
        return hash;
    }
	
	public function clone():Size {
		return new Size(this.width, this.height);
	}
	
	public function equals(other:Size):Bool {
		if (other == null) {
			return false;
		}
		
		return (this.width == other.width) && (this.height == other.height);
	}
	
	private function get_surface():Float {
		return this.width * this.height;
	}
	
	static public function Zero():Size {
		return new Size(0, 0);
	}
	
	public function add(otherSize:Size):Size {
		var r = new Size(this.width + otherSize.width, this.height + otherSize.height);
		
		return r;
	}

	public function subtract(otherSize:Size):Size {
		var r = new Size(this.width - otherSize.width, this.height - otherSize.height);
		
		return r;
	}

	public static function Lerp(start:Size, end:Size, amount:Float):Size {
		var w = Std.int(start.width + ((end.width - start.width) * amount));
		var h = Std.int(start.height + ((end.height - start.height) * amount));
		
		return new Size(w, h);
	}
	
}
