package com.babylonhx.materials;

import com.babylonhx.engine.Engine;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.RefractionTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.ColorGradingTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.Observer;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.tools.serialization.SerializationHelper;

import haxe.ds.Vector;

/**
 * ...
 * @author Krtolica Vujadin
 */

typedef SMD = StandardMaterialDefines

@:expose('BABYLON.StandardMaterial') class StandardMaterial extends PushMaterial {
	
	@serializeAsTexture("diffuseTexture")
	var _diffuseTexture:BaseTexture;
	public var diffuseTexture(get, set):BaseTexture;
	function get_diffuseTexture():BaseTexture {
		return _diffuseTexture;
	}
	function set_diffuseTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesAndMiscDirty();
		_diffuseTexture = value;
		return value;
	}

	@serializeAsTexture("ambientTexture")
	var _ambientTexture:BaseTexture;
	public var ambientTexture(get, set):BaseTexture;
	function get_ambientTexture():BaseTexture {
		return _ambientTexture;
	}
	function set_ambientTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		_ambientTexture = value;
		return value;
	}

	@serializeAsTexture("opacityTexture")
	var _opacityTexture:BaseTexture;        
	public var opacityTexture(get, set):BaseTexture;
	function get_opacityTexture():BaseTexture {
		return _opacityTexture;
	}
	function set_opacityTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesAndMiscDirty();
		_opacityTexture = value;
		return value;
	}

	@serializeAsTexture("reflectionTexture")
	var _reflectionTexture:BaseTexture;
	public var reflectionTexture(get, set):BaseTexture;
	function get_reflectionTexture():BaseTexture {
		return _reflectionTexture;
	}	
	function set_reflectionTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		_reflectionTexture = value;
		return value;
	}

	@serializeAsTexture("emissiveTexture")
	var _emissiveTexture:BaseTexture;
	public var emissiveTexture(get, set):BaseTexture;
	function get_emissiveTexture():BaseTexture {
		return _emissiveTexture;
	}	
	function set_emissiveTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		_emissiveTexture = value;
		return value;
	}

	@serializeAsTexture("specularTexture")
	var _specularTexture:BaseTexture;
	public var specularTexture(get, set):BaseTexture;
	function get_specularTexture():BaseTexture {
		return _specularTexture;
	}	
	function set_specularTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _specularTexture = value;
	}

	@serializeAsTexture("bumpTexture")
	var _bumpTexture:BaseTexture;
	public var bumpTexture(get, set):BaseTexture;
	function get_bumpTexture():BaseTexture {
		return _bumpTexture;
	}	
	function set_bumpTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		_bumpTexture = value;
		return value;
	}	

	@serializeAsTexture("lightmapTexture")
	var _lightmapTexture:BaseTexture;
	public var lightmapTexture(get, set):BaseTexture;
	function get_lightmapTexture():BaseTexture {
		return _lightmapTexture;
	}	
	function set_lightmapTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		_lightmapTexture = value;
		return value;
	}

	@serializeAsTexture("refractionTexture")
	var _refractionTexture:BaseTexture;
	public var refractionTexture(get, set):BaseTexture;
	function get_refractionTexture():BaseTexture {
		return _refractionTexture;
	}	
	function set_refractionTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		_refractionTexture = value;
		return value;
	}

	@serializeAsColor3("ambient")
	public var ambientColor:Color3 = new Color3(0, 0, 0);

	@serializeAsColor3("diffuse")
	public var diffuseColor:Color3 = new Color3(1, 1, 1);

	@serializeAsColor3("specular")
	public var specularColor:Color3 = new Color3(1, 1, 1);

	@serializeAsColor3("emissive")
	public var emissiveColor:Color3 = new Color3(0, 0, 0);

	@serialize()
	public var specularPower:Float = 64;

	@serialize("useAlphaFromDiffuseTexture")
	var _useAlphaFromDiffuseTexture:Bool = false;
	public var useAlphaFromDiffuseTexture(get, set):Bool; 
	function get_useAlphaFromDiffuseTexture():Bool {
		return _useAlphaFromDiffuseTexture;
	}
	function set_useAlphaFromDiffuseTexture(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useAlphaFromDiffuseTexture = value;
	}

	@serialize("useEmissiveAsIllumination")
	var _useEmissiveAsIllumination:Bool = false;
	public var useEmissiveAsIllumination(get, set):Bool; 
	function get_useEmissiveAsIllumination():Bool {
		return _useEmissiveAsIllumination;
	}
	function set_useEmissiveAsIllumination(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useEmissiveAsIllumination = value;
	}
  
	@serialize("linkEmissiveWithDiffuse")
	var _linkEmissiveWithDiffuse:Bool = false;
	public var linkEmissiveWithDiffuse(get, set):Bool;
	function get_linkEmissiveWithDiffuse():Bool {
		return _linkEmissiveWithDiffuse;
	}
	function set_linkEmissiveWithDiffuse(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _linkEmissiveWithDiffuse = value;
	}

	@serialize("useSpecularOverAlpha")
	var _useSpecularOverAlpha:Bool = false;
	public var useSpecularOverAlpha(get, set):Bool;
	function get_useSpecularOverAlpha():Bool {
		return _useSpecularOverAlpha;
	}
	function set_useSpecularOverAlpha(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useSpecularOverAlpha = value;
	}

	@serialize("useReflectionOverAlpha")
	var _useReflectionOverAlpha:Bool = false;
	public var useReflectionOverAlpha(get, set):Bool;
	function get_useReflectionOverAlpha():Bool {
		return _useReflectionOverAlpha;
	}
	function set_useReflectionOverAlpha(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useReflectionOverAlpha = value;
	}

	@serialize("disableLighting")
	var _disableLighting:Bool = false;
	public var disableLighting(get, set):Bool;
	function get_disableLighting():Bool {
		return _disableLighting;
	}
	function set_disableLighting(value:Bool):Bool {
		_markAllSubMeshesAsLightsDirty();
		return _disableLighting = value;
	}
	
	@serialize("useObjectSpaceNormalMap")
    private var _useObjectSpaceNormalMap:Bool = false;
    public var useObjectSpaceNormalMap(get, set):Bool;
	function get_useObjectSpaceNormalMap():Bool {
		return _useObjectSpaceNormalMap;
	}
	function set_useObjectSpaceNormalMap(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useObjectSpaceNormalMap = value;
	}

	@serialize("useParallax")
	var _useParallax:Bool = false;
	public var useParallax(get, set):Bool;
	function get_useParallax():Bool {
		return _useParallax;
	}
	function set_useParallax(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useParallax = value;
	}

	@serialize("useParallaxOcclusion")
	var _useParallaxOcclusion:Bool = false;
	public var useParallaxOcclusion(get, set):Bool;
	function get_useParallaxOcclusion():Bool {
		return _useParallaxOcclusion;
	}
	function set_useParallaxOcclusion(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useParallaxOcclusion = value;
	}

	@serialize()
	public var parallaxScaleBias:Float = 0.05;

	@serialize("roughness")
	var _roughness:Float = 0.0;
	public var roughness(get, set):Float;
	function get_roughness():Float {
		return _roughness;
	}
	function set_roughness(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _roughness = value;
	}

	@serialize()
	public var indexOfRefraction:Float = 0.98;

	@serialize()
	public var invertRefractionY:Bool = true;

	@serialize("useLightmapAsShadowmap")
	var _useLightmapAsShadowmap:Bool = false;
	public var useLightmapAsShadowmap(get, set):Bool;
	function get_useLightmapAsShadowmap():Bool {
		return _useLightmapAsShadowmap;
	}
	function set_useLightmapAsShadowmap(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useLightmapAsShadowmap = value;
	}

	// Fresnel
	@serializeAsFresnelParameters("diffuseFresnelParameters")
	var _diffuseFresnelParameters:FresnelParameters;
	public var diffuseFresnelParameters(get, set):FresnelParameters;
	function get_diffuseFresnelParameters():FresnelParameters {
		return _diffuseFresnelParameters;
	}
	function set_diffuseFresnelParameters(value:FresnelParameters):FresnelParameters {
		_markAllSubMeshesAsFresnelDirty();
		return _diffuseFresnelParameters = value;
	}

	@serializeAsFresnelParameters("opacityFresnelParameters")
	var _opacityFresnelParameters:FresnelParameters;
	public var opacityFresnelParameters(get, set):FresnelParameters;            
	function get_opacityFresnelParameters():FresnelParameters {
		return _opacityFresnelParameters;
	}
	function set_opacityFresnelParameters(value:FresnelParameters):FresnelParameters {
		_markAllSubMeshesAsFresnelAndMiscDirty();
		return _opacityFresnelParameters = value;
	}  

	@serializeAsFresnelParameters("reflectionFresnelParameters")
	var _reflectionFresnelParameters:FresnelParameters;
	public var reflectionFresnelParameters(get, set):FresnelParameters;
	function get_reflectionFresnelParameters():FresnelParameters {
		return _reflectionFresnelParameters;
	}
	function set_reflectionFresnelParameters(value:FresnelParameters):FresnelParameters {
		_markAllSubMeshesAsFresnelDirty();
		return _reflectionFresnelParameters = value;
	}

	@serializeAsFresnelParameters("refractionFresnelParameters")
	var _refractionFresnelParameters:FresnelParameters;
	public var refractionFresnelParameters(get, set):FresnelParameters;
	function get_refractionFresnelParameters():FresnelParameters {
		return _refractionFresnelParameters;
	}
	function set_refractionFresnelParameters(value:FresnelParameters):FresnelParameters {
		_markAllSubMeshesAsFresnelDirty();
		return _refractionFresnelParameters = value;
	}

	@serializeAsFresnelParameters("emissiveFresnelParameters")
	var _emissiveFresnelParameters:FresnelParameters;
	public var emissiveFresnelParameters(get, set):FresnelParameters;
	function get_emissiveFresnelParameters():FresnelParameters {
		return _emissiveFresnelParameters;
	}
	function set_emissiveFresnelParameters(value:FresnelParameters):FresnelParameters {
		_markAllSubMeshesAsFresnelDirty();
		return _emissiveFresnelParameters = value;
	}

	@serialize("useReflectionFresnelFromSpecular")
	var _useReflectionFresnelFromSpecular:Bool = false;    
	public var useReflectionFresnelFromSpecular(get, set):Bool;
	function get_useReflectionFresnelFromSpecular():Bool {
		return _useReflectionFresnelFromSpecular;
	}
	function set_useReflectionFresnelFromSpecular(value:Bool):Bool {
		_markAllSubMeshesAsFresnelDirty();
		return _useReflectionFresnelFromSpecular = value;
	}

	@serialize("useGlossinessFromSpecularMapAlpha")
	var _useGlossinessFromSpecularMapAlpha:Bool = false;
	public var useGlossinessFromSpecularMapAlpha(get, set):Bool;
	function get_useGlossinessFromSpecularMapAlpha():Bool {
		return _useGlossinessFromSpecularMapAlpha;
	}
	function set_useGlossinessFromSpecularMapAlpha(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useGlossinessFromSpecularMapAlpha = value;
	}

	@serialize("maxSimultaneousLights")
	var _maxSimultaneousLights:Int = 4;
	public var maxSimultaneousLights(get, set):Int;
	function get_maxSimultaneousLights():Int {
		return _maxSimultaneousLights;
	}
	function set_maxSimultaneousLights(value:Int):Int {
		_markAllSubMeshesAsLightsDirty();
		return _maxSimultaneousLights = value;
	}

	/**
	 * If sets to true, x component of normal map value will invert (x = 1.0 - x).
	 */
	@serialize("invertNormalMapX")
	var _invertNormalMapX:Bool = false;
	public var invertNormalMapX(get, set):Bool;
	function get_invertNormalMapX():Bool {
		return _invertNormalMapX;
	}	
	function set_invertNormalMapX(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _invertNormalMapX = value;
	}

	/**
	 * If sets to true, y component of normal map value will invert (y = 1.0 - y).
	 */
	@serialize("invertNormalMapY")
	var _invertNormalMapY:Bool = false;
	public var invertNormalMapY(get, set):Bool;
	function get_invertNormalMapY():Bool {
		return _invertNormalMapY;
	}	
	function set_invertNormalMapY(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _invertNormalMapY = value;
	}

	/**
	 * If sets to true and backfaceCulling is false, normals will be flipped on the backside.
	 */
	@serialize("twoSidedLighting")
	var _twoSidedLighting:Bool = false;
	public var twoSidedLighting(get, set):Bool;
	function get_twoSidedLighting():Bool {
		return _twoSidedLighting;
	}	
	function set_twoSidedLighting(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _twoSidedLighting = value;
	}

	/**
	 * Default configuration related to image processing available in the standard Material.
	 */
	private var _imageProcessingConfiguration:ImageProcessingConfiguration;

	public var imageProcessingConfiguration(get, set):ImageProcessingConfiguration;
	/**
	 * Gets the image processing configuration used either in this material.
	 */
	private function get_imageProcessingConfiguration():ImageProcessingConfiguration {
		return this._imageProcessingConfiguration;
	}
	/**
	 * Sets the Default image processing configuration used either in the this material.
	 * 
	 * If sets to null, the scene one is in use.
	 */
	private function set_imageProcessingConfiguration(value:ImageProcessingConfiguration):ImageProcessingConfiguration {
		this._attachImageProcessingConfiguration(value);
		
		// Ensure the effect will be rebuilt.
		this._markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Keep track of the image processing observer to allow dispose and replace.
	 */
	private var _imageProcessingObserver:Observer<ImageProcessingConfiguration>;

	/**
	 * Attaches a new image processing configuration to the Standard Material.
	 * @param configuration 
	 */
	private function _attachImageProcessingConfiguration(configuration:ImageProcessingConfiguration) {
		if (configuration != null && configuration == this._imageProcessingConfiguration) {
			return;
		}
		
		// Detaches observer.
		if (this._imageProcessingConfiguration != null && this._imageProcessingObserver != null) {
			this._imageProcessingConfiguration.onUpdateParameters.remove(this._imageProcessingObserver);
		}
		
		// Pick the scene configuration if needed.
		if (configuration == null) {
			this._imageProcessingConfiguration = this.getScene().imageProcessingConfiguration;
		}
		else {
			this._imageProcessingConfiguration = configuration;
		}
		
		// Attaches observer.
		this._imageProcessingObserver = this._imageProcessingConfiguration.onUpdateParameters.add(function(_, _) {
			this._markAllSubMeshesAsImageProcessingDirty();
		});
	}

	public var cameraColorCurvesEnabled(get, set):Bool;
	/**
	 * Gets wether the color curves effect is enabled.
	 */
	private function get_cameraColorCurvesEnabled():Bool {
		return this.imageProcessingConfiguration.colorCurvesEnabled;
	}
	/**
	 * Sets wether the color curves effect is enabled.
	 */
	private function set_cameraColorCurvesEnabled(value:Bool):Bool {
		return this.imageProcessingConfiguration.colorCurvesEnabled = value;
	}

	public var cameraColorGradingEnabled(get, set):Bool;
	/**
	 * Gets wether the color grading effect is enabled.
	 */
	private function get_cameraColorGradingEnabled():Bool {
		return this.imageProcessingConfiguration.colorGradingEnabled;
	}
	/**
	 * Gets wether the color grading effect is enabled.
	 */
	private function set_cameraColorGradingEnabled(value:Bool):Bool {
		return this.imageProcessingConfiguration.colorGradingEnabled = value;
	}

	public var cameraToneMappingEnabled(get, set):Bool;
	/**
	 * Gets wether tonemapping is enabled or not.
	 */
	private function get_cameraToneMappingEnabled():Bool {
		return this._imageProcessingConfiguration.toneMappingEnabled;
	}
	/**
	 * Sets wether tonemapping is enabled or not
	 */
	private function set_cameraToneMappingEnabled(value:Bool):Bool {
		return this._imageProcessingConfiguration.toneMappingEnabled = value;
	}

	public var cameraExposure(get, set):Float;
	/**
	 * The camera exposure used on this material.
	 * This property is here and not in the camera to allow controlling exposure without full screen post process.
	 * This corresponds to a photographic exposure.
	 */
	private function get_cameraExposure():Float {
		return this._imageProcessingConfiguration.exposure;
	}
	/**
	 * The camera exposure used on this material.
	 * This property is here and not in the camera to allow controlling exposure without full screen post process.
	 * This corresponds to a photographic exposure.
	 */
	private function set_cameraExposure(value:Float):Float {
		return this._imageProcessingConfiguration.exposure = value;
	}
	
	public var cameraContrast(get, set):Float;
	/**
	 * Gets The camera contrast used on this material.
	 */
	private function get_cameraContrast():Float {
		return this._imageProcessingConfiguration.contrast;
	}
	/**
	 * Sets The camera contrast used on this material.
	 */
	private function set_cameraContrast(value:Float):Float {
		return this._imageProcessingConfiguration.contrast = value;
	}
	
	public var cameraColorGradingTexture(get, set):BaseTexture;
	/**
	 * Gets the Color Grading 2D Lookup Texture.
	 */
	private function get_cameraColorGradingTexture():BaseTexture {
		return this._imageProcessingConfiguration.colorGradingTexture;
	}
	/**
	 * Sets the Color Grading 2D Lookup Texture.
	 */
	private function set_cameraColorGradingTexture(value:BaseTexture):BaseTexture {
		return this._imageProcessingConfiguration.colorGradingTexture = value;
	}
	
	public var cameraColorCurves(get, set):ColorCurves;
	/**
     * The color grading curves provide additional color adjustmnent that is applied after any color grading transform (3D LUT). 
     * They allow basic adjustment of saturation and small exposure adjustments, along with color filter tinting to provide white balance adjustment or more stylistic effects.
     * These are similar to controls found in many professional imaging or colorist software. The global controls are applied to the entire image. For advanced tuning, extra controls are provided to adjust the shadow, midtone and highlight areas of the image; 
     * corresponding to low luminance, medium luminance, and high luminance areas respectively.
     */
    inline private function get_cameraColorCurves():ColorCurves {
        return this._imageProcessingConfiguration.colorCurves;
    }
    /**
     * The color grading curves provide additional color adjustmnent that is applied after any color grading transform (3D LUT). 
     * They allow basic adjustment of saturation and small exposure adjustments, along with color filter tinting to provide white balance adjustment or more stylistic effects.
     * These are similar to controls found in many professional imaging or colorist software. The global controls are applied to the entire image. For advanced tuning, extra controls are provided to adjust the shadow, midtone and highlight areas of the image; 
     * corresponding to low luminance, medium luminance, and high luminance areas respectively.
     */
	inline private function set_cameraColorCurves(value:ColorCurves):ColorCurves {
        return this._imageProcessingConfiguration.colorCurves = value;
    }

	public var customShaderNameResolve:String->Array<String>->Array<String>->Array<String>->StandardMaterialDefines->String;

	public var _renderTargets:SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(16);
	public var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	public var _globalAmbientColor:Color3 = new Color3(0, 0, 0);

	public var _useLogarithmicDepth:Bool = false;
	
	
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		// Setup the default processing configuration to the scene.
		this._attachImageProcessingConfiguration(null);
		
		this.getRenderTargetTextures = function():SmartArray<RenderTargetTexture> {
			this._renderTargets.reset();
			
			if (StandardMaterial.ReflectionTextureEnabled && this._reflectionTexture != null && this._reflectionTexture.isRenderTarget) {
				this._renderTargets.push(cast this._reflectionTexture);
			}
			
			if (StandardMaterial.RefractionTextureEnabled && this._refractionTexture != null && this._refractionTexture.isRenderTarget) {
				this._renderTargets.push(cast this._refractionTexture);
			}
			
			return this._renderTargets;
		}
	}

	override public function getClassName():String {
		return "StandardMaterial";
	}        

	@serialize()
	public var useLogarithmicDepth(get, set):Bool;
	function get_useLogarithmicDepth():Bool {
		return this._useLogarithmicDepth;
	}

	function set_useLogarithmicDepth(value:Bool):Bool {
		this._useLogarithmicDepth = value && this.getScene().getEngine().getCaps().fragmentDepthSupported;
		
		this._markAllSubMeshesAsMiscDirty();
		return value;
	}

	override public function needAlphaBlending():Bool {
		return (this.alpha < 1.0) || (this._opacityTexture != null) || this._shouldUseAlphaFromDiffuseTexture() || this._opacityFresnelParameters != null && this._opacityFresnelParameters.isEnabled;
	}

	override public function needAlphaTesting():Bool {
		return this._diffuseTexture != null && this._diffuseTexture.hasAlpha;
	}

	public function _shouldUseAlphaFromDiffuseTexture():Bool {
		return this._diffuseTexture != null && this._diffuseTexture.hasAlpha && this._useAlphaFromDiffuseTexture;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return this._diffuseTexture;
	}

	/**
	 * Child classes can use it to update shaders
	 */
	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool {            
		if (subMesh.effect != null && this.isFrozen) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new StandardMaterialDefines();
		}
		
		var scene = this.getScene();
		var defines:StandardMaterialDefines = cast subMesh._materialDefines;
		if (!this.checkReadyOnEveryCall && subMesh.effect != null) {
			if (defines._renderId == scene.getRenderId()) {
				return true;
			}
		}
		
		var engine = scene.getEngine();
		
		// Lights
		defines._needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, true, this._maxSimultaneousLights, this._disableLighting);
		
		// Textures
		if (defines._areTexturesDirty) {
			defines._needUVs = false;
			defines.MAINUV1 = 0;
            defines.MAINUV2 = 0;
			if (scene.texturesEnabled) {
				if (this._diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					if (!this._diffuseTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						MaterialHelper.PrepareDefinesForMergedUV(this._diffuseTexture, defines, "DIFFUSE");
					}
				} 
				else {
					defines.DIFFUSE = 0;
				}
				
				if (this._ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
					if (!this._ambientTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						MaterialHelper.PrepareDefinesForMergedUV(this._ambientTexture, defines, "AMBIENT");
					}
				} 
				else {
					defines.AMBIENT = 0;
				}
				
				if (this._opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
					if (!this._opacityTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						MaterialHelper.PrepareDefinesForMergedUV(this._opacityTexture, defines, "OPACITY");
						defines.OPACITYRGB = this._opacityTexture.getAlphaFromRGB ? 1 : 0;
					}
				} 
				else {
					defines.OPACITY = 0;
				}
				
				if (this._reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					if (!this._reflectionTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						defines._needNormals = true;
						defines.REFLECTION = 1;
						
						defines.ROUGHNESS = (this._roughness > 0) ? 1 : 0;
						defines.REFLECTIONOVERALPHA = this._useReflectionOverAlpha ? 1 : 0;
						defines.INVERTCUBICMAP = (this._reflectionTexture.coordinatesMode == Texture.INVCUBIC_MODE) ? 1 : 0;
						defines.REFLECTIONMAP_3D = this._reflectionTexture.isCube ? 1 : 0;
						
						switch (this._reflectionTexture.coordinatesMode) {
							case Texture.CUBIC_MODE, Texture.INVCUBIC_MODE:
								defines.setReflectionMode("REFLECTIONMAP_CUBIC");
								
							case Texture.EXPLICIT_MODE:
								defines.setReflectionMode("REFLECTIONMAP_EXPLICIT");
								
							case Texture.PLANAR_MODE:
								defines.setReflectionMode("REFLECTIONMAP_PLANAR");
								
							case Texture.PROJECTION_MODE:
								defines.setReflectionMode("REFLECTIONMAP_PROJECTION");
								
							case Texture.SKYBOX_MODE:
								defines.setReflectionMode("REFLECTIONMAP_SKYBOX");
								
							case Texture.SPHERICAL_MODE:
								defines.setReflectionMode("REFLECTIONMAP_SPHERICAL");
								
							case Texture.EQUIRECTANGULAR_MODE:
								defines.setReflectionMode("REFLECTIONMAP_EQUIRECTANGULAR");
								
							case Texture.FIXED_EQUIRECTANGULAR_MODE:
								defines.setReflectionMode("REFLECTIONMAP_EQUIRECTANGULAR_FIXED");
								
							case Texture.FIXED_EQUIRECTANGULAR_MIRRORED_MODE:
								defines.setReflectionMode("REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED");
								
						}
						
						defines.USE_LOCAL_REFLECTIONMAP_CUBIC = untyped reflectionTexture.boundingBoxSize == null ? 0 : 1;
					}
				} 
				else {
					defines.REFLECTION = 0;
				}
				
				if (this._emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
					if (!this._emissiveTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						MaterialHelper.PrepareDefinesForMergedUV(this._emissiveTexture, defines, "EMISSIVE");
					}
				} 
				else {
					defines.EMISSIVE = 0;
				}
				
				if (this._lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
					if (!this._lightmapTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						MaterialHelper.PrepareDefinesForMergedUV(this._lightmapTexture, defines, "LIGHTMAP");
						defines.USELIGHTMAPASSHADOWMAP = this._useLightmapAsShadowmap ? 1 : 0;
					}
				} 
				else {
					defines.LIGHTMAP = 0;
				}
				
				if (this._specularTexture != null && StandardMaterial.SpecularTextureEnabled) {
					if (!this._specularTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						MaterialHelper.PrepareDefinesForMergedUV(this._specularTexture, defines, "SPECULAR");
						defines.GLOSSINESS = this._useGlossinessFromSpecularMapAlpha ? 1 : 0;
					}
				} 
				else {
					defines.SPECULAR = 0;
				}
				
				if (scene.getEngine().getCaps().standardDerivatives && this._bumpTexture != null && StandardMaterial.BumpTextureEnabled) {
					if (!this._bumpTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						MaterialHelper.PrepareDefinesForMergedUV(this._bumpTexture, defines, "BUMP");
						
						defines.PARALLAX = this._useParallax ? 1 : 0;
						defines.PARALLAXOCCLUSION = this._useParallaxOcclusion ? 1 : 0;
					}
					
					defines.OBJECTSPACE_NORMALMAP = this._useObjectSpaceNormalMap ? 1 : 0;
				} 
				else {
					defines.BUMP = 0;
				}
				
				if (this._refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
					if (!this._refractionTexture.isReadyOrNotBlocking()) {
						return false;
					} 
					else {
						defines._needUVs = true;
						defines.REFRACTION = 1;
						
						defines.REFRACTIONMAP_3D = this._refractionTexture.isCube ? 1 : 0;
					}
				} 
				else {
					defines.REFRACTION = 0;
				}
				
				defines.TWOSIDEDLIGHTING = !this._backFaceCulling && this._twoSidedLighting ? 1 : 0;
			} 
			else {
				defines.DIFFUSE = 0;
				defines.AMBIENT = 0;
				defines.OPACITY = 0;
				defines.REFLECTION = 0;
				defines.EMISSIVE = 0;
				defines.LIGHTMAP = 0;
				defines.BUMP = 0;
				defines.REFRACTION = 0;
			}
			
			defines.ALPHAFROMDIFFUSE = this._shouldUseAlphaFromDiffuseTexture() ? 1 : 0;
			
			defines.EMISSIVEASILLUMINATION = this._useEmissiveAsIllumination ? 1 : 0;
			
			defines.LINKEMISSIVEWITHDIFFUSE = this._linkEmissiveWithDiffuse ? 1 : 0;   
			
			defines.SPECULAROVERALPHA = this._useSpecularOverAlpha ? 1 : 0;
			
			defines.PREMULTIPLYALPHA = (this.alphaMode == Engine.ALPHA_PREMULTIPLIED || this.alphaMode == Engine.ALPHA_PREMULTIPLIED_PORTERDUFF) ? 1 : 0;
		}
		
		if (defines._areImageProcessingDirty) {
			if (!this._imageProcessingConfiguration.isReady()) {
				return false;
			}
			
			this._imageProcessingConfiguration.prepareDefines(defines);
		}
		
		if (defines._areFresnelDirty) {
			if (StandardMaterial.FresnelEnabled) {
				// Fresnel
				if (this._diffuseFresnelParameters != null || this._opacityFresnelParameters != null ||
					this._emissiveFresnelParameters != null || this._refractionFresnelParameters != null ||
					this._reflectionFresnelParameters != null) {
						
					defines.DIFFUSEFRESNEL = (this._diffuseFresnelParameters != null && this._diffuseFresnelParameters.isEnabled) ? 1 : 0;
					
					defines.OPACITYFRESNEL = (this._opacityFresnelParameters != null && this._opacityFresnelParameters.isEnabled) ? 1 : 0;
					
					defines.REFLECTIONFRESNEL = (this._reflectionFresnelParameters != null && this._reflectionFresnelParameters.isEnabled) ? 1 : 0;
					
					defines.REFLECTIONFRESNELFROMSPECULAR = this._useReflectionFresnelFromSpecular ? 1 : 0;
					
					defines.REFRACTIONFRESNEL = (this._refractionFresnelParameters != null && this._refractionFresnelParameters.isEnabled) ? 1 : 0;
					
					defines.EMISSIVEFRESNEL = (this._emissiveFresnelParameters != null && this._emissiveFresnelParameters.isEnabled) ? 1 : 0;
					
					defines._needNormals = true;
					defines.FRESNEL = 1;
				}
			} 
			else {
				defines.FRESNEL = 0;
			}
		}
		
		// Misc.
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, this._useLogarithmicDepth, this.pointsCloud, this.fogEnabled, this._shouldTurnAlphaTestOn(mesh), defines);
		
		// Attribs
		MaterialHelper.PrepareDefinesForAttributes(mesh, defines, true, true, true);
		
		// Values that need to be evaluated on every frame
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances);
		
		// Get correct effect      
		if (defines.isDirty) {
			defines.markAsProcessed();
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();
			if (defines.REFLECTION != 0) {
				fallbacks.addFallback(0, "REFLECTION");
			}
			
			if (defines.SPECULAR != 0) {
				fallbacks.addFallback(0, "SPECULAR");
			}
			
			if (defines.BUMP != 0) {
				fallbacks.addFallback(0, "BUMP");
			}
			
			if (defines.PARALLAX != 0) {
				fallbacks.addFallback(1, "PARALLAX");
			}
			
			if (defines.PARALLAXOCCLUSION != 0) {
				fallbacks.addFallback(0, "PARALLAXOCCLUSION");
			}
			
			if (defines.SPECULAROVERALPHA != 0) {
				fallbacks.addFallback(0, "SPECULAROVERALPHA");
			}
			
			if (defines.FOG != 0) {
				fallbacks.addFallback(1, "FOG");
			}
			
			if (defines.POINTSIZE != 0) {
				fallbacks.addFallback(0, "POINTSIZE");
			}
			
			if (defines.LOGARITHMICDEPTH != 0) {
				fallbacks.addFallback(0, "LOGARITHMICDEPTH");
			}
			
			MaterialHelper.HandleFallbacksForShadows(defines, fallbacks, this._maxSimultaneousLights);
			
			if (defines.SPECULARTERM != 0) {
				fallbacks.addFallback(0, "SPECULARTERM");
			}
			
			if (defines.DIFFUSEFRESNEL != 0) {
				fallbacks.addFallback(1, "DIFFUSEFRESNEL");
			}
			
			if (defines.OPACITYFRESNEL != 0) {
				fallbacks.addFallback(2, "OPACITYFRESNEL");
			}
			
			if (defines.REFLECTIONFRESNEL != 0) {
				fallbacks.addFallback(3, "REFLECTIONFRESNEL");
			}
			
			if (defines.EMISSIVEFRESNEL != 0) {
				fallbacks.addFallback(4, "EMISSIVEFRESNEL");
			}
			
			if (defines.FRESNEL != 0) {
				fallbacks.addFallback(4, "FRESNEL");
			}
			
			//Attributes
			var attribs = [VertexBuffer.PositionKind];
			
			if (defines.NORMAL != 0) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (defines.UV1 != 0) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (defines.UV2 != 0) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (defines.VERTEXCOLOR != 0) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, defines.NUM_BONE_INFLUENCERS, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, defines);
			MaterialHelper.PrepareAttributesForMorphTargets(attribs, mesh, defines);
			
			var shaderName = "default";
			
			var uniforms = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vAmbientColor", "vDiffuseColor", "vSpecularColor", "vEmissiveColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vDiffuseInfos", "vAmbientInfos", "vOpacityInfos", "vReflectionInfos", "vEmissiveInfos", "vSpecularInfos", "vBumpInfos", "vLightmapInfos", "vRefractionInfos",
				"mBones",
				"vClipPlane", "diffuseMatrix", "ambientMatrix", "opacityMatrix", "reflectionMatrix", "emissiveMatrix", "specularMatrix", "bumpMatrix", "normalMatrix", "lightmapMatrix", "refractionMatrix",
				"diffuseLeftColor", "diffuseRightColor", "opacityParts", "reflectionLeftColor", "reflectionRightColor", "emissiveLeftColor", "emissiveRightColor", "refractionLeftColor", "refractionRightColor",
				"vReflectionPosition", "vReflectionSize",
				"logarithmicDepthConstant", "vTangentSpaceParams"
			];
			
			var samplers = ["diffuseSampler", "ambientSampler", "opacitySampler", "reflectionCubeSampler", "reflection2DSampler", "emissiveSampler", "specularSampler", "bumpSampler", "lightmapSampler", "refractionCubeSampler", "refraction2DSampler"];
			
			var uniformBuffers = ["Material", "Scene"];
			
			ImageProcessingConfiguration.PrepareUniforms(uniforms, defines);
            ImageProcessingConfiguration.PrepareSamplers(samplers, defines);
			
			MaterialHelper.PrepareUniformsAndSamplersList({
				uniformsNames: uniforms, 
				uniformBuffersNames: uniformBuffers,
				samplers: samplers, 
				defines: defines, 
				maxSimultaneousLights: this._maxSimultaneousLights
			});
			
			if (this.customShaderNameResolve != null) {
				shaderName = this.customShaderNameResolve(shaderName, uniforms, uniformBuffers, samplers, defines);
			}
			
			var join = defines.toString();
			/*trace(join);
			trace(attribs, attribs.length);
			trace(uniforms, uniforms.length);
			trace(samplers, samplers.length);*/
			subMesh.setEffect(scene.getEngine().createEffect(shaderName, {
				attributes: attribs,
				uniformsNames: uniforms,
				uniformBuffersNames: uniformBuffers,
				samplers: samplers,
				defines: join,
				fallbacks: fallbacks,
				onCompiled: this.onCompiled,
				onError: this.onError,
				indexParameters: { maxSimultaneousLights: this._maxSimultaneousLights, maxSimultaneousMorphTargets: defines.NUM_MORPH_INFLUENCERS }
			}, engine), defines);
			
			this.buildUniformLayout();
		}
		
		if (subMesh.effect == null && !subMesh.effect.isReady()) {
			return false;
		}
		
		defines._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		return true;
	}

	public function buildUniformLayout() {
		// Order is important !
		this._uniformBuffer.addUniform("diffuseLeftColor", 4);
		this._uniformBuffer.addUniform("diffuseRightColor", 4);
		this._uniformBuffer.addUniform("opacityParts", 4);
		this._uniformBuffer.addUniform("reflectionLeftColor", 4);
		this._uniformBuffer.addUniform("reflectionRightColor", 4);
		this._uniformBuffer.addUniform("refractionLeftColor", 4);
		this._uniformBuffer.addUniform("refractionRightColor", 4);
		this._uniformBuffer.addUniform("emissiveLeftColor", 4);
		this._uniformBuffer.addUniform("emissiveRightColor", 4);
		
		this._uniformBuffer.addUniform("vDiffuseInfos", 2);
		this._uniformBuffer.addUniform("vAmbientInfos", 2);
		this._uniformBuffer.addUniform("vOpacityInfos", 2);
		this._uniformBuffer.addUniform("vReflectionInfos", 2);
		this._uniformBuffer.addUniform("vReflectionPosition", 3);
        this._uniformBuffer.addUniform("vReflectionSize", 3);
		this._uniformBuffer.addUniform("vEmissiveInfos", 2);
		this._uniformBuffer.addUniform("vLightmapInfos", 2);
		this._uniformBuffer.addUniform("vSpecularInfos", 2);
		this._uniformBuffer.addUniform("vBumpInfos", 3);
		
		this._uniformBuffer.addUniform("diffuseMatrix", 16);
		this._uniformBuffer.addUniform("ambientMatrix", 16);
		this._uniformBuffer.addUniform("opacityMatrix", 16);
		this._uniformBuffer.addUniform("reflectionMatrix", 16);
		this._uniformBuffer.addUniform("emissiveMatrix", 16);
		this._uniformBuffer.addUniform("lightmapMatrix", 16);
		this._uniformBuffer.addUniform("specularMatrix", 16);
		this._uniformBuffer.addUniform("bumpMatrix", 16);
		this._uniformBuffer.addUniform("vTangentSpaceParams", 2);
		this._uniformBuffer.addUniform("refractionMatrix", 16);
		this._uniformBuffer.addUniform("vRefractionInfos", 4);
		this._uniformBuffer.addUniform("vSpecularColor", 4);
		this._uniformBuffer.addUniform("vEmissiveColor", 3);
		this._uniformBuffer.addUniform("vDiffuseColor", 4);
		this._uniformBuffer.addUniform("pointSize", 1);
		
		this._uniformBuffer.create();
	}

	override public function unbind() {
		if (this._activeEffect != null) {
			if (this._reflectionTexture != null && this._reflectionTexture.isRenderTarget) {
				this._activeEffect.setTexture("reflection2DSampler", null);
			}
			
			if (this._refractionTexture != null && this._refractionTexture.isRenderTarget) {
				this._activeEffect.setTexture("refraction2DSampler", null);
			}
		}
		
		super.unbind();
	}

	override public function bindForSubMesh(world:Matrix, mesh:Mesh, subMesh:SubMesh) {
		var scene = this.getScene();
		
		var defines:StandardMaterialDefines = cast subMesh._materialDefines;
		if (defines == null) {
			return;
		}
		
		var effect = subMesh.effect;
		if (effect == null) {
			return;
		}
		this._activeEffect = effect;
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		
		// Normal Matrix
        if (defines.OBJECTSPACE_NORMALMAP > 0) {
            world.toNormalMatrix(this._normalMatrix);
            this.bindOnlyNormalMatrix(this._normalMatrix);               
        }
		
		var mustRebind = this._mustRebind(scene, effect, mesh.visibility);
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, effect);
		if (mustRebind) {
			this._uniformBuffer.bindToEffect(effect, "Material");
			
			this.bindViewProjection(effect);
			if (!this._uniformBuffer.useUbo || !this.isFrozen || !this._uniformBuffer.isSync) {
				if (StandardMaterial.FresnelEnabled && (defines.FRESNEL != 0)) {
					// Fresnel
					if (this.diffuseFresnelParameters != null && this.diffuseFresnelParameters.isEnabled) {
						this._uniformBuffer.updateColor4("diffuseLeftColor", this.diffuseFresnelParameters.leftColor, this.diffuseFresnelParameters.power);
						this._uniformBuffer.updateColor4("diffuseRightColor", this.diffuseFresnelParameters.rightColor, this.diffuseFresnelParameters.bias);
					}
					
					if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled) {
						this._uniformBuffer.updateColor4("opacityParts", new Color3(this.opacityFresnelParameters.leftColor.toLuminance(), this.opacityFresnelParameters.rightColor.toLuminance(), this.opacityFresnelParameters.bias), this.opacityFresnelParameters.power);
					}
					
					if (this.reflectionFresnelParameters != null && this.reflectionFresnelParameters.isEnabled) {
						this._uniformBuffer.updateColor4("reflectionLeftColor", this.reflectionFresnelParameters.leftColor, this.reflectionFresnelParameters.power);
						this._uniformBuffer.updateColor4("reflectionRightColor", this.reflectionFresnelParameters.rightColor, this.reflectionFresnelParameters.bias);
					}
					
					if (this.refractionFresnelParameters != null && this.refractionFresnelParameters.isEnabled) {
						this._uniformBuffer.updateColor4("refractionLeftColor", this.refractionFresnelParameters.leftColor, this.refractionFresnelParameters.power);
						this._uniformBuffer.updateColor4("refractionRightColor", this.refractionFresnelParameters.rightColor, this.refractionFresnelParameters.bias);
					}
					
					if (this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
						this._uniformBuffer.updateColor4("emissiveLeftColor", this.emissiveFresnelParameters.leftColor, this.emissiveFresnelParameters.power);
						this._uniformBuffer.updateColor4("emissiveRightColor", this.emissiveFresnelParameters.rightColor, this.emissiveFresnelParameters.bias);
					}
				}
				
				// Textures     
				if (scene.texturesEnabled) {
					if (this._diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
						this._uniformBuffer.updateFloat2("vDiffuseInfos", this._diffuseTexture.coordinatesIndex, this._diffuseTexture.level);
						MaterialHelper.BindTextureMatrix(this._diffuseTexture, this._uniformBuffer, "diffuse");
					}
					
					if (this._ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
						this._uniformBuffer.updateFloat2("vAmbientInfos", this._ambientTexture.coordinatesIndex, this._ambientTexture.level);
						MaterialHelper.BindTextureMatrix(this._ambientTexture, this._uniformBuffer, "ambient");
					}
					
					if (this._opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
						this._uniformBuffer.updateFloat2("vOpacityInfos", this._opacityTexture.coordinatesIndex, this._opacityTexture.level);
						MaterialHelper.BindTextureMatrix(this._opacityTexture, this._uniformBuffer, "opacity");
					}
					
					if (this._reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
						this._uniformBuffer.updateFloat2("vReflectionInfos", this._reflectionTexture.level, this.roughness);
						this._uniformBuffer.updateMatrix("reflectionMatrix", this._reflectionTexture.getReflectionTextureMatrix());
						
						if (untyped this._reflectionTexture.boundingBoxSize != null) {
                            var cubeTexture:CubeTexture = cast this._reflectionTexture;
							
                            this._uniformBuffer.updateVector3("vReflectionPosition", cubeTexture.boundingBoxPosition);
                            this._uniformBuffer.updateVector3("vReflectionSize", cubeTexture.boundingBoxSize);
                        }
					}
					
					if (this._emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
						this._uniformBuffer.updateFloat2("vEmissiveInfos", this._emissiveTexture.coordinatesIndex, this._emissiveTexture.level);
						MaterialHelper.BindTextureMatrix(this._emissiveTexture, this._uniformBuffer, "emissive");
					}
					
					if (this._lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
						this._uniformBuffer.updateFloat2("vLightmapInfos", this._lightmapTexture.coordinatesIndex, this._lightmapTexture.level);
						MaterialHelper.BindTextureMatrix(this._lightmapTexture, this._uniformBuffer, "lightmap");
					}
					
					if (this._specularTexture != null && StandardMaterial.SpecularTextureEnabled) {
						this._uniformBuffer.updateFloat2("vSpecularInfos", this._specularTexture.coordinatesIndex, this._specularTexture.level);
						MaterialHelper.BindTextureMatrix(this._specularTexture, this._uniformBuffer, "specular");
					}
					
					if (this._bumpTexture != null && scene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled) {
						this._uniformBuffer.updateFloat3("vBumpInfos", this._bumpTexture.coordinatesIndex, 1.0 / this._bumpTexture.level, this.parallaxScaleBias);
						MaterialHelper.BindTextureMatrix(this._bumpTexture, this._uniformBuffer, "bump");
						
						if (scene._mirroredCameraPosition != null) {
                            this._uniformBuffer.updateFloat2("vTangentSpaceParams", this.invertNormalMapX ? 1.0 : -1.0, this.invertNormalMapY ? 1.0 : -1.0);
                        } 
						else {
                            this._uniformBuffer.updateFloat2("vTangentSpaceParams", this.invertNormalMapX ? -1.0 : 1.0, this.invertNormalMapY ? -1.0 : 1.0);
                        } 
					}
					
					if (this._refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
						var depth = 1.0;
						if (!this._refractionTexture.isCube) {
							this._uniformBuffer.updateMatrix("refractionMatrix", this._refractionTexture.getReflectionTextureMatrix());
							
							if (Std.is(this.refractionTexture, RefractionTexture)) {
								depth = untyped this.refractionTexture.depth;
							}
						}
						this._uniformBuffer.updateFloat4("vRefractionInfos", this._refractionTexture.level, this.indexOfRefraction, depth, this.invertRefractionY ? -1 : 1);
					}                    
				}
				
				// Point size
				if (this.pointsCloud) {
					this._uniformBuffer.updateFloat("pointSize", this.pointSize);
				}
				
				if (defines.SPECULARTERM != 0) {
					this._uniformBuffer.updateColor4("vSpecularColor", this.specularColor, this.specularPower);
				}
				this._uniformBuffer.updateColor3("vEmissiveColor", this.emissiveColor);
				
				// Diffuse
				this._uniformBuffer.updateColor4("vDiffuseColor", this.diffuseColor, this.alpha * mesh.visibility);
			}
			
			// Textures     
			if (scene.texturesEnabled) {
				if (this._diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					effect.setTexture("diffuseSampler", this._diffuseTexture);
				}
				
				if (this._ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
					effect.setTexture("ambientSampler", this._ambientTexture);
				}
				
				if (this._opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
					effect.setTexture("opacitySampler", this._opacityTexture);
				}
				
				if (this._reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					if (this._reflectionTexture.isCube) {
						effect.setTexture("reflectionCubeSampler", this._reflectionTexture);
					} 
					else {
						effect.setTexture("reflection2DSampler", this._reflectionTexture);
					}
				}
				
				if (this._emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
					effect.setTexture("emissiveSampler", this._emissiveTexture);
				}
				
				if (this._lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
					effect.setTexture("lightmapSampler", this._lightmapTexture);
				}
				
				if (this._specularTexture != null && StandardMaterial.SpecularTextureEnabled) {
					effect.setTexture("specularSampler", this._specularTexture);
				}
				
				if (this._bumpTexture != null && scene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled) {
					effect.setTexture("bumpSampler", this._bumpTexture);
				}
				
				if (this._refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
					if (this._refractionTexture.isCube) {
						effect.setTexture("refractionCubeSampler", this._refractionTexture);
					} 
					else {
						effect.setTexture("refraction2DSampler", this._refractionTexture);
					}
				}
			}
			
			// Clip plane
			MaterialHelper.BindClipPlane(effect, scene);
			
			// Colors
			scene.ambientColor.multiplyToRef(this.ambientColor, this._globalAmbientColor);
			
			MaterialHelper.BindEyePosition(effect, scene);
			effect.setColor3("vAmbientColor", this._globalAmbientColor);
		}
		
		if (mustRebind || !this.isFrozen) {
			// Lights
			if (scene.lightsEnabled && !this._disableLighting) {
				MaterialHelper.BindLights(scene, mesh, effect, defines.SPECULARTERM == 1, this._maxSimultaneousLights);
			}
			
			// View
			if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE || this._reflectionTexture != null || this._refractionTexture != null) {
				this.bindView(effect);
			}
			
			// Fog
			MaterialHelper.BindFogParameters(scene, mesh, effect);
			
			// Morph targets
			if (defines.NUM_MORPH_INFLUENCERS > 0) {
				MaterialHelper.BindMorphTargetParameters(mesh, effect);                
			}
			
			// Log. depth
			MaterialHelper.BindLogDepth(defines.LOGARITHMICDEPTH == 1, effect, scene);
			
			// image processing
			if (!this._imageProcessingConfiguration.applyByPostProcess) {
				this._imageProcessingConfiguration.bind(this._activeEffect);
			}
		}
		
		this._uniformBuffer.update();
		this._afterBind(mesh, this._activeEffect);
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this._diffuseTexture != null && this._diffuseTexture.animations != null && this._diffuseTexture.animations.length > 0) {
			results.push(this._diffuseTexture);
		}
		
		if (this._ambientTexture != null && this._ambientTexture.animations != null && this._ambientTexture.animations.length > 0) {
			results.push(this._ambientTexture);
		}
		
		if (this._opacityTexture != null && this._opacityTexture.animations != null && this._opacityTexture.animations.length > 0) {
			results.push(this._opacityTexture);
		}
		
		if (this._reflectionTexture != null && this._reflectionTexture.animations != null && this._reflectionTexture.animations.length > 0) {
			results.push(this._reflectionTexture);
		}
		
		if (this._emissiveTexture != null && this._emissiveTexture.animations != null && this._emissiveTexture.animations.length > 0) {
			results.push(this._emissiveTexture);
		}
		
		if (this._specularTexture != null && this._specularTexture.animations != null && this._specularTexture.animations.length > 0) {
			results.push(this._specularTexture);
		}
		
		if (this._bumpTexture != null && this._bumpTexture.animations != null && this._bumpTexture.animations.length > 0) {
			results.push(this._bumpTexture);
		}
		
		if (this._lightmapTexture != null && this._lightmapTexture.animations != null && this._lightmapTexture.animations.length > 0) {
			results.push(this._lightmapTexture);
		}
		
		if (this._refractionTexture != null && this._refractionTexture.animations != null && this._refractionTexture.animations.length > 0) {
			results.push(this._refractionTexture);
		}
		
		return results;
	}
	
	override public function getActiveTextures():Array<BaseTexture> {
		var activeTextures = super.getActiveTextures();
		
		if (this._diffuseTexture != null) {
			activeTextures.push(this._diffuseTexture);
		}
		
		if (this._ambientTexture != null) {
			activeTextures.push(this._ambientTexture);
		}
		
		if (this._opacityTexture != null) {
			activeTextures.push(this._opacityTexture);
		}
		
		if (this._reflectionTexture != null) {
			activeTextures.push(this._reflectionTexture);
		}
		
		if (this._emissiveTexture != null) {
			activeTextures.push(this._emissiveTexture);
		}
		
		if (this._specularTexture != null) {
			activeTextures.push(this._specularTexture);
		}
		
		if (this._bumpTexture != null) {
			activeTextures.push(this._bumpTexture);
		}
		
		if (this._lightmapTexture != null) {
			activeTextures.push(this._lightmapTexture);
		}
		
		if (this._refractionTexture != null) {
			activeTextures.push(this._refractionTexture);
		}
		
		return activeTextures;
	}
	
	override public function hasTexture(texture:BaseTexture):Bool {
		if (super.hasTexture(texture)) {
			return true;
		}
		
		if (this._diffuseTexture == texture) {
			return true;
		}
		
		if (this._ambientTexture == texture) {
			return true;
		}
		
		if (this._opacityTexture == texture) {
			return true;
		}
		
		if (this._reflectionTexture == texture) {
			return true;
		}
		
		if (this._emissiveTexture == texture) {
			return true;
		}
        
		if (this._specularTexture == texture) {
			return true;
		}
		
		if (this._bumpTexture == texture) {
			return true;
		}
		
		if (this._lightmapTexture == texture) {
			return true;
		}
		
		if (this._refractionTexture == texture) {
			return true;
		}
		
		return false;    
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		if (forceDisposeTextures) {
			if (this._diffuseTexture != null) {
				this._diffuseTexture.dispose();
			}
			
			if (this._ambientTexture != null) {
				this._ambientTexture.dispose();
			}
			
			if (this._opacityTexture != null) {
				this._opacityTexture.dispose();
			}
			
			if (this._reflectionTexture != null) {
				this._reflectionTexture.dispose();
			}
			
			if (this._emissiveTexture != null) {
				this._emissiveTexture.dispose();
			}
			
			if (this._specularTexture != null) {
				this._specularTexture.dispose();
			}
			
			if (this._bumpTexture != null) {
				this._bumpTexture.dispose();
			}
			
			if (this._lightmapTexture != null) {
				this._lightmapTexture.dispose();
			}
			
			if (this._refractionTexture != null) {
				this._refractionTexture.dispose();
			}
		}
		
		if (this._imageProcessingConfiguration != null && this._imageProcessingObserver != null) {
			this._imageProcessingConfiguration.onUpdateParameters.remove(this._imageProcessingObserver);
		}
		
		super.dispose(forceDisposeEffect);
	}

	override public function clone(name:String, cloneChildren:Bool = false):StandardMaterial {
		var result = SerializationHelper.Clone(function() { return new StandardMaterial(name, this.getScene()); }, this);
		
		result.name = name;
		result.id = name;
		
		return result;
	}

	override public function serialize():Dynamic {
		// VK TODO:
		//return SerializationHelper.Serialize(this);
		return null;
	}

	// Statics
	/*public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):StandardMaterial {
		return SerializationHelper.Parse(function() { return new StandardMaterial(source.name, scene); }, source, scene, rootUrl);
	}*/
	
	private function _assign(source:Dynamic, target:Dynamic, property:String) {
		if (Reflect.getProperty(source, property) != null) {
			Reflect.setProperty(target, "property", Reflect.getProperty(source, property));
		}
	}
	
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):StandardMaterial {
        var material:StandardMaterial = new StandardMaterial(source.name, scene);
		
		if (source.ambient != null) {
			material.ambientColor = Color3.FromArray(source.ambient);
		}
		if (source.diffuse != null) {
			material.diffuseColor = Color3.FromArray(source.diffuse);
		}
		if (source.specular != null) {
			material.specularColor = Color3.FromArray(source.specular);
		}
		if (source.specularPower != null) {
			material.specularPower = source.specularPower;
		}
		if (source.emissive != null) {
			material.emissiveColor = Color3.FromArray(source.emissive);
		}
		if (source.useReflectionFresnelFromSpecular != null) {
			material.useReflectionFresnelFromSpecular = source.useReflectionFresnelFromSpecular;
		}
		if (source.useEmissiveAsIllumination != null) {
			material.useEmissiveAsIllumination = source.useEmissiveAsIllumination;
		}
		if (source.indexOfRefraction != null) {
			material.indexOfRefraction = source.indexOfRefraction;
		}
		if (source.invertRefractionY != null) {
			material.invertRefractionY = source.invertRefractionY;
		}
		if (source.useSpecularOverAlpha != null) {
			material.useSpecularOverAlpha = source.useSpecularOverAlpha;
		}
		if (source.useReflectionOverAlpha != null) {
			material.useReflectionOverAlpha = source.useReflectionOverAlpha;
		}
		if (source.alpha != null) {
			material.alpha = source.alpha;
		}
		if (source.id != null) {
			material.id = source.id;
		}		
		if (source.disableDepthWrite != null) {
            material.disableDepthWrite = source.disableDepthWrite;
        }
		if (source.tags != null) {
			Tags.AddTagsTo(material, source.tags);
		}
		if (source.backFaceCulling != null) {
			material.backFaceCulling = source.backFaceCulling;
		}
		if (source.wireframe != null) {
			material.wireframe = source.wireframe;
		}
		
        if (source.diffuseTexture != null) {
            material.diffuseTexture = Texture.Parse(source.diffuseTexture, scene, rootUrl);
        }
		
        if (source.diffuseFresnelParameters != null) {
            material.diffuseFresnelParameters = FresnelParameters.Parse(source.diffuseFresnelParameters);
        }
		
        if (source.ambientTexture != null) {
            material.ambientTexture = Texture.Parse(source.ambientTexture, scene, rootUrl);
        }
		
        if (source.opacityTexture != null) {
            material.opacityTexture = Texture.Parse(source.opacityTexture, scene, rootUrl);
        }
		
        if (source.opacityFresnelParameters != null) {
            material.opacityFresnelParameters = FresnelParameters.Parse(source.opacityFresnelParameters);
        }
		
        if (source.reflectionTexture != null) {
            material.reflectionTexture = Texture.Parse(source.reflectionTexture, scene, rootUrl);
        }
		
        if (source.reflectionFresnelParameters != null) {
            material.reflectionFresnelParameters = FresnelParameters.Parse(source.reflectionFresnelParameters);
        }
		
        if (source.emissiveTexture != null) {
            material.emissiveTexture = Texture.Parse(source.emissiveTexture, scene, rootUrl);
        }
		
		if (source.lightmapTexture != null) {
            material.lightmapTexture = Texture.Parse(source.lightmapTexture, scene, rootUrl);
            untyped material.lightmapThreshold = source.lightmapThreshold;
        }
		
        if (source.emissiveFresnelParameters != null) {
            material.emissiveFresnelParameters = FresnelParameters.Parse(source.emissiveFresnelParameters);
        }
		
        if (source.specularTexture != null) {
            material.specularTexture = Texture.Parse(source.specularTexture, scene, rootUrl);
        }
		
        if (source.bumpTexture != null) {
            material.bumpTexture = Texture.Parse(source.bumpTexture, scene, rootUrl);
        }
		
		if (source.refractionTexture != null) {
			material.refractionTexture = Texture.Parse(source.refractionTexture, scene, rootUrl);
		}
		
		if (source.checkReadyOnlyOnce != null) {
            material.checkReadyOnlyOnce = source.checkReadyOnlyOnce;
        }
		
        return material;
    }

	// Flags used to enable or disable a type of texture for all Standard Materials
	static var _DiffuseTextureEnabled:Bool = true;
	public static var DiffuseTextureEnabled(get, set):Bool;
	private static function get_DiffuseTextureEnabled():Bool {
		return StandardMaterial._DiffuseTextureEnabled;
	}
	private static function set_DiffuseTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._DiffuseTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._DiffuseTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}


	static var _AmbientTextureEnabled:Bool = true;
	public static var AmbientTextureEnabled(get, set):Bool;
	private static function get_AmbientTextureEnabled():Bool {
		return StandardMaterial._AmbientTextureEnabled;
	}
	private static function set_AmbientTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._AmbientTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._AmbientTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}

	static var _OpacityTextureEnabled:Bool = true;
	public static var OpacityTextureEnabled(get, set):Bool;
	private static function get_OpacityTextureEnabled():Bool {
		return StandardMaterial._OpacityTextureEnabled;
	}
	private static function set_OpacityTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._OpacityTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._OpacityTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}

	static var _ReflectionTextureEnabled:Bool = true;
	public static var ReflectionTextureEnabled(get, set):Bool;
	private static function get_ReflectionTextureEnabled():Bool {
		return StandardMaterial._ReflectionTextureEnabled;
	}
	private static function set_ReflectionTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._ReflectionTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._ReflectionTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}        
	
	static var _EmissiveTextureEnabled:Bool = true;
	public static var EmissiveTextureEnabled(get, set):Bool;
	private static function get_EmissiveTextureEnabled():Bool {
		return StandardMaterial._EmissiveTextureEnabled;
	}
	private static function set_EmissiveTextureEnabled(value:Bool) {
		if (StandardMaterial._EmissiveTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._EmissiveTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}       

	static var _SpecularTextureEnabled:Bool = true;
	public static var SpecularTextureEnabled(get, set):Bool;
	private static function get_SpecularTextureEnabled():Bool {
		return StandardMaterial._SpecularTextureEnabled;
	}
	private static function set_SpecularTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._SpecularTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._SpecularTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}     

	static var _BumpTextureEnabled:Bool = true;
	public static var BumpTextureEnabled(get, set):Bool;
	private static function get_BumpTextureEnabled():Bool {
		return StandardMaterial._BumpTextureEnabled;
	}
	private static function set_BumpTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._BumpTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._BumpTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}         

	static var _LightmapTextureEnabled:Bool = true;
	public static var LightmapTextureEnabled(get, set):Bool;
	private static function get_LightmapTextureEnabled():Bool {
		return StandardMaterial._LightmapTextureEnabled;
	}
	private static function set_LightmapTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._LightmapTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._LightmapTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}           

	static var _RefractionTextureEnabled:Bool = true;
	public static var RefractionTextureEnabled(get, set):Bool;
	private static function get_RefractionTextureEnabled():Bool {
		return StandardMaterial._RefractionTextureEnabled;
	}
	private static function set_RefractionTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._RefractionTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._RefractionTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}    

	static var _ColorGradingTextureEnabled:Bool = true;
	public static var ColorGradingTextureEnabled(get, set):Bool;
	private static function get_ColorGradingTextureEnabled():Bool {
		return StandardMaterial._ColorGradingTextureEnabled;
	}
	private static function set_ColorGradingTextureEnabled(value:Bool):Bool {
		if (StandardMaterial._ColorGradingTextureEnabled == value) {
			return value;
		}
		
		StandardMaterial._ColorGradingTextureEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.TextureDirtyFlag);
		
		return value;
	}           

	static var _FresnelEnabled:Bool = true;
	public static var FresnelEnabled(get, set):Bool;
	private static function get_FresnelEnabled():Bool {
		return StandardMaterial._FresnelEnabled;
	}
	private static function set_FresnelEnabled(value:Bool):Bool {
		if (StandardMaterial._FresnelEnabled == value) {
			return value;
		}
		
		StandardMaterial._FresnelEnabled = value;
		Engine.MarkAllMaterialsAsDirty(Material.FresnelDirtyFlag);
		
		return value;
	}

}
