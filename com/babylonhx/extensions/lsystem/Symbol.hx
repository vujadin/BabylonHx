package com.babylonhx.extensions.lsystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Symbol {
	
	public var symbol:String;
	public var parameters:Array<String>;
	public var functions:Array<Dynamic>;
	public var length:Int = 0;
	

	public function new(string:String, index:Int = -1) {
		if (index > -1) {
			this.parse(string, index);
		}
		else {
			this.symbol = string;
			this.parameters = [];
		}
	}
	
	public function parse(string:String, index:Int) {
		var startIndex = index;
		
		this.symbol = string.charAt(index);
		
		if (index + 1 < string.length && string.charAt(index + 1) == "(") {
			var scope = 1;
			var start = ++index + 1;
			
			while (string.charAt(++index)) {
				if (string.charAt(index) == "(") {
					++scope;
				}
				else if (string.charAt(index) == ")" && --scope == 0) {
					break;
				}
			}
			
			this.parameters = string.substr(start, index - start).split(",");
		}
		else {
			this.parameters = [];
		}
		
		this.length = index - startIndex;
	}
	
	public function createFunctions(keys:Array<String>) {
		this.functions = [];
		
		for (parameter in 0...this.parameters.length) {
			this.functions.push(new Function(keys, "return " + this.parameters[parameter]));
		}
	}
	
	public function getArity():Int {
		if (this.parameters == null) {
			return 0;
		}
		
		return this.parameters.length;
	}
	
	public function matches(other:Symbol):Bool {
		return other != null && this.symbol == other.symbol && this.getArity() == other.getArity();
	}
	
	public function toString():String {
		var str = this.symbol;
		
		if (this.parameters.length != 0) {
			str += "(";
			
			for (parameter in 0...this.parameters.length) {
				if (parameter == this.parameters.length - 1) {
					str += this.parameters[parameter] + ")";
				}
				else {
					str += this.parameters[parameter] + ",";
				}
			}
		}
		
		return str;
	}
	
}
