package com.babylonhx.cameras;

/**
 * @author Krtolica Vujadin
 */
interface ICameraInput {
	
	var camera:Camera;
	
	function getTypeName():String;
	function getSimpleName():String;

	function attachControl():Void;
	function detachControl():Void;
	
	var checkInputs:Null<Void->Void>;
  
}
