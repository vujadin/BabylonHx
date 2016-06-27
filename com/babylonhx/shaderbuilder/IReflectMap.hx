package com.babylonhx.shaderbuilder;

/**
 * @author Krtolica Vujadin
 */
typedef IReflectMap = {
	
	var path:String;
	var x:Float;
	var y:Float;
	var scaleX:Float;
	var scaleY:Float;
	var equirectangular:Bool;
	var rotation:IVector3;
	var useInVertex:Bool;
	var uv:String;
	var normal:String;
	var normalLevel:String;
	var bias:String;
	var alpha:Bool;
	var revers:Bool;
	var reflectMap:String;
	var refract:Bool;
	var refractMap:String;
  
}
