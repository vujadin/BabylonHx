package com.babylonhx.particles;

/**
 * @author Krtolica Vujadin
 */
interface IParticleSystem extends ISmartArrayCompatible {
	
	var id:String;
	var name:String;
	var emitter:Dynamic; // AbstractMesh | Vector3;        
	var renderingGroupId:Int;
	var layerMask:Int;
	
	function isStarted():Bool;  
	function animate():Void;   
	function render():Int;  
	function dispose():Void; 
	function clone(name:String, ?newEmitter:Dynamic):IParticleSystem;
	function serialize():Dynamic;
	
	function rebuild():Void;
	
	// BHx
	var __smartArrayFlags:Array<Int>;
  
}
