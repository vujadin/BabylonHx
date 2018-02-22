package com.babylonhx.materials.pbr;

import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialDefines extends MaterialDefines implements IImageProcessingConfigurationDefines {
	
	static inline var _flagsCount:Int = 110;
	
	var _flags:UInt8Array = new UInt8Array(_flagsCount);
	
	public var PBR:Bool = true;

	public var MAINUV1:Int;
	public var MAINUV2:Int;
	public var UV1:Int;
	public var UV2:Int;

	public var ALBEDO:Int;
	public var ALBEDODIRECTUV:Int;
	public var VERTEXCOLOR:Int;

	public var AMBIENT:Int;
	public var AMBIENTDIRECTUV:Int;
	public var AMBIENTINGRAYSCALE:Int;

	public var OPACITY:Int;
	public var VERTEXALPHA:Int;
	public var OPACITYDIRECTUV:Int;
	public var OPACITYRGB:Int;
	public var ALPHATEST:Int;
	public var DEPTHPREPASS:Int;
	public var ALPHABLEND:Int;
	public var ALPHAFROMALBEDO:Int;
	public var ALPHATESTVALUE:Float = 0.5;
	public var SPECULAROVERALPHA:Int;
	public var RADIANCEOVERALPHA:Int;
	public var ALPHAFRESNEL:Int;
	public var LINEARALPHAFRESNEL:Int;
	public var PREMULTIPLYALPHA:Int;

	public var EMISSIVE:Int;
	public var EMISSIVEDIRECTUV:Int;

	public var REFLECTIVITY:Int;
	public var REFLECTIVITYDIRECTUV:Int;
	public var SPECULARTERM:Int;

	public var MICROSURFACEFROMREFLECTIVITYMAP:Int;
	public var MICROSURFACEAUTOMATIC:Int;
	public var LODBASEDMICROSFURACE:Int;
	public var MICROSURFACEMAP:Int;
	public var MICROSURFACEMAPDIRECTUV:Int;

	public var METALLICWORKFLOW:Int;
	public var ROUGHNESSSTOREINMETALMAPALPHA:Int;
	public var ROUGHNESSSTOREINMETALMAPGREEN:Int;
	public var METALLNESSSTOREINMETALMAPBLUE:Int;
	public var AOSTOREINMETALMAPRED:Int;
	public var ENVIRONMENTBRDF:Int;

	public var NORMAL:Int;
	public var TANGENT:Int;
	public var BUMP:Int;
	public var BUMPDIRECTUV:Int;
	public var OBJECTSPACE_NORMALMAP:Int;
	public var PARALLAX:Int;
	public var PARALLAXOCCLUSION:Int;
	public var NORMALXYSCALE:Int;
	
	public var SHADOWS:Int;				// BHX

	public var LIGHTMAP:Int;
	public var LIGHTMAPDIRECTUV:Int;
	public var USELIGHTMAPASSHADOWMAP:Int;

	public var REFLECTION:Int;
	public var REFLECTIONMAP_3D:Int;
	public var REFLECTIONMAP_SPHERICAL:Int;
	public var REFLECTIONMAP_PLANAR:Int;
	public var REFLECTIONMAP_CUBIC:Int;
	public var USE_LOCAL_REFLECTIONMAP_CUBIC:Int;
	public var REFLECTIONMAP_PROJECTION:Int;
	public var REFLECTIONMAP_SKYBOX:Int;
	public var REFLECTIONMAP_EXPLICIT:Int;
	public var REFLECTIONMAP_EQUIRECTANGULAR:Int;
	public var REFLECTIONMAP_EQUIRECTANGULAR_FIXED:Int;
	public var REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED:Int;
	public var INVERTCUBICMAP:Int;
	public var USESPHERICALFROMREFLECTIONMAP:Int;
	public var USESPHERICALINVERTEX:Int;
	public var REFLECTIONMAP_OPPOSITEZ:Int;
	public var LODINREFLECTIONALPHA:Int;
	public var GAMMAREFLECTION:Int;
	public var RADIANCEOCCLUSION:Int;
    public var HORIZONOCCLUSION:Int;

	public var REFRACTION:Int;
	public var REFRACTIONMAP_3D:Int;
	public var REFRACTIONMAP_OPPOSITEZ:Int;
	public var LODINREFRACTIONALPHA:Int;
	public var GAMMAREFRACTION:Int;
	public var LINKREFRACTIONTOTRANSPARENCY:Int;

	public var INSTANCES:Int;
	
	public var NUM_BONE_INFLUENCERS:Int;
	public var BonesPerMesh:Int;
	
	public var NONUNIFORMSCALING:Int;

	public var MORPHTARGETS:Int;
	public var MORPHTARGETS_NORMAL:Int;
	public var MORPHTARGETS_TANGENT:Int;
	public var NUM_MORPH_INFLUENCERS:Int;

	public var IMAGEPROCESSING:Int;
	public var VIGNETTE:Int;
	public var VIGNETTEBLENDMODEMULTIPLY:Int;
	public var VIGNETTEBLENDMODEOPAQUE:Int;
	public var TONEMAPPING:Int;
	public var CONTRAST:Int;
	public var COLORCURVES:Int;
	public var COLORGRADING:Int;
	public var COLORGRADING3D:Int;
	public var SAMPLER3DGREENDEPTH:Int;
	public var SAMPLER3DBGRMAP:Int;
	public var IMAGEPROCESSINGPOSTPROCESS:Int;
	public var EXPOSURE:Int;

	public var USEPHYSICALLIGHTFALLOFF:Int;
	public var TWOSIDEDLIGHTING:Int;
	public var SHADOWFLOAT:Int;
	public var USERIGHTHANDEDSYSTEM:Int;
	public var CLIPPLANE:Int;
	public var POINTSIZE:Int;
	public var FOG:Int;
	public var LOGARITHMICDEPTH:Int;

	public var FORCENORMALFORWARD:Int;
	
	// BHX: reqired by IImageProcessingConfigurationDefines
	public var FROMLINEARSPACE:Int;
	

	public function new() {
		super();
		
		for (i in 0..._flagsCount) {
			_flags[i] = 0;
		}
		
		this.MAINUV1 = _flags[0];
		this.MAINUV2 = _flags[1];
		this.UV1 = _flags[2];
		this.UV2 = _flags[3];
		
		this.ALBEDO = _flags[4];
		this.ALBEDODIRECTUV = _flags[5];
		this.VERTEXCOLOR = _flags[6];
		
		this.AMBIENT = _flags[7];
		this.AMBIENTDIRECTUV = _flags[8];
		this.AMBIENTINGRAYSCALE = _flags[9];
		
		this.OPACITY = _flags[10];
		this.VERTEXALPHA = _flags[11];
		this.OPACITYDIRECTUV = _flags[12];
		this.OPACITYRGB = _flags[13];
		this.ALPHATEST = _flags[14];
		this.DEPTHPREPASS = _flags[15];
		this.ALPHABLEND = _flags[16];
		this.ALPHAFROMALBEDO = _flags[17];
		this.ALPHATESTVALUE = 0.5;
		this.SPECULAROVERALPHA = _flags[18];
		this.RADIANCEOVERALPHA = _flags[19];
		this.ALPHAFRESNEL = _flags[20];
		this.LINEARALPHAFRESNEL = _flags[21];
		this.PREMULTIPLYALPHA = _flags[22];
		
		this.EMISSIVE = _flags[23];
		this.EMISSIVEDIRECTUV = _flags[24];
		
		this.REFLECTIVITY = _flags[25];
		this.REFLECTIVITYDIRECTUV = _flags[26];
		this.SPECULARTERM = _flags[27];
		
		this.MICROSURFACEFROMREFLECTIVITYMAP = _flags[28];
		this.MICROSURFACEAUTOMATIC = _flags[29];
		this.LODBASEDMICROSFURACE = _flags[30];
		this.MICROSURFACEMAP = _flags[31];
		this.MICROSURFACEMAPDIRECTUV = _flags[32];
		
		this.METALLICWORKFLOW = _flags[33];
		this.ROUGHNESSSTOREINMETALMAPALPHA = _flags[34];
		this.ROUGHNESSSTOREINMETALMAPGREEN = _flags[35];
		this.METALLNESSSTOREINMETALMAPBLUE = _flags[36];
		this.AOSTOREINMETALMAPRED = _flags[37];
		this.ENVIRONMENTBRDF = _flags[38];
		
		this.NORMAL = _flags[39];
		this.TANGENT = _flags[40];
		this.BUMP = _flags[41];
		this.BUMPDIRECTUV = _flags[42];
		this.OBJECTSPACE_NORMALMAP = _flags[43];
		this.PARALLAX = _flags[44];
		this.PARALLAXOCCLUSION = _flags[45];
		this.NORMALXYSCALE = _flags[46] = 1;		// true by default
		
		this.SHADOWS = _flags[47];				// BHX
		
		this.LIGHTMAP = _flags[48];
		this.LIGHTMAPDIRECTUV = _flags[49];
		this.USELIGHTMAPASSHADOWMAP = _flags[50];
		
		this.REFLECTION = _flags[51];
		this.REFLECTIONMAP_3D = _flags[52];
		this.REFLECTIONMAP_SPHERICAL = _flags[53];
		this.REFLECTIONMAP_PLANAR = _flags[54];
		this.REFLECTIONMAP_CUBIC = _flags[55];
		this.USE_LOCAL_REFLECTIONMAP_CUBIC = _flags[56];
		this.REFLECTIONMAP_PROJECTION = _flags[57];
		this.REFLECTIONMAP_SKYBOX = _flags[58];
		this.REFLECTIONMAP_EXPLICIT = _flags[59];
		this.REFLECTIONMAP_EQUIRECTANGULAR = _flags[60];
		this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = _flags[61];
		this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = _flags[62];
		this.INVERTCUBICMAP = _flags[63];
		this.USESPHERICALFROMREFLECTIONMAP = _flags[64];
		this.USESPHERICALINVERTEX = _flags[65];
		this.REFLECTIONMAP_OPPOSITEZ = _flags[66];
		this.LODINREFLECTIONALPHA = _flags[67];
		this.GAMMAREFLECTION = _flags[68];
		this.RADIANCEOCCLUSION = _flags[69];
		this.HORIZONOCCLUSION = _flags[70];
		
		this.REFRACTION = _flags[71];
		this.REFRACTIONMAP_3D = _flags[72];
		this.REFRACTIONMAP_OPPOSITEZ = _flags[73];
		this.LODINREFRACTIONALPHA = _flags[74];
		this.GAMMAREFRACTION = _flags[75];
		this.LINKREFRACTIONTOTRANSPARENCY = _flags[76];
		
		this.INSTANCES = _flags[77];
		
		this.NUM_BONE_INFLUENCERS = _flags[78];
		this.BonesPerMesh = _flags[79];
		
		this.NONUNIFORMSCALING = _flags[80];
		
		this.MORPHTARGETS = _flags[81];
		this.MORPHTARGETS_NORMAL = _flags[82];
		this.MORPHTARGETS_TANGENT = _flags[83];
		this.NUM_MORPH_INFLUENCERS = _flags[84];
		
		this.IMAGEPROCESSING = _flags[85];
		this.VIGNETTE = _flags[86];
		this.VIGNETTEBLENDMODEMULTIPLY = _flags[87];
		this.VIGNETTEBLENDMODEOPAQUE = _flags[88];
		this.TONEMAPPING = _flags[89];
		this.CONTRAST = _flags[90];
		this.COLORCURVES = _flags[91];
		this.COLORGRADING = _flags[92];
		this.COLORGRADING3D = _flags[93];
		this.SAMPLER3DGREENDEPTH = _flags[94];
		this.SAMPLER3DBGRMAP = _flags[95];
		this.IMAGEPROCESSINGPOSTPROCESS = _flags[96];
		this.EXPOSURE = _flags[97];
		
		this.USEPHYSICALLIGHTFALLOFF = _flags[98];
		this.TWOSIDEDLIGHTING = _flags[99];
		this.SHADOWFLOAT = _flags[100];
		this.USERIGHTHANDEDSYSTEM = _flags[101];
		this.CLIPPLANE = _flags[102];
		this.POINTSIZE = _flags[103];
		this.FOG = _flags[104];
		this.LOGARITHMICDEPTH = _flags[105];
		
		this.FORCENORMALFORWARD = _flags[106];
		
		// BHX: reqired by IImageProcessingConfigurationDefines
		this.FROMLINEARSPACE = _flags[107];
	}
	
	override public function reset() {
		super.reset();
		
		this.PBR = true;
		
		for (i in 0..._flagsCount) {
			_flags[i] = 0;
		}
		
		this.ALPHATESTVALUE = 0.5;
		
		this.NORMALXYSCALE = 1;
		
	}
	
	public function setReflectionMode(modeToEnable:String) {		
		switch (modeToEnable) {
			case "REFLECTIONMAP_CUBIC":
				this.REFLECTIONMAP_CUBIC = 1;
				
			case "USE_LOCAL_REFLECTIONMAP_CUBIC":
				this.USE_LOCAL_REFLECTIONMAP_CUBIC = 1;
				
			case "REFLECTIONMAP_EXPLICIT":
				this.REFLECTIONMAP_EXPLICIT = 1;
				
			case "REFLECTIONMAP_PLANAR":
				this.REFLECTIONMAP_PLANAR = 1;
				
			case "REFLECTIONMAP_3D":
				this.REFLECTIONMAP_3D = 1;
				
			case "REFLECTIONMAP_PROJECTION":
				this.REFLECTIONMAP_PROJECTION = 1;
				
			case "REFLECTIONMAP_SKYBOX":
				this.REFLECTIONMAP_SKYBOX = 1;
				
			case "REFLECTIONMAP_SPHERICAL":
				this.REFLECTIONMAP_SPHERICAL = 1;
				
			case "REFLECTIONMAP_EQUIRECTANGULAR":
				this.REFLECTIONMAP_EQUIRECTANGULAR = 1;
				
			case "REFLECTIONMAP_EQUIRECTANGULAR_FIXED":
				this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = 1;
				
			case "REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED":
				this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = 1;
		}
	}
	
	override public function isEqual(other:MaterialDefines):Bool {
		if (super.isEqual(other)) {
			if (untyped this.PBR != other.PBR) return false;
			
			var len = _flags.length;
			for (i in 0...len) {
				if (this._flags[i] != untyped other._flags[i]) {
					return false;
				}
			}
			
			if (untyped this.ALPHATESTVALUE != other.ALPHATESTVALUE) return false;
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.PBR = this.PBR;
		untyped other.ALPHATESTVALUE = this.ALPHATESTVALUE;
		
		var len = _flags.length;
		for (i in 0...len) {
			untyped other._flags[i] = this._flags[i];
		}
	}
	
	override public function toString():String {
		var result = "";
		
		var sb:StringBuf = new StringBuf();
		sb.add(super.toString());
		
		if (this.PBR) {
			sb.add("#define PBR \n");
		}
		
		if (this.MAINUV1 != 0) {
			sb.add("#define MAINUV1 \n");
		}
		if (this.MAINUV2 != 0) {
			sb.add("#define MAINUV2 \n");
		}
		if (this.UV1 != 0) {
			sb.add("#define UV1 \n");
		}
		if (this.UV2 != 0) {
			sb.add("#define UV2 \n");
		}
		
		if (this.SHADOWS != 0) {
			sb.add("#define SHADOWS \n");
		}
		
		if (this.ALBEDO != 0) {
			sb.add("#define ALBEDO \n");
		}
		sb.add("#define ALBEDODIRECTUV " + this.ALBEDODIRECTUV + " \n");
		if (this.VERTEXCOLOR != 0) {
			sb.add("#define VERTEXCOLOR \n");
		}
		
		if (this.AMBIENT != 0) {
			sb.add("#define AMBIENT \n");
		}
		sb.add("#define AMBIENTDIRECTUV " + this.AMBIENTDIRECTUV + " \n");
		if (this.AMBIENTINGRAYSCALE != 0) {
			sb.add("#define AMBIENTINGRAYSCALE \n");
		}
		
		if (this.OPACITY != 0) {
			sb.add("#define OPACITY \n");
		}
		if (this.VERTEXALPHA != 0) {
			sb.add("#define VERTEXALPHA \n");
		}
		sb.add("#define OPACITYDIRECTUV " + this.OPACITYDIRECTUV + " \n");
		if (this.OPACITYRGB != 0) {
			sb.add("#define OPACITYRGB \n");
		}
		if (this.ALPHATEST != 0) {
			sb.add("#define ALPHATEST \n");
		}
		if (this.DEPTHPREPASS != 0) {
			sb.add("#define DEPTHPREPASS \n");
		}
		if (this.ALPHABLEND != 0) {
			sb.add("#define ALPHABLEND \n");
		}
		if (this.ALPHAFROMALBEDO != 0) {
			sb.add("#define ALPHAFROMALBEDO \n");
		}
		sb.add("#define ALPHATESTVALUE " + this.ALPHATESTVALUE + " \n");
		if (this.SPECULAROVERALPHA != 0) {
			sb.add("#define SPECULAROVERALPHA \n");
		}
		if (this.RADIANCEOVERALPHA != 0) {
			sb.add("#define RADIANCEOVERALPHA \n");
		}
		if (this.ALPHAFRESNEL != 0) {
			sb.add("#define ALPHAFRESNEL \n");
		}
		if (this.LINEARALPHAFRESNEL != 0) {
			sb.add("#define LINEARALPHAFRESNEL \n");
		}
		if (this.PREMULTIPLYALPHA != 0) {
			sb.add("#define PREMULTIPLYALPHA \n");
		}
		
		if (this.EMISSIVE != 0) {
			sb.add("#define EMISSIVE \n");
		}
		sb.add("#define EMISSIVEDIRECTUV " + this.EMISSIVEDIRECTUV + " \n");
		
		if (this.REFLECTIVITY != 0) {
			sb.add("#define REFLECTIVITY \n");
		}
		sb.add("#define REFLECTIVITYDIRECTUV " + this.REFLECTIVITYDIRECTUV + " \n");
		if (this.SPECULARTERM != 0) {
			sb.add("#define SPECULARTERM \n");
		}
		
		if (this.MICROSURFACEFROMREFLECTIVITYMAP != 0) {
			sb.add("#define MICROSURFACEFROMREFLECTIVITYMAP \n");
		}
		if (this.MICROSURFACEAUTOMATIC != 0) {
			sb.add("#define MICROSURFACEAUTOMATIC \n");
		}
		if (this.LODBASEDMICROSFURACE != 0) {
			sb.add("#define LODBASEDMICROSFURACE \n");
		}
		if (this.MICROSURFACEMAP != 0) {
			sb.add("#define MICROSURFACEMAP \n");
		}
		sb.add("#define MICROSURFACEMAPDIRECTUV " + this.MICROSURFACEMAPDIRECTUV + " \n");
		
		if (this.METALLICWORKFLOW != 0) {
			sb.add("#define METALLICWORKFLOW \n");
		}
		if (this.ROUGHNESSSTOREINMETALMAPALPHA != 0) {
			sb.add("#define ROUGHNESSSTOREINMETALMAPALPHA \n");
		}
		if (this.ROUGHNESSSTOREINMETALMAPGREEN != 0) {
			sb.add("#define ROUGHNESSSTOREINMETALMAPGREEN \n");
		}
		if (this.METALLNESSSTOREINMETALMAPBLUE != 0) {
			sb.add("#define METALLNESSSTOREINMETALMAPBLUE \n");
		}
		if (this.AOSTOREINMETALMAPRED != 0) {
			sb.add("#define AOSTOREINMETALMAPRED \n");
		}
		if (this.ENVIRONMENTBRDF != 0) {
			sb.add("#define ENVIRONMENTBRDF \n");
		}
		
		if (this.NORMAL != 0) {
			sb.add("#define NORMAL \n");
		}
		if (this.TANGENT != 0) {
			sb.add("#define TANGENT \n");
		}
		if (this.BUMP != 0) {
			sb.add("#define BUMP \n");
		}
		sb.add("#define BUMPDIRECTUV " + this.BUMPDIRECTUV + " \n");
		if (this.OBJECTSPACE_NORMALMAP != 0) {
			sb.add("#define OBJECTSPACE_NORMALMAP \n");
		}
		if (this.PARALLAX != 0) {
			sb.add("#define PARALLAX \n");
		}
		if (this.PARALLAXOCCLUSION != 0) {
			sb.add("#define PARALLAXOCCLUSION \n");
		}
		if (this.NORMALXYSCALE != 0) {
			sb.add("#define NORMALXYSCALE \n");
		}
		
		if (this.LIGHTMAP != 0) {
			sb.add("#define LIGHTMAP \n");
		}
		sb.add("#define LIGHTMAPDIRECTUV " + this.LIGHTMAPDIRECTUV + " \n");
		if (this.USELIGHTMAPASSHADOWMAP != 0) {
			sb.add("#define USELIGHTMAPASSHADOWMAP \n");
		}
		
		if (this.REFLECTION != 0) {
			sb.add("#define REFLECTION \n");
		}
		if (this.REFLECTIONMAP_3D != 0) {
			sb.add("#define REFLECTIONMAP_3D \n");
		}
		if (this.REFLECTIONMAP_SPHERICAL != 0) {
			sb.add("#define REFLECTIONMAP_SPHERICAL \n");
		}
		if (this.REFLECTIONMAP_PLANAR != 0) {
			sb.add("#define REFLECTIONMAP_PLANAR \n");
		}
		if (this.REFLECTIONMAP_CUBIC != 0) {
			sb.add("#define REFLECTIONMAP_CUBIC \n");
		}
		if (this.USE_LOCAL_REFLECTIONMAP_CUBIC != 0) {
			sb.add("#define USE_LOCAL_REFLECTIONMAP_CUBIC \n");
		}
		if (this.REFLECTIONMAP_PROJECTION != 0) {
			sb.add("#define REFLECTIONMAP_PROJECTION \n");
		}
		if (this.REFLECTIONMAP_SKYBOX != 0) {
			sb.add("#define REFLECTIONMAP_SKYBOX \n");
		}
		if (this.REFLECTIONMAP_EXPLICIT != 0) {
			sb.add("#define REFLECTIONMAP_EXPLICIT \n");
		}
		if (this.REFLECTIONMAP_EQUIRECTANGULAR != 0) {
			sb.add("#define REFLECTIONMAP_EQUIRECTANGULAR \n");
		}
		if (this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED != 0) {
			sb.add("#define REFLECTIONMAP_EQUIRECTANGULAR_FIXED \n");
		}
		if (this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED != 0) {
			sb.add("#define REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED \n");
		}
		if (this.INVERTCUBICMAP != 0) {
			sb.add("#define INVERTCUBICMAP \n");
		}
		if (this.USESPHERICALFROMREFLECTIONMAP != 0) {
			sb.add("#define USESPHERICALFROMREFLECTIONMAP \n");
		}
		if (this.USESPHERICALINVERTEX != 0) {
			sb.add("#define USESPHERICALINVERTEX \n");
		}
		if (this.REFLECTIONMAP_OPPOSITEZ != 0) {
			sb.add("#define REFLECTIONMAP_OPPOSITEZ \n");
		}
		if (this.LODINREFLECTIONALPHA != 0) {
			sb.add("#define LODINREFLECTIONALPHA \n");
		}
		if (this.GAMMAREFLECTION != 0) {
			sb.add("#define GAMMAREFLECTION \n");
		}
		if (this.RADIANCEOCCLUSION != 0) {
			sb.add("#define RADIANCEOCCLUSION \n");
		}
		if (this.HORIZONOCCLUSION != 0) {
			sb.add("#define HORIZONOCCLUSION \n");
		}
		
		if (this.REFRACTION != 0) {
			sb.add("#define REFRACTION \n");
		}
		if (this.REFRACTIONMAP_3D != 0) {
			sb.add("#define REFRACTIONMAP_3D \n");
		}
		if (this.REFRACTIONMAP_OPPOSITEZ != 0) {
			sb.add("#define REFRACTIONMAP_OPPOSITEZ \n");
		}
		if (this.LODINREFRACTIONALPHA != 0) {
			sb.add("#define LODINREFRACTIONALPHA \n");
		}
		if (this.GAMMAREFRACTION != 0) {
			sb.add("#define GAMMAREFRACTION \n");
		}
		if (this.LINKREFRACTIONTOTRANSPARENCY != 0) {
			sb.add("#define LINKREFRACTIONTOTRANSPARENCY \n");
		}
		
		if (this.INSTANCES != 0) {
			sb.add("#define INSTANCES \n");
		}
		
		sb.add("#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + " \n");
		sb.add("#define BonesPerMesh " + this.BonesPerMesh + " \n");
		
		if (this.NONUNIFORMSCALING != 0) {
			sb.add("#define NONUNIFORMSCALING \n");
		}
		
		if (this.MORPHTARGETS != 0) {
			sb.add("#define MORPHTARGETS \n");
		}
		if (this.MORPHTARGETS_NORMAL != 0) {
			sb.add("#define MORPHTARGETS_NORMAL \n");
		}
		if (this.MORPHTARGETS_TANGENT != 0) {
			sb.add("#define MORPHTARGETS_TANGENT \n");
		}
		sb.add("#define NUM_MORPH_INFLUENCERS " + this.NUM_MORPH_INFLUENCERS + " \n");
		
		if (this.IMAGEPROCESSING != 0) {
			sb.add("#define IMAGEPROCESSING \n");
		}
		if (this.VIGNETTE != 0) {
			sb.add("#define VIGNETTE \n");
		}
		if (this.VIGNETTEBLENDMODEMULTIPLY != 0) {
			sb.add("#define VIGNETTEBLENDMODEMULTIPLY \n");
		}
		if (this.VIGNETTEBLENDMODEOPAQUE != 0) {
			sb.add("#define VIGNETTEBLENDMODEOPAQUE \n");
		}
		if (this.TONEMAPPING != 0) {
			sb.add("#define TONEMAPPING \n");
		}
		if (this.CONTRAST != 0) {
			sb.add("#define CONTRAST \n");
		}
		if (this.COLORCURVES != 0) {
			sb.add("#define COLORCURVES \n");
		}
		if (this.COLORGRADING != 0) {
			sb.add("#define COLORGRADING \n");
		}
		if (this.COLORGRADING3D != 0) {
			sb.add("#define COLORGRADING3D \n");
		}
		if (this.SAMPLER3DGREENDEPTH != 0) {
			sb.add("#define SAMPLER3DGREENDEPTH \n");
		}
		if (this.SAMPLER3DBGRMAP != 0) {
			sb.add("#define SAMPLER3DBGRMAP \n");
		}
		if (this.IMAGEPROCESSINGPOSTPROCESS != 0) {
			sb.add("#define IMAGEPROCESSINGPOSTPROCESS \n");
		}
		if (this.EXPOSURE != 0) {
			sb.add("#define EXPOSURE \n");
		}
		
		if (this.USEPHYSICALLIGHTFALLOFF != 0) {
			sb.add("#define USEPHYSICALLIGHTFALLOFF \n");
		}
		if (this.TWOSIDEDLIGHTING != 0) {
			sb.add("#define TWOSIDEDLIGHTING \n");
		}
		if (this.SHADOWFLOAT != 0) {
			sb.add("#define SHADOWFLOAT \n");
		}
		if (this.CLIPPLANE != 0) {
			sb.add("#define CLIPPLANE \n");
		}
		if (this.POINTSIZE != 0) {
			sb.add("#define POINTSIZE \n");
		}
		if (this.FOG != 0) {
			sb.add("#define FOG \n");
		}
		if (this.LOGARITHMICDEPTH != 0) {
			sb.add("#define LOGARITHMICDEPTH \n");
		}
		
		if (this.FORCENORMALFORWARD != 0) {
			sb.add("#define FORCENORMALFORWARD \n");
		}
		
		result = sb.toString();
		
		return result;
	}
	
}
