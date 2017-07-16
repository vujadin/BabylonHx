package com.babylonhx.d2.display;

/**
 * @author Krtolica Vujadin
 */
@:enum abstract BlendMode(String) {
	
	var NORMAL 			= "normal";
	var ADD    			= "add";
	var SUBTRACT 		= "subtract";
	var MULTIPLY	    = "multiply";
	var SCREEN			= "screen";
	
	var ERASE			= "erase";
	var ALPHA			= "alpha";
	
}