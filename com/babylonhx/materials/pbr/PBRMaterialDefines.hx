package com.babylonhx.materials.pbr;

/**
 * ...
 * @author Krtolica Vujadin
 */
class PBRMaterialDefines extends MaterialDefines implements IImageProcessingConfigurationDefines {
	
	public var PBR:Bool = true;

	public var MAINUV1:Bool = false;
	public var MAINUV2:Bool = false;
	public var UV1:Bool = false;
	public var UV2:Bool = false;

	public var ALBEDO:Bool = false;
	public var ALBEDODIRECTUV:Float = 0;
	public var VERTEXCOLOR:Bool = false;

	public var AMBIENT:Bool = false;
	public var AMBIENTDIRECTUV:Float = 0;
	public var AMBIENTINGRAYSCALE:Bool = false;

	public var OPACITY:Bool = false;
	public var VERTEXALPHA:Bool = false;
	public var OPACITYDIRECTUV:Float = 0;
	public var OPACITYRGB:Bool = false;
	public var ALPHATEST:Bool = false;
	public var DEPTHPREPASS:Bool = false;
	public var ALPHABLEND:Bool = false;
	public var ALPHAFROMALBEDO:Bool = false;
	public var ALPHATESTVALUE:Float = 0.5;
	public var SPECULAROVERALPHA:Bool = false;
	public var RADIANCEOVERALPHA:Bool = false;
	public var ALPHAFRESNEL:Bool = false;
	public var PREMULTIPLYALPHA:Bool = false;

	public var EMISSIVE:Bool = false;
	public var EMISSIVEDIRECTUV:Float = 0;

	public var REFLECTIVITY:Bool = false;
	public var REFLECTIVITYDIRECTUV:Float = 0;
	public var SPECULARTERM:Bool = false;

	public var MICROSURFACEFROMREFLECTIVITYMAP:Bool = false;
	public var MICROSURFACEAUTOMATIC:Bool = false;
	public var LODBASEDMICROSFURACE:Bool = false;
	public var MICROSURFACEMAP:Bool = false;
	public var MICROSURFACEMAPDIRECTUV:Float = 0;

	public var METALLICWORKFLOW:Bool = false;
	public var ROUGHNESSSTOREINMETALMAPALPHA:Bool = false;
	public var ROUGHNESSSTOREINMETALMAPGREEN:Bool = false;
	public var METALLNESSSTOREINMETALMAPBLUE:Bool = false;
	public var AOSTOREINMETALMAPRED:Bool = false;
	public var ENVIRONMENTBRDF:Bool = false;

	public var NORMAL:Bool = false;
	public var TANGENT:Bool = false;
	public var BUMP:Bool = false;
	public var BUMPDIRECTUV:Float = 0;
	public var PARALLAX:Bool = false;
	public var PARALLAXOCCLUSION:Bool = false;
	public var NORMALXYSCALE:Bool = true;
	
	public var SHADOWS:Bool = false;				// BHX

	public var LIGHTMAP:Bool = false;
	public var LIGHTMAPDIRECTUV:Float = 0;
	public var USELIGHTMAPASSHADOWMAP:Bool = false;

	public var REFLECTION:Bool = false;
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
	public var USESPHERICALFROMREFLECTIONMAP:Bool = false;
	public var USESPHERICALINFRAGMENT:Bool = false;
	public var REFLECTIONMAP_OPPOSITEZ:Bool = false;
	public var LODINREFLECTIONALPHA:Bool = false;
	public var GAMMAREFLECTION:Bool = false;

	public var REFRACTION:Bool = false;
	public var REFRACTIONMAP_3D:Bool = false;
	public var REFRACTIONMAP_OPPOSITEZ:Bool = false;
	public var LODINREFRACTIONALPHA:Bool = false;
	public var GAMMAREFRACTION:Bool = false;
	public var LINKREFRACTIONTOTRANSPARENCY:Bool = false;

	public var INSTANCES:Bool = false;
	
	public var NUM_BONE_INFLUENCERS:Int = 0;
	public var BonesPerMesh:Int = 0;

	public var MORPHTARGETS:Bool = false;
	public var MORPHTARGETS_NORMAL:Bool = false;
	public var MORPHTARGETS_TANGENT:Bool = false;
	public var NUM_MORPH_INFLUENCERS:Int = 0;

	public var IMAGEPROCESSING:Bool = false;
	public var VIGNETTE:Bool = false;
	public var VIGNETTEBLENDMODEMULTIPLY:Bool = false;
	public var VIGNETTEBLENDMODEOPAQUE:Bool = false;
	public var TONEMAPPING:Bool = false;
	public var CONTRAST:Bool = false;
	public var COLORCURVES:Bool = false;
	public var COLORGRADING:Bool = false;
	public var SAMPLER3DGREENDEPTH:Bool = false;
	public var SAMPLER3DBGRMAP:Bool = false;
	public var IMAGEPROCESSINGPOSTPROCESS:Bool = false;
	public var EXPOSURE:Bool = false;

	public var USEPHYSICALLIGHTFALLOFF:Bool = false;
	public var TWOSIDEDLIGHTING:Bool = false;
	public var SHADOWFLOAT:Bool = false;
	public var USERIGHTHANDEDSYSTEM:Bool = false;
	public var CLIPPLANE:Bool = false;
	public var POINTSIZE:Bool = false;
	public var FOG:Bool = false;
	public var LOGARITHMICDEPTH:Bool = false;

	public var FORCENORMALFORWARD:Bool = false;
	
	// BHX: reqired by IImageProcessingConfigurationDefines
	public var FROMLINEARSPACE:Bool = false;
	

	public function new() {
		super();
	}
	
	override public function reset() {
		super.reset();
		
		this.PBR = true;
		
		this.MAINUV1 = false;
		this.MAINUV2 = false;
		this.UV1 = false;
		this.UV2 = false;
		
		this.ALBEDO = false;
		this.ALBEDODIRECTUV = 0;
		this.VERTEXCOLOR = false;
		
		this.AMBIENT = false;
		this.AMBIENTDIRECTUV = 0;
		this.AMBIENTINGRAYSCALE = false;
		
		this.OPACITY = false;
		this.VERTEXALPHA = false;
		this.OPACITYDIRECTUV = 0;
		this.OPACITYRGB = false;
		this.ALPHATEST = false;
		this.DEPTHPREPASS = false;
		this.ALPHABLEND = false;
		this.ALPHAFROMALBEDO = false;
		this.ALPHATESTVALUE = 0.5;
		this.SPECULAROVERALPHA = false;
		this.RADIANCEOVERALPHA = false;
		this.ALPHAFRESNEL = false;
		this.PREMULTIPLYALPHA = false;
		
		this.EMISSIVE = false;
		this.EMISSIVEDIRECTUV = 0;
		
		this.REFLECTIVITY = false;
		this.REFLECTIVITYDIRECTUV = 0;
		this.SPECULARTERM = false;
		
		this.MICROSURFACEFROMREFLECTIVITYMAP = false;
		this.MICROSURFACEAUTOMATIC = false;
		this.LODBASEDMICROSFURACE = false;
		this.MICROSURFACEMAP = false;
		this.MICROSURFACEMAPDIRECTUV = 0;
		
		this.METALLICWORKFLOW = false;
		this.ROUGHNESSSTOREINMETALMAPALPHA = false;
		this.ROUGHNESSSTOREINMETALMAPGREEN = false;
		this.METALLNESSSTOREINMETALMAPBLUE = false;
		this.AOSTOREINMETALMAPRED = false;
		this.ENVIRONMENTBRDF = false;
		
		this.NORMAL = false;
		this.TANGENT = false;
		this.BUMP = false;
		this.BUMPDIRECTUV = 0;
		this.PARALLAX = false;
		this.PARALLAXOCCLUSION = false;
		this.NORMALXYSCALE = true;
		
		this.SHADOWS = false;				// BHX
		
		this.LIGHTMAP = false;
		this.LIGHTMAPDIRECTUV = 0;
		this.USELIGHTMAPASSHADOWMAP = false;
		
		this.REFLECTION = false;
		this.REFLECTIONMAP_3D = false;
		this.REFLECTIONMAP_SPHERICAL = false;
		this.REFLECTIONMAP_PLANAR = false;
		this.REFLECTIONMAP_CUBIC = false;
		this.REFLECTIONMAP_PROJECTION = false;
		this.REFLECTIONMAP_SKYBOX = false;
		this.REFLECTIONMAP_EXPLICIT = false;
		this.REFLECTIONMAP_EQUIRECTANGULAR = false;
		this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = false;
		this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = false;
		this.INVERTCUBICMAP = false;
		this.USESPHERICALFROMREFLECTIONMAP = false;
		this.USESPHERICALINFRAGMENT = false;
		this.REFLECTIONMAP_OPPOSITEZ = false;
		this.LODINREFLECTIONALPHA = false;
		this.GAMMAREFLECTION = false;
		
		this.REFRACTION = false;
		this.REFRACTIONMAP_3D = false;
		this.REFRACTIONMAP_OPPOSITEZ = false;
		this.LODINREFRACTIONALPHA = false;
		this.GAMMAREFRACTION = false;
		this.LINKREFRACTIONTOTRANSPARENCY = false;
		
		this.INSTANCES = false;
		
		this.NUM_BONE_INFLUENCERS = 0;
		this.BonesPerMesh = 0;
		
		this.MORPHTARGETS = false;
		this.MORPHTARGETS_NORMAL = false;
		this.MORPHTARGETS_TANGENT = false;
		this.NUM_MORPH_INFLUENCERS = 0;
		
		this.IMAGEPROCESSING = false;
		this.VIGNETTE = false;
		this.VIGNETTEBLENDMODEMULTIPLY = false;
		this.VIGNETTEBLENDMODEOPAQUE = false;
		this.TONEMAPPING = false;
		this.CONTRAST = false;
		this.COLORCURVES = false;
		this.COLORGRADING = false;
		this.SAMPLER3DGREENDEPTH = false;
		this.SAMPLER3DBGRMAP = false;
		this.IMAGEPROCESSINGPOSTPROCESS = false;
		this.EXPOSURE = false;
		
		this.USEPHYSICALLIGHTFALLOFF = false;
		this.TWOSIDEDLIGHTING = false;
		this.SHADOWFLOAT = false;
		this.CLIPPLANE = false;
		this.POINTSIZE = false;
		this.FOG = false;
		this.LOGARITHMICDEPTH = false;
		
		this.FORCENORMALFORWARD = false;
		
		// BHX: reqired by IImageProcessingConfigurationDefines
		this.FROMLINEARSPACE = false;
	}
	
	public function setReflectionMode(modeToEnable:String) {		
		switch (modeToEnable) {
			case "REFLECTIONMAP_CUBIC":
				this.REFLECTIONMAP_CUBIC = true;
				
			case "REFLECTIONMAP_EXPLICIT":
				this.REFLECTIONMAP_EXPLICIT = true;
				
			case "REFLECTIONMAP_PLANAR":
				this.REFLECTIONMAP_PLANAR = true;
				
			case "REFLECTIONMAP_3D":
				this.REFLECTIONMAP_3D = true;
				
			case "REFLECTIONMAP_PROJECTION":
				this.REFLECTIONMAP_PROJECTION = true;
				
			case "REFLECTIONMAP_SKYBOX":
				this.REFLECTIONMAP_SKYBOX = true;
				
			case "REFLECTIONMAP_SPHERICAL":
				this.REFLECTIONMAP_SPHERICAL = true;
				
			case "REFLECTIONMAP_EQUIRECTANGULAR":
				this.REFLECTIONMAP_EQUIRECTANGULAR = true;
				
			case "REFLECTIONMAP_EQUIRECTANGULAR_FIXED":
				this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = true;
				
			case "REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED":
				this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = true;
		}
	}
	
	override public function isEqual(other:MaterialDefines):Bool {
		if (super.isEqual(other)) {
			if (untyped this.PBR != other.PBR) return false;
			
			if (untyped this.MAINUV1 != other.MAINUV1) return false;
			if (untyped this.MAINUV2 != other.MAINUV2) return false;
			if (untyped this.UV1 != other.UV1) return false;
			if (untyped this.UV2 != other.UV2) return false;
			
			if (untyped this.SHADOWS != other.SHADOWS) return false;		// BHX
			
			if (untyped this.ALBEDO != other.ALBEDO) return false;
			if (untyped this.ALBEDODIRECTUV != other.ALBEDODIRECTUV) return false;
			if (untyped this.VERTEXCOLOR != other.VERTEXCOLOR) return false;
			
			if (untyped this.AMBIENT != other.AMBIENT) return false;
			if (untyped this.AMBIENTDIRECTUV != other.AMBIENTDIRECTUV) return false;
			if (untyped this.AMBIENTINGRAYSCALE != other.AMBIENTINGRAYSCALE) return false;
			
			if (untyped this.OPACITY != other.OPACITY) return false;
			if (untyped this.VERTEXALPHA != other.VERTEXALPHA) return false;
			if (untyped this.OPACITYDIRECTUV != other.OPACITYDIRECTUV) return false;
			if (untyped this.OPACITYRGB != other.OPACITYRGB) return false;
			if (untyped this.ALPHATEST != other.ALPHATEST) return false;
			if (untyped this.DEPTHPREPASS != other.DEPTHPREPASS) return false;
			if (untyped this.ALPHABLEND != other.ALPHABLEND) return false;
			if (untyped this.ALPHAFROMALBEDO != other.ALPHAFROMALBEDO) return false;
			if (untyped this.ALPHATESTVALUE != other.ALPHATESTVALUE) return false;
			if (untyped this.SPECULAROVERALPHA != other.SPECULAROVERALPHA) return false;
			if (untyped this.RADIANCEOVERALPHA != other.RADIANCEOVERALPHA) return false;
			if (untyped this.ALPHAFRESNEL != other.ALPHAFRESNEL) return false;
			if (untyped this.PREMULTIPLYALPHA != other.PREMULTIPLYALPHA) return false;
			
			if (untyped this.EMISSIVE != other.EMISSIVE) return false;
			if (untyped this.EMISSIVEDIRECTUV != other.EMISSIVEDIRECTUV) return false;
			
			if (untyped this.REFLECTIVITY != other.REFLECTIVITY) return false;
			if (untyped this.REFLECTIVITYDIRECTUV != other.REFLECTIVITYDIRECTUV) return false;
			if (untyped this.SPECULARTERM != other.SPECULARTERM) return false;
			
			if (untyped this.MICROSURFACEFROMREFLECTIVITYMAP != other.MICROSURFACEFROMREFLECTIVITYMAP) return false;
			if (untyped this.MICROSURFACEAUTOMATIC != other.MICROSURFACEAUTOMATIC) return false;
			if (untyped this.LODBASEDMICROSFURACE != other.LODBASEDMICROSFURACE) return false;
			if (untyped this.MICROSURFACEMAP != other.MICROSURFACEMAP) return false;
			if (untyped this.MICROSURFACEMAPDIRECTUV != other.MICROSURFACEMAPDIRECTUV) return false;
			
			if (untyped this.METALLICWORKFLOW != other.METALLICWORKFLOW) return false;
			if (untyped this.ROUGHNESSSTOREINMETALMAPALPHA != other.ROUGHNESSSTOREINMETALMAPALPHA) return false;
			if (untyped this.ROUGHNESSSTOREINMETALMAPGREEN != other.ROUGHNESSSTOREINMETALMAPGREEN) return false;
			if (untyped this.METALLNESSSTOREINMETALMAPBLUE != other.METALLNESSSTOREINMETALMAPBLUE) return false;
			if (untyped this.AOSTOREINMETALMAPRED != other.AOSTOREINMETALMAPRED) return false;
			if (untyped this.ENVIRONMENTBRDF != other.ENVIRONMENTBRDF) return false;
			
			if (untyped this.NORMAL != other.NORMAL) return false;
			if (untyped this.TANGENT != other.TANGENT) return false;
			if (untyped this.BUMP != other.BUMP) return false;
			if (untyped this.BUMPDIRECTUV != other.BUMPDIRECTUV) return false;
			if (untyped this.PARALLAX != other.PARALLAX) return false;
			if (untyped this.PARALLAXOCCLUSION != other.PARALLAXOCCLUSION) return false;
			if (untyped this.NORMALXYSCALE != other.NORMALXYSCALE) return true;
			
			if (untyped this.LIGHTMAP != other.LIGHTMAP) return false;
			if (untyped this.LIGHTMAPDIRECTUV != other.LIGHTMAPDIRECTUV) return false;
			if (untyped this.USELIGHTMAPASSHADOWMAP != other.USELIGHTMAPASSHADOWMAP) return false;
			
			if (untyped this.REFLECTION != other.REFLECTION) return false;
			if (untyped this.REFLECTIONMAP_3D != other.REFLECTIONMAP_3D) return false;
			if (untyped this.REFLECTIONMAP_SPHERICAL != other.REFLECTIONMAP_SPHERICAL) return false;
			if (untyped this.REFLECTIONMAP_PLANAR != other.REFLECTIONMAP_PLANAR) return false;
			if (untyped this.REFLECTIONMAP_CUBIC != other.REFLECTIONMAP_CUBIC) return false;
			if (untyped this.REFLECTIONMAP_PROJECTION != other.REFLECTIONMAP_PROJECTION) return false;
			if (untyped this.REFLECTIONMAP_SKYBOX != other.REFLECTIONMAP_SKYBOX) return false;
			if (untyped this.REFLECTIONMAP_EXPLICIT != other.REFLECTIONMAP_EXPLICIT) return false;
			if (untyped this.REFLECTIONMAP_EQUIRECTANGULAR != other.REFLECTIONMAP_EQUIRECTANGULAR) return false;
			if (untyped this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED != other.REFLECTIONMAP_EQUIRECTANGULAR_FIXED) return false;
			if (untyped this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED != other.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED) return false;
			if (untyped this.INVERTCUBICMAP != other.INVERTCUBICMAP) return false;
			if (untyped this.USESPHERICALFROMREFLECTIONMAP != other.USESPHERICALFROMREFLECTIONMAP) return false;
			if (untyped this.USESPHERICALINFRAGMENT != other.USESPHERICALINFRAGMENT) return false;
			if (untyped this.REFLECTIONMAP_OPPOSITEZ != other.REFLECTIONMAP_OPPOSITEZ) return false;
			if (untyped this.LODINREFLECTIONALPHA != other.LODINREFLECTIONALPHA) return false;
			if (untyped this.GAMMAREFLECTION != other.GAMMAREFLECTION) return false;
			
			if (untyped this.REFRACTION != other.REFRACTION) return false;
			if (untyped this.REFRACTIONMAP_3D != other.REFRACTIONMAP_3D) return false;
			if (untyped this.REFRACTIONMAP_OPPOSITEZ != other.REFRACTIONMAP_OPPOSITEZ) return false;
			if (untyped this.LODINREFRACTIONALPHA != other.LODINREFRACTIONALPHA) return false;
			if (untyped this.GAMMAREFRACTION != other.GAMMAREFRACTION) return false;
			if (untyped this.LINKREFRACTIONTOTRANSPARENCY != other.LINKREFRACTIONTOTRANSPARENCY) return false;
			
			if (untyped this.INSTANCES != other.INSTANCES) return false;
			
			if (untyped this.NUM_BONE_INFLUENCERS != other.NUM_BONE_INFLUENCERS) return false;
			if (untyped this.BonesPerMesh != other.BonesPerMesh) return false;
			
			if (untyped this.MORPHTARGETS != other.MORPHTARGETS) return false;
			if (untyped this.MORPHTARGETS_NORMAL != other.MORPHTARGETS_NORMAL) return false;
			if (untyped this.MORPHTARGETS_TANGENT != other.MORPHTARGETS_TANGENT) return false;
			if (untyped this.NUM_MORPH_INFLUENCERS != other.NUM_MORPH_INFLUENCERS) return false;
			
			if (untyped this.IMAGEPROCESSING != other.IMAGEPROCESSING) return false;
			if (untyped this.VIGNETTE != other.VIGNETTE) return false;
			if (untyped this.VIGNETTEBLENDMODEMULTIPLY != other.VIGNETTEBLENDMODEMULTIPLY) return false;
			if (untyped this.VIGNETTEBLENDMODEOPAQUE != other.VIGNETTEBLENDMODEOPAQUE) return false;
			if (untyped this.TONEMAPPING != other.TONEMAPPING) return false;
			if (untyped this.CONTRAST != other.CONTRAST) return false;
			if (untyped this.COLORCURVES != other.COLORCURVES) return false;
			if (untyped this.COLORGRADING != other.COLORGRADING) return false;
			if (untyped this.SAMPLER3DGREENDEPTH != other.SAMPLER3DGREENDEPTH) return false;
			if (untyped this.SAMPLER3DBGRMAP != other.SAMPLER3DBGRMAP) return false;
			if (untyped this.IMAGEPROCESSINGPOSTPROCESS != other.IMAGEPROCESSINGPOSTPROCESS) return false;
			if (untyped this.EXPOSURE != other.EXPOSURE) return false;
			
			if (untyped this.USEPHYSICALLIGHTFALLOFF != other.USEPHYSICALLIGHTFALLOFF) return false;
			if (untyped this.TWOSIDEDLIGHTING != other.TWOSIDEDLIGHTING) return false;
			if (untyped this.SHADOWFLOAT != other.SHADOWFLOAT) return false;
			if (untyped this.CLIPPLANE != other.CLIPPLANE) return false;
			if (untyped this.POINTSIZE != other.POINTSIZE) return false;
			if (untyped this.FOG != other.FOG) return false;
			if (untyped this.LOGARITHMICDEPTH != other.LOGARITHMICDEPTH) return false;
			
			if (untyped this.FORCENORMALFORWARD != other.FORCENORMALFORWARD) return false;
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.PBR = this.PBR;
		
		untyped other.MAINUV1 = this.MAINUV1;
		untyped other.MAINUV2 = this.MAINUV2;
		untyped other.UV1 = this.UV1;
		untyped other.UV2 = this.UV2;
		
		untyped other.SHADOWS = this.SHADOWS;		// BHX
		
		untyped other.ALBEDO = this.ALBEDO;
		untyped other.ALBEDODIRECTUV = this.ALBEDODIRECTUV;
		untyped other.VERTEXCOLOR = this.VERTEXCOLOR;
		
		untyped other.AMBIENT = this.AMBIENT;
		untyped other.AMBIENTDIRECTUV = this.AMBIENTDIRECTUV;
		untyped other.AMBIENTINGRAYSCALE = this.AMBIENTINGRAYSCALE;
		
		untyped other.OPACITY = this.OPACITY;
		untyped other.VERTEXALPHA = this.VERTEXALPHA;
		untyped other.OPACITYDIRECTUV = this.OPACITYDIRECTUV;
		untyped other.OPACITYRGB = this.OPACITYRGB;
		untyped other.ALPHATEST = this.ALPHATEST;
		untyped other.DEPTHPREPASS = this.DEPTHPREPASS;
		untyped other.ALPHABLEND = this.ALPHABLEND;
		untyped other.ALPHAFROMALBEDO = this.ALPHAFROMALBEDO;
		untyped other.ALPHATESTVALUE = this.ALPHATESTVALUE;
		untyped other.SPECULAROVERALPHA = this.SPECULAROVERALPHA;
		untyped other.RADIANCEOVERALPHA = this.RADIANCEOVERALPHA;
		untyped other.ALPHAFRESNEL = this.ALPHAFRESNEL;
		untyped other.PREMULTIPLYALPHA = this.PREMULTIPLYALPHA;
		
		untyped other.EMISSIVE = this.EMISSIVE;
		untyped other.EMISSIVEDIRECTUV = this.EMISSIVEDIRECTUV;
		
		untyped other.REFLECTIVITY = this.REFLECTIVITY;
		untyped other.REFLECTIVITYDIRECTUV = this.REFLECTIVITYDIRECTUV;
		untyped other.SPECULARTERM = this.SPECULARTERM;
		
		untyped other.MICROSURFACEFROMREFLECTIVITYMAP = this.MICROSURFACEFROMREFLECTIVITYMAP;
		untyped other.MICROSURFACEAUTOMATIC = this.MICROSURFACEAUTOMATIC;
		untyped other.LODBASEDMICROSFURACE = this.LODBASEDMICROSFURACE;
		untyped other.MICROSURFACEMAP = this.MICROSURFACEMAP;
		untyped other.MICROSURFACEMAPDIRECTUV = this.MICROSURFACEMAPDIRECTUV;
		
		untyped other.METALLICWORKFLOW = this.METALLICWORKFLOW;
		untyped other.ROUGHNESSSTOREINMETALMAPALPHA = this.ROUGHNESSSTOREINMETALMAPALPHA;
		untyped other.ROUGHNESSSTOREINMETALMAPGREEN = this.ROUGHNESSSTOREINMETALMAPGREEN;
		untyped other.METALLNESSSTOREINMETALMAPBLUE = this.METALLNESSSTOREINMETALMAPBLUE;
		untyped other.AOSTOREINMETALMAPRED = this.AOSTOREINMETALMAPRED;
		untyped other.ENVIRONMENTBRDF = this.ENVIRONMENTBRDF;
		
		untyped other.NORMAL = this.NORMAL;
		untyped other.TANGENT = this.TANGENT;
		untyped other.BUMP = this.BUMP;
		untyped other.BUMPDIRECTUV = this.BUMPDIRECTUV;
		untyped other.PARALLAX = this.PARALLAX;
		untyped other.PARALLAXOCCLUSION = this.PARALLAXOCCLUSION;
		untyped other.NORMALXYSCALE = this.NORMALXYSCALE;
		
		untyped other.LIGHTMAP = this.LIGHTMAP;
		untyped other.LIGHTMAPDIRECTUV = this.LIGHTMAPDIRECTUV;
		untyped other.USELIGHTMAPASSHADOWMAP = this.USELIGHTMAPASSHADOWMAP;
		
		untyped other.REFLECTION = this.REFLECTION;
		untyped other.REFLECTIONMAP_3D = this.REFLECTIONMAP_3D;
		untyped other.REFLECTIONMAP_SPHERICAL = this.REFLECTIONMAP_SPHERICAL;
		untyped other.REFLECTIONMAP_PLANAR = this.REFLECTIONMAP_PLANAR;
		untyped other.REFLECTIONMAP_CUBIC = this.REFLECTIONMAP_CUBIC;
		untyped other.REFLECTIONMAP_PROJECTION = this.REFLECTIONMAP_PROJECTION;
		untyped other.REFLECTIONMAP_SKYBOX = this.REFLECTIONMAP_SKYBOX;
		untyped other.REFLECTIONMAP_EXPLICIT = this.REFLECTIONMAP_EXPLICIT;
		untyped other.REFLECTIONMAP_EQUIRECTANGULAR = this.REFLECTIONMAP_EQUIRECTANGULAR;
		untyped other.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED;
		untyped other.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED;
		untyped other.INVERTCUBICMAP = this.INVERTCUBICMAP;
		untyped other.USESPHERICALFROMREFLECTIONMAP = this.USESPHERICALFROMREFLECTIONMAP;
		untyped other.USESPHERICALINFRAGMENT = this.USESPHERICALINFRAGMENT;
		untyped other.REFLECTIONMAP_OPPOSITEZ = this.REFLECTIONMAP_OPPOSITEZ;
		untyped other.LODINREFLECTIONALPHA = this.LODINREFLECTIONALPHA;
		untyped other.GAMMAREFLECTION = this.GAMMAREFLECTION;
		
		untyped other.REFRACTION = this.REFRACTION;
		untyped other.REFRACTIONMAP_3D = this.REFRACTIONMAP_3D;
		untyped other.REFRACTIONMAP_OPPOSITEZ = this.REFRACTIONMAP_OPPOSITEZ;
		untyped other.LODINREFRACTIONALPHA = this.LODINREFLECTIONALPHA;
		untyped other.GAMMAREFRACTION = this.GAMMAREFRACTION;
		untyped other.LINKREFRACTIONTOTRANSPARENCY = this.LINKREFRACTIONTOTRANSPARENCY;
		
		untyped other.INSTANCES = this.INSTANCES;
		
		untyped other.NUM_BONE_INFLUENCERS = this.NUM_BONE_INFLUENCERS;
		untyped other.BonesPerMesh = this.BonesPerMesh;
		
		untyped other.MORPHTARGETS = this.MORPHTARGETS;
		untyped other.MORPHTARGETS_NORMAL = this.MORPHTARGETS_NORMAL;
		untyped other.MORPHTARGETS_TANGENT = this.MORPHTARGETS_TANGENT;
		untyped other.NUM_MORPH_INFLUENCERS = this.NUM_MORPH_INFLUENCERS;
		
		untyped other.IMAGEPROCESSING = this.IMAGEPROCESSING;
		untyped other.VIGNETTE = this.VIGNETTE;
		untyped other.VIGNETTEBLENDMODEMULTIPLY = this.VIGNETTEBLENDMODEMULTIPLY;
		untyped other.VIGNETTEBLENDMODEOPAQUE = this.VIGNETTEBLENDMODEOPAQUE;
		untyped other.TONEMAPPING = this.TONEMAPPING;
		untyped other.CONTRAST = this.CONTRAST;
		untyped other.COLORCURVES = this.COLORCURVES;
		untyped other.COLORGRADING = this.COLORGRADING;
		untyped other.SAMPLER3DGREENDEPTH = this.SAMPLER3DGREENDEPTH;
		untyped other.SAMPLER3DBGRMAP = this.SAMPLER3DBGRMAP;
		untyped other.IMAGEPROCESSINGPOSTPROCESS = this.IMAGEPROCESSINGPOSTPROCESS;
		untyped other.EXPOSURE = this.EXPOSURE;
		
		untyped other.USEPHYSICALLIGHTFALLOFF = this.USEPHYSICALLIGHTFALLOFF;
		untyped other.TWOSIDEDLIGHTING = this.TWOSIDEDLIGHTING;
		untyped other.SHADOWFLOAT = this.SHADOWFLOAT;
		untyped other.CLIPPLANE = this.CLIPPLANE;
		untyped other.POINTSIZE = this.POINTSIZE;
		untyped other.FOG = this.FOG;
		untyped other.LOGARITHMICDEPTH = this.LOGARITHMICDEPTH;
		
		untyped other.FORCENORMALFORWARD = this.FORCENORMALFORWARD;
	}
	
	override public function toString():String {
		var result = super.toString();
		
		if (this.PBR) {
			result += "#define PBR \n";
		}
		
		if (this.MAINUV1) {
			result += "#define MAINUV1 \n";
		}
		if (this.MAINUV2) {
			result += "#define MAINUV2 \n";
		}
		if (this.UV1) {
			result += "#define UV1 \n";
		}
		if (this.UV2) {
			result += "#define UV2 \n";
		}
		
		if (this.SHADOWS) {
			result += "#define SHADOWS \n";
		}
		
		if (this.ALBEDO) {
			result += "#define ALBEDO \n";
		}
		result += "#define ALBEDODIRECTUV " + this.ALBEDODIRECTUV + " \n";
		if (this.VERTEXCOLOR) {
			result += "#define VERTEXCOLOR \n";
		}
		
		if (this.AMBIENT) {
			result += "#define AMBIENT \n";
		}
		result += "#define AMBIENTDIRECTUV " + this.AMBIENTDIRECTUV + " \n";
		if (this.AMBIENTINGRAYSCALE) {
			result += "#define AMBIENTINGRAYSCALE \n";
		}
		
		if (this.OPACITY) {
			result += "#define OPACITY \n";
		}
		if (this.VERTEXALPHA) {
			result += "#define VERTEXALPHA \n";
		}
		result += "#define OPACITYDIRECTUV " + this.OPACITYDIRECTUV + " \n";
		if (this.OPACITYRGB) {
			result += "#define OPACITYRGB \n";
		}
		if (this.ALPHATEST) {
			result += "#define ALPHATEST \n";
		}
		if (this.DEPTHPREPASS) {
			result += "#define DEPTHPREPASS \n";
		}
		if (this.ALPHABLEND) {
			result += "#define ALPHABLEND \n";
		}
		if (this.ALPHAFROMALBEDO) {
			result += "#define ALPHAFROMALBEDO \n";
		}
		result += "#define ALPHATESTVALUE " + this.ALPHATESTVALUE + " \n";
		if (this.SPECULAROVERALPHA) {
			result += "#define SPECULAROVERALPHA \n";
		}
		if (this.RADIANCEOVERALPHA) {
			result += "#define RADIANCEOVERALPHA \n";
		}
		if (this.ALPHAFRESNEL) {
			result += "#define ALPHAFRESNEL \n";
		}
		if (this.PREMULTIPLYALPHA) {
			result += "#define PREMULTIPLYALPHA \n";
		}
		
		if (this.EMISSIVE) {
			result += "#define EMISSIVE \n";
		}
		result += "#define EMISSIVEDIRECTUV " + this.EMISSIVEDIRECTUV + " \n";
		
		if (this.REFLECTIVITY) {
			result += "#define REFLECTIVITY \n";
		}
		result += "#define REFLECTIVITYDIRECTUV " + this.REFLECTIVITYDIRECTUV + " \n";
		if (this.SPECULARTERM) {
			result += "#define SPECULARTERM \n";
		}
		
		if (this.MICROSURFACEFROMREFLECTIVITYMAP) {
			result += "#define MICROSURFACEFROMREFLECTIVITYMAP \n";
		}
		if (this.MICROSURFACEAUTOMATIC) {
			result += "#define MICROSURFACEAUTOMATIC \n";
		}
		if (this.LODBASEDMICROSFURACE) {
			result += "#define LODBASEDMICROSFURACE \n";
		}
		if (this.MICROSURFACEMAP) {
			result += "#define MICROSURFACEMAP \n";
		}
		result += "#define MICROSURFACEMAPDIRECTUV " + this.MICROSURFACEMAPDIRECTUV + " \n";
		
		if (this.METALLICWORKFLOW) {
			result += "#define METALLICWORKFLOW \n";
		}
		if (this.ROUGHNESSSTOREINMETALMAPALPHA) {
			result += "#define ROUGHNESSSTOREINMETALMAPALPHA \n";
		}
		if (this.ROUGHNESSSTOREINMETALMAPGREEN) {
			result += "#define ROUGHNESSSTOREINMETALMAPGREEN \n";
		}
		if (this.METALLNESSSTOREINMETALMAPBLUE) {
			result += "#define METALLNESSSTOREINMETALMAPBLUE \n";
		}
		if (this.AOSTOREINMETALMAPRED) {
			result += "#define AOSTOREINMETALMAPRED \n";
		}
		if (this.ENVIRONMENTBRDF) {
			result += "#define ENVIRONMENTBRDF \n";
		}
		
		if (this.NORMAL) {
			result += "#define NORMAL \n";
		}
		if (this.TANGENT) {
			result += "#define TANGENT \n";
		}
		if (this.BUMP) {
			result += "#define BUMP \n";
		}
		result += "#define BUMPDIRECTUV " + this.BUMPDIRECTUV + " \n";
		if (this.PARALLAX) {
			result += "#define PARALLAX \n";
		}
		if (this.PARALLAXOCCLUSION) {
			result += "#define PARALLAXOCCLUSION \n";
		}
		if (this.NORMALXYSCALE) {
			result += "#define NORMALXYSCALE \n";
		}
		
		if (this.LIGHTMAP) {
			result += "#define LIGHTMAP \n";
		}
		result += "#define LIGHTMAPDIRECTUV " + this.LIGHTMAPDIRECTUV + " \n";
		if (this.USELIGHTMAPASSHADOWMAP) {
			result += "#define USELIGHTMAPASSHADOWMAP \n";
		}
		
		if (this.REFLECTION) {
			result += "#define REFLECTION \n";
		}
		if (this.REFLECTIONMAP_3D) {
			result += "#define REFLECTIONMAP_3D \n";
		}
		if (this.REFLECTIONMAP_SPHERICAL) {
			result += "#define REFLECTIONMAP_SPHERICAL \n";
		}
		if (this.REFLECTIONMAP_PLANAR) {
			result += "#define REFLECTIONMAP_PLANAR \n";
		}
		if (this.REFLECTIONMAP_CUBIC) {
			result += "#define REFLECTIONMAP_CUBIC \n";
		}
		if (this.REFLECTIONMAP_PROJECTION) {
			result += "#define REFLECTIONMAP_PROJECTION \n";
		}
		if (this.REFLECTIONMAP_SKYBOX) {
			result += "#define REFLECTIONMAP_SKYBOX \n";
		}
		if (this.REFLECTIONMAP_EXPLICIT) {
			result += "#define REFLECTIONMAP_EXPLICIT \n";
		}
		if (this.REFLECTIONMAP_EQUIRECTANGULAR) {
			result += "#define REFLECTIONMAP_EQUIRECTANGULAR \n";
		}
		if (this.REFLECTIONMAP_EQUIRECTANGULAR_FIXED) {
			result += "#define REFLECTIONMAP_EQUIRECTANGULAR_FIXED \n";
		}
		if (this.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED) {
			result += "#define REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED \n";
		}
		if (this.INVERTCUBICMAP) {
			result += "#define INVERTCUBICMAP \n";
		}
		if (this.USESPHERICALFROMREFLECTIONMAP) {
			result += "#define USESPHERICALFROMREFLECTIONMAP \n";
		}
		if (this.USESPHERICALINFRAGMENT) {
			result += "#define USESPHERICALINFRAGMENT \n";
		}
		if (this.REFLECTIONMAP_OPPOSITEZ) {
			result += "#define REFLECTIONMAP_OPPOSITEZ \n";
		}
		if (this.LODINREFLECTIONALPHA) {
			result += "#define LODINREFLECTIONALPHA \n";
		}
		if (this.GAMMAREFLECTION) {
			result += "#define GAMMAREFLECTION \n";
		}
		
		if (this.REFRACTION) {
			result += "#define REFRACTION \n";
		}
		if (this.REFRACTIONMAP_3D) {
			result += "#define REFRACTIONMAP_3D \n";
		}
		if (this.REFRACTIONMAP_OPPOSITEZ) {
			result += "#define REFRACTIONMAP_OPPOSITEZ \n";
		}
		if (this.LODINREFRACTIONALPHA) {
			result += "#define LODINREFRACTIONALPHA \n";
		}
		if (this.GAMMAREFRACTION) {
			result += "#define GAMMAREFRACTION \n";
		}
		if (this.LINKREFRACTIONTOTRANSPARENCY) {
			result += "#define LINKREFRACTIONTOTRANSPARENCY \n";
		}
		
		if (this.INSTANCES) {
			result += "#define INSTANCES \n";
		}
		
		result += "#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + " \n";
		result += "#define BonesPerMesh " + this.BonesPerMesh + " \n";
		
		if (this.MORPHTARGETS) {
			result += "#define MORPHTARGETS \n";
		}
		if (this.MORPHTARGETS_NORMAL) {
			result += "#define MORPHTARGETS_NORMAL \n";
		}
		if (this.MORPHTARGETS_TANGENT) {
			result += "#define MORPHTARGETS_TANGENT \n";
		}
		result += "#define NUM_MORPH_INFLUENCERS " + this.NUM_MORPH_INFLUENCERS + " \n";
		
		if (this.IMAGEPROCESSING) {
			result += "#define IMAGEPROCESSING \n";
		}
		if (this.VIGNETTE) {
			result += "#define VIGNETTE \n";
		}
		if (this.VIGNETTEBLENDMODEMULTIPLY) {
			result += "#define VIGNETTEBLENDMODEMULTIPLY \n";
		}
		if (this.VIGNETTEBLENDMODEOPAQUE) {
			result += "#define VIGNETTEBLENDMODEOPAQUE \n";
		}
		if (this.TONEMAPPING) {
			result += "#define TONEMAPPING \n";
		}
		if (this.CONTRAST) {
			result += "#define CONTRAST \n";
		}
		if (this.COLORCURVES) {
			result += "#define COLORCURVES \n";
		}
		if (this.COLORGRADING) {
			result += "#define COLORGRADING \n";
		}
		if (this.SAMPLER3DGREENDEPTH) {
			result += "#define SAMPLER3DGREENDEPTH \n";
		}
		if (this.SAMPLER3DBGRMAP) {
			result += "#define SAMPLER3DBGRMAP \n";
		}
		if (this.IMAGEPROCESSINGPOSTPROCESS) {
			result += "#define IMAGEPROCESSINGPOSTPROCESS \n";
		}
		if (this.EXPOSURE) {
			result += "#define EXPOSURE \n";
		}
		
		if (this.USEPHYSICALLIGHTFALLOFF) {
			result += "#define USEPHYSICALLIGHTFALLOFF \n";
		}
		if (this.TWOSIDEDLIGHTING) {
			result += "#define TWOSIDEDLIGHTING \n";
		}
		if (this.SHADOWFLOAT) {
			result += "#define SHADOWFLOAT \n";
		}
		if (this.CLIPPLANE) {
			result += "#define CLIPPLANE \n";
		}
		if (this.POINTSIZE) {
			result += "#define POINTSIZE \n";
		}
		if (this.FOG) {
			result += "#define FOG \n";
		}
		if (this.LOGARITHMICDEPTH) {
			result += "#define LOGARITHMICDEPTH \n";
		}
		
		if (this.FORCENORMALFORWARD) {
			result += "#define FORCENORMALFORWARD \n";
		}
		
		return result;
	}
	
}
