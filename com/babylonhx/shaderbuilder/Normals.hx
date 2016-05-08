package com.babylonhx.shaderbuilder;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Normals {

	static public var Default = ShaderMaterialHelperStatics.Normal;
	static public var Inverse = '-1.*' + ShaderMaterialHelperStatics.Normal;
	static public var Pointed = 'normalize(' + ShaderMaterialHelperStatics.Position + '-' + ShaderMaterialHelperStatics.Center + ')';
	static public var Flat = 'normalize(cross(dFdx(' + ShaderMaterialHelperStatics.Position + ' * -1.), dFdy(' + ShaderMaterialHelperStatics.Position + ')))';
	static public var NMap = 'normalMap()';
	
}
