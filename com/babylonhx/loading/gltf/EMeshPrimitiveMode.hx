package com.babylonhx.loading.gltf;

/**
 * @author Krtolica Vujadin
 */
@:enum 
abstract EMeshPrimitiveMode(Int) {
	
	var POINTS = 0;
	var LINES = 1;
	var LINE_LOOP = 2;
	var LINE_STRIP = 3;
	var TRIANGLES = 4;
	var TRIANGLE_STRIP = 5;
	var TRIANGLE_FAN = 6;
	
}
