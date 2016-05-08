package com.babylonhx.shaderbuilder;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Shader {

	static public var _null:String = 'set null anyway';
	static public var Indexer:Int = 1;
	static public var ShaderIdentity:Int = 0;
	static public var Me:ShaderBuilder;
	
	
	static public function Replace(s:String, t:String, d:String):String {
		/*var ignore = false;
		var regex:EReg = ~/([\/\\,\\!\\\^\$\{\}\[\]\(\)\.\*\+\?\|\\<\\>\-\\&])/g;
		var regex2:EReg = ~/\$/g;
		var regex3:EReg = new EReg(regex.replace(t, "\\$&"), (ignore ? "gi" : "g"));
		
		return regex3.replace(s, regex2.replace(d, "$$$$"));*/
		
		return StringTools.replace(s, t, d);
	}
	
	static public function Def(?a:Dynamic, ?d:Dynamic):Dynamic {
		if (a != null) {
			return (d != null ? a : true);
		}
		else if (d != Shader._null) {
			return (d != null ? d : false);
		}
		
		return null;
	}
	
	static public function Join(s:Array<String>):String {
		return s.join("\n");
	}

	static public function Print(?n:Dynamic):String {
		if (n == null) {
			return "0.";
		}
		var reg:EReg = new EReg('^\\d+$', '');
		var sn = Shader.Replace(Std.string(n), '-', '0');
		if (reg.match(sn) && Std.string(n).indexOf('.') == -1) {
			return n + ".";
		}
		
		return n.toString();
	}
	
	static public function Custom():String {
		return "custom_" + Print(++Me.CustomIndexer) + "_";
	}
	
	static public function Index():String {
		return "_" + Shader.Indexer + "_";
	}
	
	static public function DefCustom(t:String, c:String) {
		Me.Body += t + " custom_" + Print(++Me.CustomIndexer) + "_ = " + c + ";";
	}
	
	static public function toRGB(a:Int, b:Int):Dynamic {
		b = Shader.Def(b, 255);
		var x = a - Math.floor(a / b) * b;
		a = Math.floor(a / b);
		var y = a - Math.floor(a / b) * b;
		a = Math.floor(a / b);
		var z = a - Math.floor(a / b) * b;
		
		if (x > 126) {
			x++;
		}
		if (y > 126) {
			y++;
		}
		if (z > 126) {
			z++;
		}
		
		return { r: x, g: y, b: z };
	}

	static public function torgb(a:Dynamic, b:Dynamic):Dynamic {
		b = Shader.Def(b, 255);
		var i = Shader.toRGB(a, b);
		
		return { r: i.r / 256, g: i.g / 256, b: i.b / 256 };
	}

	static public function toID(a:Dynamic, b:Dynamic):Float {
		b = Shader.Def(b, 255);
		var c = 255 / b;
		
		var x = Math.floor(a.r / c);
		var y = Math.floor(a.g / c);
		var z = Math.floor(a.b / c);

		return z * b * b + y * b + x;
	}
	
}
