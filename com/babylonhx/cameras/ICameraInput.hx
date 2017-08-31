package com.babylonhx.cameras;

/**
 * @author Krtolica Vujadin
 */
interface ICameraInput {
	
	var camera:Camera;	
	function getClassName():String;
	function getSimpleName():String;
	function attachControl():Void;
	function detachControl():Void;	
	var checkInputs:Void->Void;
  
}
