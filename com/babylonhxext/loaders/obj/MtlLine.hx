package com.babylonhxext.loaders.obj;

/**
 * ...
 * @author Krtolica Vujadin
 */

enum MtlHeader {
	None;
	Comment;
	Material;
	DiffuseColor;
	DiffuseTexture;
	SpecularColor;
	SpecularTexture;
	SpecularPower;
	EmissiveColor;
	Alpha;
	IlluminationModel;
	BumpTexture;
	ReflectionTexture;
	TransparencyTexture;
	AmbientTexture;
	AmbientColor;
	RefractionIndex;
	Transparency;
	TransmissionFiter;
}
 
class MtlLine extends Line {
	
	public var header(get, never):MtlHeader;

	public function new(data:String) {
		super(data);
	}
	
	override function get_blockSeparator():String {
		return "newmtl";
	}
	
	function get_header():MtlHeader {
		if (isComment) {
			return MtlHeader.Comment;
		}
		
		var lineType:String = tokens[0].toLowerCase();
		switch (lineType) {
			case "newmtl":
				return MtlHeader.Material;
				
			case "kd":
				return MtlHeader.DiffuseColor;
				
			case "map_kd":
				return MtlHeader.DiffuseTexture;
				
			case "ks":
				return MtlHeader.SpecularColor;
				
			case "ns":
				return MtlHeader.SpecularPower;
				
			case "map_ks":
				return MtlHeader.SpecularTexture;
				
			case "ke":
				return MtlHeader.EmissiveColor;
				
			case "d":
				return MtlHeader.Alpha;
				
			case "illum":
				return MtlHeader.IlluminationModel;
				
			case "ni":
				return MtlHeader.RefractionIndex;
				
			case "tr":
				return MtlHeader.Transparency;
				
			case "map_d":
				return MtlHeader.TransparencyTexture;
				
			case "tf":
				return MtlHeader.TransmissionFiter;
				
			case "ka":
				return MtlHeader.AmbientColor;
				
			case "map_ka":
				return MtlHeader.AmbientTexture;
				
			case "bump", "map_bump":
				return MtlHeader.BumpTexture;
				
			case "map_refl":
				return MtlHeader.ReflectionTexture;
				
			/*default:
				trace("Usupported line type: " + lineType);*/
		}
		
		return MtlHeader.None;
		
	}
	
}
