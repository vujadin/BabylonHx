package com.babylonhx.behaviors;

/**
 * ...
 * @author Krtolica Vujadin
 */
interface Behavior<T:Node> {
	
	var name(get, never):String;

	function attach(node:T):Void;
	function detach():Void;
	
}
