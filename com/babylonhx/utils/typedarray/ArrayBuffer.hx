package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if snow

	typedef ArrayBuffer = snow.api.buffers.ArrayBuffer;
	
#elseif lime

	typedef ArrayBuffer = lime.utils.ArrayBuffer;

#elseif kha



#end