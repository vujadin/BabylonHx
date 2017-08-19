package com.babylonhx.loading.obj;

import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Line {
	
	public var tokens:Array<String> = [];
	
	public var isValid(get, never):Bool;
	public var isComment(get, never):Bool;	
	public var blockSeparator(get, never):String;
	

	public function new(data:String) {
		setLine(data);
	}
	
	public function setLine(line:String) {
		var blanks = [" ", "\t"];
		tokens = line.split(blanks[0]);
		tokens.concat(line.split(blanks[1]));
	}
	
	public function toFloat():Float {
		return Std.parseFloat(tokens[1]);
	}
	
	public function toVector2():Vector2 {
		return new Vector2(Std.parseFloat(tokens[1]), Std.parseFloat(tokens[2]));
	}
	
	public function toVector3():Vector3 {
		return new Vector3(Std.parseFloat(tokens[1]), Std.parseFloat(tokens[2]), Std.parseFloat(tokens[3]));
	}
	
	public function toColor3():Color3 {
		return new Color3(Std.parseFloat(tokens[1]), Std.parseFloat(tokens[2]), Std.parseFloat(tokens[3]));
	}
	
	public function toString():String {
		return tokens.join(" ");
	}
	
	// getters/setters	
	function get_isValid():Bool {
		return tokens.length > 0;
	}	
	
	function get_isComment():Bool {
		return StringTools.startsWith(tokens[0], "#");
	}
	
	function get_blockSeparator():String {
		return "_*_";
	}
	
}
