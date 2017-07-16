package com.babylonhx.materials;

/**
 * @author Krtolica Vujadin
 */
typedef EffectCreationOptions = {
	
	attributes:Null<Array<String>>,
	uniformsNames:Null<Array<String>>,
	uniformBuffersNames:Null<Array<String>>,
	samplers:Null<Array<String>>,
	defines:Null<Dynamic>,
	fallbacks:Null<EffectFallbacks>,
	onCompiled:Null<Effect->Void>,
	onError:Null<Effect->String->Void>,
	indexParameters:Null<Dynamic>,
	maxSimultaneousLights:Null<Int>
	
}
