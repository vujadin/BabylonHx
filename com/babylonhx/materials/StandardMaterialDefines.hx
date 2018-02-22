package com.babylonhx.materials;

import com.babylonhx.utils.typedarray.UInt8Array;

/**
 * ...
 * @author Krtolica Vujadin
 */
 
class StandardMaterialDefines extends MaterialDefines implements IImageProcessingConfigurationDefines {
	
	static inline var _flagsCount:Int = 100;
	
	var _flags:UInt8Array = new UInt8Array(_flagsCount);
	
	public var MAINUV1:Int;
	public var MAINUV2:Int;
	public var DIFFUSE:Int;
	public var DIFFUSEDIRECTUV:Int;
	public var AMBIENT:Int;
	public var AMBIENTDIRECTUV:Int;
	public var OPACITY:Int;
	public var OPACITYDIRECTUV:Int;
	public var OPACITYRGB:Int;
	public var REFLECTION:Int;
	public var EMISSIVE:Int;
	public var EMISSIVEDIRECTUV:Int;
	public var SPECULAR:Int;
	public var SPECULARDIRECTUV:Int;
	public var BUMP:Int;
	public var BUMPDIRECTUV:Int;
	public var PARALLAX:Int;
	public var PARALLAXOCCLUSION:Int;
	public var SPECULAROVERALPHA:Int;
	public var CLIPPLANE:Int;
	public var ALPHATEST:Int;
	public var DEPTHPREPASS:Int;
	public var ALPHAFROMDIFFUSE:Int;
	public var POINTSIZE:Int;
	public var FOG:Int;
	public var SPECULARTERM:Int;
	public var SHADOWS:Int;				// BHX
	//public var SHADOWFULLFLOAT:Int;		// BHX
	public var DIFFUSEFRESNEL:Int;
	public var OPACITYFRESNEL:Int;
	public var REFLECTIONFRESNEL:Int;
	public var REFRACTIONFRESNEL:Int;
	public var EMISSIVEFRESNEL:Int;
	public var FRESNEL:Int;
	public var NORMAL:Int;
	public var UV1:Int;
	public var UV2:Int;
	public var VERTEXCOLOR:Int;
	public var VERTEXALPHA:Int;
	public var NUM_BONE_INFLUENCERS:Int;
	public var BonesPerMesh:Int;
	public var INSTANCES:Int;
	public var GLOSSINESS:Int;
	public var ROUGHNESS:Int;
	public var EMISSIVEASILLUMINATION:Int;
	public var LINKEMISSIVEWITHDIFFUSE:Int;
	public var REFLECTIONFRESNELFROMSPECULAR:Int;
	public var LIGHTMAP:Int;
	public var LIGHTMAPDIRECTUV:Int;
	public var OBJECTSPACE_NORMALMAP:Int;
	public var USELIGHTMAPASSHADOWMAP:Int;
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
	public var LOGARITHMICDEPTH:Int;
	public var REFRACTION:Int;
	public var REFRACTIONMAP_3D:Int;
	public var REFLECTIONOVERALPHA:Int;
	public var TWOSIDEDLIGHTING:Int;
	public var SHADOWFLOAT:Int;
	public var MORPHTARGETS:Int;
	public var MORPHTARGETS_NORMAL:Int;
	public var MORPHTARGETS_TANGENT:Int;
	public var NUM_MORPH_INFLUENCERS:Int;
	public var NONUNIFORMSCALING:Int;
	public var PREMULTIPLYALPHA:Int;

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
	
	public var FROMLINEARSPACE:Int;	// BHX: not used - needed because of IImageProcessingConfigurationDefines
	
	
	public function new() {
		super();
		
		for (i in 0..._flagsCount) {
			_flags[i] = 0;
		}
		
		this.MAINUV1 = _flags[0];
		this.MAINUV2 = _flags[1];
		this.DIFFUSE = _flags[2];
		this.DIFFUSEDIRECTUV = _flags[3];
		this.AMBIENT = _flags[4];
		this.AMBIENTDIRECTUV = _flags[5];
		this.OPACITY = _flags[6];
		this.OPACITYDIRECTUV = _flags[7];
		this.OPACITYRGB = _flags[8];
		this.REFLECTION = _flags[9];
		this.EMISSIVE = _flags[10];
		this.EMISSIVEDIRECTUV = _flags[11];
		this.SPECULAR = _flags[12];
		this.SPECULARDIRECTUV = _flags[13];
		this.BUMP = _flags[14];
		this.BUMPDIRECTUV = _flags[15];
		this.PARALLAX = _flags[16];
		this.PARALLAXOCCLUSION = _flags[17];
		this.SPECULAROVERALPHA = _flags[18];
		this.CLIPPLANE = _flags[19];
		this.ALPHATEST = _flags[20];
		this.DEPTHPREPASS = _flags[21];
		this.ALPHAFROMDIFFUSE = _flags[22];
		this.POINTSIZE = _flags[23];
		this.FOG = _flags[24];
		this.SPECULARTERM = _flags[25];
		this.SHADOWS = _flags[26];				// BHX
		//this.SHADOWFULLFLOAT = _flags[0];		// BHX
		this.DIFFUSEFRESNEL = _flags[27];
		this.OPACITYFRESNEL = _flags[28];
		this.REFLECTIONFRESNEL = _flags[29];
		this.REFRACTIONFRESNEL = _flags[30];
		this.EMISSIVEFRESNEL = _flags[31];
		this.FRESNEL = _flags[32];
		this.NORMAL = _flags[33];
		this.UV1 = _flags[34];
		this.UV2 = _flags[35];
		this.VERTEXCOLOR = _flags[36];
		this.VERTEXALPHA = _flags[37];
		this.NUM_BONE_INFLUENCERS = _flags[38];
		this.BonesPerMesh = _flags[39];
		this.INSTANCES = _flags[40];
		this.GLOSSINESS = _flags[41];
		this.ROUGHNESS = _flags[42];
		this.EMISSIVEASILLUMINATION = _flags[43];
		this.LINKEMISSIVEWITHDIFFUSE = _flags[44];
		this.REFLECTIONFRESNELFROMSPECULAR = _flags[45];
		this.LIGHTMAP = _flags[46];
		this.LIGHTMAPDIRECTUV = _flags[47];
		this.OBJECTSPACE_NORMALMAP = _flags[48];
		this.USELIGHTMAPASSHADOWMAP = _flags[49];
		this.REFLECTIONMAP_3D = _flags[50];
		this.REFLECTIONMAP_SPHERICAL = _flags[51];
		this.REFLECTIONMAP_PLANAR = _flags[52];
		this.REFLECTIONMAP_CUBIC = _flags[53];
		this.USE_LOCAL_REFLECTIONMAP_CUBIC = _flags[54];
		this.REFLECTIONMAP_PROJECTION = _flags[55];
		this.REFLECTIONMAP_SKYBOX = _flags[56];
		this.REFLECTIONMAP_EXPLICIT = _flags[57];
		this.REFLECTIONMAP_EQUIRECTANGULAR = _flags[58];
		this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = _flags[59];
		this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = _flags[60];
		this.INVERTCUBICMAP = _flags[61];
		this.LOGARITHMICDEPTH = _flags[62];
		this.REFRACTION = _flags[63];
		this.REFRACTIONMAP_3D = _flags[64];
		this.REFLECTIONOVERALPHA = _flags[65];
		this.TWOSIDEDLIGHTING = _flags[66];
		this.SHADOWFLOAT = _flags[67];
		this.MORPHTARGETS = _flags[68];
		this.MORPHTARGETS_NORMAL = _flags[69];
		this.MORPHTARGETS_TANGENT = _flags[70];
		this.NUM_MORPH_INFLUENCERS = _flags[71];
		this.NONUNIFORMSCALING = _flags[72];
		this.PREMULTIPLYALPHA = _flags[73];

		this.IMAGEPROCESSING = _flags[74];
		this.VIGNETTE = _flags[75];
		this.VIGNETTEBLENDMODEMULTIPLY = _flags[76];
		this.VIGNETTEBLENDMODEOPAQUE = _flags[77];
		this.TONEMAPPING = _flags[78];
		this.CONTRAST = _flags[79];
		this.COLORCURVES = _flags[80];
		this.COLORGRADING = _flags[81];
		this.COLORGRADING3D = _flags[82];
		this.SAMPLER3DGREENDEPTH = _flags[83];
		this.SAMPLER3DBGRMAP = _flags[84];
		this.IMAGEPROCESSINGPOSTPROCESS = _flags[85];
		this.EXPOSURE = _flags[86];
		
		this.FROMLINEARSPACE = _flags[87];	// BHX: not used - needed because of IImageProcessingConfigurationDefines
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
			var len = _flags.length;
			for (i in 0...len) {
				if (this._flags[i] != untyped other._flags[i]) {
					return false;
				}
			}
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		var len = _flags.length;
		for (i in 0...len) {
			untyped other._flags[i] = this._flags[i];
		}
	}
	
	override public function reset() {
		super.reset();
		
		for (i in 0..._flagsCount) {
			_flags[i] = 0;
		}
	}

	override public function toString():String {
		var result = "";
		
		var sb:StringBuf = new StringBuf();
		sb.add(super.toString());
		
		if (this.MAINUV1 != 0) {
			sb.add("#define MAINUV1 \n");
		}
		if (this.MAINUV2 != 0) {
			sb.add("#define MAINUV2 \n");
		}
		if (this.DIFFUSE != 0) {
			sb.add("#define DIFFUSE \n");
		}
		if (this.AMBIENT != 0) {
			sb.add("#define AMBIENT \n");
		}
		if (this.OPACITY != 0) {
			sb.add("#define OPACITY \n");
		}
		if (this.OPACITYRGB != 0) {
			sb.add("#define OPACITYRGB \n");
		}
		if (this.REFLECTION != 0) {
			sb.add("#define REFLECTION \n");
		}
		if (this.EMISSIVE != 0) {
			sb.add("#define EMISSIVE \n");
		}
		if (this.SPECULAR != 0) {
			sb.add("#define SPECULAR \n");
		}
		if (this.BUMP != 0) {
			sb.add("#define BUMP \n");
		}
		if (this.PARALLAX != 0) {
			sb.add("#define PARALLAX \n");
		}
		if (this.PARALLAXOCCLUSION != 0) {
			sb.add("#define PARALLAXOCCLUSION \n");
		}
		if (this.SPECULAROVERALPHA != 0) {
			sb.add("#define SPECULAROVERALPHA \n");
		}
		if (this.CLIPPLANE != 0) {
			sb.add("#define CLIPPLANE \n");
		}
		if (this.ALPHATEST != 0) {
			sb.add("#define ALPHATEST \n");
		}
		if (this.DEPTHPREPASS != 0) {
			sb.add("#define DEPTHPREPASS \n");
		}
		if (this.ALPHAFROMDIFFUSE != 0) {
			sb.add("#define ALPHAFROMDIFFUSE \n");
		}
		if (this.POINTSIZE != 0) {
			sb.add("#define POINTSIZE \n");
		}
		if (this.FOG != 0) {
			sb.add("#define FOG \n");
		}
		if (this.SPECULARTERM != 0) {
			sb.add("#define SPECULARTERM \n");
		}
		if (this.SHADOWS != 0) {
			sb.add("#define SHADOWS \n");
		}
		if (this.DIFFUSEFRESNEL != 0) {
			sb.add("#define DIFFUSEFRESNEL \n");
		}
		if (this.OPACITYFRESNEL != 0) {
			sb.add("#define OPACITYFRESNEL \n");
		}
		if (this.REFLECTIONFRESNEL != 0) {
			sb.add("#define REFLECTIONFRESNEL \n");
		}
		if (this.REFRACTIONFRESNEL != 0) {
			sb.add("#define REFRACTIONFRESNEL \n");
		}
		if (this.EMISSIVEFRESNEL != 0) {
			sb.add("#define EMISSIVEFRESNEL \n");
		}
		if (this.FRESNEL != 0) {
			sb.add("#define FRESNEL \n");
		}
		if (this.NORMAL != 0) {
			sb.add("#define NORMAL \n");
		}
		if (this.UV1 != 0) {
			sb.add("#define UV1 \n");
		}
		if (this.UV2 != 0) {
			sb.add("#define UV2 \n");
		}
		if (this.VERTEXCOLOR != 0) {
			sb.add("#define VERTEXCOLOR \n");
		}
		if (this.VERTEXALPHA != 0) {
			sb.add("#define VERTEXALPHA \n");
		}
		if (this.INSTANCES != 0) {
			sb.add("#define INSTANCES \n");
		}
		if (this.GLOSSINESS != 0) {
			sb.add("#define GLOSSINESS \n");
		}
		if (this.ROUGHNESS != 0) {
			sb.add("#define ROUGHNESS \n");
		}
		if (this.EMISSIVEASILLUMINATION != 0) {
			sb.add("#define EMISSIVEASILLUMINATION \n");
		}
		if (this.LINKEMISSIVEWITHDIFFUSE != 0) {
			sb.add("#define LINKEMISSIVEWITHDIFFUSE \n");
		}
		if (this.REFLECTIONFRESNELFROMSPECULAR != 0) {
			sb.add("#define REFLECTIONFRESNELFROMSPECULAR \n");
		}
		if (this.LIGHTMAP != 0) {
			sb.add("#define LIGHTMAP \n");
		}
		if (this.OBJECTSPACE_NORMALMAP != 0) {
			sb.add("#define OBJECTSPACE_NORMALMAP \n");
		}
		if (this.USELIGHTMAPASSHADOWMAP != 0) {
			sb.add("#define USELIGHTMAPASSHADOWMAP \n");
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
		if (this.LOGARITHMICDEPTH != 0) {
			sb.add("#define LOGARITHMICDEPTH \n");
		}
		if (this.REFRACTION != 0) {
			sb.add("#define REFRACTION \n");
		}
		if (this.REFRACTIONMAP_3D != 0) {
			sb.add("#define REFRACTIONMAP_3D \n");
		}
		if (this.REFLECTIONOVERALPHA != 0) {
			sb.add("#define REFLECTIONOVERALPHA \n");
		}
		if (this.TWOSIDEDLIGHTING != 0) {
			sb.add("#define TWOSIDEDLIGHTING \n");
		}
		if (this.SHADOWFLOAT != 0) {
			sb.add("#define SHADOWFLOAT \n");
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
		if (this.NONUNIFORMSCALING != 0) {
			sb.add("#define NONUNIFORMSCALING \n");
		}
		if (this.PREMULTIPLYALPHA != 0) {
			sb.add("#define PREMULTIPLYALPHA \n");
		}
		
		sb.add("#define DIFFUSEDIRECTUV " + this.DIFFUSEDIRECTUV + "\n");
		sb.add("#define AMBIENTDIRECTUV " + this.AMBIENTDIRECTUV + "\n");
		sb.add("#define OPACITYDIRECTUV " + this.OPACITYDIRECTUV + "\n");
		sb.add("#define EMISSIVEDIRECTUV " + this.EMISSIVEDIRECTUV + "\n");
		sb.add("#define SPECULARDIRECTUV " + this.SPECULARDIRECTUV + "\n");
		sb.add("#define BUMPDIRECTUV " + this.BUMPDIRECTUV + "\n");
		sb.add("#define LIGHTMAPDIRECTUV " + this.LIGHTMAPDIRECTUV + "\n");
		
		sb.add("#define BonesPerMesh " + this.BonesPerMesh + "\n");
		sb.add("#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + "\n");
		sb.add("#define NUM_MORPH_INFLUENCERS " + this.NUM_MORPH_INFLUENCERS + "\n");
		
		result = sb.toString();
		
		return result;
	}
	
}
