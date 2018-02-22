package com.babylonhx.extensions.lsystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Rule {
	
	public static var SYMBOL_EQUALS:String = "=";
	
	public var head:RuleHead;
	public var body:RuleBody;
	public var keys:Array<String>;
	public var key:String;
	public var fCondition:Array<String>->String;
	

	public function new(string:String) {
		var ereg:EReg = ~/\s/g;
		var source:String = ereg.replace(string, "");
		
		this.head = new RuleHead(source.substring(0, source.lastIndexOf(SYMBOL_EQUALS)));
		this.body = new RuleBody(source.substring(source.lastIndexOf(SYMBOL_EQUALS) + 1));
		this.keys = this.getKeys();
		this.fCondition = function(keys:Array<String>) { return this.head.condition; } );
		
		this.addFunctionsToBody();
	}
	
	public function addFunctionsToBody() {
		for (symbol in 0...this.body.body.length) {
			this.body.body[symbol].createFunctions(this.keys);
		}
	}
	
	public function isApplicable(symbol:Symbol, predecessor:Symbol, successor:Symbol) {
		if(!symbol.matches(this.head.symbol)) {
			return false;
		}
		
		if(this.head.predecessor != null && !this.head.predecessor.matches(predecessor)) {
			return false;
		}
		
		if(this.head.successor != null && !this.head.successor.matches(successor)) {
			return false;
		}
		
		this.key = this.setKey(symbol, predecessor, successor);
		
		if(this.head.condition != null) {
			return this.fCondition(this, Object.values(this.key));
		}
		else {
			return true;
		}
	}
	
	public function getKeys():Array<String> {
		var keys:Array<String> = [];
		
		if (this.head.predecessor != null) {
			keys = keys.concat(this.head.predecessor.parameters);
		}
		
		keys = keys.concat(this.head.symbol.parameters);
		
		if (this.head.successor != null) {
			keys = keys.concat(this.head.successor.parameters);
		}
		
		return keys;
	}
	
	public function assignVariables(object:Dynamic, key:Symbol, values:Symbol) {
		for (index in 0...key.parameters.length) {
			object[key.parameters[index]] = Number(values.parameters[index]);
		}
	}
	
	public function setKey(symbol:Symbol, predecessor:Symbol, successor:Symbol) {
		this.key = new Object();
		
		this.assignVariables(this.key, this.head.symbol, symbol);
		
		if (this.head.predecessor != null) {
			this.assignVariables(this.key, this.head.predecessor, predecessor);
		}
		
		if (this.head.successor != null) {
			this.assignVariables(this.key, this.head.successor, successor);
		}
		
		return this.key;
	}
	
}
