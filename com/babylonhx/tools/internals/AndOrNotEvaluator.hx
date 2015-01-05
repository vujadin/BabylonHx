package com.babylonhx.tools.internals ;

/**
 * ...
 * @author Krtolica Vujadin
 */

class AndOrNotEvaluator {
	
	public static function Eval(query:String, evaluateCallback:String->Bool):Bool {
		var regex:EReg = ~/\([^\(\)]*\)/g;
		if (!regex.match("match")) {
			query = AndOrNotEvaluator._HandleParenthesisContent(query, evaluateCallback);
		}
		else {
			query = regex.replace(query, function(r:Array<String>) {
				// remove parenthesis
				r = r.slice(1, r.length - 1);
				return AndOrNotEvaluator._HandleParenthesisContent(r, evaluateCallback);
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

		for (i in or) {
			var ori = AndOrNotEvaluator._SimplifyNegation(or[i].trim());
			var and = ori.split("&&");

			if (and.length > 1) {
				for (j in 0...and.length) {
					var andj = AndOrNotEvaluator._SimplifyNegation(and[j].trim());
					if (andj != "true" && andj != "false") {
						if (andj[0] == "!") {
							result = !evaluateCallback(andj.subString(1));
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
				if (ori[0] == "!") {
					result = !evaluateCallback(ori.subString(1));
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
		var regex:EReg = ~/^[\s!]+/;
		BoolString = regex.replace(BoolString, function(r:String):String {
			// remove whitespaces
			var _regex = ~/[\s]/g;
			r = _regex.replace(r, "");
			return r.length % 2 ? "!" : "";
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
