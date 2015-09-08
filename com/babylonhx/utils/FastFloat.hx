package com.babylonhx.utils;

/**
 * ...
 * @author Krtolica Vujadin
 */

// taken from https://github.com/KTXSoftware/Kha/blob/master/Sources/kha/FastFloat.hx

#if cpp

	typedef FastFloat = cpp.Float32;
	
#else

	typedef FastFloat = Float;
	
#end
