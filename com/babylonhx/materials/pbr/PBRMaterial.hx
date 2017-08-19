package com.babylonhx.materials.pbr;

import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.math.Color3;
import com.babylonhx.tools.TextureTools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The Physically based material of BJS.
 * 
 * This offers the main features of a standard PBR material.
 * For more information, please refer to the documentation : 
 * http://doc.babylonjs.com/extensions/Physically_Based_Rendering
 */
class PBRMaterial extends PBRBaseMaterial {

	/**
	 * PBRMaterialTransparencyMode: No transparency mode, Alpha channel is not use.
	 */
	public static inline var PBRMATERIAL_OPAQUE:Int = 0;
	/**
	 * PBRMaterialTransparencyMode: Alpha Test mode, pixel are discarded below a certain threshold defined by the alpha cutoff value.
	 */
	public static inline var PBRMATERIAL_ALPHATEST:Int = 1;
	/**
	 * PBRMaterialTransparencyMode: Pixels are blended (according to the alpha mode) with the already drawn pixels in the current frame buffer.
	 */
	public static inline var PBRMATERIAL_ALPHABLEND:Int = 2;
	/**
	 * PBRMaterialTransparencyMode: Pixels are blended (according to the alpha mode) with the already drawn pixels in the current frame buffer.
	 * They are also discarded below the alpha cutoff threshold to improve performances.
	 */
	public static inline var PBRMATERIAL_ALPHATESTANDBLEND:Int = 3;
	

	/**
	 * Intensity of the direct lights e.g. the four lights available in your scene.
	 * This impacts both the direct diffuse and specular highlights.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var directIntensity(get, set):Float; //= 1.0;
	inline private function get_directIntensity():Float {
		return _directIntensity;
	}
	inline private function set_directIntensity(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _directIntensity = value;
	}
	
	/**
	 * Intensity of the emissive part of the material.
	 * This helps controlling the emissive effect without modifying the emissive color.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var emissiveIntensity(get, set):Float;// = 1.0;
	inline private function get_emissiveIntensity():Float {
		return _emissiveIntensity;
	}
	inline private function set_emissiveIntensity(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _emissiveIntensity = value;
	}
	
	/**
	 * Intensity of the environment e.g. how much the environment will light the object
	 * either through harmonics for rough material or through the refelction for shiny ones.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var environmentIntensity(get, set):Float; //= 1.0;
	inline private function get_environmentIntensity():Float {
		return _environmentIntensity;
	}
	inline private function set_environmentIntensity(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _environmentIntensity = value;
	}
	
	/**
	 * This is a special control allowing the reduction of the specular highlights coming from the 
	 * four lights of the scene. Those highlights may not be needed in full environment lighting.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var specularIntensity(get, set):Float;
	inline private function get_specularIntensity():Float { 
		return _specularIntensity;
	}
	inline private function set_specularIntensity(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _specularIntensity = value;
	}

	/**
	 * Debug Control allowing disabling the bump map on this material.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var disableBumpMap(get, set):Bool;
	inline private function get_disableBumpMap():Bool {
		return _disableBumpMap;
	}
	inline private function set_disableBumpMap(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _disableBumpMap = value;
	}

	/**
	 * AKA Diffuse Texture in standard nomenclature.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var albedoTexture(get, set):BaseTexture;
	inline private function get_albedoTexture():BaseTexture {
		return _albedoTexture;
	}
	inline private function set_albedoTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _albedoTexture = value;
	}
	
	/**
	 * AKA Occlusion Texture in other nomenclature.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var ambientTexture(get, set):BaseTexture;
	inline private function get_ambientTexture():BaseTexture {
		return _ambientTexture;
	}
	inline private function set_ambientTexture(value:BaseTexture):BaseTexture { 
		_markAllSubMeshesAsTexturesDirty();
		return _ambientTexture = value;
	}

	/**
	 * AKA Occlusion Texture Intensity in other nomenclature.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var ambientTextureStrength(get, set):Float;
	inline private function get_ambientTextureStrength():Float {
		return _ambientTextureStrength;
	}
	inline private function set_ambientTextureStrength(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _ambientTextureStrength = value;
	}

	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var opacityTexture(get, set):BaseTexture;
	inline private function get_opacityTexture():BaseTexture {
		return _opacityTexture;
	}
	inline private function set_opacityTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _opacityTexture = value;
	}

	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionTexture(get, set):BaseTexture;
	inline private function get_reflectionTexture():BaseTexture {
		return _reflectionTexture;
	}
	inline private function set_reflectionTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _reflectionTexture = value;
	}

	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var emissiveTexture(get, set):BaseTexture;
	inline private function get_emissiveTexture():BaseTexture {
		return _emissiveTexture;
	}
	inline private function set_emissiveTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _emissiveTexture = value;
	}
	
	/**
	 * AKA Specular texture in other nomenclature.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectivityTexture(get, set):BaseTexture;
	inline private function get_reflectivityTexture():BaseTexture {
		return _reflectivityTexture;
	}
	inline private function set_reflectivityTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _reflectivityTexture = value;
	}

	/**
	 * Used to switch from specular/glossiness to metallic/roughness workflow.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var metallicTexture(get, set):BaseTexture;
	inline private function get_metallicTexture():BaseTexture {
		return _metallicTexture;
	}
	inline private function set_metallicTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _metallicTexture = value;
	}

	/**
	 * Specifies the metallic scalar of the metallic/roughness workflow.
	 * Can also be used to scale the metalness values of the metallic texture.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var metallic(get, set):Float;
	inline private function get_metallic():Float {
		return _metallic;
	}
	inline private function set_metallic(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _metallic = value;
	}

	/**
	 * Specifies the roughness scalar of the metallic/roughness workflow.
	 * Can also be used to scale the roughness values of the metallic texture.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var roughness(get, set):Float;
	inline private function get_roughness():Float {
		return _roughness;
	}
	inline private function set_roughness(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _roughness = value;
	}

	/**
	 * Used to enable roughness/glossiness fetch from a separate chanel depending on the current mode.
	 * Gray Scale represents roughness in metallic mode and glossiness in specular mode.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var microSurfaceTexture(get, set):BaseTexture;
	inline private function get_microSurfaceTexture():BaseTexture {
		return _microSurfaceTexture;
	}
	inline private function set_microSurfaceTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _microSurfaceTexture = value;
	}

	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var bumpTexture(get, set):BaseTexture;
	inline private function get_bumpTexture():BaseTexture {
		return _bumpTexture;
	}
	inline private function set_bumpTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _bumpTexture = value;
	}

	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", null)
	public var lightmapTexture(get, set):BaseTexture;
	inline private function get_lightmapTexture():BaseTexture {
		return _lightmapTexture;
	}
	inline private function set_lightmapTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _lightmapTexture = value;
	}

	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var refractionTexture(get, set):BaseTexture;
	inline private function get_refractionTexture():BaseTexture {
		return _refractionTexture;
	}
	inline private function set_refractionTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _refractionTexture = value;
	}

	@serializeAsColor3("ambient")
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var ambientColor(get, set):Color3;
	inline private function get_ambientColor():Color3 {
		return _ambientColor;
	}
	inline private function set_ambientColor(value:Color3):Color3 {
		_markAllSubMeshesAsTexturesDirty();
		return _ambientColor = value;
	}

	/**
	 * AKA Diffuse Color in other nomenclature.
	 */
	@serializeAsColor3("albedo")
	@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var albedoColor(get, set):Color3;
	inline private function get_albedoColor():Color3 {
		return _albedoColor;
	}
	inline private function set_albedoColor(value:Color3):Color3 {
		_markAllSubMeshesAsTexturesDirty();
		return _albedoColor = value;
	}
	
	/**
	 * AKA Specular Color in other nomenclature.
	 */
	@serializeAsColor3("reflectivity")
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectivityColor(get, set):Color3;
	inline private function get_reflectivityColor():Color3 {
		return _reflectivityColor;
	}
	inline private function set_reflectivityColor(value:Color3):Color3 {
		_markAllSubMeshesAsTexturesDirty();
		return _reflectivityColor = value;
	}

	@serializeAsColor3("reflection")
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionColor(get, set):Color3;
	inline private function get_reflectionColor():Color3 {
		return _reflectionColor;
	}
	inline private function set_reflectionColor(value:Color3):Color3 {
		_markAllSubMeshesAsTexturesDirty();
		return _reflectionColor = value;
	}

	@serializeAsColor3("emissive")
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var emissiveColor(get, set):Color3;
	inline private function get_emissiveColor():Color3 {
		return _emissiveColor;
	}
	inline private function set_emissiveColor(value:Color3):Color3 {
		_markAllSubMeshesAsTexturesDirty();
		return _emissiveColor = value;
	}
	
	/**
	 * AKA Glossiness in other nomenclature.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var microSurface(get, set):Float;
	inline private function get_microSurface():Float {
		return _microSurface;
	}
	inline private function set_microSurface(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _microSurface = value;
	}

	/**
	 * source material index of refraction (IOR)' / 'destination material IOR.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var indexOfRefraction(get, set):Float;
	inline private function get_indexOfRefraction():Float {
		return _indexOfRefraction;
	}
	inline private function set_indexOfRefraction(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _indexOfRefraction = value;
	}
	
	/**
	 * Controls if refraction needs to be inverted on Y. This could be usefull for procedural texture.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var invertRefractionY(get, set):Bool;
	inline private function get_invertRefractionY():Bool {
		return _invertRefractionY;
	}
	inline private function set_invertRefractionY(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _invertRefractionY = value;
	}

	/**
	 * This parameters will make the material used its opacity to control how much it is refracting aginst not.
	 * Materials half opaque for instance using refraction could benefit from this control.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var linkRefractionWithTransparency(get, set):Bool;
	inline private function get_linkRefractionWithTransparency():Bool {
		return _linkRefractionWithTransparency;
	}
	inline private function set_linkRefractionWithTransparency(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _linkRefractionWithTransparency = value;
	}

	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useLightmapAsShadowmap(get, set):Bool;
	inline private function get_useLightmapAsShadowmap():Bool {
		return _useLightmapAsShadowmap;
	}
	inline private function set_useLightmapAsShadowmap(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useLightmapAsShadowmap = value;
	}
	
	/**
	 * Specifies that the alpha is coming form the albedo channel alpha channel.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useAlphaFromAlbedoTexture(get, set):Bool;
	inline private function get_useAlphaFromAlbedoTexture():Bool {
		return _useAlphaFromAlbedoTexture;
	}
	inline private function set_useAlphaFromAlbedoTexture(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useAlphaFromAlbedoTexture = value;
	}

	/**
	 * Enforces alpha test in opaque or blend mode in order to improve the performances of some situations.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var forceAlphaTest(get, set):Bool;
	inline private function get_forceAlphaTest():Bool {
		return _forceAlphaTest;
	}
	inline private function set_forceAlphaTest(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _forceAlphaTest = value;
	}

	/**
	 * Defines the alpha limits in alpha test mode.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var alphaCutOff(get, set):Float;
	inline private function get_alphaCutOff():Float {
		return _alphaCutOff;
	}
	inline private function set_alphaCutOff(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _alphaCutOff = value;
	}
	
	/**
	 * Specifies that the material will keeps the specular highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When sun reflects on it you can not see what is behind.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useSpecularOverAlpha(get, set):Bool;
	inline private function get_useSpecularOverAlpha():Bool {
		return _useSpecularOverAlpha;
	}
	inline private function set_useSpecularOverAlpha(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useSpecularOverAlpha = value;
	}
	
	/**
	 * Specifies if the reflectivity texture contains the glossiness information in its alpha channel.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useMicroSurfaceFromReflectivityMapAlpha(get, set):Bool;
	inline private function get_useMicroSurfaceFromReflectivityMapAlpha():Bool {
		return _useMicroSurfaceFromReflectivityMapAlpha;
	}
	inline private function set_useMicroSurfaceFromReflectivityMapAlpha(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useMicroSurfaceFromReflectivityMapAlpha = value;
	}

	/**
	 * Specifies if the metallic texture contains the roughness information in its alpha channel.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useRoughnessFromMetallicTextureAlpha(get, set):Bool;
	inline private function get_useRoughnessFromMetallicTextureAlpha():Bool {
		return _useRoughnessFromMetallicTextureAlpha;
	}
	inline private function set_useRoughnessFromMetallicTextureAlpha(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useRoughnessFromMetallicTextureAlpha = value;
	}

	/**
	 * Specifies if the metallic texture contains the roughness information in its green channel.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useRoughnessFromMetallicTextureGreen(get, set):Bool;
	inline private function get_useRoughnessFromMetallicTextureGreen():Bool {
		return _useRoughnessFromMetallicTextureGreen;
	}
	inline private function set_useRoughnessFromMetallicTextureGreen(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useRoughnessFromMetallicTextureGreen = value;
	}

	/**
	 * Specifies if the metallic texture contains the metallness information in its blue channel.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useMetallnessFromMetallicTextureBlue(get, set):Bool;
	inline private function get_useMetallnessFromMetallicTextureBlue():Bool {
		return _useMetallnessFromMetallicTextureBlue;
	}
	inline private function set_useMetallnessFromMetallicTextureBlue(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useMetallnessFromMetallicTextureBlue = value;
	}

	/**
	 * Specifies if the metallic texture contains the ambient occlusion information in its red channel.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useAmbientOcclusionFromMetallicTextureRed(get, set):Bool;
	inline private function get_useAmbientOcclusionFromMetallicTextureRed():Bool {
		return _useAmbientOcclusionFromMetallicTextureRed;
	}
	inline private function set_useAmbientOcclusionFromMetallicTextureRed(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useAmbientOcclusionFromMetallicTextureRed = value;
	}

	/**
	 * Specifies if the ambient texture contains the ambient occlusion information in its red channel only.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useAmbientInGrayScale(get, set):Bool;
	inline private function get_useAmbientInGrayScale():Bool {
		return _useAmbientInGrayScale;
	}
	inline private function set_useAmbientInGrayScale(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useAmbientInGrayScale = value;
	}
	
	/**
	 * In case the reflectivity map does not contain the microsurface information in its alpha channel,
	 * The material will try to infer what glossiness each pixel should be.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useAutoMicroSurfaceFromReflectivityMap(get, set):Bool;
	inline private function get_useAutoMicroSurfaceFromReflectivityMap():Bool {
		return _useAutoMicroSurfaceFromReflectivityMap;
	}
	inline private function set_useAutoMicroSurfaceFromReflectivityMap(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useAutoMicroSurfaceFromReflectivityMap = value;
	}
	
	/**
	 * BJS is using an harcoded light falloff based on a manually sets up range.
	 * In PBR, one way to represents the fallof is to use the inverse squared root algorythm.
	 * This parameter can help you switch back to the BJS mode in order to create scenes using both materials.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var usePhysicalLightFalloff(get, set):Bool;
	inline private function get_usePhysicalLightFalloff():Bool {
		return _usePhysicalLightFalloff;
	}
	inline private function set_usePhysicalLightFalloff(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _usePhysicalLightFalloff = value;
	}
	
	/**
	 * Specifies that the material will keeps the reflection highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When the street lights reflects on it you can not see what is behind.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useRadianceOverAlpha(get, set):Bool;
	inline private function get_useRadianceOverAlpha():Bool {
		return _useRadianceOverAlpha;
	}
	inline private function set_useRadianceOverAlpha(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useRadianceOverAlpha = value;
	}
	
	/**
	 * Allows using the bump map in parallax mode.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useParallax(get, set):Bool;
	inline private function get_useParallax():Bool {
		return _useParallax;
	}
	inline private function set_useParallax(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useParallax = value;
	}

	/**
	 * Allows using the bump map in parallax occlusion mode.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useParallaxOcclusion(get, set):Bool;
	inline private function get_useParallaxOcclusion():Bool {
		return _useParallaxOcclusion;
	}
	inline private function set_useParallaxOcclusion(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useParallaxOcclusion = value;
	}

	/**
	 * Controls the scale bias of the parallax mode.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var parallaxScaleBias(get, set):Float;
	inline private function get_parallaxScaleBias():Float {
		return _parallaxScaleBias;
	}
	inline private function set_parallaxScaleBias(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _parallaxScaleBias = value;
	}
	
	/**
	 * If sets to true, disables all the lights affecting the material.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var disableLighting(get, set):Bool;
	inline private function get_disableLighting():Bool {
		return _disableLighting;
	}
	inline private function set_disableLighting(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _disableLighting = value;
	}

	/**
	 * Force the shader to compute irradiance in the fragment shader in order to take bump in account.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var forceIrradianceInFragment(get, set):Bool;
	inline private function get_forceIrradianceInFragment():Bool {
		return _forceIrradianceInFragment;
	}
	inline private function set_forceIrradianceInFragment(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _forceIrradianceInFragment = value;
	}

	/**
	 * Number of Simultaneous lights allowed on the material.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var maxSimultaneousLights(get, set):Int;
	inline private function get_maxSimultaneousLights():Int {
		return _maxSimultaneousLights;
	}
	inline private function set_maxSimultaneousLights(value:Int):Int {
		_markAllSubMeshesAsTexturesDirty();
		return _maxSimultaneousLights = value;
	}

	/**
	 * If sets to true, x component of normal map value will invert (x = 1.0 - x).
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var invertNormalMapX(get, set):Bool;
	inline private function get_invertNormalMapX():Bool {
		return _invertNormalMapX;
	}
	inline private function set_invertNormalMapX(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _invertNormalMapX = value;
	}

	/**
	 * If sets to true, y component of normal map value will invert (y = 1.0 - y).
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var invertNormalMapY(get, set):Bool;
	inline private function get_invertNormalMapY():Bool {
		return _invertNormalMapY;
	}
	inline private function set_invertNormalMapY(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _invertNormalMapY = value;
	}

	/**
	 * If sets to true and backfaceCulling is false, normals will be flipped on the backside.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var twoSidedLighting(get, set):Bool;
	inline private function get_twoSidedLighting():Bool {
		return _twoSidedLighting;
	}
	inline private function set_twoSidedLighting(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _twoSidedLighting = value;
	}

	/**
	 * Specifies that the alpha is premultiplied before output (this enables alpha premultiplied blending).
	 * in your scene composition.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var preMultiplyAlpha(get, set):Bool;
	inline private function get_preMultiplyAlpha():Bool {
		return _preMultiplyAlpha;
	}
	inline private function set_preMultiplyAlpha(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _preMultiplyAlpha = value;
	}

	/**
	 * A fresnel is applied to the alpha of the model to ensure grazing angles edges are not alpha tested.
	 * And/Or occlude the blended part.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useAlphaFresnel(get, set):Bool;
	inline private function get_useAlphaFresnel():Bool {
		return _useAlphaFresnel;
	}
	inline private function set_useAlphaFresnel(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _useAlphaFresnel = value;
	}

	/**
	 * A fresnel is applied to the alpha of the model to ensure grazing angles edges are not alpha tested.
	 * And/Or occlude the blended part.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var environmentBRDFTexture(get, set):BaseTexture;
	inline private function get_environmentBRDFTexture():BaseTexture {
		return _environmentBRDFTexture;
	}
	inline private function set_environmentBRDFTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _environmentBRDFTexture = value;
	}

	/**
	 * Force normal to face away from face.
	 * (Temporary internal fix to remove before 3.1)
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var forceNormalForward(get, set):Bool;
	inline private function get_forceNormalForward():Bool {
		return _forceNormalForward;
	}
	inline private function set_forceNormalForward(value:Bool):Bool {
		_markAllSubMeshesAsTexturesDirty();
		return _forceNormalForward = value;
	}
	
	/**
	 * Gets the image processing configuration used either in this material.
	 */
	public var imageProcessingConfiguration(get, set):ImageProcessingConfiguration;
	inline private function get_imageProcessingConfiguration():ImageProcessingConfiguration {
		return this._imageProcessingConfiguration;
	}
	/**
	 * Sets the Default image processing configuration used either in the this material.
	 * 
	 * If sets to null, the scene one is in use.
	 */
	inline private function set_imageProcessingConfiguration(value:ImageProcessingConfiguration):ImageProcessingConfiguration {
		this._attachImageProcessingConfiguration(value);
		
		// Ensure the effect will be rebuilt.
		this._markAllSubMeshesAsTexturesDirty();
		
		return value;
	}

	/**
	 * Gets wether the color curves effect is enabled.
	 */
	public var cameraColorCurvesEnabled(get, set):Bool;
	inline private function get_cameraColorCurvesEnabled():Bool {
		return this.imageProcessingConfiguration.colorCurvesEnabled;
	}
	/**
	 * Sets wether the color curves effect is enabled.
	 */
	inline private function set_cameraColorCurvesEnabled(value:Bool):Bool {
		return this.imageProcessingConfiguration.colorCurvesEnabled = value;
	}

	/**
	 * Gets wether the color grading effect is enabled.
	 */
	public var cameraColorGradingEnabled(get, set):Bool;
	inline private function get_cameraColorGradingEnabled():Bool {
		return this.imageProcessingConfiguration.colorGradingEnabled;
	}
	/**
	 * Gets wether the color grading effect is enabled.
	 */
	inline private function set_cameraColorGradingEnabled(value:Bool):Bool {
		return this.imageProcessingConfiguration.colorGradingEnabled = value;
	}

	/**
	 * Gets wether tonemapping is enabled or not.
	 */
	public var cameraToneMappingEnabled(get, set):Bool;
	inline private function get_cameraToneMappingEnabled():Bool {
		return this._imageProcessingConfiguration.toneMappingEnabled;
	}
	/**
	 * Sets wether tonemapping is enabled or not
	 */
	inline private function set_cameraToneMappingEnabled(value:Bool):Bool {
		return this._imageProcessingConfiguration.toneMappingEnabled = value;
	}
	
	/**
	 * The camera exposure used on this material.
	 * This property is here and not in the camera to allow controlling exposure without full screen post process.
	 * This corresponds to a photographic exposure.
	 */
	public var cameraExposure:Float;// = 1.0;
	inline private function get_cameraExposure():Float {
		return this._imageProcessingConfiguration.exposure;
	}
	inline private function set_cameraExposure(value:Float):Float {
		return this._imageProcessingConfiguration.exposure = value;
	}
	
	/**
	 * The camera contrast used on this material.
	 * This property is here and not in the camera to allow controlling contrast without full screen post process.
	 */
	public var cameraContrast:Float;// = 1.0;
	inline private function get_cameraContrast():Float {
		return this._imageProcessingConfiguration.contrast;
	}
	inline private function set_cameraContrast(value:Float):Float {
		return this._imageProcessingConfiguration.contrast = value;
	}
	
	/**
	 * Color Grading 2D Lookup Texture.
	 * This allows special effects like sepia, black and white to sixties rendering style. 
	 */
	public var cameraColorGradingTexture(get, set):BaseTexture;
	inline private function get_cameraColorGradingTexture():BaseTexture {
		return this._imageProcessingConfiguration.colorGradingTexture;
	}
	inline private function set_cameraColorGradingTexture(value:BaseTexture):BaseTexture {
		return this._imageProcessingConfiguration.colorGradingTexture = value;
	}
	
	/**
	 * The color grading curves provide additional color adjustmnent that is applied after any color grading transform (3D LUT). 
	 * They allow basic adjustment of saturation and small exposure adjustments, along with color filter tinting to provide white balance adjustment or more stylistic effects.
	 * These are similar to controls found in many professional imaging or colorist software. The global controls are applied to the entire image. For advanced tuning, extra controls are provided to adjust the shadow, midtone and highlight areas of the image; 
	 * corresponding to low luminance, medium luminance, and high luminance areas respectively.
	 */
	public var cameraColorCurves(get, set):ColorCurves;// = null;
	inline private function get_cameraColorCurves():ColorCurves {
		return this._imageProcessingConfiguration.colorCurves;
	}
	inline private function set_cameraColorCurves(value:ColorCurves):ColorCurves {
		return this._imageProcessingConfiguration.colorCurves = value;
	}
	

	/**
	 * Instantiates a new PBRMaterial instance.
	 * 
	 * @param name The material name
	 * @param scene The scene the material will be use in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this._environmentBRDFTexture = TextureTools.GetEnvironmentBRDFTexture(scene);
	}

	override public function getClassName():String {
		return "PBRMaterial";
	}
	
	override public function getActiveTextures():Array<BaseTexture> {
		var activeTextures = super.getActiveTextures();
		
		if (this._albedoTexture != null) {
			activeTextures.push(this._albedoTexture);
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
		
		if (this._reflectivityTexture != null) {
			activeTextures.push(this._reflectivityTexture);
		}
		
		if (this._metallicTexture != null) {
			activeTextures.push(this._metallicTexture);
		}
		
		if (this._microSurfaceTexture != null) {
			activeTextures.push(this._microSurfaceTexture);
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
		
		if (this._albedoTexture == texture) {
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
		
		if (this._reflectivityTexture == texture) {
			return true;
		}
		
		if (this._metallicTexture == texture) {
			return true;
		}
		
		if (this._microSurfaceTexture == texture) {
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

	override public function clone(name:String, cloneChildren:Bool = false):Material {
		//return SerializationHelper.Clone(function() { return new PBRMaterial(name, this.getScene()); }, this);
		// VK TODO:
		return null;
	}

	override public function serialize():Dynamic {
		//var serializationObject = SerializationHelper.Serialize(this);
		//serializationObject.customType = "BABYLON.PBRMaterial";
		//return serializationObject;
		// VK TODO:
		return null;
	}

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):PBRMaterial {
		//return SerializationHelper.Parse(() => new PBRMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
