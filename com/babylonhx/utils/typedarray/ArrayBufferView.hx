package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if snow

	typedef ArrayBufferView = snow.io.typedarray.ArrayBufferView;
	
#elseif lime

	typedef ArrayBufferView = lime.utils.ArrayBufferView;

#elseif kha



#end
