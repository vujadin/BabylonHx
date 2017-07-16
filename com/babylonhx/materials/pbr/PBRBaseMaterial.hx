package com.babylonhx.materials.pbr;

import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.RefractionTexture;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Tools;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.animations.IAnimatable;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The Physically based material base class of BJS.
 * 
 * This offers the main features of a standard PBR material.
 * For more information, please refer to the documentation : 
 * http://doc.babylonjs.com/extensions/Physically_Based_Rendering
 */
class PBRBaseMaterial extends Material {

	/**
	 * Intensity of the direct lights e.g. the four lights available in your scene.
	 * This impacts both the direct diffuse and specular highlights.
	 */
	public var _directIntensity:Float = 1.0;
	
	/**
	 * Intensity of the emissive part of the material.
	 * This helps controlling the emissive effect without modifying the emissive color.
	 */
	public var _emissiveIntensity:Float = 1.0;
	
	/**
	 * Intensity of the environment e.g. how much the environment will light the object
	 * either through harmonics for rough material or through the refelction for shiny ones.
	 */
	public var _environmentIntensity:Float = 1.0;
	
	/**
	 * This is a special control allowing the reduction of the specular highlights coming from the 
	 * four lights of the scene. Those highlights may not be needed in full environment lighting.
	 */
	public var _specularIntensity:Float = 1.0;

	private var _lightingInfos:Vector4 = new Vector4(this._directIntensity, this._emissiveIntensity, this._environmentIntensity, this._specularIntensity);
	
	/**
	 * Debug Control allowing disabling the bump map on this material.
	 */
	public var _disableBumpMap:Bool = false;

	/**
	 * The camera exposure used on this material.
	 * This property is here and not in the camera to allow controlling exposure without full screen post process.
	 * This corresponds to a photographic exposure.
	 */
	public var _cameraExposure:Float = 1.0;
	
	/**
	 * The camera contrast used on this material.
	 * This property is here and not in the camera to allow controlling contrast without full screen post process.
	 */
	public var _cameraContrast:Float = 1.0;
	
	/**
	 * Color Grading 2D Lookup Texture.
	 * This allows special effects like sepia, black and white to sixties rendering style. 
	 */
	public var _cameraColorGradingTexture:BaseTexture = null;
	
	/**
	 * The color grading curves provide additional color adjustmnent that is applied after any color grading transform (3D LUT). 
	 * They allow basic adjustment of saturation and small exposure adjustments, along with color filter tinting to provide white balance adjustment or more stylistic effects.
	 * These are similar to controls found in many professional imaging or colorist software. The global controls are applied to the entire image. For advanced tuning, extra controls are provided to adjust the shadow, midtone and highlight areas of the image; 
	 * corresponding to low luminance, medium luminance, and high luminance areas respectively.
	 */
	public var _cameraColorCurves:ColorCurves = null;
	 
	private var _cameraInfos:Vector4 = new Vector4(1.0, 1.0, 0.0, 0.0);

	private var _microsurfaceTextureLods:Vector2 = new Vector2(0.0, 0.0);

	/**
	 * AKA Diffuse Texture in standard nomenclature.
	 */
	public var _albedoTexture:BaseTexture;
	
	/**
	 * AKA Occlusion Texture in other nomenclature.
	 */
	public var _ambientTexture:BaseTexture;

	/**
	 * AKA Occlusion Texture Intensity in other nomenclature.
	 */
	public var _ambientTextureStrength:Float = 1.0;

	public var _opacityTexture:BaseTexture;

	public var _reflectionTexture:BaseTexture;

	public var _emissiveTexture:BaseTexture;
	
	/**
	 * AKA Specular texture in other nomenclature.
	 */
	public var _reflectivityTexture:BaseTexture;

	/**
	 * Used to switch from specular/glossiness to metallic/roughness workflow.
	 */
	public var _metallicTexture:BaseTexture;

	/**
	 * Specifies the metallic scalar of the metallic/roughness workflow.
	 * Can also be used to scale the metalness values of the metallic texture.
	 */
	public var _metallic:Float = 0;

	/**
	 * Specifies the roughness scalar of the metallic/roughness workflow.
	 * Can also be used to scale the roughness values of the metallic texture.
	 */
	public var _roughness:Float = 0;

	/**
	 * Used to enable roughness/glossiness fetch from a separate chanel depending on the current mode.
	 * Gray Scale represents roughness in metallic mode and glossiness in specular mode.
	 */
	public var _microSurfaceTexture:BaseTexture;

	public var _bumpTexture:BaseTexture;

	public var _lightmapTexture:BaseTexture;

	public var _refractionTexture:BaseTexture;

	public var _ambientColor:Color3 = new Color3(0, 0, 0);

	/**
	 * AKA Diffuse Color in other nomenclature.
	 */
	public var _albedoColor:Color3 = new Color3(1, 1, 1);
	
	/**
	 * AKA Specular Color in other nomenclature.
	 */
	public var _reflectivityColor:Color3 = new Color3(1, 1, 1);

	public var _reflectionColor:Color3 = new Color3(0.0, 0.0, 0.0);

	public var _emissiveColor:Color3 = new Color3(0, 0, 0);
	
	/**
	 * AKA Glossiness in other nomenclature.
	 */
	public var _microSurface:Float = 0.9;

	/**
	 * source material index of refraction (IOR)' / 'destination material IOR.
	 */
	public var _indexOfRefraction:Float = 0.66;
	
	/**
	 * Controls if refraction needs to be inverted on Y. This could be usefull for procedural texture.
	 */
	public var _invertRefractionY:Bool = false;

	public var _opacityFresnelParameters:FresnelParameters;

	public var _emissiveFresnelParameters:FresnelParameters;

	/**
	 * This parameters will make the material used its opacity to control how much it is refracting aginst not.
	 * Materials half opaque for instance using refraction could benefit from this control.
	 */
	public var _linkRefractionWithTransparency:Bool = false;

	public var _useLightmapAsShadowmap:Bool = false;
	
	/**
	 * In this mode, the emissive informtaion will always be added to the lighting once.
	 * A light for instance can be thought as emissive.
	 */
	public var _useEmissiveAsIllumination:Bool = false;
	
	/**
	 * Secifies that the alpha is coming form the albedo channel alpha channel.
	 */
	public var _useAlphaFromAlbedoTexture:Bool = false;
	
	/**
	 * Specifies that the material will keeps the specular highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When sun reflects on it you can not see what is behind.
	 */
	public var _useSpecularOverAlpha:Bool = true;
	
	/**
	 * Specifies if the reflectivity texture contains the glossiness information in its alpha channel.
	 */
	public var _useMicroSurfaceFromReflectivityMapAlpha:Bool = false;

	/**
	 * Specifies if the metallic texture contains the roughness information in its alpha channel.
	 */
	public var _useRoughnessFromMetallicTextureAlpha:Bool = true;

	/**
	 * Specifies if the metallic texture contains the roughness information in its green channel.
	 */
	public var _useRoughnessFromMetallicTextureGreen:Bool = false;

	/**
	 * Specifies if the metallic texture contains the metallness information in its blue channel.
	 */
	public var _useMetallnessFromMetallicTextureBlue:Bool = false;

	/**
	 * Specifies if the metallic texture contains the ambient occlusion information in its red channel.
	 */
	public var _useAmbientOcclusionFromMetallicTextureRed:Bool = false;

	/**
	 * Specifies if the ambient texture contains the ambient occlusion information in its red channel only.
	 */
	public var _useAmbientInGrayScale:Bool = false;
	
	/**
	 * In case the reflectivity map does not contain the microsurface information in its alpha channel,
	 * The material will try to infer what glossiness each pixel should be.
	 */
	public var _useAutoMicroSurfaceFromReflectivityMap:Bool = false;
	
	/**
	 * Allows to work with scalar in linear mode. This is definitely a matter of preferences and tools used during
	 * the creation of the material.
	 */
	public var _useScalarInLinearSpace:Bool = false;
	
	/**
	 * BJS is using an harcoded light falloff based on a manually sets up range.
	 * In PBR, one way to represents the fallof is to use the inverse squared root algorythm.
	 * This parameter can help you switch back to the BJS mode in order to create scenes using both materials.
	 */
	public var _usePhysicalLightFalloff:Bool = true;
	
	/**
	 * Specifies that the material will keeps the reflection highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When the street lights reflects on it you can not see what is behind.
	 */
	public var _useRadianceOverAlpha:Bool = true;
	
	/**
	 * Allows using the bump map in parallax mode.
	 */
	public var _useParallax:Bool = false;

	/**
	 * Allows using the bump map in parallax occlusion mode.
	 */
	public var _useParallaxOcclusion:Bool = false;

	/**
	 * Controls the scale bias of the parallax mode.
	 */
	public var _parallaxScaleBias:Bool = 0.05;
	
	/**
	 * If sets to true, disables all the lights affecting the material.
	 */
	public var _disableLighting:Bool = false;

	/**
	 * Number of Simultaneous lights allowed on the material.
	 */
	public var _maxSimultaneousLights:Int = 4;  

	/**
	 * If sets to true, x component of normal map value will invert (x = 1.0 - x).
	 */
	public var _invertNormalMapX:Bool = false;

	/**
	 * If sets to true, y component of normal map value will invert (y = 1.0 - y).
	 */
	public var _invertNormalMapY:Bool = false;

	/**
	 * If sets to true and backfaceCulling is false, normals will be flipped on the backside.
	 */
	public var _twoSidedLighting:Bool = false;

	/**
	 * Defines the alpha limits in alpha test mode.
	 */
	public var _alphaCutOff:Float = 0.4;

	/**
	 * Enforces alpha test in opaque or blend mode in order to improve the performances of some situations.
	 */
	public var _forceAlphaTest:Bool = false;

	/**
	 * If false, it allows the output of the shader to be in hdr space (e.g. more than one) which is usefull
	 * in combination of post process in float or half float mode.
	 */
	public var _ldrOutput:Bool = true;

	private var _renderTargets:SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(16);
	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _globalAmbientColor:Color3 = new Color3(0, 0, 0);
	private var _tempColor:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:PBRMaterialDefines = new PBRMaterialDefines();
	private var _cachedDefines:PBRMaterialDefines = new PBRMaterialDefines();

	private var _useLogarithmicDepth:Bool;
	

	/**
	 * Instantiates a new PBRMaterial instance.
	 * 
	 * @param name The material name
	 * @param scene The scene the material will be use in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this._cachedDefines.BonesPerMesh = -1;
		
		this.getRenderTargetTextures = function():SmartArray<RenderTargetTexture> {
			this._renderTargets.reset();
			
			if (StandardMaterial.ReflectionTextureEnabled && this._reflectionTexture != null && this._reflectionTexture.isRenderTarget) {
				this._renderTargets.push(this._reflectionTexture);
			}
			
			if (StandardMaterial.RefractionTextureEnabled && this._refractionTexture != null && this._refractionTexture.isRenderTarget) {
				this._renderTargets.push(this._refractionTexture);
			}
			
			return this._renderTargets;
		}
	}

	public function getClassName():String {
		// to be overriden...
		return 'PBRBaseMaterial';
	}

	@serialize()
	public var useLogarithmicDepth(get, set):Bool;
	inline private function get_useLogarithmicDepth():Bool {
		return this._useLogarithmicDepth;
	}
	inline private function set_useLogarithmicDepth(value:Bool):Bool {
		this._useLogarithmicDepth = value && this.getScene().getEngine().getCaps().fragmentDepthSupported;
		return value;
	}

	public function needAlphaBlending():Bool {
		if (this._linkRefractionWithTransparency) {
			return false;
		}
		return (this.alpha < 1.0) || (this._opacityTexture != null) || this._shouldUseAlphaFromAlbedoTexture() || this._opacityFresnelParameters != null && this._opacityFresnelParameters.isEnabled;
	}

	public function needAlphaTesting():Bool {
		if (this._linkRefractionWithTransparency) {
			return false;
		}
		return this._albedoTexture != null && this._albedoTexture.hasAlpha;
	}

	public function _shouldUseAlphaFromAlbedoTexture(): boolean {
		return this._albedoTexture != null && this._albedoTexture.hasAlpha && this._useAlphaFromAlbedoTexture;
	}

	inline public function getAlphaTestTexture():BaseTexture {
		return this._albedoTexture;
	}

	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this._defines.INSTANCES != useInstances) {
			return false;
		}
		
		return false;
	}

	private function convertColorToLinearSpaceToRef(color:Color3, ref:Color3) {
		PBRMaterial.convertColorToLinearSpaceToRef(color, ref, this._useScalarInLinearSpace);
	}

	private static function _convertColorToLinearSpaceToRef(color:Color3, ref:Color3, useScalarInLinear:Bool) {
		if (!useScalarInLinear) {
			color.toLinearSpaceToRef(ref);
		} 
		else {
			ref.r = color.r;
			ref.g = color.g;
			ref.b = color.b;
		}
	}

	private static var _scaledAlbedo:Color3 = new Color3();
	private static var _scaledReflectivity:Color3 = new Color3();
	private static var _scaledEmissive:Color3 = new Color3();
	private static var _scaledReflection:Color3 = new Color3();

	public static function BindLights(scene:Scene, mesh:AbstractMesh, effect:Effect, defines:MaterialDefines, useScalarInLinearSpace:Bool, maxSimultaneousLights:Int, usePhysicalLightFalloff:Bool) {
		var lightIndex:Int = 0;
		var depthValuesAlreadySet:Bool = false;
		for (light in mesh._lightSources) {
			var useUbo = light._uniformBuffer.useUbo;
			
			light._uniformBuffer.bindToEffect(effect, "Light" + lightIndex);
			MaterialHelper.BindLightProperties(light, effect, lightIndex);
			
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(light.diffuse, PBRMaterial._scaledAlbedo, useScalarInLinearSpace);
			
			PBRMaterial._scaledAlbedo.scaleToRef(light.intensity, PBRMaterial._scaledAlbedo);
			light._uniformBuffer.updateColor4(useUbo ? "vLightDiffuse" : "vLightDiffuse" + lightIndex, PBRMaterial._scaledAlbedo, usePhysicalLightFalloff ? light.radius : light.range);
			
			if (defines.SPECULARTERM) {
				this.convertColorToLinearSpaceToRef(light.specular, PBRMaterial._scaledReflectivity, useScalarInLinearSpace);
				
				PBRMaterial._scaledReflectivity.scaleToRef(light.intensity, PBRMaterial._scaledReflectivity);
				light._uniformBuffer.updateColor3(useUbo ? "vLightSpecular" : "vLightSpecular" + lightIndex, PBRMaterial._scaledReflectivity);
			}
			
			// Shadows
			if (scene.shadowsEnabled) {
				depthValuesAlreadySet = MaterialHelper.BindLightShadow(light, scene, mesh, lightIndex + "", effect, depthValuesAlreadySet);
			}
			
			light._uniformBuffer.update();
			
			lightIndex++;
			
			if (lightIndex == maxSimultaneousLights) {
				break;
			}
		}
	}

	public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (this.isFrozen) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		var scene = this.getScene();
		var engine = scene.getEngine();
		var needUVs = false;
		
		this._defines.reset();
		
		if (scene.lightsEnabled && !this._disableLighting) {
			MaterialHelper.PrepareDefinesForLights(scene, mesh, this._defines, true, this._maxSimultaneousLights);
		}
		
		if (!this.checkReadyOnEveryCall) {
			if (this._renderId == scene.getRenderId()) {
				if (this._checkCache(scene, mesh, useInstances)) {
					return true;
				}
			}
		}
		
		if (scene.texturesEnabled) {
			if (scene.getEngine().getCaps().textureLOD) {
				this._defines.LODBASEDMICROSFURACE = true;
			}
			
			if (this._albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
				if (!this._albedoTexture.isReadyOrNotBlocking()) {
					return false;
				}
				
				needUVs = true;
				this._defines.ALBEDO = true;
			}
			
			if (this._ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
				if (!this._ambientTexture.isReadyOrNotBlocking()) {
					return false;
				}
				
				needUVs = true;
				this._defines.AMBIENT = true;
				this._defines.AMBIENTINGRAYSCALE = this._useAmbientInGrayScale;
			}
			
			if (this._opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
				if (!this._opacityTexture.isReadyOrNotBlocking()) {
					return false;
				}
				
				needUVs = true;
				this._defines.OPACITY = true;
				
				if (this._opacityTexture.getAlphaFromRGB) {
					this._defines.OPACITYRGB = true;
				}
			}
			
			var reflectionTexture = this._reflectionTexture != null ? this._reflectionTexture : scene.environmentTexture;
			if (reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
				if (!reflectionTexture.isReadyOrNotBlocking()) {
					return false;
				}
				
				this._defines.REFLECTION = true;
				
				if (reflectionTexture.coordinatesMode == Texture.INVCUBIC_MODE) {
					this._defines.INVERTCUBICMAP = true;
				}
				
				this._defines.REFLECTIONMAP_3D = reflectionTexture.isCube;
				
				switch (reflectionTexture.coordinatesMode) {
					case Texture.CUBIC_MODE, Texture.INVCUBIC_MODE:
						this._defines.REFLECTIONMAP_CUBIC = true;
						
					case Texture.EXPLICIT_MODE:
						this._defines.REFLECTIONMAP_EXPLICIT = true;
						
					case Texture.PLANAR_MODE:
						this._defines.REFLECTIONMAP_PLANAR = true;
						
					case Texture.PROJECTION_MODE:
						this._defines.REFLECTIONMAP_PROJECTION = true;
						
					case Texture.SKYBOX_MODE:
						this._defines.REFLECTIONMAP_SKYBOX = true;
						
					case Texture.SPHERICAL_MODE:
						this._defines.REFLECTIONMAP_SPHERICAL = true;
						
					case Texture.EQUIRECTANGULAR_MODE:
						this._defines.REFLECTIONMAP_EQUIRECTANGULAR = true;
						
					case Texture.FIXED_EQUIRECTANGULAR_MODE:
						this._defines.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = true;
						
					case Texture.FIXED_EQUIRECTANGULAR_MIRRORED_MODE:
						this._defines.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = true;
				}
				
				if (Std.is(reflectionTexture, HDRCubeTexture)) {
					this._defines.USESPHERICALFROMREFLECTIONMAP = true;
					
					if (untyped reflectionTexture).isPMREM) {
						this._defines.USEPMREMREFLECTION = true;
					}
				}
			}
			
			if (this._lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
				if (!this._lightmapTexture.isReadyOrNotBlocking()) {
					return false;
				}
				
				needUVs = true;
				this._defines.LIGHTMAP = true;
				this._defines.USELIGHTMAPASSHADOWMAP = this._useLightmapAsShadowmap;
			}
			
			if (this._emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
				if (!this._emissiveTexture.isReadyOrNotBlocking()) {
					return false;
				}
				
				needUVs = true;
				this._defines.EMISSIVE = true;
			}

			if (StandardMaterial.SpecularTextureEnabled) {
				if (this._metallicTexture != null) {
					if (!this._metallicTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					needUVs = true;
					this._defines.METALLICWORKFLOW = true;
					this._defines.METALLICMAP = true;
					this._defines.ROUGHNESSSTOREINMETALMAPALPHA = this._useRoughnessFromMetallicTextureAlpha;
					this._defines.ROUGHNESSSTOREINMETALMAPGREEN = !this._useRoughnessFromMetallicTextureAlpha && this._useRoughnessFromMetallicTextureGreen;
					this._defines.METALLNESSSTOREINMETALMAPBLUE = this._useMetallnessFromMetallicTextureBlue;
					this._defines.AOSTOREINMETALMAPRED = this._useAmbientOcclusionFromMetallicTextureRed;
				}
				else if (this._reflectivityTexture != null) {
					if (!this._reflectivityTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					needUVs = true;
					this._defines.REFLECTIVITY = true;
					this._defines.MICROSURFACEFROMREFLECTIVITYMAP = this._useMicroSurfaceFromReflectivityMapAlpha;
					this._defines.MICROSURFACEAUTOMATIC = this._useAutoMicroSurfaceFromReflectivityMap;
				}
				
				if (this._microSurfaceTexture != null) {
					if (!this._microSurfaceTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					needUVs = true;
					this._defines.MICROSURFACEMAP = true;
				}
			}
			
			if (scene.getEngine().getCaps().standardDerivatives && this._bumpTexture != null && StandardMaterial.BumpTextureEnabled && !this._disableBumpMap) {
				// Bump texure can not be none blocking.
				if (!this._bumpTexture.isReady()) {
					return false;
				}
				
				needUVs = true;
				this._defines.BUMP = true;
				
				if (this._useParallax && this._albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					this._defines.PARALLAX = true;
					if (this._useParallaxOcclusion) {
						this._defines.PARALLAXOCCLUSION = true;
					}
				}
				
				if (this._invertNormalMapX) {
					this._defines.INVERTNORMALMAPX = true;
				}
				
				if (this._invertNormalMapY) {
					this._defines.INVERTNORMALMAPY = true;
				}
				
				if (scene._mirroredCameraPosition) {
					this._defines.INVERTNORMALMAPX = !this._defines.INVERTNORMALMAPX;
					this._defines.INVERTNORMALMAPY = !this._defines.INVERTNORMALMAPY;
				}
				
				this._defines.USERIGHTHANDEDSYSTEM = scene.useRightHandedSystem;
			}
			
			if (this._refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
				if (!this._refractionTexture.isReadyOrNotBlocking()) {
					return false;
				}
				
				needUVs = true;
				this._defines.REFRACTION = true;
				this._defines.REFRACTIONMAP_3D = this._refractionTexture.isCube;
				
				if (this._linkRefractionWithTransparency) {
					this._defines.LINKREFRACTIONTOTRANSPARENCY = true;
				}
				if (Std.is(this._refractionTexture, HDRCubeTexture)) {
					this._defines.REFRACTIONMAPINLINEARSPACE = true;
					
					if (untyped this._refractionTexture.isPMREM) {
						this._defines.USEPMREMREFRACTION = true;
					}
				}
			}
			
			if (this._cameraColorGradingTexture != null && StandardMaterial.ColorGradingTextureEnabled) {
				// Color Grading texure can not be none blocking.
				if (!this._cameraColorGradingTexture.isReady()) {
					return false;
				}
				
				this._defines.CAMERACOLORGRADING = true;
			}
			
			if (!this.backFaceCulling && this._twoSidedLighting) {
				this._defines.TWOSIDEDLIGHTING = true;
			}
		}
		
		this._defines.LDROUTPUT = this._ldrOutput;
		
		// Effect
		if (scene.clipPlane != null) {
			this._defines.CLIPPLANE = true;
		}
		
		this._defines.ALPHATESTVALUE = this._alphaCutOff;
		if (engine.getAlphaTesting() || this._forceAlphaTest) {
			this._defines.ALPHATEST = true;
		}
		
		if (this._shouldUseAlphaFromAlbedoTexture()) {
			this._defines.ALPHAFROMALBEDO = true;
		}
		
		if (this._useEmissiveAsIllumination) {
			this._defines.EMISSIVEASILLUMINATION = true;
		}
		
		if (this.useLogarithmicDepth) {
			this._defines.LOGARITHMICDEPTH = true;
		}
		
		if (this._cameraContrast != 1) {
			this._defines.CAMERACONTRAST = true;
		}
		
		if (this._cameraExposure != 1) {
			this._defines.CAMERATONEMAP = true;
		}
		
		if (this._cameraColorCurves != null) {
			this._defines.CAMERACOLORCURVES = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this._defines.POINTSIZE = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this._defines.FOG = true;
		}
		
		if (StandardMaterial.FresnelEnabled) {
			// Fresnel
			if (this._opacityFresnelParameters != null && this._opacityFresnelParameters.isEnabled ||
				this._emissiveFresnelParameters != null && this._emissiveFresnelParameters.isEnabled) {
					
				if (this._opacityFresnelParameters != null && this._opacityFresnelParameters.isEnabled) {
					this._defines.OPACITYFRESNEL = true;
				}
				
				if (this._emissiveFresnelParameters != null && this._emissiveFresnelParameters.isEnabled) {
					this._defines.EMISSIVEFRESNEL = true;
				}
				
				this._defines.FRESNEL = true;
			}
		}
		
		if (this._defines.SPECULARTERM && this._useSpecularOverAlpha) {
			this._defines.SPECULAROVERALPHA = true;
		}
		
		if (this._usePhysicalLightFalloff) {
			this._defines.USEPHYSICALLIGHTFALLOFF = true;
		}
		
		if (this._useRadianceOverAlpha) {
			this._defines.RADIANCEOVERALPHA = true;
		}
		
		if ((this._metallic != 0) || (this._roughness != 0)) {
			this._defines.METALLICWORKFLOW = true;
		}
		
		// Attribs
		if (mesh != null) {
			if (!scene.getEngine().getCaps().standardDerivatives && !mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
				mesh.createNormals(true);
				Tools.Warn("PBRMaterial: Normals have been created for the mesh: " + mesh.name);
			}
			
			if (mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
				this._defines.NORMAL = true;
				if (mesh.isVerticesDataPresent(VertexBuffer.TangentKind)) {
					this._defines.TANGENT = true;
				}
			}
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this._defines.UV1 = true;
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					this._defines.UV2 = true;
				}
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this._defines.VERTEXCOLOR = true;
				
				if (mesh.hasVertexAlpha) {
					this._defines.VERTEXALPHA = true;
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
			}
			
			// Instances
			if (useInstances) {
				this._defines.INSTANCES = true;
			}
			
		    if (mesh.morphTargetManager != null) {
				var manager = mesh.morphTargetManager;
				this._defines.MORPHTARGETS_TANGENT = manager.supportsTangents && this._defines.TANGENT;
				this._defines.MORPHTARGETS_NORMAL = manager.supportsNormals && this._defines.NORMAL;
				this._defines.MORPHTARGETS = (manager.numInfluencers > 0);
				this._defines.NUM_MORPH_INFLUENCERS = manager.numInfluencers;
			}
		}
		
		// Get correct effect
		if (!this._defines.isEqual(this._cachedDefines)) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();
			if (this._defines.REFLECTION) {
				fallbacks.addFallback(0, "REFLECTION");
			}
			
			if (this._defines.REFRACTION) {
				fallbacks.addFallback(0, "REFRACTION");
			}
			
			if (this._defines.REFLECTIVITY) {
				fallbacks.addFallback(0, "REFLECTIVITY");
			}
			
			if (this._defines.BUMP) {
				fallbacks.addFallback(0, "BUMP");
			}
			
			if (this._defines.PARALLAX) {
				fallbacks.addFallback(1, "PARALLAX");
			}
			
			if (this._defines.PARALLAXOCCLUSION) {
				fallbacks.addFallback(0, "PARALLAXOCCLUSION");
			}
			
			if (this._defines.SPECULAROVERALPHA) {
				fallbacks.addFallback(0, "SPECULAROVERALPHA");
			}
			
			if (this._defines.FOG) {
				fallbacks.addFallback(1, "FOG");
			}
			
			if (this._defines.POINTSIZE) {
				fallbacks.addFallback(0, "POINTSIZE");
			}
			
			if (this._defines.LOGARITHMICDEPTH) {
				fallbacks.addFallback(0, "LOGARITHMICDEPTH");
			}
			
			MaterialHelper.HandleFallbacksForShadows(this._defines, fallbacks, this._maxSimultaneousLights);
			
			if (this._defines.SPECULARTERM) {
				fallbacks.addFallback(0, "SPECULARTERM");
			}
			
			if (this._defines.OPACITYFRESNEL) {
				fallbacks.addFallback(1, "OPACITYFRESNEL");
			}
			
			if (this._defines.EMISSIVEFRESNEL) {
				fallbacks.addFallback(2, "EMISSIVEFRESNEL");
			}
			
			if (this._defines.FRESNEL) {
				fallbacks.addFallback(3, "FRESNEL");
			}
			
			if (this._defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs = [VertexBuffer.PositionKind];
			
			if (this._defines.NORMAL) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this._defines.TANGENT) {
				attribs.push(VertexBuffer.TangentKind);
			}
			
			if (this._defines.UV1) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this._defines.UV2) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (this._defines.VERTEXCOLOR) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, this._defines, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, this._defines);
			MaterialHelper.PrepareAttributesForMorphTargets(attribs, mesh, this._defines);
			
			// Legacy browser patch
			var join = this._defines.toString();
			
			var uniforms = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vAmbientColor", "vAlbedoColor", "vReflectivityColor", "vEmissiveColor", "vReflectionColor",
					"vFogInfos", "vFogColor", "pointSize",
					"vAlbedoInfos", "vAmbientInfos", "vOpacityInfos", "vReflectionInfos", "vEmissiveInfos", "vReflectivityInfos", "vMicroSurfaceSamplerInfos", "vBumpInfos", "vLightmapInfos", "vRefractionInfos",
					"mBones",
					"vClipPlane", "albedoMatrix", "ambientMatrix", "opacityMatrix", "reflectionMatrix", "emissiveMatrix", "reflectivityMatrix", "microSurfaceSamplerMatrix", "bumpMatrix", "lightmapMatrix", "refractionMatrix",
					"depthValues",
					"opacityParts", "emissiveLeftColor", "emissiveRightColor",
					"vLightingIntensity",
					"logarithmicDepthConstant",
					"vSphericalX", "vSphericalY", "vSphericalZ",
					"vSphericalXX", "vSphericalYY", "vSphericalZZ",
					"vSphericalXY", "vSphericalYZ", "vSphericalZX",
					"vMicrosurfaceTextureLods",
					"vCameraInfos"
			];
			
			var samplers = ["albedoSampler", "ambientSampler", "opacitySampler", "reflectionCubeSampler", "reflection2DSampler", "emissiveSampler", "reflectivitySampler", "microSurfaceSampler", "bumpSampler", "lightmapSampler", "refractionCubeSampler", "refraction2DSampler"];
			var uniformBuffers = ["Material", "Scene"];
			
			if (this._defines.CAMERACOLORCURVES) {
				ColorCurves.PrepareUniforms(uniforms);
			}
			if (this._defines.CAMERACOLORGRADING) {
				ColorGradingTexture.PrepareUniformsAndSamplers(uniforms, samplers);
			}
			MaterialHelper.PrepareUniformsAndSamplersList({
				uniformsNames: uniforms, 
				uniformBuffersNames: uniformBuffers,
				samplers: samplers, 
				defines: this._defines, 
				maxSimultaneousLights: this._maxSimultaneousLights
			});
			
			var onCompiled = function(effect:Effect) {
				if (this.onCompiled != null) {
					this.onCompiled(effect);
				}
				
				this.bindSceneUniformBuffer(effect, scene.getSceneUniformBuffer());
			};
			
			this._effect = scene.getEngine().createEffect("pbr", {
				attributes: attribs,
				uniformsNames: uniforms,
				uniformBuffersNames: uniformBuffers,
				samplers: samplers,
				defines: join,
				fallbacks: fallbacks,
				onCompiled: onCompiled,
				onError: this.onError,
				indexParameters: { maxSimultaneousLights: this._maxSimultaneousLights, maxSimultaneousMorphTargets: this._defines.NUM_MORPH_INFLUENCERS }
			}, engine);
			
			this.buildUniformLayout();
		}
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		return true;
	}

	public buildUniformLayout(): void {
		// Order is important !
		this._uniformBuffer.addUniform("vAlbedoInfos", 2);
		this._uniformBuffer.addUniform("vAmbientInfos", 3);
		this._uniformBuffer.addUniform("vOpacityInfos", 2);
		this._uniformBuffer.addUniform("vEmissiveInfos", 2);
		this._uniformBuffer.addUniform("vLightmapInfos", 2);
		this._uniformBuffer.addUniform("vReflectivityInfos", 3);
		this._uniformBuffer.addUniform("vMicroSurfaceSamplerInfos", 2);
		this._uniformBuffer.addUniform("vRefractionInfos", 4);
		this._uniformBuffer.addUniform("vReflectionInfos", 2);
		this._uniformBuffer.addUniform("vBumpInfos", 3);
		this._uniformBuffer.addUniform("albedoMatrix", 16);
		this._uniformBuffer.addUniform("ambientMatrix", 16);
		this._uniformBuffer.addUniform("opacityMatrix", 16);
		this._uniformBuffer.addUniform("emissiveMatrix", 16);
		this._uniformBuffer.addUniform("lightmapMatrix", 16);
		this._uniformBuffer.addUniform("reflectivityMatrix", 16);
		this._uniformBuffer.addUniform("microSurfaceSamplerMatrix", 16);
		this._uniformBuffer.addUniform("bumpMatrix", 16);
		this._uniformBuffer.addUniform("refractionMatrix", 16);
		this._uniformBuffer.addUniform("reflectionMatrix", 16);
		
		this._uniformBuffer.addUniform("vReflectionColor", 3);
		this._uniformBuffer.addUniform("vAlbedoColor", 4);
		this._uniformBuffer.addUniform("vLightingIntensity", 4);
		
		this._uniformBuffer.addUniform("vMicrosurfaceTextureLods", 2);
		this._uniformBuffer.addUniform("vReflectivityColor", 4);
		this._uniformBuffer.addUniform("vEmissiveColor", 3);
		this._uniformBuffer.addUniform("opacityParts", 4);
		this._uniformBuffer.addUniform("emissiveLeftColor", 4);
		this._uniformBuffer.addUniform("emissiveRightColor", 4);
		
		this._uniformBuffer.addUniform("pointSize", 1);
		this._uniformBuffer.create();
	}

	public function unbind() {
		if (this._reflectionTexture != null && this._reflectionTexture.isRenderTarget) {
			this._uniformBuffer.setTexture("reflection2DSampler", null);
		}
		
		if (this._refractionTexture != null && this._refractionTexture.isRenderTarget) {
			this._uniformBuffer.setTexture("refraction2DSampler", null);
		}
		
		super.unbind();
	}

	public function bindOnlyWorldMatrix(world:Matrix) {
		this._effect.setMatrix("world", world);
	}

	private var _myScene:Scene = null;
	private var _myShadowGenerator:ShadowGenerator = null;

	public function bind(world:Matrix, ?mesh:Mesh) {
		this._myScene = this.getScene();
		var effect = this._effect;
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._effect);
		
		if (this._myScene.getCachedMaterial() != this) {
			this._uniformBuffer.bindToEffect(effect, "Material");
			
			this.bindViewProjection(effect);
			
			if (!this._uniformBuffer.useUbo || !this.isFrozen || !this._uniformBuffer.isSync) {
				// Fresnel
				if (StandardMaterial.FresnelEnabled) {
					if (this._opacityFresnelParameters != null && this._opacityFresnelParameters.isEnabled) {
						this._uniformBuffer.updateColor4("opacityParts", new Color3(this._opacityFresnelParameters.leftColor.toLuminance(), this._opacityFresnelParameters.rightColor.toLuminance(), this._opacityFresnelParameters.bias), this._opacityFresnelParameters.power);
					}
					
					if (this._emissiveFresnelParameters != null && this._emissiveFresnelParameters.isEnabled) {
						this._uniformBuffer.updateColor4("emissiveLeftColor", this._emissiveFresnelParameters.leftColor, this._emissiveFresnelParameters.power);
						this._uniformBuffer.updateColor4("emissiveRightColor", this._emissiveFresnelParameters.rightColor, this._emissiveFresnelParameters.bias);
					}
				}
				
				// Texture uniforms      
				if (this._myScene.texturesEnabled) {
					if (this._albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
						this._uniformBuffer.updateFloat2("vAlbedoInfos", this._albedoTexture.coordinatesIndex, this._albedoTexture.level);
						this._uniformBuffer.updateMatrix("albedoMatrix", this._albedoTexture.getTextureMatrix());
					}
					
					if (this._ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
						this._uniformBuffer.updateFloat3("vAmbientInfos", this._ambientTexture.coordinatesIndex, this._ambientTexture.level, this._ambientTextureStrength);
						this._uniformBuffer.updateMatrix("ambientMatrix", this._ambientTexture.getTextureMatrix());
					}
					
					if (this._opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
						this._uniformBuffer.updateFloat2("vOpacityInfos", this._opacityTexture.coordinatesIndex, this._opacityTexture.level);
						this._uniformBuffer.updateMatrix("opacityMatrix", this._opacityTexture.getTextureMatrix());
					}
					
					var reflectionTexture = this._reflectionTexture != null ? this._reflectionTexture : this._myScene.environmentTexture;
					if (reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
						this._microsurfaceTextureLods.x = Math.round(Math.log(reflectionTexture.getSize().width) * Math.LOG2E);
						this._uniformBuffer.updateMatrix("reflectionMatrix", reflectionTexture.getReflectionTextureMatrix());
						this._uniformBuffer.updateFloat2("vReflectionInfos", reflectionTexture.level, 0);
						
						if (this._defines.USESPHERICALFROMREFLECTIONMAP) {
							var sp = cast (this.reflectionTexture, HDRCubeTexture).sphericalPolynomial;
							this._effect.setFloat3("vSphericalX", sp.x.x, sp.x.y, sp.x.z);
							this._effect.setFloat3("vSphericalY", sp.y.x, sp.y.y, sp.y.z);
							this._effect.setFloat3("vSphericalZ", sp.z.x, sp.z.y, sp.z.z);
							this._effect.setFloat3("vSphericalXX", sp.xx.x, sp.xx.y, sp.xx.z);
							this._effect.setFloat3("vSphericalYY", sp.yy.x, sp.yy.y, sp.yy.z);
							this._effect.setFloat3("vSphericalZZ", sp.zz.x, sp.zz.y, sp.zz.z);
							this._effect.setFloat3("vSphericalXY", sp.xy.x, sp.xy.y, sp.xy.z);
							this._effect.setFloat3("vSphericalYZ", sp.yz.x, sp.yz.y, sp.yz.z);
							this._effect.setFloat3("vSphericalZX", sp.zx.x, sp.zx.y, sp.zx.z);
						}
					}
					
					if (this._emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
						this._uniformBuffer.updateFloat2("vEmissiveInfos", this._emissiveTexture.coordinatesIndex, this._emissiveTexture.level);
						this._uniformBuffer.updateMatrix("emissiveMatrix", this._emissiveTexture.getTextureMatrix());
					}
					
					if (this._lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
						this._uniformBuffer.updateFloat2("vLightmapInfos", this._lightmapTexture.coordinatesIndex, this._lightmapTexture.level);
						this._uniformBuffer.updateMatrix("lightmapMatrix", this._lightmapTexture.getTextureMatrix());
					}
					
					if (StandardMaterial.SpecularTextureEnabled) {
						if (this._metallicTexture != null) {
							this._uniformBuffer.updateFloat3("vReflectivityInfos", this._metallicTexture.coordinatesIndex, this._metallicTexture.level, this._ambientTextureStrength);
							this._uniformBuffer.updateMatrix("reflectivityMatrix", this._metallicTexture.getTextureMatrix());
						}
						else if (this._reflectivityTexture != null) {
							this._uniformBuffer.updateFloat3("vReflectivityInfos", this._reflectivityTexture.coordinatesIndex, this._reflectivityTexture.level, 1.0);
							this._uniformBuffer.updateMatrix("reflectivityMatrix", this._reflectivityTexture.getTextureMatrix());
						}
						
						if (this._microSurfaceTexture != null) {
							this._uniformBuffer.updateFloat2("vMicroSurfaceSamplerInfos", this._microSurfaceTexture.coordinatesIndex, this._microSurfaceTexture.level);
							this._uniformBuffer.updateMatrix("microSurfaceSamplerMatrix", this._microSurfaceTexture.getTextureMatrix());
						}
					}
					
					if (this._bumpTexture != null && this._myScene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled && !this._disableBumpMap) {
						this._uniformBuffer.updateFloat3("vBumpInfos", this._bumpTexture.coordinatesIndex, this._bumpTexture.level, this._parallaxScaleBias);
						this._uniformBuffer.updateMatrix("bumpMatrix", this._bumpTexture.getTextureMatrix());
					}
					
					if (this._refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
						this._microsurfaceTextureLods.y = Math.round(Math.log(this._refractionTexture.getSize().width) * com.babylonhx.math.Tools.LOG2E);
						
						var depth:Float = 1.0;
						if (!this._refractionTexture.isCube) {
							this._uniformBuffer.updateMatrix("refractionMatrix", this._refractionTexture.getReflectionTextureMatrix());
							
							if (Std.is(this.refractionTexture, RefractionTexture)) {
								depth = untyped this.refractionTexture.depth;
							}
						}
						this._uniformBuffer.updateFloat4("vRefractionInfos", this._refractionTexture.level, this._indexOfRefraction, depth, this._invertRefractionY ? -1 : 1);
					}
					
					if (reflectionTexture != null ? reflectionTexture : this._refractionTexture) {
						this._uniformBuffer.updateFloat2("vMicrosurfaceTextureLods", this._microsurfaceTextureLods.x, this._microsurfaceTextureLods.y);
					}
				}
				
				// Point size
				if (this.pointsCloud) {
					this._uniformBuffer.updateFloat("pointSize", this.pointSize);
				}
				
				// Colors
				if (this._defines.METALLICWORKFLOW) {
					PBRMaterial._scaledReflectivity.r = (this._metallic == 0) ? 1 : this._metallic;
					PBRMaterial._scaledReflectivity.g = (this._roughness == 0) ? 1 : this._roughness;
					this._uniformBuffer.updateColor4("vReflectivityColor", PBRMaterial._scaledReflectivity, 0);
				}
				else {
					// GAMMA CORRECTION.
					this.convertColorToLinearSpaceToRef(this._reflectivityColor, PBRMaterial._scaledReflectivity);
					this._uniformBuffer.updateColor4("vReflectivityColor", PBRMaterial._scaledReflectivity, this._microSurface);
				}
				
				// GAMMA CORRECTION.
				this.convertColorToLinearSpaceToRef(this._emissiveColor, PBRMaterial._scaledEmissive);
				this._uniformBuffer.updateColor3("vEmissiveColor", PBRMaterial._scaledEmissive);
				
				// GAMMA CORRECTION.
				this.convertColorToLinearSpaceToRef(this._reflectionColor, PBRMaterial._scaledReflection);
				this._uniformBuffer.updateColor3("vReflectionColor", PBRMaterial._scaledReflection);
				
				// GAMMA CORRECTION.
				this.convertColorToLinearSpaceToRef(this._albedoColor, PBRMaterial._scaledAlbedo);
				this._uniformBuffer.updateColor4("vAlbedoColor", PBRMaterial._scaledAlbedo, this.alpha * mesh.visibility);
				
				// Misc
				this._lightingInfos.x = this._directIntensity;
				this._lightingInfos.y = this._emissiveIntensity;
				this._lightingInfos.z = this._environmentIntensity;
				this._lightingInfos.w = this._specularIntensity;
				
				this._uniformBuffer.updateVector4("vLightingIntensity", this._lightingInfos);
			}
			
			// Textures        
			if (this._myScene.texturesEnabled) {
				if (this._albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					this._uniformBuffer.setTexture("albedoSampler", this._albedoTexture);
				}
				
				if (this._ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
					this._uniformBuffer.setTexture("ambientSampler", this._ambientTexture);
				}
				
				if (this._opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
					this._uniformBuffer.setTexture("opacitySampler", this._opacityTexture);
				}
				
				if (reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					if (reflectionTexture.isCube) {
						this._uniformBuffer.setTexture("reflectionCubeSampler", reflectionTexture);
					} 
					else {
						this._uniformBuffer.setTexture("reflection2DSampler", reflectionTexture);
					}
				}
				
				if (this._emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
					this._uniformBuffer.setTexture("emissiveSampler", this._emissiveTexture);
				}
				
				if (this._lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
					this._uniformBuffer.setTexture("lightmapSampler", this._lightmapTexture);
				}
				
				if (StandardMaterial.SpecularTextureEnabled) {
					if (this._metallicTexture != null) {
						this._uniformBuffer.setTexture("reflectivitySampler", this._metallicTexture);
					}
					else if (this._reflectivityTexture != null) {
						this._uniformBuffer.setTexture("reflectivitySampler", this._reflectivityTexture);
					}
					
					if (this._microSurfaceTexture != null) {
						this._uniformBuffer.setTexture("microSurfaceSampler", this._microSurfaceTexture);
					}
				}
				
				if (this._bumpTexture != null && this._myScene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled && !this._disableBumpMap) {
					this._uniformBuffer.setTexture("bumpSampler", this._bumpTexture);
				}
				
				if (this._refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
					if (this._refractionTexture.isCube) {
						this._uniformBuffer.setTexture("refractionCubeSampler", this._refractionTexture);
					} 
					else {
						this._uniformBuffer.setTexture("refraction2DSampler", this._refractionTexture);
					}
				}
				
				if (this._cameraColorGradingTexture != null && StandardMaterial.ColorGradingTextureEnabled) {
					ColorGradingTexture.Bind(this._cameraColorGradingTexture, this._effect);
				}
			}
			
			// Clip plane
			MaterialHelper.BindClipPlane(this._effect, this._myScene);
			
			// Colors
			this._myScene.ambientColor.multiplyToRef(this._ambientColor, this._globalAmbientColor);
			
			effect.setVector3("vEyePosition", this._myScene._mirroredCameraPosition ? this._myScene._mirroredCameraPosition : this._myScene.activeCamera.position);
			effect.setColor3("vAmbientColor", this._globalAmbientColor);
		}
		
		if (this._myScene.getCachedMaterial() != this || !this.isFrozen) {
			// Lights
			if (this._myScene.lightsEnabled && !this._disableLighting) {
				PBRMaterial.BindLights(this._myScene, mesh, this._effect, this._defines, this._useScalarInLinearSpace, this._maxSimultaneousLights, this._usePhysicalLightFalloff);
			}
			
			// View
			if (this._myScene.fogEnabled && mesh.applyFog && this._myScene.fogMode != Scene.FOGMODE_NONE || reflectionTexture) {
				this.bindView(effect);
			}
			
			// Fog
			MaterialHelper.BindFogParameters(this._myScene, mesh, this._effect);
			
			// Morph targets
			if (this._defines.NUM_MORPH_INFLUENCERS) {
				MaterialHelper.BindMorphTargetParameters(mesh, this._effect);
			}
			
			this._cameraInfos.x = this._cameraExposure;
			this._cameraInfos.y = this._cameraContrast;
			effect.setVector4("vCameraInfos", this._cameraInfos);
			
			if (this._cameraColorCurves != null) {
				ColorCurves.Bind(this._cameraColorCurves, this._effect);
			}
			
			// Log. depth
			MaterialHelper.BindLogDepth(this._defines.LOGARITHMICDEPTH, this._effect, this._myScene);
		}
		
		this._uniformBuffer.update();
		
		this._afterBind(mesh);
		
		this._myScene = null;
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this._albedoTexture != null && this._albedoTexture.animations != null && this._albedoTexture.animations.length > 0) {
			results.push(this._albedoTexture);
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
		
		if (this._metallicTexture != null && this._metallicTexture.animations != null && this._metallicTexture.animations.length > 0) {
			results.push(this._metallicTexture);
		}
		else if (this._reflectivityTexture != null && this._reflectivityTexture.animations != null && this._reflectivityTexture.animations.length > 0) {
			results.push(this._reflectivityTexture);
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
		
		if (this._cameraColorGradingTexture != null && this._cameraColorGradingTexture.animations != null && this._cameraColorGradingTexture.animations.length > 0) {
			results.push(this._cameraColorGradingTexture);
		}
		
		return results;
	}

	public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		if (forceDisposeTextures) {
			if (this._albedoTexture != null) {
				this._albedoTexture.dispose();
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
			
			if (this._metallicTexture != null) {
				this._metallicTexture.dispose();
			}
			
			if (this._reflectivityTexture != null) {
				this._reflectivityTexture.dispose();
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
			
			if (this._cameraColorGradingTexture != null) {
				this._cameraColorGradingTexture.dispose();
			}
		}
		
		this._renderTargets.dispose();
		
		super.dispose(forceDisposeEffect, forceDisposeTextures);
	}
	
}
