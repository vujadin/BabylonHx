package com.babylonhx.shaderbuilder;

import com.babylonhx.materials.Effect;

/**
 * @author Krtolica Vujadin
 */
typedef IPostProcess = {
	
	var samplingMode:Int;
	var engine:Dynamic;
	var reusable:Bool;
	var defines:String;
	var onApply:Effect->Void;
  
}
