package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if purejs

	typedef UInt16Array = js.html.UInt16Array;

#elseif snow
 
	typedef UInt16Array = snow.api.buffers.Uint16Array;
	
#elseif openfl

	typedef UInt16Array = openfl.utils.UInt16Array;
	
#elseif lime

	typedef UInt16Array = lime.utils.UInt16Array;	
	
#elseif nme

	typedef UInt16Array = nme.utils.UInt16Array;

#elseif kha



#end