package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if snow

	typedef UInt8Array = snow.io.typedarray.Uint8Array;
	
#elseif lime

	typedef UInt8Array = lime.utils.UInt8Array;

#elseif kha



#end
