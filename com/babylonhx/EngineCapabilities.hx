package com.babylonhx;

#if (js || purejs || html5)
	typedef EngineCapabilities = com.babylonhx.utils.engineCapabilities.js.EngineCapabilities;
#else
	typedef EngineCapabilities = com.babylonhx.utils.engineCapabilities.native.EngineCapabilities;
#end