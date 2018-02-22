package com.babylonhx.extensions.lsystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RuleHead {
	
	public static var SYMBOL_CONTEXT_LEFT:String = "<";
	public static var SYMBOL_CONTEXT_RIGHT:String = ">";
	public static var SYMBOL_CONDITION:String = ":";
	
	public var predecessor:Symbol;
	public var successor:Symbol;
	public var symbol:Symbol;
	public var condition:String;
	

	public function new(string:String) {
		var index = 0;
		var conditionIndex = string.indexOf(SYMBOL_CONDITION);
		var predecessorIndex = string.indexOf(SYMBOL_CONTEXT_LEFT);
		var successorIndex = string.indexOf(SYMBOL_CONTEXT_RIGHT);
		
		if (conditionIndex != -1) {
			if (predecessorIndex > conditionIndex) {
				predecessorIndex = -1;
			}
			
			if (successorIndex > conditionIndex) {
				successorIndex = -1;
			}
		}
		
		if (predecessorIndex != -1) {
			this.predecessor = new Symbol(string, index);
			
			index = predecessorIndex + 1;
		}
		else {
			this.predecessor = null;
		}
		
		this.symbol = new Symbol(string, index);
		
		if (successorIndex != -1) {
			this.successor = new Symbol(string, successorIndex + 1);
		}
		else {
			this.successor = null;
		}
		
		if (conditionIndex != -1) {
			this.condition = string.substr(conditionIndex + 1);
		}
		else {
			this.condition = null;
		}
	}
	
}
