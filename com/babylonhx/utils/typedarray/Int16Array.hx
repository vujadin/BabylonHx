package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if purejs

	typedef Int16Array = js.html.Int16Array;

#elseif snow

	typedef Int16Array = snow.api.buffers.Int16Array;
	
#elseif lime

	typedef Int16Array = lime.utils.Int16Array;
	
#elseif openfl

	typedef Int16Array = openfl.utils.Int16Array;	
	
#elseif nme

	typedef Int16Array = nme.utils.Int16Array;

#elseif kha



#end
