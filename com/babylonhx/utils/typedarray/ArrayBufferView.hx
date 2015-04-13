package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if snow

	typedef ArrayBufferView = snow.api.buffers.ArrayBufferView;
	
#elseif lime

	typedef ArrayBufferView = lime.utils.ArrayBufferView;

#elseif kha



#end
