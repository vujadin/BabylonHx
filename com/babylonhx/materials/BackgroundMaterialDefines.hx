package com.babylonhx.materials;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Background material defines definition.
 */
class BackgroundMaterialDefines extends MaterialDefines implements IImageProcessingConfigurationDefines {
	
	/**
	 * True if the diffuse texture is in use.
	 */
	public var DIFFUSE:Bool = false;

	/**
	 * The direct UV channel to use.
	 */
	public var DIFFUSEDIRECTUV:Int = 0;

	/**
	 * True if the diffuse texture is in gamma space.
	 */
	public var GAMMADIFFUSE:Bool = false;

	/**
	 * True if the diffuse texture has opacity in the alpha channel.
	 */
	public var DIFFUSEHASALPHA:Bool = false;

	/**
	 * True if you want the material to fade to transparent at grazing angle.
	 */
	public var OPACITYFRESNEL:Bool = false;

	/**
	 * True if an extra blur needs to be added in the reflection.
	 */
	public var REFLECTIONBLUR:Bool = false;

	/**
	 * True if you want the material to fade to reflection at grazing angle.
	 */
	public var REFLECTIONFRESNEL:Bool = false;

	/**
	 * True if you want the material to falloff as far as you move away from the scene center.
	 */
	public var REFLECTIONFALLOFF:Bool = false;

	/**
	 * False if the current Webgl implementation does not support the texture lod extension.
	 */
	public var TEXTURELODSUPPORT:Bool = false;

	/**
	 * True to ensure the data are premultiplied.
	 */
	public var PREMULTIPLYALPHA:Bool = false;

	/**
	 * True if the texture contains cooked RGB values and not gray scaled multipliers.
	 */
	public var USERGBCOLOR:Bool = false;

	/**
	 * True to add noise in order to reduce the banding effect.
	 */
	public var NOISE:Bool = false;

	
	// Image Processing Configuration.	
	public var IMAGEPROCESSING:Int = 0;
	public var VIGNETTE:Int = 0;
	public var VIGNETTEBLENDMODEMULTIPLY:Int = 0;
	public var VIGNETTEBLENDMODEOPAQUE:Int = 0;
	public var TONEMAPPING:Int = 0;
	public var CONTRAST:Int = 0;
	public var COLORCURVES:Int = 0;
	public var COLORGRADING:Int = 0;
	public var COLORGRADING3D:Int = 0;
	public var FROMLINEARSPACE:Int = 0;				// BHX: not used - needed because of IImageProcessingConfigurationDefines
	public var SAMPLER3DGREENDEPTH:Int = 0;
	public var SAMPLER3DBGRMAP:Int = 0;
	public var IMAGEPROCESSINGPOSTPROCESS:Int = 0;
	public var EXPOSURE:Int = 0;

	// Reflection.
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
	public var REFLECTIONMAP_OPPOSITEZ:Bool = false;
	public var LODINREFLECTIONALPHA:Bool = false;
	public var GAMMAREFLECTION:Bool = false;
	public var EQUIRECTANGULAR_RELFECTION_FOV:Bool = false;

	// Default BJS.
	public var MAINUV1:Bool = false;
	public var MAINUV2:Bool = false;
	public var UV1:Bool = false;
	public var UV2:Bool = false;
	public var CLIPPLANE:Bool = false;
	public var POINTSIZE:Bool = false;
	public var FOG:Bool = false;
	public var NORMAL:Bool = false;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	public var BonesPerMesh:Int = 0;
	public var INSTANCES:Bool = false;
	public var SHADOWFLOAT:Bool = false;
	
	public var SHADOWS:Bool = false;				// BHX
	public var LOGARITHMICDEPTH:Bool = false;		// BHX: always false
	public var NONUNIFORMSCALING:Bool = false;		// BHX: always false
	public var ALPHATEST:Bool = false;				// BHX: always false
	public var DEPTHPREPASS:Bool = false;			// BHX: always false
	

	public function new() {
		super();
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
			if (untyped this.DIFFUSEDIRECTUV != other.DIFFUSEDIRECTUV) return false;
			if (untyped this.GAMMADIFFUSE != other.GAMMADIFFUSE) return false;
			if (untyped this.DIFFUSEHASALPHA != other.DIFFUSEHASALPHA) return false;
			if (untyped this.OPACITYFRESNEL != other.OPACITYFRESNEL) return false;
			if (untyped this.REFLECTIONBLUR != other.REFLECTIONBLUR) return false;
			if (untyped this.REFLECTIONFRESNEL != other.REFLECTIONFRESNEL) return false;
			if (untyped this.REFLECTIONFALLOFF != other.REFLECTIONFALLOFF) return false;
			if (untyped this.TEXTURELODSUPPORT != other.TEXTURELODSUPPORT) return false;
			if (untyped this.PREMULTIPLYALPHA != other.PREMULTIPLYALPHA) return false;
			if (untyped this.USERGBCOLOR != other.USERGBCOLOR) return false;
			if (untyped this.NOISE != other.NOISE) return false;
			if (untyped this.IMAGEPROCESSING != other.IMAGEPROCESSING) return false;
			if (untyped this.VIGNETTE != other.VIGNETTE) return false;
			if (untyped this.VIGNETTEBLENDMODEMULTIPLY != other.VIGNETTEBLENDMODEMULTIPLY) return false;
			if (untyped this.VIGNETTEBLENDMODEOPAQUE != other.VIGNETTEBLENDMODEOPAQUE) return false;
			if (untyped this.TONEMAPPING != other.TONEMAPPING) return false;
			if (untyped this.CONTRAST != other.CONTRAST) return false;
			if (untyped this.COLORCURVES != other.COLORCURVES) return false;
			if (untyped this.COLORGRADING != other.COLORGRADING) return false;
			if (untyped this.COLORGRADING3D != other.COLORGRADING3D) return false;
			if (untyped this.SAMPLER3DGREENDEPTH != other.SAMPLER3DGREENDEPTH) return false;
			if (untyped this.SAMPLER3DBGRMAP != other.SAMPLER3DBGRMAP) return false;
			if (untyped this.IMAGEPROCESSINGPOSTPROCESS != other.IMAGEPROCESSINGPOSTPROCESS) return false;
			if (untyped this.EXPOSURE != other.EXPOSURE) return false;
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
			if (untyped this.REFLECTIONMAP_OPPOSITEZ != other.REFLECTIONMAP_OPPOSITEZ) return false;
			if (untyped this.LODINREFLECTIONALPHA != other.LODINREFLECTIONALPHA) return false;
			if (untyped this.GAMMAREFLECTION != other.GAMMAREFLECTION) return false;
			if (untyped this.MAINUV1 != other.MAINUV1) return false;
			if (untyped this.MAINUV2 != other.MAINUV2) return false;
			if (untyped this.UV1 != other.UV1) return false;
			if (untyped this.UV2 != other.UV2) return false;
			if (untyped this.CLIPPLANE != other.CLIPPLANE) return false;
			if (untyped this.POINTSIZE != other.POINTSIZE) return false;
			if (untyped this.FOG != other.FOG) return false;
			if (untyped this.NORMAL != other.NORMAL) return false;
			if (untyped this.NUM_BONE_INFLUENCERS != other.NUM_BONE_INFLUENCERS) return false;
			if (untyped this.BonesPerMesh != other.BonesPerMesh) return false;
			if (untyped this.INSTANCES != other.INSTANCES) return false;
			if (untyped this.SHADOWFLOAT != other.SHADOWFLOAT) return false;
			if (untyped this.SHADOWS != other.SHADOWS) return false;
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.DIFFUSE = this.DIFFUSE;
		untyped other.DIFFUSEDIRECTUV = this.DIFFUSEDIRECTUV;
		untyped other.GAMMADIFFUSE = this.GAMMADIFFUSE;
		untyped other.DIFFUSEHASALPHA = this.DIFFUSEHASALPHA;
		untyped other.OPACITYFRESNEL = this.OPACITYFRESNEL;
		untyped other.REFLECTIONBLUR = this.REFLECTIONBLUR;
		untyped other.REFLECTIONFRESNEL = this.REFLECTIONFRESNEL;
		untyped other.REFLECTIONFALLOFF = this.REFLECTIONFALLOFF;
		untyped other.TEXTURELODSUPPORT = this.TEXTURELODSUPPORT;
		untyped other.PREMULTIPLYALPHA = this.PREMULTIPLYALPHA;
		untyped other.USERGBCOLOR = this.USERGBCOLOR;
		untyped other.NOISE = this.NOISE;
		untyped other.IMAGEPROCESSING = this.IMAGEPROCESSING;
		untyped other.VIGNETTE = this.VIGNETTE;
		untyped other.VIGNETTEBLENDMODEMULTIPLY = this.VIGNETTEBLENDMODEMULTIPLY;
		untyped other.VIGNETTEBLENDMODEOPAQUE = this.VIGNETTEBLENDMODEOPAQUE;
		untyped other.TONEMAPPING = this.TONEMAPPING;
		untyped other.CONTRAST = this.CONTRAST;
		untyped other.COLORCURVES = this.COLORCURVES;
		untyped other.COLORGRADING = this.COLORGRADING;
		untyped other.COLORGRADING3D = this.COLORGRADING3D;
		untyped other.SAMPLER3DGREENDEPTH = this.SAMPLER3DGREENDEPTH;
		untyped other.SAMPLER3DBGRMAP = this.SAMPLER3DBGRMAP;
		untyped other.IMAGEPROCESSINGPOSTPROCESS = this.IMAGEPROCESSINGPOSTPROCESS;
		untyped other.EXPOSURE = this.EXPOSURE;
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
		untyped other.REFLECTIONMAP_OPPOSITEZ = this.REFLECTIONMAP_OPPOSITEZ;
		untyped other.LODINREFLECTIONALPHA = this.LODINREFLECTIONALPHA;
		untyped other.GAMMAREFLECTION = this.GAMMAREFLECTION;
		untyped other.MAINUV1 = this.MAINUV1;
		untyped other.MAINUV2 = this.MAINUV2;
		untyped other.UV1 = this.UV1;
		untyped other.UV2 = this.UV2;
		untyped other.CLIPPLANE = this.CLIPPLANE;
		untyped other.POINTSIZE = this.POINTSIZE;
		untyped other.FOG = this.FOG;
		untyped other.NORMAL = this.NORMAL;
		untyped other.NUM_BONE_INFLUENCERS = this.NUM_BONE_INFLUENCERS;
		untyped other.BonesPerMesh = this.BonesPerMesh;
		untyped other.INSTANCES = this.INSTANCES;
		untyped other.SHADOWFLOAT = this.SHADOWFLOAT;
		untyped other.SHADOWS = this.SHADOWS;
	}
	
	override public function reset() {
		super.reset();
		
		this.DIFFUSE = false;
		this.DIFFUSEDIRECTUV = 0;
		this.GAMMADIFFUSE = false;
		this.DIFFUSEHASALPHA = false;
		this.OPACITYFRESNEL = false;
		this.REFLECTIONBLUR = false;
		this.REFLECTIONFRESNEL = false;
		this.REFLECTIONFALLOFF = false;
		this.TEXTURELODSUPPORT = false;
		this.PREMULTIPLYALPHA = false;
		this.USERGBCOLOR = false;
		this.NOISE = false;
		this.IMAGEPROCESSING = 0;
		this.VIGNETTE = 0;
		this.VIGNETTEBLENDMODEMULTIPLY = 0;
		this.VIGNETTEBLENDMODEOPAQUE = 0;
		this.TONEMAPPING = 0;
		this.CONTRAST = 0;
		this.COLORCURVES = 0;
		this.COLORGRADING = 0;
		this.COLORGRADING3D = 0;
		this.SAMPLER3DGREENDEPTH = 0;
		this.SAMPLER3DBGRMAP = 0;
		this.IMAGEPROCESSINGPOSTPROCESS = 0;
		this.EXPOSURE = 0;
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
		this.REFLECTIONMAP_OPPOSITEZ = false;
		this.LODINREFLECTIONALPHA = false;
		this.GAMMAREFLECTION = false;
		this.MAINUV1 = false;
		this.MAINUV2 = false;
		this.UV1 = false;
		this.UV2 = false;
		this.CLIPPLANE = false;
		this.POINTSIZE = false;
		this.FOG = false;
		this.NORMAL = false;
		this.NUM_BONE_INFLUENCERS = 0;
		this.BonesPerMesh = 0;
		this.INSTANCES = false;
		this.SHADOWFLOAT = false;
		this.SHADOWS = false;
	}
	
	override public function toString():String {
		var result = super.toString();
		
		if (this.DIFFUSE) {
			result += "#define DIFFUSE \n";
		}
		if (this.GAMMADIFFUSE) {
			result += "#define GAMMADIFFUSE \n";
		}
		if (this.DIFFUSEHASALPHA) {
			result += "#define DIFFUSEHASALPHA \n";
		}
		if (this.OPACITYFRESNEL) {
			result += "#define OPACITYFRESNEL \n";
		}
		if (this.REFLECTIONBLUR) {
			result += "#define REFLECTIONBLUR \n";
		}
		if (this.REFLECTIONFRESNEL) {
			result += "#define REFLECTIONFRESNEL \n";
		}
		if (this.REFLECTIONFALLOFF) {
			result += "#define REFLECTIONFALLOFF \n";
		}
		if (this.TEXTURELODSUPPORT) {
			result += "#define TEXTURELODSUPPORT \n";
		}
		if (this.PREMULTIPLYALPHA) {
			result += "#define PREMULTIPLYALPHA \n";
		}
		if (this.USERGBCOLOR) {
			result += "#define USERGBCOLOR \n";
		}
		if (this.NOISE) {
			result += "#define NOISE \n";
		}
		if (this.IMAGEPROCESSING != 0) {
			result += "#define IMAGEPROCESSING \n";
		}
		if (this.VIGNETTE != 0) {
			result += "#define VIGNETTE \n";
		}
		if (this.VIGNETTEBLENDMODEMULTIPLY != 0) {
			result += "#define VIGNETTEBLENDMODEMULTIPLY \n";
		}
		if (this.VIGNETTEBLENDMODEOPAQUE != 0) {
			result += "#define VIGNETTEBLENDMODEOPAQUE \n";
		}
		if (this.TONEMAPPING != 0) {
			result += "#define TONEMAPPING \n";
		}
		if (this.CONTRAST != 0) {
			result += "#define CONTRAST \n";
		}
		if (this.COLORCURVES != 0) {
			result += "#define COLORCURVES \n";
		}
		if (this.COLORGRADING != 0) {
			result += "#define COLORGRADING \n";
		}
		if (this.COLORGRADING3D != 0) {
			result += "#define COLORGRADING3D \n";
		}
		if (this.SAMPLER3DGREENDEPTH != 0) {
			result += "#define SAMPLER3DGREENDEPTH \n";
		}
		if (this.SAMPLER3DBGRMAP != 0) {
			result += "#define SAMPLER3DBGRMAP \n";
		}
		if (this.IMAGEPROCESSINGPOSTPROCESS != 0) {
			result += "#define IMAGEPROCESSINGPOSTPROCESS \n";
		}
		if (this.EXPOSURE != 0) {
			result += "#define EXPOSURE \n";
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
		if (this.REFLECTIONMAP_OPPOSITEZ) {
			result += "#define REFLECTIONMAP_OPPOSITEZ \n";
		}
		if (this.LODINREFLECTIONALPHA) {
			result += "#define LODINREFLECTIONALPHA \n";
		}
		if (this.GAMMAREFLECTION) {
			result += "#define GAMMAREFLECTION \n";
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
		if (this.CLIPPLANE) {
			result += "#define CLIPPLANE \n";
		}
		if (this.POINTSIZE) {
			result += "#define POINTSIZE \n";
		}
		if (this.FOG) {
			result += "#define FOG \n";
		}
		if (this.NORMAL) {
			result += "#define NORMAL \n";
		}
		if (this.INSTANCES) {
			result += "#define INSTANCES \n";
		}
		if (this.SHADOWFLOAT) {
			result += "#define SHADOWFLOAT \n";
		}
		if (this.SHADOWS) {
			result += "#define SHADOWS \n";
		}
		
		result += "#define BonesPerMesh " + this.BonesPerMesh + "\n";
		result += "#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + "\n";
		result += "#define DIFFUSEDIRECTUV " + this.DIFFUSEDIRECTUV + "\n";
		
		return result;
	}
	
}
