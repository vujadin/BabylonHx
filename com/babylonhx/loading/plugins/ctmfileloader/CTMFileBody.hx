package com.babylonhx.loading.plugins.ctmfileloader;

import com.babylonhx.utils.typedarray.UInt32Array;
import com.babylonhx.utils.typedarray.Float32Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class CTMFileBody {
	
	public var indices:UInt32Array;
	public var vertices:Float32Array;
	public var normals:Float32Array;
	public var uvMaps:Array<CTMUVMap>;
	public var attrMaps:Array<CTMAttrMap>;
	

	public function new(header:CTMFileHeader) {
		var i:Int = Std.int(header.triangleCount * 3);
		var v:Int = Std.int(header.vertexCount * 3);
		var n:Int = header.hasNormals() ? Std.int(header.vertexCount * 3) : 0;
		var u:Int = Std.int(header.vertexCount * 2);
		var a:Int = Std.int(header.vertexCount * 4);
		
		this.indices = new UInt32Array(i);
		
		this.vertices = new Float32Array(v);
		
		if (header.hasNormals()) {
			this.normals = new Float32Array(n);
		}
	  
		if (header.uvMapCount > 0) {
			this.uvMaps = [];
			for (j in 0...header.uvMapCount) {
				this.uvMaps[j] = new CTMUVMap(new Float32Array(u), "", "");
			}
		}
	  
		if (header.attrMapCount > 0) {
			this.attrMaps = [];
			for (j in 0...header.attrMapCount) {
				this.attrMaps[j] = new CTMAttrMap(new Float32Array(a), "");
			}
		}
	}
	
}
