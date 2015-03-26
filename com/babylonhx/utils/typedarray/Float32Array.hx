package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if snow

	typedef Float32Array = snow.io.typedarray.Float32Array;
	
#elseif lime

	typedef Float32Array = lime.utils.Float32Array;

#elseif kha



#end
