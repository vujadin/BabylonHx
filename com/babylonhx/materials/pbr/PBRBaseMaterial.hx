package com.babylonhx.materials.pbr;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.RefractionTexture;
import com.babylonhx.tools.TextureTools;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.Tools;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.BaseSubMesh;
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
class PBRBaseMaterial extends PushMaterial {

	/**
	 * Intensity of the direct lights e.g. the four lights available in your scene.
	 * This impacts both the direct diffuse and specular highlights.
	 */
	private var _directIntensity:Float = 1.0;
	
	/**
	 * Intensity of the emissive part of the material.
	 * This helps controlling the emissive effect without modifying the emissive color.
	 */
	private var _emissiveIntensity:Float = 1.0;
	
	/**
	 * Intensity of the environment e.g. how much the environment will light the object
	 * either through harmonics for rough material or through the refelction for shiny ones.
	 */
	private var _environmentIntensity:Float = 1.0;
	
	/**
	 * This is a special control allowing the reduction of the specular highlights coming from the 
	 * four lights of the scene. Those highlights may not be needed in full environment lighting.
	 */
	private var _specularIntensity:Float = 1.0;

	private var _lightingInfos:Vector4;
	
	/**
	 * Debug Control allowing disabling the bump map on this material.
	 */
	private var _disableBumpMap:Bool = false;

	/**
	 * AKA Diffuse Texture in standard nomenclature.
	 */
	private var _albedoTexture:BaseTexture;
	
	/**
	 * AKA Occlusion Texture in other nomenclature.
	 */
	private var _ambientTexture:BaseTexture;

	/**
	 * AKA Occlusion Texture Intensity in other nomenclature.
	 */
	private var _ambientTextureStrength:Float = 1.0;

	private var _opacityTexture:BaseTexture;

	private var _reflectionTexture:BaseTexture;

	private var _refractionTexture:BaseTexture;

	private var _emissiveTexture:BaseTexture;
	
	/**
	 * AKA Specular texture in other nomenclature.
	 */
	private var _reflectivityTexture:BaseTexture;

	/**
	 * Used to switch from specular/glossiness to metallic/roughness workflow.
	 */
	private var _metallicTexture:BaseTexture;

	/**
	 * Specifies the metallic scalar of the metallic/roughness workflow.
	 * Can also be used to scale the metalness values of the metallic texture.
	 */
	private var _metallic:Float = Math.NEGATIVE_INFINITY;

	/**
	 * Specifies the roughness scalar of the metallic/roughness workflow.
	 * Can also be used to scale the roughness values of the metallic texture.
	 */
	private var _roughness:Float = Math.NEGATIVE_INFINITY;

	/**
	 * Used to enable roughness/glossiness fetch from a separate chanel depending on the current mode.
	 * Gray Scale represents roughness in metallic mode and glossiness in specular mode.
	 */
	private var _microSurfaceTexture:BaseTexture;

	private var _bumpTexture:BaseTexture;

	private var _lightmapTexture:BaseTexture;

	private var _ambientColor:Color3 = new Color3(0, 0, 0);

	/**
	 * AKA Diffuse Color in other nomenclature.
	 */
	private var _albedoColor:Color3 = new Color3(1, 1, 1);
	
	/**
	 * AKA Specular Color in other nomenclature.
	 */
	private var _reflectivityColor:Color3 = new Color3(1, 1, 1);

	private var _reflectionColor:Color3 = new Color3(1, 1, 1);

	private var _emissiveColor:Color3 = new Color3(0, 0, 0);
	
	/**
	 * AKA Glossiness in other nomenclature.
	 */
	private var _microSurface:Float = 0.9;

	/**
	 * source material index of refraction (IOR)' / 'destination material IOR.
	 */
	private var _indexOfRefraction:Float = 0.66;
	
	/**
	 * Controls if refraction needs to be inverted on Y. This could be usefull for procedural texture.
	 */
	private var _invertRefractionY:Bool = false;

	/**
	 * This parameters will make the material used its opacity to control how much it is refracting aginst not.
	 * Materials half opaque for instance using refraction could benefit from this control.
	 */
	private var _linkRefractionWithTransparency:Bool = false;

	private var _useLightmapAsShadowmap:Bool = false;
	
	/**
     * This parameters will enable/disable Horizon occlusion to prevent normal maps to look shiny when the normal
     * makes the reflect vector face the model (under horizon).
     */
    private var _useHorizonOcclusion:Bool = true; 

    /**
     * This parameters will enable/disable radiance occlusion by preventing the radiance to lit
     * too much the area relying on ambient texture to define their ambient occlusion.
     */
    private var _useRadianceOcclusion:Bool = true;
	
	/**
	 * Specifies that the alpha is coming form the albedo channel alpha channel for alpha blending.
	 */
	private var _useAlphaFromAlbedoTexture:Bool = false;
	
	/**
	 * Specifies that the material will keeps the specular highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When sun reflects on it you can not see what is behind.
	 */
	private var _useSpecularOverAlpha:Bool = true;
	
	/**
	 * Specifies if the reflectivity texture contains the glossiness information in its alpha channel.
	 */
	private var _useMicroSurfaceFromReflectivityMapAlpha:Bool = false;

	/**
	 * Specifies if the metallic texture contains the roughness information in its alpha channel.
	 */
	private var _useRoughnessFromMetallicTextureAlpha:Bool = true;

	/**
	 * Specifies if the metallic texture contains the roughness information in its green channel.
	 */
	private var _useRoughnessFromMetallicTextureGreen:Bool = false;

	/**
	 * Specifies if the metallic texture contains the metallness information in its blue channel.
	 */
	private var _useMetallnessFromMetallicTextureBlue:Bool = false;

	/**
	 * Specifies if the metallic texture contains the ambient occlusion information in its red channel.
	 */
	private var _useAmbientOcclusionFromMetallicTextureRed:Bool = false;

	/**
	 * Specifies if the ambient texture contains the ambient occlusion information in its red channel only.
	 */
	private var _useAmbientInGrayScale:Bool = false;
	
	/**
	 * In case the reflectivity map does not contain the microsurface information in its alpha channel,
	 * The material will try to infer what glossiness each pixel should be.
	 */
	private var _useAutoMicroSurfaceFromReflectivityMap:Bool = false;
	
	/**
	 * BJS is using an harcoded light falloff based on a manually sets up range.
	 * In PBR, one way to represents the fallof is to use the inverse squared root algorythm.
	 * This parameter can help you switch back to the BJS mode in order to create scenes using both materials.
	 */
	private var _usePhysicalLightFalloff:Bool = true;
	
	/**
	 * Specifies that the material will keeps the reflection highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When the street lights reflects on it you can not see what is behind.
	 */
	private var _useRadianceOverAlpha:Bool = true;
	
	/**
	 * Allows using the bump map in parallax mode.
	 */
	private var _useParallax:Bool = false;

	/**
	 * Allows using the bump map in parallax occlusion mode.
	 */
	private var _useParallaxOcclusion:Bool = false;

	/**
	 * Controls the scale bias of the parallax mode.
	 */
	private var _parallaxScaleBias:Float = 0.05;
	
	/**
	 * If sets to true, disables all the lights affecting the material.
	 */
	private var _disableLighting:Bool = false;

	/**
	 * Number of Simultaneous lights allowed on the material.
	 */
	private var _maxSimultaneousLights:Int = 4;  

	/**
	 * If sets to true, x component of normal map value will be inverted (x = 1.0 - x).
	 */
	private var _invertNormalMapX:Bool = false;

	/**
	 * If sets to true, y component of normal map value will be inverted (y = 1.0 - y).
	 */
	private var _invertNormalMapY:Bool = false;

	/**
	 * If sets to true and backfaceCulling is false, normals will be flipped on the backside.
	 */
	private var _twoSidedLighting:Bool = false;

	/**
	 * Defines the alpha limits in alpha test mode.
	 */
	private var _alphaCutOff:Float = 0.4;

	/**
	 * Enforces alpha test in opaque or blend mode in order to improve the performances of some situations.
	 */
	private var _forceAlphaTest:Bool = false;

	/**
	 * Specifies that the alpha is premultiplied before output (this enables alpha premultiplied blending).
	 * in your scene composition.
	 */
	private var _preMultiplyAlpha:Bool = false;

	/**
	 * A fresnel is applied to the alpha of the model to ensure grazing angles edges are not alpha tested.
	 * And/Or occlude the blended part. (alpha is converted to gamma to compute the fresnel)
	 */
	private var _useAlphaFresnel:Bool = false;
	
	/**
     * A fresnel is applied to the alpha of the model to ensure grazing angles edges are not alpha tested.
     * And/Or occlude the blended part. (alpha stays linear to compute the fresnel)
     */
    private var _useLinearAlphaFresnel:Bool = false;
	
	/**
	 * The transparency mode of the material.
	 */
	private var _transparencyMode:Int = -1;

	/**
	 * Specifies the environment BRDF texture used to comput the scale and offset roughness values
	 * from cos thetav and roughness: 
	 * http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
	 */
	private var _environmentBRDFTexture:BaseTexture = null;

	/**
	 * Force the shader to compute irradiance in the fragment shader in order to take bump in account.
	 */
	private var _forceIrradianceInFragment:Bool = false;

	/**
	 * Force normal to face away from face.
	 * (Temporary internal fix to remove before 3.1)
	 */
	private var _forceNormalForward:Bool = false;
	
	/**
	 * Force metallic workflow.
     */
	private var _forceMetallicWorkflow:Bool = false;

	/**
	 * Default configuration related to image processing available in the PBR Material.
	 */
	@serializeAsImageProcessingConfiguration()
	private var _imageProcessingConfiguration:ImageProcessingConfiguration;

	/**
	 * Keep track of the image processing observer to allow dispose and replace.
	 */
	private var _imageProcessingObserver:Observer<ImageProcessingConfiguration>;

	/**
	 * Attaches a new image processing configuration to the PBR Material.
	 * @param configuration 
	 */
	private function _attachImageProcessingConfiguration(configuration:ImageProcessingConfiguration) {
		// BHX: need to check if configuration is null !!
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

	private var _renderTargets:SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(16);
	private var _globalAmbientColor:Color3 = new Color3(0, 0, 0);
	private var _useLogarithmicDepth:Bool;
	

	/**
	 * Instantiates a new PBRMaterial instance.
	 * 
	 * @param name The material name
	 * @param scene The scene the material will be use in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		// BHX - must be in constructor
		_lightingInfos = new Vector4(this._directIntensity, this._emissiveIntensity, this._environmentIntensity, this._specularIntensity);
		
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
		
		this._environmentBRDFTexture = TextureTools.GetEnvironmentBRDFTexture(scene);
	}

	override public function getClassName():String {
		return "PBRBaseMaterial";
	}  

	@serialize()
	public var useLogarithmicDepth(get, set):Bool;
	inline private function get_useLogarithmicDepth():Bool {
		return this._useLogarithmicDepth;
	}
	private function set_useLogarithmicDepth(value:Bool):Bool {
		this._useLogarithmicDepth = value && this.getScene().getEngine().getCaps().fragmentDepthSupported;
		return value;
	}
	
	/**
	 * Gets the current transparency mode.
	 */
	@serialize()
	public var transparencyMode(get, set):Int;
	inline private function get_transparencyMode():Int {
		return this._transparencyMode;
	}
	/**
	 * Sets the transparency mode of the material.
	 */
	private function set_transparencyMode(value:Int):Int {
		if (this._transparencyMode == value) {
			return value;
		}
		
		this._transparencyMode = value;
		
		this._forceAlphaTest = (value == PBRMaterial.PBRMATERIAL_ALPHATESTANDBLEND);
		
		this._markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Returns true if alpha blending should be disabled.
	 */
	public var _disableAlphaBlending(get, never):Bool;	
	inline private function get__disableAlphaBlending():Bool {
		return (this._linkRefractionWithTransparency ||
			this._transparencyMode == PBRMaterial.PBRMATERIAL_OPAQUE ||
			this._transparencyMode == PBRMaterial.PBRMATERIAL_ALPHATEST);
	}

	override public function needAlphaBlending():Bool {
		if (this._linkRefractionWithTransparency) {
			return false;
		}
		return (this.alpha < 1.0) || (this._opacityTexture != null) || this._shouldUseAlphaFromAlbedoTexture();
	}
	
	/**
	 * Specifies whether or not this material should be rendered in alpha blend mode for the given mesh.
	 */
	override public function needAlphaBlendingForMesh(mesh:AbstractMesh):Bool {
		if (this._disableAlphaBlending) {
			return false;
		}
		
		return super.needAlphaBlendingForMesh(mesh);
	}

	override public function needAlphaTesting():Bool {
		if (this._forceAlphaTest) {
			return true;
		}
		
		if (this._linkRefractionWithTransparency) {
			return false;
		}
		return this._albedoTexture != null && this._albedoTexture.hasAlpha && (this._transparencyMode == -1 || this._transparencyMode == PBRMaterial.PBRMATERIAL_ALPHATEST);
	}

	private function _shouldUseAlphaFromAlbedoTexture():Bool {
		return this._albedoTexture != null && this._albedoTexture.hasAlpha && this._useAlphaFromAlbedoTexture && this._transparencyMode != PBRMaterial.PBRMATERIAL_OPAQUE;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return this._albedoTexture;
	}

	private static var _scaledReflectivity:Color3 = new Color3();

	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool { 
		if (subMesh.effect != null && this.isFrozen) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new PBRMaterialDefines();
		}
		
		var scene = this.getScene();
		var defines:PBRMaterialDefines = cast subMesh._materialDefines;
		if (!this.checkReadyOnEveryCall && subMesh.effect != null) {
			if (defines._renderId == scene.getRenderId()) {
				return true;
			}
		}
		
		var engine = scene.getEngine();
		
		// Lights
		MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, true, this._maxSimultaneousLights, this._disableLighting);
		defines._needNormals = true;
		
		// Textures
		if (defines._areTexturesDirty) {
			defines._needUVs = false;
			if (scene.texturesEnabled) {
				if (scene.getEngine().getCaps().textureLOD) {
					defines.LODBASEDMICROSFURACE = true;
				}
				
				if (this._albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					if (!this._albedoTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					MaterialHelper.PrepareDefinesForMergedUV(this._albedoTexture, defines, "ALBEDO");
				} 
				else {
					defines.ALBEDO = false;
				}
				
				if (this._ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
					if (!this._ambientTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					MaterialHelper.PrepareDefinesForMergedUV(this._ambientTexture, defines, "AMBIENT"); 
					defines.AMBIENTINGRAYSCALE = this._useAmbientInGrayScale;
				} 
				else {
					defines.AMBIENT = false;
				}
				
				if (this._opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
					if (!this._opacityTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					MaterialHelper.PrepareDefinesForMergedUV(this._opacityTexture, defines, "OPACITY"); 
					defines.OPACITYRGB = this._opacityTexture.getAlphaFromRGB;
				} 
				else {
					defines.OPACITY = false;
				}
				
				var reflectionTexture = this._getReflectionTexture();
				if (reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					if (!reflectionTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					defines.REFLECTION = true;
					defines.GAMMAREFLECTION = reflectionTexture.gammaSpace;
					defines.REFLECTIONMAP_OPPOSITEZ = this.getScene().useRightHandedSystem ? !reflectionTexture.invertZ : reflectionTexture.invertZ;
					defines.LODINREFLECTIONALPHA = reflectionTexture.lodLevelInAlpha;
					
					if (reflectionTexture.coordinatesMode == Texture.INVCUBIC_MODE) {
						defines.INVERTCUBICMAP = true;
					}
					
					defines.REFLECTIONMAP_3D = reflectionTexture.isCube;
					
					switch (reflectionTexture.coordinatesMode) {
						case Texture.CUBIC_MODE, Texture.INVCUBIC_MODE:
							defines.REFLECTIONMAP_CUBIC = true;
							
						case Texture.EXPLICIT_MODE:
							defines.REFLECTIONMAP_EXPLICIT = true;
							
						case Texture.PLANAR_MODE:
							defines.REFLECTIONMAP_PLANAR = true;
							
						case Texture.PROJECTION_MODE:
							defines.REFLECTIONMAP_PROJECTION = true;
							
						case Texture.SKYBOX_MODE:
							defines.REFLECTIONMAP_SKYBOX = true;
							
						case Texture.SPHERICAL_MODE:
							defines.REFLECTIONMAP_SPHERICAL = true;
							
						case Texture.EQUIRECTANGULAR_MODE:
							defines.REFLECTIONMAP_EQUIRECTANGULAR = true;
							
						case Texture.FIXED_EQUIRECTANGULAR_MODE:
							defines.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = true;
							
						case Texture.FIXED_EQUIRECTANGULAR_MIRRORED_MODE:
							defines.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = true;
							
					}
					
					if (reflectionTexture.coordinatesMode != Texture.SKYBOX_MODE) {
						if (reflectionTexture.sphericalPolynomial != null) {
							defines.USESPHERICALFROMREFLECTIONMAP = true;
							if (this._forceIrradianceInFragment || scene.getEngine().getCaps().maxVaryingVectors <= 8) {
								defines.USESPHERICALINVERTEX = true;
							}
							else {
								defines.USESPHERICALINVERTEX = true;
							}
						}
					}
				} 
				else {
					defines.REFLECTION = false;
					defines.REFLECTIONMAP_3D = false;
					defines.REFLECTIONMAP_SPHERICAL = false;
					defines.REFLECTIONMAP_PLANAR = false;
					defines.REFLECTIONMAP_CUBIC = false;
					defines.REFLECTIONMAP_PROJECTION = false;
					defines.REFLECTIONMAP_SKYBOX = false;
					defines.REFLECTIONMAP_EXPLICIT = false;
					defines.REFLECTIONMAP_EQUIRECTANGULAR = false;
					defines.REFLECTIONMAP_EQUIRECTANGULAR_FIXED = false;
					defines.REFLECTIONMAP_MIRROREDEQUIRECTANGULAR_FIXED = false;
					defines.INVERTCUBICMAP = false;
					defines.USESPHERICALFROMREFLECTIONMAP = false;
					defines.USESPHERICALINVERTEX = false;
					defines.REFLECTIONMAP_OPPOSITEZ = false;
					defines.LODINREFLECTIONALPHA = false;
					defines.GAMMAREFLECTION = false;
				}
				
				if (this._lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
					if (!this._lightmapTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					MaterialHelper.PrepareDefinesForMergedUV(this._lightmapTexture, defines, "LIGHTMAP"); 
					defines.USELIGHTMAPASSHADOWMAP = this._useLightmapAsShadowmap;
				} 
				else {
					defines.LIGHTMAP = false;
				}
				
				if (this._emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
					if (!this._emissiveTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					MaterialHelper.PrepareDefinesForMergedUV(this._emissiveTexture, defines, "EMISSIVE");
				} 
				else {
					defines.EMISSIVE = false;
				}
				
				if (StandardMaterial.SpecularTextureEnabled) {
					if (this._metallicTexture != null) {
						if (!this._metallicTexture.isReadyOrNotBlocking()) {
							return false;
						}
						
						MaterialHelper.PrepareDefinesForMergedUV(this._metallicTexture, defines, "REFLECTIVITY");
						defines.METALLICWORKFLOW = true;
						defines.ROUGHNESSSTOREINMETALMAPALPHA = this._useRoughnessFromMetallicTextureAlpha;
						defines.ROUGHNESSSTOREINMETALMAPGREEN = !this._useRoughnessFromMetallicTextureAlpha && this._useRoughnessFromMetallicTextureGreen;
						defines.METALLNESSSTOREINMETALMAPBLUE = this._useMetallnessFromMetallicTextureBlue;
						defines.AOSTOREINMETALMAPRED = this._useAmbientOcclusionFromMetallicTextureRed;
					}
					else if (this._reflectivityTexture != null) {
						if (!this._reflectivityTexture.isReadyOrNotBlocking()) {
							return false;
						}
						
						defines.METALLICWORKFLOW = false;
						MaterialHelper.PrepareDefinesForMergedUV(this._reflectivityTexture, defines, "REFLECTIVITY");
						defines.MICROSURFACEFROMREFLECTIVITYMAP = this._useMicroSurfaceFromReflectivityMapAlpha;
						defines.MICROSURFACEAUTOMATIC = this._useAutoMicroSurfaceFromReflectivityMap;
					} 
					else {
						defines.METALLICWORKFLOW = false;
						defines.REFLECTIVITY = false;
					}
					
					if (this._microSurfaceTexture != null) {
						if (!this._microSurfaceTexture.isReadyOrNotBlocking()) {
							return false;
						}
						
						MaterialHelper.PrepareDefinesForMergedUV(this._microSurfaceTexture, defines, "MICROSURFACEMAP");
					} 
					else {
						defines.MICROSURFACEMAP = false;
					}
				} 
				else {
					defines.REFLECTIVITY = false;
					defines.MICROSURFACEMAP = false;
				}
				
				if (scene.getEngine().getCaps().standardDerivatives && this._bumpTexture != null && StandardMaterial.BumpTextureEnabled && !this._disableBumpMap) {
					// Bump texure can not be none blocking.
					if (!this._bumpTexture.isReady()) {
						return false;
					}
					
					MaterialHelper.PrepareDefinesForMergedUV(this._bumpTexture, defines, "BUMP");
					
					if (this._useParallax && this._albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
						defines.PARALLAX = true;
						defines.PARALLAXOCCLUSION = !!this._useParallaxOcclusion;
					}
					else {
						defines.PARALLAX = false;
					}
				} 
				else {
					defines.BUMP = false;
				}
				
				var refractionTexture = this._getRefractionTexture();
				if (refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
					if (!refractionTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					defines.REFRACTION = true;
					defines.REFRACTIONMAP_3D = refractionTexture.isCube;
					defines.GAMMAREFRACTION = refractionTexture.gammaSpace;
					defines.REFRACTIONMAP_OPPOSITEZ = refractionTexture.invertZ;
					defines.LODINREFRACTIONALPHA = refractionTexture.lodLevelInAlpha;
					
					if (this._linkRefractionWithTransparency) {
						defines.LINKREFRACTIONTOTRANSPARENCY = true;
					}
				} 
				else {
					defines.REFRACTION = false;
				}
				
				if (this._environmentBRDFTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					// This is blocking.
					if (!this._environmentBRDFTexture.isReady()) {
						return false;
					}
					defines.ENVIRONMENTBRDF = true;
				}
				else {
					defines.ENVIRONMENTBRDF = false;
				}
				
				if (this._shouldUseAlphaFromAlbedoTexture()) {
					defines.ALPHAFROMALBEDO = true;
				}
				else {
					defines.ALPHAFROMALBEDO = false;
				}
			}
			
			defines.SPECULAROVERALPHA = this._useSpecularOverAlpha;
			
			defines.USEPHYSICALLIGHTFALLOFF = this._usePhysicalLightFalloff;
			
			defines.RADIANCEOVERALPHA = this._useRadianceOverAlpha;
			
			if (this._forceMetallicWorkflow || (this._metallic != Math.NEGATIVE_INFINITY) || (this._roughness != Math.NEGATIVE_INFINITY)) {
				defines.METALLICWORKFLOW = true;
			}
			else {
				defines.METALLICWORKFLOW = false;
			}
			
			if (!this.backFaceCulling && this._twoSidedLighting) {
				defines.TWOSIDEDLIGHTING = true;
			}
			else {
				defines.TWOSIDEDLIGHTING = false;
			}
			
			defines.ALPHATESTVALUE = this._alphaCutOff;
			defines.PREMULTIPLYALPHA = (this.alphaMode == Engine.ALPHA_PREMULTIPLIED || this.alphaMode == Engine.ALPHA_PREMULTIPLIED_PORTERDUFF);
			defines.ALPHABLEND = this.needAlphaBlending();
			defines.ALPHAFRESNEL = this._useAlphaFresnel || this._useLinearAlphaFresnel;
			defines.LINEARALPHAFRESNEL = this._useLinearAlphaFresnel;
		}
		
		if (defines._areImageProcessingDirty) {
			if (!this._imageProcessingConfiguration.isReady()) {
				return false;
			}
			
			this._imageProcessingConfiguration.prepareDefines(defines);
		}
		
		defines.FORCENORMALFORWARD = this._forceNormalForward;
		
		defines.RADIANCEOCCLUSION = this._useRadianceOcclusion;
		
		defines.HORIZONOCCLUSION = this._useHorizonOcclusion;
		
		// Misc.
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, this._useLogarithmicDepth, this.pointsCloud, this.fogEnabled, defines);
		
		// Values that need to be evaluated on every frame
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances, this._forceAlphaTest);
		
		// Attribs
		if (MaterialHelper.PrepareDefinesForAttributes(mesh, defines, true, true, true)) {
			if (mesh != null) {
				if (!scene.getEngine().getCaps().standardDerivatives && !mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
					mesh.createNormals(true);
					Tools.Warn("PBRMaterial: Normals have been created for the mesh: " + mesh.name);
				}
			}
		}
		
		// Get correct effect
		if (defines.isDirty) {
			defines.markAsProcessed();
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();
			var fallbackRank:Int = 0;
			if (defines.USESPHERICALINVERTEX) {
				fallbacks.addFallback(fallbackRank++, "USESPHERICALINVERTEX");
			}
			
			if (defines.FOG) {
				fallbacks.addFallback(fallbackRank, "FOG");
			}
			if (defines.POINTSIZE) {
				fallbacks.addFallback(fallbackRank, "POINTSIZE");
			}
			if (defines.LOGARITHMICDEPTH) {
				fallbacks.addFallback(fallbackRank, "LOGARITHMICDEPTH");
			}
			if (defines.PARALLAX) {
				fallbacks.addFallback(fallbackRank, "PARALLAX");
			}
			if (defines.PARALLAXOCCLUSION) {
				fallbacks.addFallback(fallbackRank++, "PARALLAXOCCLUSION");
			}
			
			if (defines.ENVIRONMENTBRDF) {
				fallbacks.addFallback(fallbackRank++, "ENVIRONMENTBRDF");
			}
			
			if (defines.TANGENT) {
				fallbacks.addFallback(fallbackRank++, "TANGENT");
			}
			
			if (defines.BUMP) {
				fallbacks.addFallback(fallbackRank++, "BUMP");
			}
			
			fallbackRank = MaterialHelper.HandleFallbacksForShadows(defines, fallbacks, this._maxSimultaneousLights, fallbackRank++);
			
			if (defines.SPECULARTERM) {
				fallbacks.addFallback(fallbackRank++, "SPECULARTERM");
			}
			
			if (defines.USESPHERICALFROMREFLECTIONMAP) {
				fallbacks.addFallback(fallbackRank++, "USESPHERICALFROMREFLECTIONMAP");
			}
			
			if (defines.LIGHTMAP) {
				fallbacks.addFallback(fallbackRank++, "LIGHTMAP");
			}
			
			if (defines.NORMAL) {
				fallbacks.addFallback(fallbackRank++, "NORMAL");
			}
			
			if (defines.AMBIENT) {
				fallbacks.addFallback(fallbackRank++, "AMBIENT");
			}
			
			if (defines.EMISSIVE) {
				fallbacks.addFallback(fallbackRank++, "EMISSIVE");
			}
			
			if (defines.VERTEXCOLOR) {
				fallbacks.addFallback(fallbackRank++, "VERTEXCOLOR");
			}
			
			if (defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(fallbackRank++, mesh);
			}
			
			if (defines.MORPHTARGETS) {
				fallbacks.addFallback(fallbackRank++, "MORPHTARGETS");
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (defines.NORMAL) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (defines.TANGENT) {
				attribs.push(VertexBuffer.TangentKind);
			}
			
			if (defines.UV1) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (defines.UV2) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (defines.VERTEXCOLOR) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, defines.NUM_BONE_INFLUENCERS, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, defines);
			MaterialHelper.PrepareAttributesForMorphTargets(attribs, mesh, defines);
			
			var uniforms = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vAmbientColor", "vAlbedoColor", "vReflectivityColor", "vEmissiveColor", "vReflectionColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vAlbedoInfos", "vAmbientInfos", "vOpacityInfos", "vReflectionInfos", "vEmissiveInfos", "vReflectivityInfos", "vMicroSurfaceSamplerInfos", "vBumpInfos", "vLightmapInfos", "vRefractionInfos",
				"mBones",
				"vClipPlane", "albedoMatrix", "ambientMatrix", "opacityMatrix", "reflectionMatrix", "emissiveMatrix", "reflectivityMatrix", "microSurfaceSamplerMatrix", "bumpMatrix", "lightmapMatrix", "refractionMatrix",
				"vLightingIntensity",
				"logarithmicDepthConstant",
				"vSphericalX", "vSphericalY", "vSphericalZ",
				"vSphericalXX", "vSphericalYY", "vSphericalZZ",
				"vSphericalXY", "vSphericalYZ", "vSphericalZX",
				"vReflectionMicrosurfaceInfos", "vRefractionMicrosurfaceInfos",
				"vTangentSpaceParams"
			];
			
			var samplers = ["albedoSampler", "reflectivitySampler", "ambientSampler", "emissiveSampler", 
				"bumpSampler", "lightmapSampler", "opacitySampler",
				"refractionSampler", "refractionSamplerLow", "refractionSamplerHigh",
				"reflectionSampler", "reflectionSamplerLow", "reflectionSamplerHigh",
				"microSurfaceSampler", "environmentBrdfSampler"];
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
			
			var _onCompiled = function(effect:Effect) {
				if (this.onCompiled != null) {
					this.onCompiled(effect);
				}
				
				this.bindSceneUniformBuffer(effect, scene.getSceneUniformBuffer());
			};
			
			var join = defines.toString();
			subMesh.setEffect(scene.getEngine().createEffect("pbr", {
				attributes: attribs,
				uniformsNames: uniforms,
				uniformBuffersNames: uniformBuffers,
				samplers: samplers,
				defines: join,
				fallbacks: fallbacks,
				onCompiled: _onCompiled,
				onError: this.onError,
				indexParameters: { maxSimultaneousLights: this._maxSimultaneousLights, maxSimultaneousMorphTargets: defines.NUM_MORPH_INFLUENCERS }
			}, engine), defines);
			
			this.buildUniformLayout();
		}
		
		if (subMesh.effect == null || !subMesh.effect.isReady()) {
			return false;
		}
		
		defines._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		return true;
	}

	public function buildUniformLayout() {
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
		this._uniformBuffer.addUniform("vTangentSpaceParams", 2);
		this._uniformBuffer.addUniform("refractionMatrix", 16);
		this._uniformBuffer.addUniform("reflectionMatrix", 16);

		this._uniformBuffer.addUniform("vReflectionColor", 3);
		this._uniformBuffer.addUniform("vAlbedoColor", 4);
		this._uniformBuffer.addUniform("vLightingIntensity", 4);

		this._uniformBuffer.addUniform("vRefractionMicrosurfaceInfos", 3);
		this._uniformBuffer.addUniform("vReflectionMicrosurfaceInfos", 3);
		this._uniformBuffer.addUniform("vReflectivityColor", 4);
		this._uniformBuffer.addUniform("vEmissiveColor", 3);

		this._uniformBuffer.addUniform("pointSize", 1);
		this._uniformBuffer.create();
	}

	override public function unbind() {
		if (this._reflectionTexture != null && this._reflectionTexture.isRenderTarget) {
			this._uniformBuffer.setTexture("reflectionSampler", null);
		}
		
		if (this._refractionTexture != null && this._refractionTexture.isRenderTarget) {
			this._uniformBuffer.setTexture("refractionSampler", null);
		}
		
		super.unbind();
	}

	override public function bindOnlyWorldMatrix(world:Matrix) {
		this._activeEffect.setMatrix("world", world);
	}

	override public function bindForSubMesh(world:Matrix, mesh:Mesh, subMesh:SubMesh) {
		var scene = this.getScene();
		
		var defines:PBRMaterialDefines = cast subMesh._materialDefines;
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
		
		var mustRebind = this._mustRebind(scene, effect, mesh.visibility);
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._activeEffect);
		
		// BHX...
		var reflectionTexture:BaseTexture = null;
		var refractionTexture:BaseTexture = null;
		
		if (mustRebind) {
			this._uniformBuffer.bindToEffect(effect, "Material");
			
			this.bindViewProjection(effect);			
			reflectionTexture = this._getReflectionTexture();
            refractionTexture = this._getRefractionTexture();
			
			if (!this._uniformBuffer.useUbo || !this.isFrozen || !this._uniformBuffer.isSync) {
				
				// Texture uniforms
				if (scene.texturesEnabled) {
					if (this._albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
						this._uniformBuffer.updateFloat2("vAlbedoInfos", this._albedoTexture.coordinatesIndex, this._albedoTexture.level);
						MaterialHelper.BindTextureMatrix(this._albedoTexture, this._uniformBuffer, "albedo");
					}
					
					if (this._ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
						this._uniformBuffer.updateFloat3("vAmbientInfos", this._ambientTexture.coordinatesIndex, this._ambientTexture.level, this._ambientTextureStrength);
						MaterialHelper.BindTextureMatrix(this._ambientTexture, this._uniformBuffer, "ambient");
					}
					
					if (this._opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
						this._uniformBuffer.updateFloat2("vOpacityInfos", this._opacityTexture.coordinatesIndex, this._opacityTexture.level);
						MaterialHelper.BindTextureMatrix(this._opacityTexture, this._uniformBuffer, "opacity");
					}
					
					if (reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
						this._uniformBuffer.updateMatrix("reflectionMatrix", reflectionTexture.getReflectionTextureMatrix());
						this._uniformBuffer.updateFloat2("vReflectionInfos", reflectionTexture.level, 0);
						
						var polynomials = reflectionTexture.sphericalPolynomial;
						if (defines.USESPHERICALFROMREFLECTIONMAP && polynomials != null) {							
							this._activeEffect.setFloat3("vSphericalX", polynomials.x.x, polynomials.x.y, polynomials.x.z);
							this._activeEffect.setFloat3("vSphericalY", polynomials.y.x, polynomials.y.y, polynomials.y.z);
							this._activeEffect.setFloat3("vSphericalZ", polynomials.z.x, polynomials.z.y, polynomials.z.z);
							this._activeEffect.setFloat3("vSphericalXX_ZZ", polynomials.xx.x - polynomials.zz.x,
								polynomials.xx.y - polynomials.zz.y,
								polynomials.xx.z - polynomials.zz.z);
							this._activeEffect.setFloat3("vSphericalYY_ZZ", polynomials.yy.x - polynomials.zz.x,
								polynomials.yy.y - polynomials.zz.y,
								polynomials.yy.z - polynomials.zz.z);
							this._activeEffect.setFloat3("vSphericalZZ", polynomials.zz.x, polynomials.zz.y, polynomials.zz.z);
							this._activeEffect.setFloat3("vSphericalXY", polynomials.xy.x, polynomials.xy.y, polynomials.xy.z);
							this._activeEffect.setFloat3("vSphericalYZ", polynomials.yz.x, polynomials.yz.y, polynomials.yz.z);
							this._activeEffect.setFloat3("vSphericalZX", polynomials.zx.x, polynomials.zx.y, polynomials.zx.z);
						}
						
						this._uniformBuffer.updateFloat3("vReflectionMicrosurfaceInfos", 
							reflectionTexture.getSize().width, 
							reflectionTexture.lodGenerationScale,
							reflectionTexture.lodGenerationOffset);
					}
					
					if (this._emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
						this._uniformBuffer.updateFloat2("vEmissiveInfos", this._emissiveTexture.coordinatesIndex, this._emissiveTexture.level);
						MaterialHelper.BindTextureMatrix(this._emissiveTexture, this._uniformBuffer, "emissive");
					}
					
					if (this._lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
						this._uniformBuffer.updateFloat2("vLightmapInfos", this._lightmapTexture.coordinatesIndex, this._lightmapTexture.level);
						MaterialHelper.BindTextureMatrix(this._lightmapTexture, this._uniformBuffer, "lightmap");
					}
					
					if (StandardMaterial.SpecularTextureEnabled) {
						if (this._metallicTexture != null) {
							this._uniformBuffer.updateFloat3("vReflectivityInfos", this._metallicTexture.coordinatesIndex, this._metallicTexture.level, this._ambientTextureStrength);
							MaterialHelper.BindTextureMatrix(this._metallicTexture, this._uniformBuffer, "reflectivity");
						}
						else if (this._reflectivityTexture != null) {
							this._uniformBuffer.updateFloat3("vReflectivityInfos", this._reflectivityTexture.coordinatesIndex, this._reflectivityTexture.level, 1.0);
							MaterialHelper.BindTextureMatrix(this._reflectivityTexture, this._uniformBuffer, "reflectivity");
						}
						
						if (this._microSurfaceTexture != null) {
							this._uniformBuffer.updateFloat2("vMicroSurfaceSamplerInfos", this._microSurfaceTexture.coordinatesIndex, this._microSurfaceTexture.level);
							MaterialHelper.BindTextureMatrix(this._microSurfaceTexture, this._uniformBuffer, "microSurfaceSampler");
						}
					}
					
					if (this._bumpTexture != null && scene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled && !this._disableBumpMap) {
						this._uniformBuffer.updateFloat3("vBumpInfos", this._bumpTexture.coordinatesIndex, this._bumpTexture.level, this._parallaxScaleBias);
						MaterialHelper.BindTextureMatrix(this._bumpTexture, this._uniformBuffer, "bump");
						
						if (scene._mirroredCameraPosition != null) {
							this._uniformBuffer.updateFloat2("vTangentSpaceParams", this._invertNormalMapX ? 1.0 : -1.0, this._invertNormalMapY ? 1.0 : -1.0);
						} 
						else {
							this._uniformBuffer.updateFloat2("vTangentSpaceParams", this._invertNormalMapX ? -1.0 : 1.0, this._invertNormalMapY ? -1.0 : 1.0);
						}                                                         
					}
					
					if (refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
						this._uniformBuffer.updateMatrix("refractionMatrix", refractionTexture.getReflectionTextureMatrix());
						
						var depth = 1.0;
						if (!refractionTexture.isCube) {
							if (Std.is(refractionTexture, RefractionTexture)) {
								depth = untyped refractionTexture.depth;
							}
						}
						this._uniformBuffer.updateFloat4("vRefractionInfos", refractionTexture.level, this._indexOfRefraction, depth, this._invertRefractionY ? -1 : 1);
						this._uniformBuffer.updateFloat3("vRefractionMicrosurfaceInfos", 
							refractionTexture.getSize().width, 
							refractionTexture.lodGenerationScale,
							refractionTexture.lodGenerationOffset);
					}
				}
				
				// Point size
				if (this.pointsCloud) {
					this._uniformBuffer.updateFloat("pointSize", this.pointSize);
				}
				
				// Colors
				if (defines.METALLICWORKFLOW) {
					PBRBaseMaterial._scaledReflectivity.r = (this._metallic == Math.NEGATIVE_INFINITY) ? 1 : this._metallic;
					PBRBaseMaterial._scaledReflectivity.g = (this._roughness == Math.NEGATIVE_INFINITY) ? 1 : this._roughness;
					this._uniformBuffer.updateColor4("vReflectivityColor", PBRBaseMaterial._scaledReflectivity, 0);
				}
				else {
					this._uniformBuffer.updateColor4("vReflectivityColor", this._reflectivityColor, this._microSurface);
				}
				
				this._uniformBuffer.updateColor3("vEmissiveColor", this._emissiveColor);
				this._uniformBuffer.updateColor3("vReflectionColor", this._reflectionColor);
				this._uniformBuffer.updateColor4("vAlbedoColor", this._albedoColor, this.alpha * mesh.visibility);
				
				// Misc
				this._lightingInfos.x = this._directIntensity;
				this._lightingInfos.y = this._emissiveIntensity;
				this._lightingInfos.z = this._environmentIntensity;
				this._lightingInfos.w = this._specularIntensity;
				
				this._uniformBuffer.updateVector4("vLightingIntensity", this._lightingInfos);
			}
			
			// Textures
			if (scene.texturesEnabled) {
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
					if (defines.LODBASEDMICROSFURACE) {
						this._uniformBuffer.setTexture("reflectionSampler", reflectionTexture);
					}
					else {
						this._uniformBuffer.setTexture("reflectionSampler", reflectionTexture._lodTextureMid != null ? reflectionTexture._lodTextureMid : reflectionTexture);
						this._uniformBuffer.setTexture("reflectionSamplerLow", reflectionTexture._lodTextureLow != null ? reflectionTexture._lodTextureLow : reflectionTexture);
						this._uniformBuffer.setTexture("reflectionSamplerHigh", reflectionTexture._lodTextureHigh != null ? reflectionTexture._lodTextureHigh : reflectionTexture);
					}
				}
				
				if (defines.ENVIRONMENTBRDF) {
					this._uniformBuffer.setTexture("environmentBrdfSampler", this._environmentBRDFTexture);
				}
				
				if (refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
					if (defines.LODBASEDMICROSFURACE) {
						this._uniformBuffer.setTexture("refractionSampler", refractionTexture);
					}
					else {
						this._uniformBuffer.setTexture("refractionSampler", refractionTexture._lodTextureMid != null ? refractionTexture._lodTextureMid : refractionTexture);
						this._uniformBuffer.setTexture("refractionSamplerLow", refractionTexture._lodTextureLow != null ? refractionTexture._lodTextureLow : refractionTexture);
						this._uniformBuffer.setTexture("refractionSamplerHigh", refractionTexture._lodTextureHigh != null ? refractionTexture._lodTextureHigh : refractionTexture);
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
				
				if (this._bumpTexture != null && scene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled && !this._disableBumpMap) {
					this._uniformBuffer.setTexture("bumpSampler", this._bumpTexture);
				}
			}
			
			// Clip plane
			MaterialHelper.BindClipPlane(this._activeEffect, scene);
			
			// Colors
			scene.ambientColor.multiplyToRef(this._ambientColor, this._globalAmbientColor);
			
			var eyePosition = scene._mirroredCameraPosition != null ? scene._mirroredCameraPosition : scene.activeCamera.globalPosition;
			var invertNormal = (scene.useRightHandedSystem == (scene._mirroredCameraPosition != null));
            effect.setFloat4("vEyePosition",
				eyePosition.x,
				eyePosition.y,
				eyePosition.z,
				invertNormal ? -1 : 1);
			effect.setColor3("vAmbientColor", this._globalAmbientColor);
		}
		
		if (mustRebind || !this.isFrozen) {
			// Lights
			if (scene.lightsEnabled && !this._disableLighting) {
				MaterialHelper.BindLights(scene, mesh, this._activeEffect, defines.SPECULARTERM, this._maxSimultaneousLights, this._usePhysicalLightFalloff);
			}
			
			// View
			if (scene.fogEnabled && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE || reflectionTexture != null) {
				this.bindView(effect);
			}
			
			// Fog
			MaterialHelper.BindFogParameters(scene, mesh, this._activeEffect);
			
			// Morph targets
			if (defines.NUM_MORPH_INFLUENCERS > 0) {
				MaterialHelper.BindMorphTargetParameters(mesh, this._activeEffect);
			}
			
			// image processing
			this._imageProcessingConfiguration.bind(this._activeEffect);
			
			// Log. depth
			MaterialHelper.BindLogDepth(defines.LOGARITHMICDEPTH, this._activeEffect, scene);
		}
		
		this._uniformBuffer.update();
		
		this._afterBind(mesh);
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
		
		return results;
	}

	private function _getReflectionTexture():BaseTexture {
		if (this._reflectionTexture != null) {
			return this._reflectionTexture;
		}
		
		return this.getScene().environmentTexture;
	}

	private function _getRefractionTexture():BaseTexture {
		if (this._refractionTexture != null) {
			return this._refractionTexture;
		}
		
		if (this._linkRefractionWithTransparency) {
			return this.getScene().environmentTexture;
		}
		
		return null;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
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
			
			if (this._environmentBRDFTexture != null) {
				this._environmentBRDFTexture.dispose();
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
		}
		
		this._renderTargets.dispose();
		
		if (this._imageProcessingConfiguration != null && this._imageProcessingObserver != null) {
			this._imageProcessingConfiguration.onUpdateParameters.remove(this._imageProcessingObserver);
		}
		
		super.dispose(forceDisposeEffect, forceDisposeTextures);
	}
	
}
