package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if purejs

	typedef ArrayBufferView = js.html.ArrayBufferView;

#elseif snow

	typedef ArrayBufferView = snow.api.buffers.ArrayBufferView;
	
#elseif lime

	typedef ArrayBufferView = lime.utils.ArrayBufferView;
	
#elseif openfl

	typedef ArrayBufferView = openfl.utils.ArrayBufferView;	
	
#elseif nme

	typedef ArrayBufferView = nme.utils.ArrayBufferView;

#elseif kha



#end
