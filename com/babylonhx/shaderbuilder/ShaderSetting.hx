package com.babylonhx.shaderbuilder;

import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.CubeTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShaderSetting {

	public var Texture2Ds:Array<ITexture>;
	public var TextureCubes:Array<ITexture>;
	public var CameraShot:Bool;
	public var PrecisionMode:String;

	public var Transparency:Bool;
	public var Back:Bool;
	public var Front:Bool;
	public var Wire:Bool;
	public var Uv:Bool;
	public var Uv2:Bool;
	public var Center:Bool;
	public var Flags:Bool;

	public var FragmentView:Bool;
	public var FragmentWorld:Bool;
	public var FragmentWorldView:Bool;
	public var FragmentViewProjection:Bool;

	public var SpecularMap:String;
	public var NormalMap:String;
	public var Normal:String;
	public var NormalOpacity:String;

	public var WorldPosition:Bool;
	public var Vertex:Bool;

	public var VertexView:Bool;
	public var VertexWorld:Bool;
	public var VertexWorldView:Bool;
	public var VertexViewProjection:Bool;

	public var Mouse:Bool;
	public var Screen:Bool;
	public var Camera:Bool;
	public var Look:Bool;
	public var Time:Bool;
	public var GlobalTime:Bool;
	public var ReflectMatrix:Bool;

	public var Helpers:Bool;
	

	public function new() {
		this.PrecisionMode = ShaderMaterialHelperStatics.PrecisionHighMode;
	}
	
}
