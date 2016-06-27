package com.babylonhx.loading.plugins.ctmfileloader;

import haxe.io.BytesInput;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMFile {
	
	public var file:BytesInput;
	public var header:CTMFileHeader;
	public var body:CTMFileBody;
	

	public function new(file:BytesInput) {
		this.file = file;
	}
	
	public function load(){
		this.header = new CTMFileHeader(this.file);
		this.body = new CTMFileBody(this.header);
		this.getReader().read(this.file, this.body);
	}
	
	public function getReader():ICTMReader {
		var reader:ICTMReader = null;
		
		switch (this.header.compressionMethod) {
			case CTM.CompressionMethod.RAW:
				reader = new CTMReaderRAW();
				
			case CTM.CompressionMethod.MG1:
				reader = new CTMReaderMG1();
				
			case CTM.CompressionMethod.MG2:
				reader = new CTMReaderMG2();
		}
		
		return reader;
	}
	
}
