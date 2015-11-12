package com.babylonhx.materials;

/**
 * @author Krtolica Vujadin
 */

interface IMaterialDefines {
	
	function isEqual(other:IMaterialDefines):Bool;
	function cloneTo(other:IMaterialDefines):Void;
	function reset():Void;
	function toString():String;
  
}
