package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if purejs

	typedef UInt8Array = js.html.Uint8Array;

#elseif snow

	typedef UInt8Array = snow.api.buffers.Uint8Array;
	
#elseif lime

	typedef UInt8Array = lime.utils.UInt8Array;
	
#elseif nme

	typedef UInt8Array = nme.utils.UInt8Array;

#elseif kha



#end
