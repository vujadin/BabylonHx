package com.babylonhx.extensions.lsystem;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Lindenmayer {
	
	public var rules:Array<Rule>;
	public var constants:String;
	

	public function new() {
		this.rules = [];
		this.constants = "";
	}
	
	public function setConstants(constants:String) {
		this.constants = constants;
	}
	
	public function setRules(rules:Array<String>) {
		for (rule in 0...rules.length) {
			this.addRule(rules[rule]);
		}
	}
	
	public function removeRules() {
		this.setRules([]);
	}
	
	public function addRule(rule:String) {
		this.rules.push(new Rule(rule));
	}
	
	public function process(axiom:String, iterations:Int):Array<Symbol> {
		var ereg = ~/\s/g;
		var axiom = this.toSymbols(ereg.replace(axiom, ""));
		
		for (iteration in 0...iterations) {
			axiom = this.applyRules(axiom);
		}
		
		return axiom;
	}
	
	public function toSymbols(string:String):Array<Symbol> {
		var symbols:Array<Symbol> = [];
		
		for (index in 0...string.length) {
			var symbol = new Symbol(string, index);
			
			index += symbol.length;
			symbols.push(symbol);
		}
		
		return symbols;
	}
	
	public function getRules(symbol:Symbol, predecessor:Symbol, successor:Symbol):Array<Rule> {
		var rules:Array<Rule> = [];
		
		for (rule in 0...this.rules.length) {
			if (this.rules[rule].isApplicable(symbol, predecessor, successor)) {
				rules.push(this.rules[rule]);
			}
		}
		
		return rules;
	}
	
	public function applyRule(rule:Rule, symbol:Symbol, predecessor:Symbol, successor:Symbol) {
		var returnSymbols:Array<Symbol> = [];
		
		for (index in 0...rule.body.body.length) {
			var s:Symbol = rule.body.body[index];
			var result:Symbol = new Symbol(s.symbol);
			
			if (s.parameters.length > 0) {
				for (parameter in 0...s.parameters.length) {
					result.parameters.push(s.functions[parameter].apply(this, Object.values(rule.key)));
				}
			}
				
			returnSymbols.push(result);
		}
		
		return returnSymbols;
	},
	
	parseSymbol(predecessor, symbol, successor) {
		var rules = this.getRules(symbol, predecessor, successor);
		
		if(rules.length == 0)
			return [symbol];
		
		return this.applyRule(rules[Math.floor(Math.random() * rules.length)], symbol, predecessor, successor);
	},
	
	applyRules(sentence) {
		var newSentence = [];
		
		for(var symbol = 0; symbol < sentence.length; ++symbol) {
			var predecessor = null;
			var successor = null;
			
			if(symbol > 0)
				predecessor = sentence[symbol - 1];
			
			if(symbol + 1 < sentence.length)
				successor = sentence[symbol + 1];
			
			newSentence = newSentence.concat(this.parseSymbol(predecessor, sentence[symbol], successor));
		}
		
		return newSentence;
	},
	
	toString(symbols) {
		var sentence = "";
		
		for(var index = 0; index < symbols.length; ++index)
			sentence += symbols[index].toString()
		
		return sentence;
	}
	
}
