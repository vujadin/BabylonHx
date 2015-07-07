package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if purejs

	typedef ArrayBuffer = js.html.ArrayBuffer;

#elseif snow

	typedef ArrayBuffer = snow.api.buffers.ArrayBuffer;
	
#elseif lime

	typedef ArrayBuffer = lime.utils.ArrayBuffer;
	
#elseif nme

	typedef ArrayBuffer = nme.utils.ArrayBuffer;

#elseif kha



#end