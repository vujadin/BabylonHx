package com.babylonhx.loading.plugins.ctmfileloader;

import haxe.io.BytesInput;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.UInt32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMReaderRAW implements ICTMReader {	

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
		
		for (i in 0...indices.length) {
			indices[i] = stream.readInt32();
		}
	}

	public function readVertices(stream:BytesInput, vertices:Float32Array) {
		stream.readInt32(); //magic "VERT"
		
		for (i in 0...vertices.length) {
			vertices[i] = stream.readFloat();
		}
	}

	public function readNormals(stream:BytesInput, normals:Float32Array) {
		stream.readInt32(); //magic "NORM"
		
		for (i in 0...normals.length) {
			normals[i] = stream.readFloat();
		}
	}

	public function readUVMaps(stream:BytesInput, uvMaps:Array<CTMUVMap>) {
		for (i in 0...uvMaps.length) {
			stream.readInt32(); //magic "TEXC"
			
			uvMaps[i].name = stream.readString(stream.readInt32());
			uvMaps[i].filename = stream.readString(stream.readInt32());
			
			for (j in 0...uvMaps[i].uv.length) {
				uvMaps[i].uv[j] = stream.readFloat();
			}
		}
	}

	public function readAttrMaps(stream:BytesInput, attrMaps:Array<CTMAttrMap>) {
		for (i in 0...attrMaps.length) {
			stream.readInt32(); //magic "ATTR"
			
			attrMaps[i].name = stream.readString(stream.readInt32());
			
			for (j in 0...attrMaps[i].attr.length) {
				attrMaps[i].attr[j] = stream.readFloat();
			}
		}
	}
	
}
