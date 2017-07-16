package com.babylonhx.shaderbuilder;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShaderMaterialHelperStatics {

	static public var Dark:Bool = false;
	static public var Light:Bool = true;

	static public var PrecisionHighMode:String = "highp";
	static public var PrecisionMediumMode:String = "mediump";


	static public var face_back:String = "!gl_FrontFacing";
	static public var face_front:String = "gl_FrontFacing";

	static public var AttrPosition:String = "position";
	static public var AttrNormal:String = "normal";
	static public var AttrUv:String = "uv";
	static public var AttrUv2:String = "uv2";

	static public var AttrTypeForPosition:String = "vec3";
	static public var AttrTypeForNormal:String = "vec3";
	static public var AttrTypeForUv:String = "vec2";
	static public var AttrTypeForUv2:String = "vec2";

	static public var uniformView:String = "view";
	static public var uniformWorld:String = "world";
	static public var uniformWorldView:String = "worldView";
	static public var uniformViewProjection:String = "viewProjection";
	static public var uniformWorldViewProjection:String = "worldViewProjection";

	static public var uniformStandardType:String = "mat4";
	static public var uniformFlags:String = "flags";

	static public var Mouse:String = "mouse";
	static public var Screen:String = "screen";
	static public var Camera:String = "camera";
	static public var Look:String = "look";

	static public var Time:String = "time";
	static public var GlobalTime:String = "gtime";
	static public var Position:String = "pos";
	static public var WorldPosition:String = "wpos";

	static public var Normal:String = "nrm";
	static public var WorldNormal:String = "wnrm";
	static public var Uv:String = "vuv";
	static public var Uv2:String = "vuv2";
	static public var Center:String = "center";

	static public var ReflectMatrix:String = "refMat";

	static public var Texture2D:String = "txtRef_";
	static public var TextureCube:String = "cubeRef_";

	static public var IdentityHelper:Int;
	
}