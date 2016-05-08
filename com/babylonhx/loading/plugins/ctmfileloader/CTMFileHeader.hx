package com.babylonhx.loading.plugins.ctmfileloader;

import haxe.io.BytesInput;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMFileHeader {
	
	public var fileFormat:Int;
	public var compressionMethod:Int;
	public var vertexCount:Int;
	public var triangleCount:Int;
	public var uvMapCount:Int;
	public var attrMapCount:Int;
	public var flags:Int;
	public var comment:String;
	

	public function new(file:BytesInput) {
		file.readInt32(); //magic "OCTM"
		this.fileFormat = file.readInt32();
		this.compressionMethod = file.readInt32();
		this.vertexCount = file.readInt32();
		this.triangleCount = file.readInt32();
		this.uvMapCount = file.readInt32();
		this.attrMapCount = file.readInt32();
		this.flags = file.readInt32();
		this.comment = file.readString(file.readInt32());
	}
	
	public function hasNormals():Bool {
		return this.flags & 0x00000001/*Flags.NORMALS*/ == 0 ? false : true;
	}
	
}
