package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if snow

	typedef Int16Array = snow.api.buffers.Int16Array;
	
#elseif lime

	typedef Int16Array = lime.utils.Int16Array;

#elseif kha



#end
