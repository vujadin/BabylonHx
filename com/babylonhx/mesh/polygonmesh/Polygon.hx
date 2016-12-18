package com.babylonhx.mesh.polygonmesh;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Path2;


/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.Polygon') class Polygon {

	static public inline function Rectangle(xmin:Float, ymin:Float, xmax:Float, ymax:Float):Array<Vector2> {
		return [
			new Vector2(xmin, ymin),
			new Vector2(xmax, ymin),
			new Vector2(xmax, ymax),
			new Vector2(xmin, ymax)
		];
	}

	static public inline function Circle(radius:Float, cx:Float = 0, cy:Float = 0, numberOfSides:Int = 32):Array<Vector2> {
		var result:Array<Vector2> = [];
		
		var angle:Float = 0;
		var increment:Float = (Math.PI * 2) / numberOfSides;
		
		for (i in 0...numberOfSides) {
			result.push(new Vector2(cx + Math.cos(angle) * radius, cy + Math.sin(angle) * radius));
			angle -= increment;
		}
		
		return result;
	}

	static public inline function Parse(input:String, separator:String = " "):Array<Vector2> {
		//var regx = ~/[^-+eE\.\d]+/i;
		//var floats = regx.split(input).map(Std.parseFloat).filter(function(val):Bool { return !Math.isNaN(val); } );
		var floats = input.split(separator).map(Std.parseFloat);
		var i:Int = 0;
		var result:Array<Vector2> = [];
		while(i < (floats.length & 0x7FFFFFFE)) {
			result.push(new Vector2(floats[i], floats[i + 1]));
			i += 2;
		}
		
		return result;
	}

	static public inline function StartingAt(x:Float, y:Float):Path2 {
		return Path2.StartingAt(x, y);
	}
	
}
