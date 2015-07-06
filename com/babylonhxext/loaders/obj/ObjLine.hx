package com.babylonhxext.loaders.obj;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*@:enum 
abstract ObjHeader(Int) {
	var None = -1;
	var Comment = 0;
	var Object = 1;
	var Vertices = 2;
	var TextureCoordinates = 3;
	var Normals = 4;
	var Group = 5;
	var SmoothingGroup = 6;
	var Line = 7;
	var Faces = 8;
	var MaterialLibrary = 9;
	var Material = 10;
}*/

enum ObjHeader {
	None;
	Shading;		// smooth or not
	Comment;
	Object;
	Vertices;
	TextureCoordinates;
	Normals;
	Group;
	SmoothingGroup;
	Line;
	Faces;
	MaterialLibrary;
	Material;
}
 
class ObjLine extends Line {
	
	public var header(get, never):ObjHeader;
	

	public function new(data:String) {
		super(data);
	}
	
	override function get_blockSeparator():String {
		return "v";
	}
	
	// getters/setters
	function get_header():ObjHeader {
		if (isComment) {
			return ObjHeader.Comment;
		}
		
		var lineType:String = tokens[0].toLowerCase();
		if(StringTools.trim(lineType) != "") {
			switch(lineType) {
				case "o":
					return ObjHeader.Object;
					
				case "v":
					return ObjHeader.Vertices;
					
				case "vt":
					return ObjHeader.TextureCoordinates;
					
				case "vn":
					return ObjHeader.Normals;
					
				case "g":
					return ObjHeader.Group;
					
				case "s":
					return ObjHeader.Shading;
					
				case "l":
					return ObjHeader.Line;
					
				case "f":
					return ObjHeader.Faces;
					
				case "mtllib":
					return ObjHeader.MaterialLibrary;
					
				case "usemtl":
					return ObjHeader.Material;
					
			}
			
			trace("Unsuported line type: " + lineType);
		}		
		 
		return ObjHeader.None;
	}
	
}
