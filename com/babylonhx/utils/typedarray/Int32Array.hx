package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if purejs

	typedef Int32Array = js.html.Int32Array;

#elseif snow
 
	typedef Int32Array = snow.api.buffers.Int32Array;
	
#elseif openfl

	typedef Int32Array = openfl.utils.Int32Array;
	
#elseif lime

	typedef Int32Array = lime.utils.Int32Array;	
	
#elseif nme

	typedef Int32Array = nme.utils.Int32Array;

#elseif kha



#end
