package com.babylonhx.behaviors;

/**
 * ...
 * @author Krtolica Vujadin
 */
interface Behavior<T:Node> {
	
	var name(get, never):String;

	function init():Void;
	function attach(node:T):Void;
	function detach():Void;
	
}
