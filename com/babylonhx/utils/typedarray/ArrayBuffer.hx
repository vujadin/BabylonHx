package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if snow

	typedef ArrayBuffer = snow.io.typedarray.ArrayBuffer;
	
#elseif lime

	typedef ArrayBuffer = lime.utils.ArrayBuffer;

#elseif kha



#end