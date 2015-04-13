package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if snow
 
	typedef Int32Array = snow.api.buffers.Int32Array;
	
#elseif lime

	typedef Int32Array = lime.utils.Int32Array;

#elseif kha



#end
