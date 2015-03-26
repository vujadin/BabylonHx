package com.babylonhxext.bumper;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BlurStack {
	
	public var r:Int;
	public var g:Int;
	public var b:Int;
	public var a:Int;
	public var next:BlurStack;
	

	public function new() {
		this.r = 0;
		this.g = 0;
		this.b = 0;
		this.a = 0;
		this.next = null;
	}
	
}