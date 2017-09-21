package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */
class StandardMaterialDefines extends MaterialDefines implements IImageProcessingConfigurationDefines {
	
	public var MAINUV1:Bool = false;
	public var MAINUV2:Bool = false;
	public var DIFFUSE:Bool = false;
	public var DIFFUSEDIRECTUV:Int = 0;
	public var AMBIENT:Bool = false;
	public var AMBIENTDIRECTUV:Int = 0;
	public var OPACITY:Bool = false;
	public var OPACITYDIRECTUV:Int = 0;
	public var OPACITYRGB:Bool = false;
	public var REFLECTION:Bool = false;
	public var EMISSIVE:Bool = false;
	public var EMISSIVEDIRECTUV:Int = 0;
	public var SPECULAR:Bool = false;
	public var SPECULARDIRECTUV:Int = 0;
	public var BUMP:Bool = false;
	public var BUMPDIRECTUV:Int = 0;
	public var PARALLAX:Bool = false;
	public var PARALLAXOCCLUSION:Bool = false;
	public var SPECULAROVERALPHA:Bool = false;
	public var CLIPPLANE:Bool = false;
	public var ALPHATEST:Bool = false;
	public var DEPTHPREPASS:Bool = false;
	public var ALPHAFROMDIFFUSE:Bool = false;
	public var POINTSIZE:Bool = false;
	public var FOG:Bool = false;
	public var SPECULARTERM:Bool = false;
	public var SHADOWS:Bool = false;				// BHX
	//public var SHADOWFULLFLOAT:Bool = false;		// BHX
	public var DIFFUSEFRESNEL:Bool = false;
	public var OPACITYFRESNEL:Bool = false;
	public var REFLECTIONFRESNEL:Bool = false;
	public var REFRACTIONFRESNEL:Bool = false;
	public var EMISSIVEFRESNEL:Bool = false;
	public var FRESNEL:Bool = false;
	public var NORMAL:Bool = false;
	public var UV1:Bool = false;
	public var UV2:Bool = false;
	public var VERTEXCOLOR:Bool = false;
	public var VERTEXALPHA:Bool = false;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	public var BonesPerMesh:Int = 0;
	public var INSTANCES:Bool = false;
	public var GLOSSINESS:Bool = false;
	public var ROUGHNESS:Bool = false;
	public var EMISSIVEASILLUMINATION:Bool = false;
	public var LINKEMISSIVEWITHDIFFUSE:Bool = false;
	public var REFLECTIONFRESNELFROMSPECULAR:Bool = false;
	public var LIGHTMAP:Bool = false;
	public var LIGHTMAPDIRECTUV:Int = 0;
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
	public var REFRACTION:Bool = false;
	public var REFRACTIONMAP_3D:Bool = false;
	public var REFLECTIONOVERALPHA:Bool = false;
	public var TWOSIDEDLIGHTING:Bool = false;
	public var SHADOWFLOAT:Bool = false;
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
	
	public var FROMLINEARSPACE:Bool = false;	// BHX: not used
	
	
	public function new() {
		super();
		
		this.BonesPerMesh = 0;
		this.NUM_BONE_INFLUENCERS = 0;
		this.NUM_MORPH_INFLUENCERS = 0;
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
			if (untyped this.DIFFUSE != other.DIFFUSE) return false; 
			if (untyped this.AMBIENT != other.AMBIENT) return false; 
			if (untyped this.OPACITY != other.OPACITY) return false;
			if (untyped this.OPACITYRGB != other.OPACITYRGB) return false;
			if (untyped this.REFLECTION != other.REFLECTION) return false; 
			if (untyped this.EMISSIVE != other.EMISSIVE) return false;
			if (untyped this.SPECULAR != other.SPECULAR) return false; 
			if (untyped this.BUMP != other.BUMP) return false;
			if (untyped this.PARALLAX != other.PARALLAX) return false; 
			if (untyped this.PARALLAXOCCLUSION != other.PARALLAXOCCLUSION) return false;
			if (untyped this.SPECULAROVERALPHA != other.SPECULAROVERALPHA) return false;
			if (untyped this.CLIPPLANE != other.CLIPPLANE) return false;
			if (untyped this.ALPHATEST != other.ALPHATEST) return false;
			if (untyped this.DEPTHPREPASS != other.DEPTHPREPASS) return false;
			if (untyped this.ALPHAFROMDIFFUSE != other.ALPHAFROMDIFFUSE) return false;
			if (untyped this.POINTSIZE != other.POINTSIZE) return false;
			if (untyped this.FOG != other.FOG) return false;
			if (untyped this.SPECULARTERM != other.SPECULARTERM) return false;
			if (untyped this.SHADOWS != other.SHADOWS) return false;
			if (untyped this.DIFFUSEFRESNEL != other.DIFFUSEFRESNEL) return false;
			if (untyped this.OPACITYFRESNEL != other.OPACITYFRESNEL) return false;
			if (untyped this.REFLECTIONFRESNEL != other.REFLECTIONFRESNEL) return false;
			if (untyped this.REFRACTIONFRESNEL != other.REFRACTIONFRESNEL) return false;
			if (untyped this.EMISSIVEFRESNEL != other.EMISSIVEFRESNEL) return false;
			if (untyped this.FRESNEL != other.FRESNEL) return false;
			if (untyped this.NORMAL != other.NORMAL) return false;
			if (untyped this.UV1 != other.UV1) return false;
			if (untyped this.UV2 != other.UV2) return false;
			if (untyped this.VERTEXCOLOR != other.VERTEXCOLOR) return false;
			if (untyped this.VERTEXALPHA != other.VERTEXALPHA) return false;
			if (untyped this.NUM_BONE_INFLUENCERS != other.NUM_BONE_INFLUENCERS) return false;
			if (untyped this.BonesPerMesh != other.BonesPerMesh) return false;
			if (untyped this.INSTANCES != other.INSTANCES) return false;
			if (untyped this.GLOSSINESS != other.GLOSSINESS) return false;
			if (untyped this.ROUGHNESS != other.ROUGHNESS) return false;
			if (untyped this.EMISSIVEASILLUMINATION != other.EMISSIVEASILLUMINATION) return false;
			if (untyped this.LINKEMISSIVEWITHDIFFUSE != other.LINKEMISSIVEWITHDIFFUSE) return false;
			if (untyped this.REFLECTIONFRESNELFROMSPECULAR != other.REFLECTIONFRESNELFROMSPECULAR) return false;
			if (untyped this.LIGHTMAP != other.LIGHTMAP) return false;
			if (untyped this.USELIGHTMAPASSHADOWMAP != other.USELIGHTMAPASSHADOWMAP) return false;
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
			if (untyped this.LOGARITHMICDEPTH != other.LOGARITHMICDEPTH) return false;
			if (untyped this.REFRACTION != other.REFRACTION) return false;
			if (untyped this.REFRACTIONMAP_3D != other.REFRACTIONMAP_3D) return false;
			if (untyped this.REFLECTIONOVERALPHA != other.REFLECTIONOVERALPHA) return false;
			if (untyped this.TWOSIDEDLIGHTING != other.TWOSIDEDLIGHTING) return false;
			if (untyped this.SHADOWFLOAT != other.SHADOWFLOAT) return false;
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
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.DIFFUSE = this.DIFFUSE;
		untyped other.AMBIENT = this.AMBIENT;
		untyped other.OPACITY = this.OPACITY;
		untyped other.OPACITYRGB = this.OPACITYRGB;
		untyped other.REFLECTION = this.REFLECTION;
		untyped other.EMISSIVE = this.EMISSIVE;
		untyped other.SPECULAR = this.SPECULAR;
		untyped other.BUMP = this.BUMP;
		untyped other.PARALLAX = this.PARALLAX;
		untyped other.PARALLAXOCCLUSION = this.PARALLAXOCCLUSION;
		untyped other.SPECULAROVERALPHA = this.SPECULAROVERALPHA;
		untyped other.CLIPPLANE = this.CLIPPLANE;
		untyped other.ALPHATEST = this.ALPHATEST;
		untyped other.DEPTHPREPASS = this.DEPTHPREPASS;
		untyped other.ALPHAFROMDIFFUSE = this.ALPHAFROMDIFFUSE;
		untyped other.POINTSIZE = this.POINTSIZE;
		untyped other.FOG = this.FOG;
		untyped other.SPECULARTERM = this.SPECULARTERM;
		untyped other.SHADOWS = this.SHADOWS;
		untyped other.DIFFUSEFRESNEL = this.DIFFUSEFRESNEL;
		untyped other.OPACITYFRESNEL = this.OPACITYFRESNEL;
		untyped other.REFLECTIONFRESNEL = this.REFLECTIONFRESNEL;
		untyped other.REFRACTIONFRESNEL = this.REFRACTIONFRESNEL;
		untyped other.EMISSIVEFRESNEL = this.EMISSIVEFRESNEL;
		untyped other.FRESNEL = this.FRESNEL;
		untyped other.NORMAL = this.NORMAL;
		untyped other.UV1 = this.UV1;
		untyped other.UV2 = this.UV2;
		untyped other.VERTEXCOLOR = this.VERTEXCOLOR;
		untyped other.VERTEXALPHA = this.VERTEXALPHA;
		untyped other.INSTANCES = this.INSTANCES;
		untyped other.GLOSSINESS = this.GLOSSINESS;
		untyped other.ROUGHNESS = this.ROUGHNESS;
		untyped other.EMISSIVEASILLUMINATION = this.EMISSIVEASILLUMINATION;
		untyped other.LINKEMISSIVEWITHDIFFUSE = this.LINKEMISSIVEWITHDIFFUSE;
		untyped other.REFLECTIONFRESNELFROMSPECULAR = this.REFLECTIONFRESNELFROMSPECULAR;
		untyped other.LIGHTMAP = this.LIGHTMAP;
		untyped other.USELIGHTMAPASSHADOWMAP = this.USELIGHTMAPASSHADOWMAP;
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
		untyped other.LOGARITHMICDEPTH = this.LOGARITHMICDEPTH;
		untyped other.REFRACTION = this.REFRACTION;
		untyped other.REFRACTIONMAP_3D = this.REFRACTIONMAP_3D;
		untyped other.REFLECTIONOVERALPHA = this.REFLECTIONOVERALPHA;
		untyped other.TWOSIDEDLIGHTING = this.TWOSIDEDLIGHTING;
		untyped other.SHADOWFLOAT = this.SHADOWFLOAT;
		untyped other.MORPHTARGETS = this.MORPHTARGETS;
		untyped other.MORPHTARGETS_NORMAL = this.MORPHTARGETS_NORMAL;
		untyped other.MORPHTARGETS_TANGENT = this.MORPHTARGETS_TANGENT;
		
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
		
		untyped other.BonesPerMesh = this.BonesPerMesh;
		untyped other.NUM_BONE_INFLUENCERS = this.NUM_BONE_INFLUENCERS;
		untyped other.NUM_MORPH_INFLUENCERS = this.NUM_MORPH_INFLUENCERS;
	}
	
	override public function reset() {
		super.reset();
		
		this.DIFFUSE = false;
		this.AMBIENT = false;
		this.OPACITY = false;
		this.OPACITYRGB = false;
		this.REFLECTION = false;
		this.EMISSIVE = false;
		this.SPECULAR = false;
		this.BUMP = false;
		this.PARALLAX = false;
		this.PARALLAXOCCLUSION = false;
		this.SPECULAROVERALPHA = false;
		this.CLIPPLANE = false;
		this.ALPHATEST = false;
		this.DEPTHPREPASS = false;
		this.ALPHAFROMDIFFUSE = false;
		this.POINTSIZE = false;
		this.FOG = false;
		this.SPECULARTERM = false;
		this.SHADOWS = false;
		this.DIFFUSEFRESNEL = false;
		this.OPACITYFRESNEL = false;
		this.REFLECTIONFRESNEL = false;
		this.REFRACTIONFRESNEL = false;
		this.EMISSIVEFRESNEL = false;
		this.FRESNEL = false;
		this.NORMAL = false;
		this.UV1 = false;
		this.UV2 = false;
		this.VERTEXCOLOR = false;
		this.VERTEXALPHA = false;
		this.INSTANCES = false;
		this.GLOSSINESS = false;
		this.ROUGHNESS = false;
		this.EMISSIVEASILLUMINATION = false;
		this.LINKEMISSIVEWITHDIFFUSE = false;
		this.REFLECTIONFRESNELFROMSPECULAR = false;
		this.LIGHTMAP = false;
		this.USELIGHTMAPASSHADOWMAP = false;
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
		this.LOGARITHMICDEPTH = false;
		this.REFRACTION = false;
		this.REFRACTIONMAP_3D = false;
		this.REFLECTIONOVERALPHA = false;
		this.TWOSIDEDLIGHTING = false;
		this.SHADOWFLOAT = false;
		this.MORPHTARGETS = false;
		this.MORPHTARGETS_NORMAL = false;
		this.MORPHTARGETS_TANGENT = false;
		
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
		
		this.BonesPerMesh = 0;
		this.NUM_BONE_INFLUENCERS = 0;
		this.NUM_MORPH_INFLUENCERS = 0;
	}

	override public function toString():String {
		var result = super.toString();
		
		if (this.MAINUV1) {
			result += "#define MAINUV1 \n";
		}
		if (this.MAINUV2) {
			result += "#define MAINUV2 \n";
		}
		if (this.DIFFUSE) {
			result += "#define DIFFUSE \n";
		}
		if (this.AMBIENT) {
			result += "#define AMBIENT \n";
		}
		if (this.OPACITY) {
			result += "#define OPACITY \n";
		}
		if (this.OPACITYRGB) {
			result += "#define OPACITYRGB \n";
		}
		if (this.REFLECTION) {
			result += "#define REFLECTION \n";
		}
		if (this.EMISSIVE) {
			result += "#define EMISSIVE \n";
		}
		if (this.SPECULAR) {
			result += "#define SPECULAR \n";
		}
		if (this.BUMP) {
			result += "#define BUMP \n";
		}
		if (this.PARALLAX) {
			result += "#define PARALLAX \n";
		}
		if (this.PARALLAXOCCLUSION) {
			result += "#define PARALLAXOCCLUSION \n";
		}
		if (this.SPECULAROVERALPHA) {
			result += "#define SPECULAROVERALPHA \n";
		}
		if (this.CLIPPLANE) {
			result += "#define CLIPPLANE \n";
		}
		if (this.ALPHATEST) {
			result += "#define ALPHATEST \n";
		}
		if (this.DEPTHPREPASS) {
			result += "#define DEPTHPREPASS \n";
		}
		if (this.ALPHAFROMDIFFUSE) {
			result += "#define ALPHAFROMDIFFUSE \n";
		}
		if (this.POINTSIZE) {
			result += "#define POINTSIZE \n";
		}
		if (this.FOG) {
			result += "#define FOG \n";
		}
		if (this.SPECULARTERM) {
			result += "#define SPECULARTERM \n";
		}
		if (this.SHADOWS) {
			result += "#define SHADOWS \n";
		}
		if (this.DIFFUSEFRESNEL) {
			result += "#define DIFFUSEFRESNEL \n";
		}
		if (this.OPACITYFRESNEL) {
			result += "#define OPACITYFRESNEL \n";
		}
		if (this.REFLECTIONFRESNEL) {
			result += "#define REFLECTIONFRESNEL \n";
		}
		if (this.REFRACTIONFRESNEL) {
			result += "#define REFRACTIONFRESNEL \n";
		}
		if (this.EMISSIVEFRESNEL) {
			result += "#define EMISSIVEFRESNEL \n";
		}
		if (this.FRESNEL) {
			result += "#define FRESNEL \n";
		}
		if (this.NORMAL) {
			result += "#define NORMAL \n";
		}
		if (this.UV1) {
			result += "#define UV1 \n";
		}
		if (this.UV2) {
			result += "#define UV2 \n";
		}
		if (this.VERTEXCOLOR) {
			result += "#define VERTEXCOLOR \n";
		}
		if (this.VERTEXALPHA) {
			result += "#define VERTEXALPHA \n";
		}
		if (this.INSTANCES) {
			result += "#define INSTANCES \n";
		}
		if (this.GLOSSINESS) {
			result += "#define GLOSSINESS \n";
		}
		if (this.ROUGHNESS) {
			result += "#define ROUGHNESS \n";
		}
		if (this.EMISSIVEASILLUMINATION) {
			result += "#define EMISSIVEASILLUMINATION \n";
		}
		if (this.LINKEMISSIVEWITHDIFFUSE) {
			result += "#define LINKEMISSIVEWITHDIFFUSE \n";
		}
		if (this.REFLECTIONFRESNELFROMSPECULAR) {
			result += "#define REFLECTIONFRESNELFROMSPECULAR \n";
		}
		if (this.LIGHTMAP) {
			result += "#define LIGHTMAP \n";
		}
		if (this.USELIGHTMAPASSHADOWMAP) {
			result += "#define USELIGHTMAPASSHADOWMAP \n";
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
		if (this.LOGARITHMICDEPTH) {
			result += "#define LOGARITHMICDEPTH \n";
		}
		if (this.REFRACTION) {
			result += "#define REFRACTION \n";
		}
		if (this.REFRACTIONMAP_3D) {
			result += "#define REFRACTIONMAP_3D \n";
		}
		if (this.REFLECTIONOVERALPHA) {
			result += "#define REFLECTIONOVERALPHA \n";
		}
		if (this.TWOSIDEDLIGHTING) {
			result += "#define TWOSIDEDLIGHTING \n";
		}
		if (this.SHADOWFLOAT) {
			result += "#define SHADOWFLOAT \n";
		}
		if (this.MORPHTARGETS) {
			result += "#define MORPHTARGETS \n";
		}
		if (this.MORPHTARGETS_NORMAL) {
			result += "#define MORPHTARGETS_NORMAL \n";
		}
		if (this.MORPHTARGETS_TANGENT) {
			result += "#define MORPHTARGETS_TANGENT \n";
		}
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
		
		result += "#define DIFFUSEDIRECTUV " + this.DIFFUSEDIRECTUV + "\n";
		result += "#define AMBIENTDIRECTUV " + this.AMBIENTDIRECTUV + "\n";
		result += "#define OPACITYDIRECTUV " + this.OPACITYDIRECTUV + "\n";
		result += "#define EMISSIVEDIRECTUV " + this.EMISSIVEDIRECTUV + "\n";
		result += "#define SPECULARDIRECTUV " + this.SPECULARDIRECTUV + "\n";
		result += "#define BUMPDIRECTUV " + this.BUMPDIRECTUV + "\n";
		result += "#define LIGHTMAPDIRECTUV " + this.LIGHTMAPDIRECTUV + "\n";
		
		result += "#define BonesPerMesh " + this.BonesPerMesh + "\n";
		result += "#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + "\n";
		result += "#define NUM_MORPH_INFLUENCERS " + this.NUM_MORPH_INFLUENCERS + "\n";
		
		return result;
	}
	
}
