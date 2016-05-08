package com.babylonhx.loading.plugins.ctmfileloader;

import haxe.io.BytesInput;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMReaderMG2 implements ICTMReader {
	
	public var MG2Header:CTMFileMG2Header;
	private var body:CTMFileBody;
	

	public function new() { }
	
	public function read(stream:BytesInput, body:CTMFileBody) {
		this.MG2Header = new CTMFileMG2Header(stream);
		this.body = body;
		
		this.readVertices(stream, body.vertices);
		this.readIndices(stream, body.indices);
		
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
	
	public function readGridIndices(stream:BytesInput, vertices:Float32Array):UInt32Array {
		stream.readInt32(); //magic "GIDX"
		var size = stream.readInt32(); //packed size
	  
		var gridIndices = new UInt32Array(Std.int(vertices.length / 3));
	  
		var interleaved = new CTMInterleavedStream(gridIndices, 1);
		CTM.decompress(stream, size, interleaved);
	  
		CTM.restoreGridIndices(gridIndices, gridIndices.length);
		
		return gridIndices;
	}
	
	public function readVertices(stream:BytesInput, vertices:Float32Array) {
		stream.readInt32(); //magic "VERT"
		var size = stream.readInt32(); //packed size
	  
		var interleaved = new CTMInterleavedStream(vertices, 3);
		CTM.decompress(stream, size, interleaved);
		
		var gridIndices = this.readGridIndices(stream, vertices);
		
		CTM.restoreVertices(vertices, this.MG2Header, gridIndices, this.MG2Header.vertexPrecision);
	}
	
	public function readNormals(stream:BytesInput, normals:Float32Array) {
		stream.readInt32(); //magic "NORM"		
		var size = stream.readInt32(); //packed size
		
		var interleaved = new CTMInterleavedStream(body.normals, 3);
		CTM.decompress(stream, size, interleaved);
		
		var smooth = CTM.calcSmoothNormals(body.indices, body.vertices);
		
		CTM.restoreNormals(body.normals, smooth, this.MG2Header.normalPrecision);
	}
	
	public function readUVMaps(stream:BytesInput, uvMaps:Array<CTMUVMap>) {
		for (i in 0...uvMaps.length) {
			stream.readInt32(); //magic "TEXC"
			
			uvMaps[i].name = stream.readString(stream.readInt32());
			uvMaps[i].filename = stream.readString(stream.readInt32());
			
			var precision = stream.readFloat();
			
			var size = stream.readInt32(); //packed size
			
			var interleaved = new CTMInterleavedStream(uvMaps[i].uv, 2);
			CTM.decompress(stream, size, interleaved);
			
			CTM.restoreMap(uvMaps[i].uv, 2, precision);
		}
	}
	
	public function readAttrMaps(stream:BytesInput, attrMaps:Array<CTMAttrMap>) {
		for (i in 0...attrMaps.length) {
			stream.readInt32(); //magic "ATTR"
			
			attrMaps[i].name = stream.readString(stream.readInt32());
			
			var precision = stream.readFloat();
			
			var size = stream.readInt32(); //packed size
			
			var interleaved = new CTMInterleavedStream(attrMaps[i].attr, 4);
			CTM.decompress(stream, size, interleaved);
			
			CTM.restoreMap(attrMaps[i].attr, 4, precision);
		}
	}
	
}
