package com.babylonhx.mesh;

import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt32Array;

/**
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.IGetSetVerticesData') interface IGetSetVerticesData {
	
	function isVerticesDataPresent(kind:String):Bool;
	function getVerticesData(kind:String, copyWhenShared:Bool = false, forceCopy:Bool = false):Float32Array;
	function getIndices(copyWhenShared:Bool = false):UInt32Array;
	function setVerticesData(kind:String, data:Float32Array, updatable:Bool = false, ?stride:Int):Void;
	function updateVerticesData(kind:String, data:Float32Array, updateExtends:Bool = false, makeItUnique:Bool = false):Void;
	function setIndices(indices:UInt32Array, totalVertices:Int = -1, updatable:Bool = false):Void;
	
}
