package com.babylonhx.shaderbuilder;

/**
 * @author Krtolica Vujadin
 */
typedef ILight = {
	
	var direction:String;
	var rotation:IVector3;
	var color:IColor;
	var darkColorMode:Bool;

	var specular:IColor;
	var specularPower:Float;
	var specularLevel:Float;

	var phonge:IColor;
	var phongePower:Float;
	var phongeLevel:Float;

	var normal:String;

	var reducer:String;

	var supplement:Bool;

	var parallel:Bool;
  
}
