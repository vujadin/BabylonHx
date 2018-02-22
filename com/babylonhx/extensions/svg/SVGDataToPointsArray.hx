package com.babylonhx.extensions.svg;

/**
 * ...
 * @author Krtolica Vujadin
 */
class SVGDataToPointsArray {

	public var commands:Array<String>;
	

    public function new() {
		commands = [];
    }

    function f2a(f:Float):String {
		if (Math.abs(f) < 0.000001) {
			return "0";
		}
		if (Math.abs(1 - f) < 0.000001) {
			return "1";
		}
		
		return f + "";
    }

	public function moveTo(inX:Float, inY:Float) {
		commands.push("g.moveTo(" + inX + "," + inY + ");"); 	
	}
	
	public function lineTo(inX:Float, inY:Float) {
		commands.push("g.lineTo(" + inX + "," + inY + ");");
	}
	
	public function curveTo(inCX:Float, inCY:Float, inX:Float, inY:Float) {
		commands.push("g.curveTo(" + inCX + "," + inCY + "," + inX + "," + inY + ");");
	}
	
}
