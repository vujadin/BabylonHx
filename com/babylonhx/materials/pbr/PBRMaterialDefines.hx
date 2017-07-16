package com.babylonhx.materials.pbr;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialDefines extends MaterialDefines {
	
	public var ALBEDO:Bool = false;
	public var AMBIENT:Bool = false;
	public var AMBIENTINGRAYSCALE:Bool = false;
	public var OPACITY:Bool = false;
	public var OPACITYRGB:Bool = false;
	public var REFLECTION:Bool = false;
	public var EMISSIVE:Bool = false;
	public var REFLECTIVITY:Bool = false;
	public var BUMP:Bool = false;
	public var PARALLAX:Bool = false;
	public var PARALLAXOCCLUSION:Bool = false;
	public var SPECULAROVERALPHA:Bool = false;
	public var CLIPPLANE:Bool = false;
	public var ALPHATEST:Bool = false;
	public var ALPHAFROMALBEDO:Bool = false;
	public var POINTSIZE:Bool = false;
	public var FOG:Bool = false;
	public var SPECULARTERM:Bool = false;
	public var OPACITYFRESNEL:Bool = false;
	public var EMISSIVEFRESNEL:Bool = false;
	public var FRESNEL:Bool = false;
	public var NORMAL:Bool = false;
	public var TANGENT:Bool = false;
	public var UV1:Bool = false;
	public var UV2:Bool = false;
	public var VERTEXCOLOR:Bool = false;
	public var VERTEXALPHA:Bool = false;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	public var BonesPerMesh:Int = 0;
	public var INSTANCES:Bool = false;
	public var MICROSURFACEFROMREFLECTIVITYMAP:Bool = false;
	public var MICROSURFACEAUTOMATIC:Bool = false;
	public var EMISSIVEASILLUMINATION:Bool = false;
	public var LIGHTMAP:Bool = false;
	public var USELIGHTMAPASSHADOWMAP:Bool = false;
	public var REFLECTIONMAP_3D:Bool = false;
	public var REFLECTIONMAP_SPHERICAL:Bool = false;
	public var REFLECTIONMAP_PLANAR:Bool = false;
	public var REFLECTIONMAP_CUBIC:Bool = false;
	public var REFLECTIONMAP_PROJECTION:Bool = false;
	public var REFLECTIONMAP_SKYBOX:Bool = false;
	public var REFLECTIONMAP_EXPLICIT:Bool = false;
	public var REFLECTIONMAP_EQUIRECTANGULAR:Bool = false;
	public var REFLECTIONMAP_EQUIRECTANGULAR_FIXED:Bool = false;
	public var REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED:Bool = false;
	public var INVERTCUBICMAP:Bool = false;
	public var LOGARITHMICDEPTH:Bool = false;
	public var CAMERATONEMAP:Bool = false;
	public var CAMERACONTRAST:Bool = false;
	public var CAMERACOLORGRADING:Bool = false;
	public var CAMERACOLORCURVES:Bool = false;
	public var USESPHERICALFROMREFLECTIONMAP:Bool = false;
	public var REFRACTION:Bool = false;
	public var REFRACTIONMAP_3D:Bool = false;
	public var LINKREFRACTIONTOTRANSPARENCY:Bool = false;
	public var REFRACTIONMAPINLINEARSPACE:Bool = false;
	public var LODBASEDMICROSFURACE:Bool = false;
	public var USEPHYSICALLIGHTFALLOFF:Bool = false;
	public var RADIANCEOVERALPHA:Bool = false;
	public var USEPMREMREFLECTION:Bool = false;
	public var USEPMREMREFRACTION:Bool = false;
	public var INVERTNORMALMAPX:Bool = false;
	public var INVERTNORMALMAPY:Bool = false;
	public var TWOSIDEDLIGHTING:Bool = false;
	public var SHADOWFULLFLOAT:Bool = false;
	public var NORMALXYSCALE:Bool = true;
	public var USERIGHTHANDEDSYSTEM:Bool = false;

	public var METALLICWORKFLOW:Bool = false;
	public var METALLICMAP:Bool = false;
	public var ROUGHNESSSTOREINMETALMAPALPHA:Bool = false;
	public var ROUGHNESSSTOREINMETALMAPGREEN:Bool = false;
	public var METALLNESSSTOREINMETALMAPBLUE:Bool = false;
	public var AOSTOREINMETALMAPRED:Bool = false;
	public var MICROSURFACEMAP:Bool = false;

	public var MORPHTARGETS:Bool = false;
	public var MORPHTARGETS_NORMAL:Bool = false;
	public var MORPHTARGETS_TANGENT:Bool = false;
	public var NUM_MORPH_INFLUENCERS:Int = 0;
	
	public var ALPHATESTVALUE:Float = 0.4;
	public var LDROUTPUT:Bool = true;
	

	public function new() {
		super();
	}
	
}
