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
	
}
