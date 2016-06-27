package com.babylonhx.loading.plugins.ctmfileloader;

import haxe.io.BytesInput;

import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt32Array;

/**
 * @author Krtolica Vujadin
 */
interface ICTMReader {
	
	function read(stream:BytesInput, body:CTMFileBody):Void;
	function readIndices(stream:BytesInput, indices:UInt32Array):Void;
	function readVertices(stream:BytesInput, vertices:Float32Array):Void;
	function readNormals(stream:BytesInput, normals:Float32Array):Void;
	function readUVMaps(stream:BytesInput, uvMaps:Array<CTMUVMap>):Void;
	function readAttrMaps(stream:BytesInput, attrMaps:Array<CTMAttrMap>):Void;
  
}
