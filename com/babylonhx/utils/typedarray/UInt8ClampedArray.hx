package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

#if purejs

	typedef UInt8ClampedArray = js.html.Uint8ClampedArray;

#elseif snow

	typedef UInt8ClampedArray = snow.api.buffers.UInt8ClampedArray;
	
#elseif lime

	typedef UInt8ClampedArray = lime.utils.UInt8ClampedArray;

#elseif openfl

	typedef UInt8ClampedArray = openfl.utils.UInt8ClampedArray;	
	
#elseif nme

	typedef UInt8ClampedArray = nme.utils.UInt8ClampedArray;

#elseif kha



#end
