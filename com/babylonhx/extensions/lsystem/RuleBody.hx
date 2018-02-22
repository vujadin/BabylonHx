package com.babylonhx.extensions.lsystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class RuleBody {
	
	public var body:Array<Symbol>;
	

	public function new(string:String) {
		this.body = Lindenmayer.toSymbols(string);
	}
	
}
