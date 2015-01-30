package com.babylonhx.tools.internals ;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.AndOrNotEvaluator') class AndOrNotEvaluator {
	
	public static function Eval(query:String, evaluateCallback:String->Bool):Bool {
		var regex:EReg = ~/\([^\(\)]*\)/g;
		if (!regex.match("match")) {
			query = AndOrNotEvaluator._HandleParenthesisContent(query, evaluateCallback);
		}
		else {
			
			query = regex.map(query, function(r) {
				// todo
				// remove parenthesis
				query = query.substring(1, query.length - 1);
				return AndOrNotEvaluator._HandleParenthesisContent(query, evaluateCallback);
			});
		}
		
		if (query == "true") {
			return true;
		}
		
		if (query == "false") {
			return false;
		}
		
		return AndOrNotEvaluator.Eval(query, evaluateCallback);
	}

	private static function _HandleParenthesisContent(parenthesisContent:String, evaluateCallback:String->Bool):String {
		evaluateCallback = evaluateCallback != null ? evaluateCallback : function(r:String):Bool {
			return r == "true" ? true : false;
		};
		
		var result:Bool = false;
		var or = parenthesisContent.split("||");
		
		for (i in 0...or.length) {
			var ori = AndOrNotEvaluator._SimplifyNegation(StringTools.trim(or[i]));
			var and = ori.split("&&");
			
			if (and.length > 1) {
				for (j in 0...and.length) { 
					var andj = AndOrNotEvaluator._SimplifyNegation(StringTools.trim(and[j]));
					if (andj != "true" && andj != "false") {
						
						if (andj.substring(0,1) == "!") {
							result = !evaluateCallback(andj.substring(1));
						}
						else {
							result = evaluateCallback(andj);
						}
					}
					else {
						result = andj == "true" ? true :false;
					}
					if (!result) { // no need to continue since 'false && ... && ...' will always return false
						ori = "false";
						break;
					}
				}
			}
			
			if (result || ori == "true") { // no need to continue since 'true || ... || ...' will always return true
				result = true;
				break;
			}
			
			// result equals false (or undefined)
			
			if (ori != "true" && ori != "false") {
				
				if (ori.substring(0,1) == "!") {
					result = !evaluateCallback(ori.substring(1));
				}
				else {
					result = evaluateCallback(ori);
				}
			}
			else {
				result = ori == "true" ? true : false;
			}
		}
		
		// the whole parenthesis scope is replaced by 'true' or 'false'
		return result ? "true" : "false";
	}

	private static function _SimplifyNegation(BoolString:String):String {
		// todo 
		var regex:EReg = ~/^[\s!]+/;
		BoolString = regex.map(BoolString, function(regex):String {
			// remove whitespaces
			var _regex:EReg = ~/[\s]/g;
			var ret;
			var r = _regex.replace(BoolString, "");
			if(r.length % 2 == 1){
				ret = "!";
			}else{
				ret = "";
			}
			return ret;
		});
		
		BoolString = StringTools.trim(BoolString);
		
		if (BoolString == "!true") {
			BoolString = "false";
		}
		else if (BoolString == "!false") {
			BoolString = "true";
		}
		
		return BoolString;
	}
	
}
