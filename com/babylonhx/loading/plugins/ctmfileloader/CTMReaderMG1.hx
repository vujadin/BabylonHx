package com.babylonhx.loading.plugins.ctmfileloader;

import haxe.io.BytesInput;

import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMReaderMG1 implements ICTMReader {

	public function new() { }
	
	public function read(stream:BytesInput, body:CTMFileBody) {
		this.readIndices(stream, body.indices);
		this.readVertices(stream, body.vertices);
		
		if (body.normals != null) {
			this.readNormals(stream, body.normals);
		}
		if (body.uvMaps != null) {
			this.readUVMaps(stream, body.uvMaps);
		}
		if (body.attrMaps != null) {
			this.readAttrMaps(stream, body.attrMaps);
		}
	}
	
	public function readIndices(stream:BytesInput, indices:UInt32Array) {
		stream.readInt32(); //magic "INDX"
		var size = stream.readInt32(); //packed size
		
		var interleaved = new CTMInterleavedStream(indices, 3);
		CTM.decompress(stream, size, interleaved);
		
		CTM.restoreIndices(indices, indices.length);
	}
	
	public function readVertices(stream:BytesInput, vertices:Float32Array) {
		stream.readInt32(); //magic "VERT"
		var size = stream.readInt32(); //packed size
	  
		var interleaved = new CTMInterleavedStream(vertices, 1);
		CTM.decompress(stream, size, interleaved);
	}
	
	public function readNormals(stream:BytesInput, normals:Float32Array) {
		stream.readInt32(); //magic "NORM"
		
		var size = stream.readInt32(); //packed size
		
		var interleaved = new CTMInterleavedStream(normals, 3);
		CTM.decompress(stream, size, interleaved);
	}
	
	public function readUVMaps(stream:BytesInput, uvMaps:Array<CTMUVMap>) {
		for (i in 0...uvMaps.length) {
			stream.readInt32(); //magic "TEXC"
			
			uvMaps[i].name = stream.readString(stream.readInt32());
			uvMaps[i].filename = stream.readString(stream.readInt32());
			
			var size = stream.readInt32(); //packed size
			
			var interleaved = new CTMInterleavedStream(uvMaps[i].uv, 2);
			CTM.decompress(stream, size, interleaved);
		}
	}
	
	public function readAttrMaps(stream:BytesInput, attrMaps:Array<CTMAttrMap>) {
		for (i in 0...attrMaps.length) {
			stream.readInt32(); //magic "ATTR"
			
			attrMaps[i].name = stream.readString(stream.readInt32());
			
			var size = stream.readInt32(); //packed size
			
			var interleaved = new CTMInterleavedStream(attrMaps[i].attr, 4);
			CTM.decompress(stream, size, interleaved);
		}
	}
	
}
