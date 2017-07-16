package com.babylonhx.loading.plugins.ctmfileloader;

import haxe.io.BytesInput;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMFileMG2Header {
	
	public var vertexPrecision:Float;
	public var normalPrecision:Float;
	public var lowerBoundx:Float;
	public var lowerBoundy:Float;
	public var lowerBoundz:Float;
	public var higherBoundx:Float;
	public var higherBoundy:Float;
	public var higherBoundz:Float;
	public var divx:Int;
	public var divy:Int;
	public var divz:Int;
  
	public var sizex:Float;
	public var sizey:Float;
	public var sizez:Float;
		

	public function new(stream:BytesInput) {
		stream.readInt32(); //magic "MG2H"
		this.vertexPrecision = stream.readFloat();
		this.normalPrecision = stream.readFloat();
		this.lowerBoundx = stream.readFloat();
		this.lowerBoundy = stream.readFloat();
		this.lowerBoundz = stream.readFloat();
		this.higherBoundx = stream.readFloat();
		this.higherBoundy = stream.readFloat();
		this.higherBoundz = stream.readFloat();
		this.divx = stream.readInt32();
		this.divy = stream.readInt32();
		this.divz = stream.readInt32();
	  
		this.sizex = (this.higherBoundx - this.lowerBoundx) / this.divx;
		this.sizey = (this.higherBoundy - this.lowerBoundy) / this.divy;
		this.sizez = (this.higherBoundz - this.lowerBoundz) / this.divz;
	}
	
}
