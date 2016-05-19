package com.babylonhx.materials;

import com.babylonhx.Engine;
import com.babylonhx.lights.shadows.ShadowGenerator;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.lights.Light;
import com.babylonhx.materials.EffectFallbacks;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.HDRCubeTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.textures.RefractionTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.SphericalPolynomial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.lights.SpotLight;
import com.babylonhx.lights.DirectionalLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.Tags;
import com.babylonhx.tools.serialization.SerializationHelper;
import com.babylonhx.animations.IAnimatable;
import com.babylonhx.math.Tools in MathTools;


/**
 * ...
 * @author Krtolica Vujadin
 */
 
class PBRMaterial extends Material {
	
	/**
	 * Intensity of the direct lights e.g. the four lights available in your scene.
	 * This impacts both the direct diffuse and specular highlights.
	 */
	@serialize()
	public var directIntensity:Float = 1.0;
	
	/**
	 * Intensity of the emissive part of the material.
	 * This helps controlling the emissive effect without modifying the emissive color.
	 */
	@serialize()
	public var emissiveIntensity:Float = 1.0;
	
	/**
	 * Intensity of the environment e.g. how much the environment will light the object
	 * either through harmonics for rough material or through the refelction for shiny ones.
	 */
	@serialize()
	public var environmentIntensity:Float = 1.0;
	
	/**
	 * This is a special control allowing the reduction of the specular highlights coming from the 
	 * four lights of the scene. Those highlights may not be needed in full environment lighting.
	 */
	@serialize()
	public var specularIntensity:Float = 1.0;

	private var _lightingInfos:Vector4;
	
	/**
	 * Debug Control allowing disabling the bump map on this material.
	 */
	@serialize()
	public var disableBumpMap:Bool = false;

	/**
	 * Debug Control helping enforcing or dropping the darkness of shadows.
	 * 1.0 means the shadows have their normal darkness, 0.0 means the shadows are not visible.
	 */
	@serialize()
	public var overloadedShadowIntensity:Float = 1.0;
	
	/**
	 * Debug Control helping dropping the shading effect coming from the diffuse lighting.
	 * 1.0 means the shade have their normal impact, 0.0 means no shading at all.
	 */
	@serialize()
	public var overloadedShadeIntensity:Float = 1.0;

	private var _overloadedShadowInfos:Vector4;

	/**
	 * The camera exposure used on this material.
	 * This property is here and not in the camera to allow controlling exposure without full screen post process.
	 * This corresponds to a photographic exposure.
	 */
	@serialize()
	public var cameraExposure:Float = 1.0;
	
	/**
	 * The camera contrast used on this material.
	 * This property is here and not in the camera to allow controlling contrast without full screen post process.
	 */
	@serialize()
	public var cameraContrast:Float = 1.0;
	
	/**
	 * Color Grading 2D Lookup Texture.
	 * This allows special effects like sepia, black and white to sixties rendering style. 
	 */
	@serializeAsTexture()
	public var cameraColorGradingTexture:BaseTexture = null;

	private var _cameraColorGradingScaleOffset:Vector4 = new Vector4(1.0, 1.0, 0.0, 0.0);
	private var _cameraColorGradingInfos:Vector4 = new Vector4(1.0, 1.0, 0.0, 0.0);
	
	private var _cameraInfos:Vector4 = new Vector4(1.0, 1.0, 0.0, 0.0);

	private var _microsurfaceTextureLods:Vector2 = new Vector2(0.0, 0.0);

	/**
	 * Debug Control allowing to overload the ambient color.
	 * This as to be use with the overloadedAmbientIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedAmbient:Color3 = Color3.White();

	/**
	 * Debug Control indicating how much the overloaded ambient color is used against the default one.
	 */
	@serialize()
	public var overloadedAmbientIntensity:Float = 0.0;
	
	/**
	 * Debug Control allowing to overload the albedo color.
	 * This as to be use with the overloadedAlbedoIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedAlbedo:Color3 = Color3.White();
	
	/**
	 * Debug Control indicating how much the overloaded albedo color is used against the default one.
	 */
	@serialize()
	public var overloadedAlbedoIntensity:Float = 0.0;
	
	/**
	 * Debug Control allowing to overload the reflectivity color.
	 * This as to be use with the overloadedReflectivityIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedReflectivity:Color3 = new Color3(0.3, 0.3, 0.3);
	
	/**
	 * Debug Control indicating how much the overloaded reflectivity color is used against the default one.
	 */
	@serialize()
	public var overloadedReflectivityIntensity:Float = 0.0;
	
	/**
	 * Debug Control allowing to overload the emissive color.
	 * This as to be use with the overloadedEmissiveIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedEmissive:Color3 = Color3.White();
	
	/**
	 * Debug Control indicating how much the overloaded emissive color is used against the default one.
	 */
	@serialize()
	public var overloadedEmissiveIntensity:Float = 0.0;

	private var _overloadedIntensity:Vector4;
	
	/**
	 * Debug Control allowing to overload the reflection color.
	 * This as to be use with the overloadedReflectionIntensity parameter.
	 */
	@serializeAsColor3()
	public var overloadedReflection:Color3 = Color3.White();
	
	/**
	 * Debug Control indicating how much the overloaded reflection color is used against the default one.
	 */
	@serialize()
	public var overloadedReflectionIntensity:Float = 0.0;

	/**
	 * Debug Control allowing to overload the microsurface.
	 * This as to be use with the overloadedMicroSurfaceIntensity parameter.
	 */
	@serialize()
	public var overloadedMicroSurface:Float = 0.0;
	
	/**
	 * Debug Control indicating how much the overloaded microsurface is used against the default one.
	 */
	@serialize()
	public var overloadedMicroSurfaceIntensity:Float = 0.0;

	private var _overloadedMicroSurface:Vector3;

	/**
	 * AKA Diffuse Texture in standard nomenclature.
	 */
	@serializeAsTexture()
	public var albedoTexture:BaseTexture;
	
	/**
	 * AKA Occlusion Texture in other nomenclature.
	 */
	@serializeAsTexture()
	public var ambientTexture:BaseTexture;

	@serializeAsTexture()
	public var opacityTexture:BaseTexture;

	@serializeAsTexture()
	public var reflectionTexture:BaseTexture;

	@serializeAsTexture()
	public var emissiveTexture:BaseTexture;
	
	/**
	 * AKA Specular texture in other nomenclature.
	 */
	@serializeAsTexture()
	public var reflectivityTexture:BaseTexture;

	@serializeAsTexture()
	public var bumpTexture:BaseTexture;

	@serializeAsTexture()
	public var lightmapTexture:BaseTexture;

	@serializeAsTexture()
	public var refractionTexture:BaseTexture;

	@serializeAsColor3("ambient")
	public var ambientColor:Color3 = new Color3(0, 0, 0);
	
	/**
	 * AKA Diffuse Color in other nomenclature.
	 */
	@serializeAsColor3("albedo")
	public var albedoColor:Color3 = new Color3(1, 1, 1);
	
	/**
	 * AKA Specular Color in other nomenclature.
	 */
	@serializeAsColor3("reflectivity")
	public var reflectivityColor:Color3 = new Color3(1, 1, 1);

	@serializeAsColor3("reflection")
	public var reflectionColor:Color3 = new Color3(0.5, 0.5, 0.5);

	@serializeAsColor3("emissive")
	public var emissiveColor:Color3 = new Color3(0, 0, 0);
	
	/**
	 * AKA Glossiness in other nomenclature.
	 */
	@serialize()
	public var microSurface:Float = 0.9;
	
	/**
	 * source material index of refraction (IOR)' / 'destination material IOR.
	 */
	@serialize()
	public var indexOfRefraction:Float = 0.66;
	
	/**
	 * Controls if refraction needs to be inverted on Y. This could be usefull for procedural texture.
	 */
	@serialize()
	public var invertRefractionY:Bool = false;

	@serializeAsFresnelParameters()
	public var opacityFresnelParameters:FresnelParameters;

	@serializeAsFresnelParameters()
	public var emissiveFresnelParameters:FresnelParameters;

	/**
	 * This parameters will make the material used its opacity to control how much it is refracting aginst not.
	 * Materials half opaque for instance using refraction could benefit from this control.
	 */
	@serialize()
	public var linkRefractionWithTransparency:Bool = false;
	
	/**
	 * The emissive and albedo are linked to never be more than one (Energy conservation).
	 */
	@serialize()
	public var linkEmissiveWithAlbedo:Bool = false;

	@serialize()
	public var useLightmapAsShadowmap:Bool = false;
	
	/**
	 * In this mode, the emissive informtaion will always be added to the lighting once.
	 * A light for instance can be thought as emissive.
	 */
	@serialize()
	public var useEmissiveAsIllumination:Bool = false;
	
	/**
	 * Secifies that the alpha is coming form the albedo channel alpha channel.
	 */
	@serialize()
	public var useAlphaFromAlbedoTexture:Bool = false;
	
	/**
	 * Specifies that the material will keeps the specular highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When sun reflects on it you can not see what is behind.
	 */
	@serialize()
	public var useSpecularOverAlpha:Bool = true;
	
	/**
	 * Specifies if the reflectivity texture contains the glossiness information in its alpha channel.
	 */
	@serialize()
	public var useMicroSurfaceFromReflectivityMapAlpha:Bool = false;
	
	/**
	 * In case the reflectivity map does not contain the microsurface information in its alpha channel,
	 * The material will try to infer what glossiness each pixel should be.
	 */
	@serialize()
	public var useAutoMicroSurfaceFromReflectivityMap:Bool = false;
	
	/**
	 * Allows to work with scalar in linear mode. This is definitely a matter of preferences and tools used during
	 * the creation of the material.
	 */
	@serialize()
	public var useScalarInLinearSpace:Bool = false;
	
	/**
	 * BJS is using an harcoded light falloff based on a manually sets up range.
	 * In PBR, one way to represents the fallof is to use the inverse squared root algorythm.
	 * This parameter can help you switch back to the BJS mode in order to create scenes using both materials.
	 */
	@serialize()
	public var usePhysicalLightFalloff:Bool = true;
	
	/**
	 * Specifies that the material will keeps the reflection highlights over a transparent surface (only the most limunous ones).
	 * A car glass is a good exemple of that. When the street lights reflects on it you can not see what is behind.
	 */
	@serialize()
	public var useRadianceOverAlpha:Bool = true;
	
	/**
	 * Allows using the bump map in parallax mode.
	 */
	@serialize()
	public var useParallax:Bool = false;

	/**
	 * Allows using the bump map in parallax occlusion mode.
	 */
	@serialize()
	public var useParallaxOcclusion:Bool = false;

	/**
	 * Controls the scale bias of the parallax mode.
	 */
	@serialize()
	public var parallaxScaleBias:Float = 0.05;
	
	/**
	 * If sets to true, disables all the lights affecting the material.
	 */
	@serialize()
	public var disableLighting:Bool = false;

	/**
	 * Number of Simultaneous lights allowed on the material.
	 */
	@serialize()
	public var maxSimultaneousLights:Int = 4; 
	
	/**
     * If sets to true, normal map will be considered following OpenGL convention.
     */
    @serialize()
    public var useOpenGLNormalMap:Bool = false;

	private var _renderTargets:SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(16);
	private var _worldViewProjectionMatrix:Matrix = Matrix.Zero();
	private var _globalAmbientColor:Color3 = new Color3(0, 0, 0);
	private var _tempColor:Color3 = new Color3();
	private var _renderId:Int;

	private var _defines:PBRMaterialDefines = new PBRMaterialDefines();
	private var _cachedDefines:PBRMaterialDefines = new PBRMaterialDefines();

	@serialize("useLogarithmicDepth")
	private var _useLogarithmicDepth:Bool;
	public var useLogarithmicDepth(get, set):Bool;
	
	private var defs:Map<String, Bool>;
	

	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this._cachedDefines.BonesPerMesh = -1;
		
		if (ShadersStore.Shaders.exists("pbr.fragment")) {
			var fragmentShader = ShadersStore.Shaders["pbr.fragment"];
			
			var textureLODExt = scene.getEngine().getCaps().textureLODExt;
			var textureCubeLod = scene.getEngine().getCaps().textureCubeLodFnName;
			
			fragmentShader = StringTools.replace(fragmentShader, "GL_EXT_shader_texture_lod", textureLODExt);
			fragmentShader = StringTools.replace(fragmentShader, "textureCubeLodEXT", textureCubeLod);
			//fragmentShader = StringTools.replace(fragmentShader, "texture2DLodEXT", "textureLod");
			
			ShadersStore.Shaders.set("pbr.fragment", fragmentShader);
		}
		else {
			throw "No pbr shaders !";
		}
		
		this._lightingInfos = new Vector4(this.directIntensity, this.emissiveIntensity, this.environmentIntensity, this.specularIntensity);
		this._overloadedShadowInfos = new Vector4(this.overloadedShadowIntensity, this.overloadedShadeIntensity, 0.0, 0.0);
		this._overloadedIntensity = new Vector4(this.overloadedAmbientIntensity, this.overloadedAlbedoIntensity, this.overloadedReflectivityIntensity, this.overloadedEmissiveIntensity);
		this._overloadedMicroSurface = new Vector3(this.overloadedMicroSurface, this.overloadedMicroSurfaceIntensity, this.overloadedReflectionIntensity);
		
		this.getRenderTargetTextures = function():SmartArray<RenderTargetTexture> {
			this._renderTargets.reset();
			
			if (this.reflectionTexture != null && this.reflectionTexture.isRenderTarget) {
				this._renderTargets.push(cast this.reflectionTexture);
			}
			
			if (this.refractionTexture != null && this.refractionTexture.isRenderTarget) {
				this._renderTargets.push(cast this.refractionTexture);
			}
			
			return this._renderTargets;
		};
		
		this.defs = this._defines.defines;
	}

	private function get_useLogarithmicDepth():Bool {
		return this._useLogarithmicDepth;
	}
	private function set_useLogarithmicDepth(value:Bool):Bool {
		this._useLogarithmicDepth = value && this.getScene().getEngine().getCaps().fragmentDepthSupported;
		
		return value;
	}

	override public function needAlphaBlending():Bool {
		if (this.linkRefractionWithTransparency) {
			return false;
		}
		
		return (this.alpha < 1.0) || (this.opacityTexture != null) || this._shouldUseAlphaFromAlbedoTexture() || this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled;
	}

	override public function needAlphaTesting():Bool {
		if (this.linkRefractionWithTransparency) {
			return false;
		}
		
		return this.albedoTexture != null && this.albedoTexture.hasAlpha;
	}

	private function _shouldUseAlphaFromAlbedoTexture():Bool {
		return this.albedoTexture != null && this.albedoTexture.hasAlpha && this.useAlphaFromAlbedoTexture;
	}

	override public function getAlphaTestTexture():BaseTexture {
		return this.albedoTexture;
	}

	private function _checkCache(scene:Scene, ?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (mesh == null) {
			return true;
		}
		
		if (this.defs["INSTANCES"] != useInstances) {
			return false;
		}
		
		if (mesh._materialDefines != null && mesh._materialDefines.isEqual(this._defines)) {
			return true;
		}
		
		return false;
	}

	inline private function convertColorToLinearSpaceToRef(color:Color3, ref:Color3) {
		PBRMaterial._convertColorToLinearSpaceToRef(color, ref, this.useScalarInLinearSpace);
	}

	inline private static function _convertColorToLinearSpaceToRef(color:Color3, ref:Color3, useScalarInLinear:Bool) {
		if (!useScalarInLinear) {
			color.toLinearSpaceToRef(ref);
		} 
		else {
			ref.r = color.r;
			ref.g = color.g;
			ref.b = color.b;
		}
	}

	private static var _scaledAlbedo = new Color3();
	private static var _scaledReflectivity = new Color3();
	private static var _scaledEmissive = new Color3();
	private static var _scaledReflection = new Color3();

	public static function BindLights(scene:Scene, mesh:AbstractMesh, effect:Effect, defines:MaterialDefines, useScalarInLinearSpace:Bool, maxSimultaneousLights:Int, usePhysicalLightFalloff:Bool) {
		var lightIndex:Int = 0;
		var depthValuesAlreadySet:Bool = false;
		for (index in 0...scene.lights.length) {
			var light = scene.lights[index];
			
			if (!light.isEnabled()) {
				continue;
			}
			
			if (!light.canAffectMesh(mesh)) {
				continue;
			}
			
			MaterialHelper.BindLightProperties(light, effect, lightIndex);
			
			// GAMMA CORRECTION.
			_convertColorToLinearSpaceToRef(light.diffuse, PBRMaterial._scaledAlbedo, useScalarInLinearSpace);
			
			PBRMaterial._scaledAlbedo.scaleToRef(light.intensity, PBRMaterial._scaledAlbedo);
			effect.setColor4("vLightDiffuse" + lightIndex, PBRMaterial._scaledAlbedo, usePhysicalLightFalloff ? light.radius : light.range);
			
			if (defines.defines["SPECULARTERM"]) {
				_convertColorToLinearSpaceToRef(light.specular, PBRMaterial._scaledReflectivity, useScalarInLinearSpace);
				
				PBRMaterial._scaledReflectivity.scaleToRef(light.intensity, PBRMaterial._scaledReflectivity);
				effect.setColor3("vLightSpecular" + lightIndex, PBRMaterial._scaledReflectivity);
			}
			
			// Shadows
			if (scene.shadowsEnabled) {
				depthValuesAlreadySet = MaterialHelper.BindLightShadow(light, scene, mesh, lightIndex, effect, depthValuesAlreadySet);
			}
			
			lightIndex++;
			
			if (lightIndex == maxSimultaneousLights) {
				break;
			}
		}
	}

	override public function isReady(?mesh:AbstractMesh, useInstances:Bool = false):Bool {
		if (this.checkReadyOnlyOnce) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		var scene = this.getScene();
		
		if (!this.checkReadyOnEveryCall) {
			if (this._renderId == scene.getRenderId()) {
				if (this._checkCache(scene, mesh, useInstances)) {
					return true;
				}
			}
		}
		
		var engine = scene.getEngine();
		var needNormals = false;
		var needUVs = false;
		
		this._defines.reset();
		
		if (scene.texturesEnabled) {
			// Textures
			if (scene.texturesEnabled) {
				if (scene.getEngine().getCaps().textureLOD) {
					this.defs["LODBASEDMICROSFURACE"] = true;
				}
				
				if (this.albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					if (!this.albedoTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this.defs["ALBEDO"] = true;
					}
				}
				
				if (this.ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
					if (!this.ambientTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this.defs["AMBIENT"] = true;
					}
				}
				
				if (this.opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
					if (!this.opacityTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this.defs["OPACITY"] = true;
						
						if (this.opacityTexture.getAlphaFromRGB) {
							this.defs["OPACITYRGB"] = true;
						}
					}
				}
				
				if (this.reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					if (!this.reflectionTexture.isReady()) {
						return false;
					} 
					else {
						needNormals = true;
						this.defs["REFLECTION"] = true;
						
						if (this.reflectionTexture.coordinatesMode == Texture.INVCUBIC_MODE) {
							this.defs["INVERTCUBICMAP"] = true;
						}
						
						this.defs["REFLECTIONMAP_3D"] = this.reflectionTexture.isCube;
						
						switch (this.reflectionTexture.coordinatesMode) {
							case Texture.CUBIC_MODE, Texture.INVCUBIC_MODE:
								this.defs["REFLECTIONMAP_CUBIC"] = true;
								
							case Texture.EXPLICIT_MODE:
								this.defs["REFLECTIONMAP_EXPLICIT"] = true;
								
							case Texture.PLANAR_MODE:
								this.defs["REFLECTIONMAP_PLANAR"] = true;
								
							case Texture.PROJECTION_MODE:
								this.defs["REFLECTIONMAP_PROJECTION"] = true;
								
							case Texture.SKYBOX_MODE:
								this.defs["REFLECTIONMAP_SKYBOX"] = true;
								
							case Texture.SPHERICAL_MODE:
								this.defs["REFLECTIONMAP_SPHERICAL"] = true;
								
							case Texture.EQUIRECTANGULAR_MODE:
								this.defs["REFLECTIONMAP_EQUIRECTANGULAR"] = true;
								
						}
						
						if (Std.is(this.reflectionTexture, HDRCubeTexture)) {
							this.defs["USESPHERICALFROMREFLECTIONMAP"] = true;
							needNormals = true;
							
							if (untyped this.reflectionTexture.isPMREM) {
								this.defs["USEPMREMREFLECTION"] = true;
							}
						}
					}
				}
				
				if (this.lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
					if (!this.lightmapTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this.defs["LIGHTMAP"] = true;
						this.defs["USELIGHTMAPASSHADOWMAP"] = this.useLightmapAsShadowmap;
					}
				}
				
				if (this.emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
					if (!this.emissiveTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this.defs["EMISSIVE"] = true;
					}
				}
				
				if (this.reflectivityTexture != null && StandardMaterial.SpecularTextureEnabled) {
					if (!this.reflectivityTexture.isReady()) {
						return false;
					} 
					else {
						needUVs = true;
						this.defs["REFLECTIVITY"] = true;
						this.defs["MICROSURFACEFROMREFLECTIVITYMAP"] = this.useMicroSurfaceFromReflectivityMapAlpha;
						this.defs["MICROSURFACEAUTOMATIC"] = this.useAutoMicroSurfaceFromReflectivityMap;
					}
				}
			}
			
			if (scene.getEngine().getCaps().standardDerivatives && this.bumpTexture != null && StandardMaterial.BumpTextureEnabled && !this.disableBumpMap) {
				if (!this.bumpTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this.defs["BUMP"] = true;
					
					if (this.useParallax) {
						this.defs["PARALLAX"] = true;
						if (this.useParallaxOcclusion) {
							this.defs["PARALLAXOCCLUSION"] = true;
						}
					}
					
					if (this.useOpenGLNormalMap) {
                        this.defs["OPENGLNORMALMAP"] = true;
                    }
				}
			}
			
			if (this.refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
				if (!this.refractionTexture.isReady()) {
					return false;
				} 
				else {
					needUVs = true;
					this.defs["REFRACTION"] = true;
					this.defs["REFRACTIONMAP_3D"] = this.refractionTexture.isCube;
					
					if (this.linkRefractionWithTransparency) {
						this.defs["LINKREFRACTIONTOTRANSPARENCY"] = true;
					}
					if (Std.is(this.refractionTexture, HDRCubeTexture)) {
						this.defs["REFRACTIONMAPINLINEARSPACE"] = true;
						
						if (untyped this.refractionTexture.isPMREM) {
							this.defs["USEPMREMREFRACTION"] = true;
						}
					}
				}
			}
			
			if (this.cameraColorGradingTexture != null) {
				if (!this.cameraColorGradingTexture.isReady()) {
					return false;
				} 
				else {
					this.defs["CAMERACOLORGRADING"] = true;
				}
			}
		}
		
		// Effect
		if (scene.clipPlane != null) {
			this.defs["CLIPPLANE"] = true;
		}
		
		if (engine.getAlphaTesting()) {
			this.defs["ALPHATEST"] = true;
		}
		
		if (this._shouldUseAlphaFromAlbedoTexture()) {
			this.defs["ALPHAFROMALBEDO"] = true;
		}
		
		if (this.useEmissiveAsIllumination) {
			this.defs["EMISSIVEASILLUMINATION"] = true;
		}
		
		if (this.linkEmissiveWithAlbedo) {
			this.defs["LINKEMISSIVEWITHALBEDO"] = true;
		}
		
		if (this.useLogarithmicDepth) {
			this.defs["LOGARITHMICDEPTH"] = true;
		}
		
		if (this.cameraContrast != 1) {
			this.defs["CAMERACONTRAST"] = true;
		}
		
		if (this.cameraExposure != 1) {
			this.defs["CAMERATONEMAP"] = true;
		}
		
		if (this.overloadedShadeIntensity != 1 ||
			this.overloadedShadowIntensity != 1) {
			this.defs["OVERLOADEDSHADOWVALUES"] = true;
		}
		
		if (this.overloadedMicroSurfaceIntensity > 0 ||
			this.overloadedEmissiveIntensity > 0 ||
			this.overloadedReflectivityIntensity > 0 ||
			this.overloadedAlbedoIntensity > 0 ||
			this.overloadedAmbientIntensity > 0 ||
			this.overloadedReflectionIntensity > 0) {
			this.defs["OVERLOADEDVALUES"] = true;
		}
		
		// Point size
		if (this.pointsCloud || scene.forcePointsCloud) {
			this.defs["POINTSIZE"] = true;
		}
		
		// Fog
		if (scene.fogEnabled && mesh != null && mesh.applyFog && scene.fogMode != Scene.FOGMODE_NONE && this.fogEnabled) {
			this.defs["FOG"] = true;
		}
		
		if (scene.lightsEnabled && !this.disableLighting) {
			needNormals = MaterialHelper.PrepareDefinesForLights(scene, mesh, this._defines, this.maxSimultaneousLights);
		}
		
		if (StandardMaterial.FresnelEnabled) {
			// Fresnel
			if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled ||
				this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
				
				if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled) {
					this.defs["OPACITYFRESNEL"] = true;
				}
				
				if (this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
					this.defs["EMISSIVEFRESNEL"] = true;
				}
				
				needNormals = true;
				this.defs["FRESNEL"] = true;
			}
		}
		
		if (this.defs["SPECULARTERM"] && this.useSpecularOverAlpha) {
			this.defs["SPECULAROVERALPHA"] = true;
		}
		
		if (this.usePhysicalLightFalloff) {
			this.defs["USEPHYSICALLIGHTFALLOFF"] = true;
		}
		
		if (this.useRadianceOverAlpha) {
			this.defs["RADIANCEOVERALPHA"] = true;
		}
		
		// Attribs
		if (mesh != null) {
			if (needNormals && mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
				this.defs["NORMAL"] = true;
			}
			if (needUVs) {
				if (mesh.isVerticesDataPresent(VertexBuffer.UVKind)) {
					this.defs["UV1"] = true;
				}
				if (mesh.isVerticesDataPresent(VertexBuffer.UV2Kind)) {
					this.defs["UV2"] = true;
				}
			}
			if (mesh.useVertexColors && mesh.isVerticesDataPresent(VertexBuffer.ColorKind)) {
				this.defs["VERTEXCOLOR"] = true;
				
				if (mesh.hasVertexAlpha) {
					this.defs["VERTEXALPHA"] = true;
				}
			}
			if (mesh.useBones && mesh.computeBonesUsingShaders) {
				this._defines.NUM_BONE_INFLUENCERS = mesh.numBoneInfluencers;
				this._defines.BonesPerMesh = (mesh.skeleton.bones.length + 1);
			}
			
			// Instances
			if (useInstances) {
				this.defs["INSTANCES"] = true;
			}
		}
		
		// Get correct effect
		if (!this._defines.isEqual(this._cachedDefines)) {
			this._defines.cloneTo(this._cachedDefines);
			
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();
			if (this.defs["REFLECTION"]) {
				fallbacks.addFallback(0, "REFLECTION");
			}
			
			if (this.defs["REFRACTION"]) {
				fallbacks.addFallback(0, "REFRACTION");
			}
			
			if (this.defs["REFLECTIVITY"]) {
				fallbacks.addFallback(0, "REFLECTIVITY");
			}
			
			if (this.defs["BUMP"]) {
				fallbacks.addFallback(0, "BUMP");
			}
			
			if (this.defs["PARALLAX"]) {
				fallbacks.addFallback(1, "PARALLAX");
			}
			
			if (this.defs["PARALLAXOCCLUSION"]) {
				fallbacks.addFallback(0, "PARALLAXOCCLUSION");
			}
			
			if (this.defs["SPECULAROVERALPHA"]) {
				fallbacks.addFallback(0, "SPECULAROVERALPHA");
			}
			
			if (this.defs["FOG"]) {
				fallbacks.addFallback(1, "FOG");
			}
			
			if (this.defs["POINTSIZE"]) {
				fallbacks.addFallback(0, "POINTSIZE");
			}
			
			if (this.defs["LOGARITHMICDEPTH"]) {
				fallbacks.addFallback(0, "LOGARITHMICDEPTH");
			}
			
			MaterialHelper.HandleFallbacksForShadows(this._defines, fallbacks, this.maxSimultaneousLights);
			
			if (this.defs["SPECULARTERM"]) {
				fallbacks.addFallback(0, "SPECULARTERM");
			}
			
			if (this.defs["OPACITYFRESNEL"]) {
				fallbacks.addFallback(1, "OPACITYFRESNEL");
			}
			
			if (this.defs["EMISSIVEFRESNEL"]) {
				fallbacks.addFallback(2, "EMISSIVEFRESNEL");
			}
			
			if (this.defs["FRESNEL"]) {
				fallbacks.addFallback(3, "FRESNEL");
			}
			
			if (this._defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (this.defs["NORMAL"]) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (this.defs["UV1"]) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (this.defs["UV2"]) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			if (this.defs["VERTEXCOLOR"]) {
				attribs.push(VertexBuffer.ColorKind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, this._defines, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, this._defines);
			
			// Legacy browser patch
			var shaderName:String = "pbr";
			if (!scene.getEngine().getCaps().standardDerivatives) {
				shaderName = "legacypbr";
			}
			var join:String = this._defines.toString();
			
			var uniforms:Array<String> = ["world", "view", "viewProjection", "vEyePosition", "vLightsType", "vAmbientColor", "vAlbedoColor", "vReflectivityColor", "vEmissiveColor", "vReflectionColor",
				"vFogInfos", "vFogColor", "pointSize",
				"vAlbedoInfos", "vAmbientInfos", "vOpacityInfos", "vReflectionInfos", "vEmissiveInfos", "vReflectivityInfos", "vBumpInfos", "vLightmapInfos", "vRefractionInfos",
				"mBones",
				"vClipPlane", "albedoMatrix", "ambientMatrix", "opacityMatrix", "reflectionMatrix", "emissiveMatrix", "reflectivityMatrix", "bumpMatrix", "lightmapMatrix", "refractionMatrix",
				"depthValues",
				"opacityParts", "emissiveLeftColor", "emissiveRightColor",
				"vLightingIntensity", "vOverloadedShadowIntensity", "vOverloadedIntensity", "vOverloadedAlbedo", "vOverloadedReflection", "vOverloadedReflectivity", "vOverloadedEmissive", "vOverloadedMicroSurface",
				"logarithmicDepthConstant",
				"vSphericalX", "vSphericalY", "vSphericalZ",
				"vSphericalXX", "vSphericalYY", "vSphericalZZ",
				"vSphericalXY", "vSphericalYZ", "vSphericalZX",
				"vMicrosurfaceTextureLods",
				"vCameraInfos", "vCameraColorGradingInfos", "vCameraColorGradingScaleOffset"
			];
			
			var samplers:Array<String> = ["albedoSampler", "ambientSampler", "opacitySampler", "reflectionCubeSampler", "reflection2DSampler", "emissiveSampler", "reflectivitySampler", "bumpSampler", "lightmapSampler", "refractionCubeSampler", "refraction2DSampler", "cameraColorGrading2DSampler"];
			
			MaterialHelper.PrepareUniformsAndSamplersList(uniforms, samplers, this._defines, this.maxSimultaneousLights); 
			
			this._effect = scene.getEngine().createEffect(shaderName,
				attribs, uniforms, samplers,
				join, fallbacks, this.onCompiled, this.onError, { maxSimultaneousLights: this.maxSimultaneousLights });
		}
		if (!this._effect.isReady()) {
			return false;
		}
		
		this._renderId = scene.getRenderId();
		this._wasPreviouslyReady = true;
		
		if (mesh != null) {
			if (mesh._materialDefines == null) {
				mesh._materialDefines = new PBRMaterialDefines();
			}
			
			this._defines.cloneTo(mesh._materialDefines);
		}
		
		return true;
	}


	override public function unbind() {
		if (this.reflectionTexture != null && this.reflectionTexture.isRenderTarget) {
			this._effect.setTexture("reflection2DSampler", null);
		}
		
		if (this.refractionTexture != null && this.refractionTexture.isRenderTarget) {
			this._effect.setTexture("refraction2DSampler", null);
		}
		
		super.unbind();
	}

	override public function bindOnlyWorldMatrix(world:Matrix) {
		this._effect.setMatrix("world", world);
	}

	private var _myScene:Scene = null;
	private var _myShadowGenerator:ShadowGenerator = null;

	override public function bind(world:Matrix, ?mesh:Mesh) {
		this._myScene = this.getScene();
		
		// Matrices        
		this.bindOnlyWorldMatrix(world);
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._effect);
		
		if (this._myScene.getCachedMaterial() != this) {
			this._effect.setMatrix("viewProjection", this._myScene.getTransformMatrix());
			
			if (StandardMaterial.FresnelEnabled) {
				if (this.opacityFresnelParameters != null && this.opacityFresnelParameters.isEnabled) {
					this._effect.setColor4("opacityParts", new Color3(this.opacityFresnelParameters.leftColor.toLuminance(), this.opacityFresnelParameters.rightColor.toLuminance(), this.opacityFresnelParameters.bias), this.opacityFresnelParameters.power);
				}
				
				if (this.emissiveFresnelParameters != null && this.emissiveFresnelParameters.isEnabled) {
					this._effect.setColor4("emissiveLeftColor", this.emissiveFresnelParameters.leftColor, this.emissiveFresnelParameters.power);
					this._effect.setColor4("emissiveRightColor", this.emissiveFresnelParameters.rightColor, this.emissiveFresnelParameters.bias);
				}
			}
			
			// Textures        
			if (this._myScene.texturesEnabled) {
				if (this.albedoTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					this._effect.setTexture("albedoSampler", this.albedoTexture);
					
					this._effect.setFloat2("vAlbedoInfos", this.albedoTexture.coordinatesIndex, this.albedoTexture.level);
					this._effect.setMatrix("albedoMatrix", this.albedoTexture.getTextureMatrix());
				}
				
				if (this.ambientTexture != null && StandardMaterial.AmbientTextureEnabled) {
					this._effect.setTexture("ambientSampler", this.ambientTexture);
					
					this._effect.setFloat2("vAmbientInfos", this.ambientTexture.coordinatesIndex, this.ambientTexture.level);
					this._effect.setMatrix("ambientMatrix", this.ambientTexture.getTextureMatrix());
				}
				
				if (this.opacityTexture != null && StandardMaterial.OpacityTextureEnabled) {
					this._effect.setTexture("opacitySampler", this.opacityTexture);
					
					this._effect.setFloat2("vOpacityInfos", this.opacityTexture.coordinatesIndex, this.opacityTexture.level);
					this._effect.setMatrix("opacityMatrix", this.opacityTexture.getTextureMatrix());
				}
				
				if (this.reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					this._microsurfaceTextureLods.x = Math.round(Math.log(this.reflectionTexture.getSize().width) * MathTools.LOG2E);
					
					if (this.reflectionTexture.isCube) {
						this._effect.setTexture("reflectionCubeSampler", this.reflectionTexture);
					} 
					else {
						this._effect.setTexture("reflection2DSampler", this.reflectionTexture);
					}
					
					this._effect.setMatrix("reflectionMatrix", this.reflectionTexture.getReflectionTextureMatrix());
					this._effect.setFloat2("vReflectionInfos", this.reflectionTexture.level, 0);
					
					if (this.defs["USESPHERICALFROMREFLECTIONMAP"]) {
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
				
				if (this.emissiveTexture != null && StandardMaterial.EmissiveTextureEnabled) {
					this._effect.setTexture("emissiveSampler", this.emissiveTexture);
					
					this._effect.setFloat2("vEmissiveInfos", this.emissiveTexture.coordinatesIndex, this.emissiveTexture.level);
					this._effect.setMatrix("emissiveMatrix", this.emissiveTexture.getTextureMatrix());
				}
				
				if (this.lightmapTexture != null && StandardMaterial.LightmapTextureEnabled) {
					this._effect.setTexture("lightmapSampler", this.lightmapTexture);
					
					this._effect.setFloat2("vLightmapInfos", this.lightmapTexture.coordinatesIndex, this.lightmapTexture.level);
					this._effect.setMatrix("lightmapMatrix", this.lightmapTexture.getTextureMatrix());
				}
				
				if (this.reflectivityTexture != null && StandardMaterial.SpecularTextureEnabled) {
					this._effect.setTexture("reflectivitySampler", this.reflectivityTexture);
					
					this._effect.setFloat2("vReflectivityInfos", this.reflectivityTexture.coordinatesIndex, this.reflectivityTexture.level);
					this._effect.setMatrix("reflectivityMatrix", this.reflectivityTexture.getTextureMatrix());
				}
				
				if (this.bumpTexture != null && this._myScene.getEngine().getCaps().standardDerivatives && StandardMaterial.BumpTextureEnabled && !this.disableBumpMap) {
					this._effect.setTexture("bumpSampler", this.bumpTexture);
					
					this._effect.setFloat3("vBumpInfos", this.bumpTexture.coordinatesIndex, 1.0 / this.bumpTexture.level, this.parallaxScaleBias);
					this._effect.setMatrix("bumpMatrix", this.bumpTexture.getTextureMatrix());
				}
				
				if (this.refractionTexture != null && StandardMaterial.RefractionTextureEnabled) {
					this._microsurfaceTextureLods.y = Math.round(Math.log(this.refractionTexture.getSize().width) * MathTools.LOG2E);
					
					var depth = 1.0;
					if (this.refractionTexture.isCube) {
						this._effect.setTexture("refractionCubeSampler", this.refractionTexture);
					} 
					else {
						this._effect.setTexture("refraction2DSampler", this.refractionTexture);
						this._effect.setMatrix("refractionMatrix", this.refractionTexture.getReflectionTextureMatrix());
						
						if (Std.is(this.refractionTexture, RefractionTexture)) {
							depth = untyped this.refractionTexture.depth;
						}
					}
					this._effect.setFloat4("vRefractionInfos", this.refractionTexture.level, this.indexOfRefraction, depth, this.invertRefractionY ? -1 : 1);
				}
				
				if ((this.reflectionTexture != null || this.refractionTexture != null)) {
					this._effect.setFloat2("vMicrosurfaceTextureLods", this._microsurfaceTextureLods.x, this._microsurfaceTextureLods.y);
				}
				
				if (this.cameraColorGradingTexture != null) {
					this._effect.setTexture("cameraColorGrading2DSampler", this.cameraColorGradingTexture);
					
					this._cameraColorGradingInfos.x = this.cameraColorGradingTexture.level;                     // Texture Level
					this._cameraColorGradingInfos.y = this.cameraColorGradingTexture.getSize().height;          // Texture Size example with 8
					this._cameraColorGradingInfos.z = this._cameraColorGradingInfos.y - 1.0;                    // SizeMinusOne 8 - 1
					this._cameraColorGradingInfos.w = 1 / this._cameraColorGradingInfos.y;                      // Space of 1 slice 1 / 8
					
					this._effect.setFloat4("vCameraColorGradingInfos", 
						this._cameraColorGradingInfos.x,
						this._cameraColorGradingInfos.y,
						this._cameraColorGradingInfos.z,
						this._cameraColorGradingInfos.w);
						
					var slicePixelSizeU = this._cameraColorGradingInfos.w / this._cameraColorGradingInfos.y;    // Space of 1 pixel in U direction, e.g. 1/64
					var slicePixelSizeV = 1.0 / this._cameraColorGradingInfos.y;							    // Space of 1 pixel in V direction, e.g. 1/8
					this._cameraColorGradingScaleOffset.x = this._cameraColorGradingInfos.z * slicePixelSizeU;  // Extent of lookup range in U for a single slice so that range corresponds to (size-1) texels, for example 7/64
					this._cameraColorGradingScaleOffset.y = this._cameraColorGradingInfos.z / this._cameraColorGradingInfos.y; // Extent of lookup range in V for a single slice so that range corresponds to (size-1) texels, for example 7/8
					this._cameraColorGradingScaleOffset.z = 0.5 * slicePixelSizeU;						        // Offset of lookup range in U to align sample position with texel centre, for example 0.5/64 
					this._cameraColorGradingScaleOffset.w = 0.5 * slicePixelSizeV;						        // Offset of lookup range in V to align sample position with texel centre, for example 0.5/8
					
					this._effect.setFloat4("vCameraColorGradingScaleOffset", 
						this._cameraColorGradingScaleOffset.x,
						this._cameraColorGradingScaleOffset.y,
						this._cameraColorGradingScaleOffset.z,
						this._cameraColorGradingScaleOffset.w);
				}
			}
			
			// Clip plane
			MaterialHelper.BindClipPlane(this._effect, this._myScene);
			
			// Point size
			if (this.pointsCloud) {
				this._effect.setFloat("pointSize", this.pointSize);
			}
			
			// Colors
			this._myScene.ambientColor.multiplyToRef(this.ambientColor, this._globalAmbientColor);
			
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(this.reflectivityColor, PBRMaterial._scaledReflectivity);
			
			this._effect.setVector3("vEyePosition", this._myScene._mirroredCameraPosition != null ? this._myScene._mirroredCameraPosition : this._myScene.activeCamera.position);
			this._effect.setColor3("vAmbientColor", this._globalAmbientColor);
			this._effect.setColor4("vReflectivityColor", PBRMaterial._scaledReflectivity, this.microSurface);
			
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(this.emissiveColor, PBRMaterial._scaledEmissive);
			this._effect.setColor3("vEmissiveColor", PBRMaterial._scaledEmissive);
			
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(this.reflectionColor, PBRMaterial._scaledReflection);
			this._effect.setColor3("vReflectionColor", PBRMaterial._scaledReflection);
		}

		if (this._myScene.getCachedMaterial() != this || !this.isFrozen) {
			// GAMMA CORRECTION.
			this.convertColorToLinearSpaceToRef(this.albedoColor, PBRMaterial._scaledAlbedo);
			this._effect.setColor4("vAlbedoColor", PBRMaterial._scaledAlbedo, this.alpha * mesh.visibility);
			
			// Lights
			if (this._myScene.lightsEnabled && !this.disableLighting) {
				PBRMaterial.BindLights(this._myScene, mesh, this._effect, this._defines, this.useScalarInLinearSpace, this.maxSimultaneousLights, this.usePhysicalLightFalloff);
			}
			
			// View
			if (this._myScene.fogEnabled && mesh.applyFog && this._myScene.fogMode != Scene.FOGMODE_NONE || this.reflectionTexture != null) {
				this._effect.setMatrix("view", this._myScene.getViewMatrix());
			}
			
			// Fog
			MaterialHelper.BindFogParameters(this._myScene, mesh, this._effect);
			
			this._lightingInfos.x = this.directIntensity;
			this._lightingInfos.y = this.emissiveIntensity;
			this._lightingInfos.z = this.environmentIntensity;
			this._lightingInfos.w = this.specularIntensity;
			
			this._effect.setVector4("vLightingIntensity", this._lightingInfos);
			
			this._overloadedShadowInfos.x = this.overloadedShadowIntensity;
			this._overloadedShadowInfos.y = this.overloadedShadeIntensity;
			this._effect.setVector4("vOverloadedShadowIntensity", this._overloadedShadowInfos);
			
			this._cameraInfos.x = this.cameraExposure;
			this._cameraInfos.y = this.cameraContrast;
			this._effect.setVector4("vCameraInfos", this._cameraInfos);
			
			this._overloadedIntensity.x = this.overloadedAmbientIntensity;
			this._overloadedIntensity.y = this.overloadedAlbedoIntensity;
			this._overloadedIntensity.z = this.overloadedReflectivityIntensity;
			this._overloadedIntensity.w = this.overloadedEmissiveIntensity;
			this._effect.setVector4("vOverloadedIntensity", this._overloadedIntensity);
			
			this.convertColorToLinearSpaceToRef(this.overloadedAmbient, this._tempColor);
			this._effect.setColor3("vOverloadedAmbient", this._tempColor);
			this.convertColorToLinearSpaceToRef(this.overloadedAlbedo, this._tempColor);
			this._effect.setColor3("vOverloadedAlbedo", this._tempColor);
			this.convertColorToLinearSpaceToRef(this.overloadedReflectivity, this._tempColor);
			this._effect.setColor3("vOverloadedReflectivity", this._tempColor);
			this.convertColorToLinearSpaceToRef(this.overloadedEmissive, this._tempColor);
			this._effect.setColor3("vOverloadedEmissive", this._tempColor);
			this.convertColorToLinearSpaceToRef(this.overloadedReflection, this._tempColor);
			this._effect.setColor3("vOverloadedReflection", this._tempColor);
			
			this._overloadedMicroSurface.x = this.overloadedMicroSurface;
			this._overloadedMicroSurface.y = this.overloadedMicroSurfaceIntensity;
			this._overloadedMicroSurface.z = this.overloadedReflectionIntensity;
			this._effect.setVector3("vOverloadedMicroSurface", this._overloadedMicroSurface);
			
			// Log. depth
			MaterialHelper.BindLogDepth(this._defines, this._effect, this._myScene);
		}
		super.bind(world, mesh);
		
		this._myScene = null;
	}

	public function getAnimatables():Array<IAnimatable> {
		var results:Array<IAnimatable> = [];
		
		if (this.albedoTexture != null && this.albedoTexture.animations != null && this.albedoTexture.animations.length > 0) {
			results.push(this.albedoTexture);
		}
		
		if (this.ambientTexture != null && this.ambientTexture.animations != null && this.ambientTexture.animations.length > 0) {
			results.push(this.ambientTexture);
		}
		
		if (this.opacityTexture != null && this.opacityTexture.animations != null && this.opacityTexture.animations.length > 0) {
			results.push(this.opacityTexture);
		}
		
		if (this.reflectionTexture != null && this.reflectionTexture.animations != null && this.reflectionTexture.animations.length > 0) {
			results.push(this.reflectionTexture);
		}
		
		if (this.emissiveTexture != null && this.emissiveTexture.animations != null && this.emissiveTexture.animations.length > 0) {
			results.push(this.emissiveTexture);
		}
		
		if (this.reflectivityTexture != null && this.reflectivityTexture.animations != null && this.reflectivityTexture.animations.length > 0) {
			results.push(this.reflectivityTexture);
		}
		
		if (this.bumpTexture != null && this.bumpTexture.animations != null && this.bumpTexture.animations.length > 0) {
			results.push(this.bumpTexture);
		}
		
		if (this.lightmapTexture != null && this.lightmapTexture.animations != null && this.lightmapTexture.animations.length > 0) {
			results.push(this.lightmapTexture);
		}
		
		if (this.refractionTexture != null && this.refractionTexture.animations != null && this.refractionTexture.animations.length > 0) {
			results.push(this.refractionTexture);
		}
		
		if (this.cameraColorGradingTexture != null && this.cameraColorGradingTexture.animations != null && this.cameraColorGradingTexture.animations.length > 0) {
			results.push(this.cameraColorGradingTexture);
		}
		
		return results;
	}

	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = true) {
		if (forceDisposeTextures) {
			if (this.albedoTexture != null) {
				this.albedoTexture.dispose();
			}
			
			if (this.ambientTexture != null) {
				this.ambientTexture.dispose();
			}
			
			if (this.opacityTexture != null) {
				this.opacityTexture.dispose();
			}
			
			if (this.reflectionTexture != null) {
				this.reflectionTexture.dispose();
			}
			
			if (this.emissiveTexture != null) {
				this.emissiveTexture.dispose();
			}
			
			if (this.reflectivityTexture != null) {
				this.reflectivityTexture.dispose();
			}
			
			if (this.bumpTexture != null) {
				this.bumpTexture.dispose();
			}
			
			if (this.lightmapTexture != null) {
				this.lightmapTexture.dispose();
			}
			
			if (this.refractionTexture != null) {
				this.refractionTexture.dispose();
			}
			
			if (this.cameraColorGradingTexture != null) {
				this.cameraColorGradingTexture.dispose();
			}
		}
		
		super.dispose(forceDisposeEffect, forceDisposeTextures);
	}

	override public function clone(name:String, cloneChildren:Bool = false):PBRMaterial {
		// TODO
		//return SerializationHelper.Clone(() => new PBRMaterial(name, this.getScene()), this);
		return null;
	}

	override public function serialize():Dynamic {
		return SerializationHelper.Serialize(PBRMaterial, this, super.serialize());
	}

	// Statics
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):PBRMaterial {
		// TODO
		//return SerializationHelper.Parse(() => new PBRMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
