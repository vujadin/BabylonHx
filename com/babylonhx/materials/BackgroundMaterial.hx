package com.babylonhx.materials;

import com.babylonhx.engine.Engine;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector4;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.lights.IShadowLight;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.Tools;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.tools.serialization.SerializationHelper;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.BaseSubMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.Mesh;


/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * Background material used to create an efficient environement around your scene.
 */
class BackgroundMaterial extends PushMaterial {

	/**
	 * Standard reflectance value at parallel view angle.
	 */
	public static var standardReflectance0:Float = 0.05;

	/**
	 * Standard reflectance value at grazing angle.
	 */
	public static var standardReflectance90:Float = 0.5;

	/**
	 * Key light Color (multiply against the R channel of the environement texture)
	 */
	@serializeAsColor3()
	private var _primaryColor:Color3 = Color3.White();
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var primaryColor(get, set):Color3;
	inline private function get_primaryColor():Color3 {
		return _primaryColor;
	}
	inline private function set_primaryColor(value:Color3):Color3 {
		_primaryColor = value;
		_markAllSubMeshesAsLightsDirty();
		return value;
	}

	/**
	 * Key light Level (allowing HDR output of the background)
	 */
	@serialize()
	private var _primaryLevel:Float = 1;
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var primaryLevel(get, set):Float;
	inline private function get_primaryLevel():Float {
		return _primaryLevel;
	}
	inline private function set_primaryLevel(value:Float):Float {
		_primaryLevel = value;
		_markAllSubMeshesAsLightsDirty();
		return value;
	}
	/**
	 * Secondary light Color (multiply against the G channel of the environement texture)
	 */
	@serializeAsColor3()
	private var _secondaryColor:Color3 = Color3.Gray();
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var secondaryColor(get, set):Color3;
	inline private function get_secondaryColor():Color3 {
		return _secondaryColor;
	}
	inline private function set_secondaryColor(value:Color3):Color3 {
		_secondaryColor = value;
		_markAllSubMeshesAsLightsDirty();
		return value;
	}

	/**
	 * Secondary light Level (allowing HDR output of the background)
	 */
	@serialize()
	private var _secondaryLevel:Float = 1;
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var secondaryLevel(get, set):Float;
	inline private function get_secondaryLevel():Float {
		return _secondaryLevel;
	}
	inline private function set_secondaryLevel(value:Float):Float {
		_secondaryLevel = value;
		_markAllSubMeshesAsLightsDirty();
		return value;
	}

	/**
	 * Tertiary light Color (multiply against the B channel of the environement texture)
	 */
	@serializeAsColor3()
	private var _tertiaryColor:Color3 = Color3.Black();
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var tertiaryColor(get, set):Color3;
	inline private function get_tertiaryColor():Color3 {
		return _tertiaryColor;
	}
	inline private function set_tertiaryColor(value:Color3):Color3 {
		_tertiaryColor = value;
		_markAllSubMeshesAsLightsDirty();
		return value;
	}

	/**
	 * Tertiary light Level (allowing HDR output of the background)
	 */
	@serialize()
	private var _tertiaryLevel:Float = 1;
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var tertiaryLevel(get, set):Float;
	inline private function get_tertiaryLevel():Float {
		return _tertiaryLevel;
	}
	inline private function set_tertiaryLevel(value:Float):Float {
		_tertiaryLevel = value;
		_markAllSubMeshesAsLightsDirty();
		return value;
	}

	/**
	 * Reflection Texture used in the material.
	 * Should be author in a specific way for the best result (refer to the documentation).
	 */
	@serializeAsTexture()
	private var _reflectionTexture:BaseTexture = null;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionTexture(get, set):BaseTexture;
	inline private function get_reflectionTexture():BaseTexture {
		return _reflectionTexture;
	}
	inline private function set_reflectionTexture(value:BaseTexture):BaseTexture {
		_reflectionTexture = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Reflection Texture level of blur.
	 * 
	 * Can be use to reuse an existing HDR Texture and target a specific LOD to prevent authoring the 
	 * texture twice.
	 */
	@serialize()
	private var _reflectionBlur:Float = 0;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionBlur(get, set):Float;
	inline private function get_reflectionBlur():Float {
		return _reflectionBlur;
	}
	inline private function set_reflectionBlur(value:Float):Float {
		_reflectionBlur = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}
	
	/**
	 * Diffuse Texture used in the material.
	 * Should be author in a specific way for the best result (refer to the documentation).
	 */
	@serializeAsTexture()
	private var _diffuseTexture:BaseTexture = null;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var diffuseTexture(get, set):BaseTexture;
	inline private function get_diffuseTexture():BaseTexture {
		return _diffuseTexture;
	}
	inline private function set_diffuseTexture(value:BaseTexture):BaseTexture {
		_diffuseTexture = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Specify the list of lights casting shadow on the material.
	 * All scene shadow lights will be included if null.
	 */
	private var _shadowLights:Array<IShadowLight> = null;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var shadowLights(get, set):Array<IShadowLight>;
	inline private function get_shadowLights():Array<IShadowLight> {
		return _shadowLights;
	}
	inline private function set_shadowLights(value:Array<IShadowLight>):Array<IShadowLight> {
		_shadowLights = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * For the lights having a blurred shadow generator, this can add a second blur pass in order to reach
	 * soft lighting on the background.
	 */
	@serialize()
	private var _shadowBlurScale:Int = 1;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var shadowBlurScale(get, set):Int;
	inline private function get_shadowBlurScale():Int {
		return _shadowBlurScale;
	}
	inline private function set_shadowBlurScale(value:Int):Int {
		_shadowBlurScale = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Helps adjusting the shadow to a softer level if required.
	 * 0 means black shadows and 1 means no shadows.
	 */
	@serialize()
	private var _shadowLevel:Float = 0;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var shadowLevel(get, set):Float;
	inline private function get_shadowLevel():Float {
		return _shadowLevel;
	}
	inline private function set_shadowLevel(value:Float):Float {
		_shadowLevel = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * In case of opacity Fresnel or reflection falloff, this is use as a scene center.
	 * It is usually zero but might be interesting to modify according to your setup.
	 */
	@serializeAsVector3()
	private var _sceneCenter:Vector3 = Vector3.Zero();
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var sceneCenter(get, set):Vector3;
	inline private function get_sceneCenter():Vector3 {
		return _sceneCenter;
	}
	inline private function set_sceneCenter(value:Vector3):Vector3 {
		_sceneCenter = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * This helps specifying that the material is falling off to the sky box at grazing angle.
	 * This helps ensuring a nice transition when the camera goes under the ground.
	 */
	@serialize()
	private var _opacityFresnel:Bool = true;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var opacityFresnel(get, set):Bool;
	inline private function get_opacityFresnel():Bool {
		return _opacityFresnel;
	}
	inline private function set_opacityFresnel(value:Bool):Bool {
		_opacityFresnel = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * This helps specifying that the material is falling off from diffuse to the reflection texture at grazing angle. 
	 * This helps adding a mirror texture on the ground.
	 */
	@serialize()
	private var _reflectionFresnel:Bool = false;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionFresnel(get, set):Bool;
	inline private function get_reflectionFresnel():Bool {
		return _reflectionFresnel;
	}
	inline private function set_reflectionFresnel(value:Bool):Bool {
		_reflectionFresnel = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * This helps specifying the falloff radius off the reflection texture from the sceneCenter.
	 * This helps adding a nice falloff effect to the reflection if used as a mirror for instance.
	 */
	@serialize()
	private var _reflectionFalloffDistance:Float = 0.0;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionFalloffDistance(get, set):Float;
	inline private function get_reflectionFalloffDistance():Float {
		return _reflectionFalloffDistance;
	}
	inline private function set_reflectionFalloffDistance(value:Float):Float {
		_reflectionFalloffDistance = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * This specifies the weight of the reflection against the background in case of reflection Fresnel.
	 */
	@serialize()
	private var _reflectionAmount:Float = 1.0;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionAmount(get, set):Float;
	inline private function get_reflectionAmount():Float {
		return _reflectionAmount;
	}
	inline private function set_reflectionAmount(value:Float):Float {
		_reflectionAmount = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * This specifies the weight of the reflection at grazing angle.
	 */
	@serialize()
	private var _reflectionReflectance0:Float = 0.5;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionReflectance0(get, set):Float;
	inline private function get_reflectionReflectance0():Float {
		return _reflectionReflectance0;
	}
	inline private function set_reflectionReflectance0(value:Float):Float {
		_reflectionReflectance0 = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * This specifies the weight of the reflection at a perpendicular point of view.
	 */
	@serialize()
	private var _reflectionReflectance90:Float = 0.5;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var reflectionReflectance90(get, set):Float;
	inline private function get_reflectionReflectance90():Float {
		return _reflectionReflectance90;
	}
	inline private function set_reflectionReflectance90(value:Float):Float {
		_reflectionReflectance90 = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Sets the reflection reflectance fresnel values according to the default standard
	 * empirically know to work well :-)
	 */
	public var reflectionStandardFresnelWeight(never, set):Float;
	private function set_reflectionStandardFresnelWeight(value:Float):Float {
		var reflectionWeight = value;
		
		if (reflectionWeight < 0.5) {
			reflectionWeight = reflectionWeight * 2.0;
			this.reflectionReflectance0 = BackgroundMaterial.standardReflectance0 * reflectionWeight;
			this.reflectionReflectance90 = BackgroundMaterial.standardReflectance90 * reflectionWeight;
		} 
		else {
			reflectionWeight = reflectionWeight * 2.0 - 1.0;
			this.reflectionReflectance0 = BackgroundMaterial.standardReflectance0 + (1.0 - BackgroundMaterial.standardReflectance0) * reflectionWeight;
			this.reflectionReflectance90 = BackgroundMaterial.standardReflectance90 + (1.0 - BackgroundMaterial.standardReflectance90) * reflectionWeight;
		}
		return value;
	}

	/**
	 * Helps to directly use the maps channels instead of their level.
	 */
	@serialize()
	private var _useRGBColor:Bool = true;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useRGBColor(get, set):Bool;
	inline private function get_useRGBColor():Bool {
		return _useRGBColor;
	}
	inline private function set_useRGBColor(value:Bool):Bool {
		_useRGBColor = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * This helps reducing the banding effect that could occur on the background.
	 */
	@serialize()
	private var _enableNoise:Bool = false;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var enableNoise(get, set):Bool;
	inline private function get_enableNoise():Bool {
		return _enableNoise;
	}
	inline private function set_enableNoise(value:Bool):Bool {
		_enableNoise = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}


	/**
	 * Number of Simultaneous lights allowed on the material.
	 */
	@serialize()
	private var _maxSimultaneousLights:Int = 4;
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var maxSimultaneousLights(get, set):Int;
	inline private function get_maxSimultaneousLights():Int {
		return _maxSimultaneousLights;
	}
	inline private function set_maxSimultaneousLights(value:Int):Int {
		_maxSimultaneousLights = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Default configuration related to image processing available in the Background Material.
	 */
	@serializeAsImageProcessingConfiguration()
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
	private var _imageProcessingObserver:Observer<ImageProcessingConfiguration> = null;

	/**
	 * Attaches a new image processing configuration to the PBR Material.
	 * @param configuration (if null the scene configuration will be use)
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
	inline private function get_cameraColorCurvesEnabled():Bool {
		return this.imageProcessingConfiguration.colorCurvesEnabled;
	}
	/**
	 * Sets wether the color curves effect is enabled.
	 */
	inline private function set_cameraColorCurvesEnabled(value:Bool):Bool {
		return this.imageProcessingConfiguration.colorCurvesEnabled = value;
	}

	public var cameraColorGradingEnabled(get, set):Bool;
	/**
	 * Gets wether the color grading effect is enabled.
	 */
	private inline function get_cameraColorGradingEnabled():Bool {
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
	inline private function get_cameraToneMappingEnabled():Bool {
		return this._imageProcessingConfiguration.toneMappingEnabled;
	}
	/**
	 * Sets wether tonemapping is enabled or not
	 */
	inline private function set_cameraToneMappingEnabled(value:Bool):Bool {
		return this._imageProcessingConfiguration.toneMappingEnabled = value;
	}

	public var cameraExposure(get, set):Float;
	/**
	 * The camera exposure used on this material.
	 * This property is here and not in the camera to allow controlling exposure without full screen post process.
	 * This corresponds to a photographic exposure.
	 */
	inline private function get_cameraExposure():Float {
		return this._imageProcessingConfiguration.exposure;
	}
	/**
	 * The camera exposure used on this material.
	 * This property is here and not in the camera to allow controlling exposure without full screen post process.
	 * This corresponds to a photographic exposure.
	 */
	inline private function set_cameraExposure(value:Float):Float {
		return this._imageProcessingConfiguration.exposure = value;
	}
	
	public var cameraContrast(get, set):Float;
	/**
	 * Gets The camera contrast used on this material.
	 */
	inline private function get_cameraContrast():Float {
		return this._imageProcessingConfiguration.contrast;
	}
	/**
	 * Sets The camera contrast used on this material.
	 */
	inline private function set_cameraContrast(value:Float):Float {
		return this._imageProcessingConfiguration.contrast = value;
	}
	
	public var cameraColorGradingTexture(get, set):BaseTexture;
	/**
	 * Gets the Color Grading 2D Lookup Texture.
	 */
	inline private function get_cameraColorGradingTexture():BaseTexture {
		return this._imageProcessingConfiguration.colorGradingTexture;
	}
	/**
	 * Sets the Color Grading 2D Lookup Texture.
	 */
	inline private function set_cameraColorGradingTexture(value:BaseTexture):BaseTexture {
		return this.imageProcessingConfiguration.colorGradingTexture = value;
	}

	public var cameraColorCurves(get, set):ColorCurves;
	/**
	 * The color grading curves provide additional color adjustmnent that is applied after any color grading transform (3D LUT). 
	 * They allow basic adjustment of saturation and small exposure adjustments, along with color filter tinting to provide white balance adjustment or more stylistic effects.
	 * These are similar to controls found in many professional imaging or colorist software. The global controls are applied to the entire image. For advanced tuning, extra controls are provided to adjust the shadow, midtone and highlight areas of the image; 
	 * corresponding to low luminance, medium luminance, and high luminance areas respectively.
	 */
	inline private function get_cameraColorCurves():ColorCurves {
		return this.imageProcessingConfiguration.colorCurves;
	}
	/**
	 * The color grading curves provide additional color adjustmnent that is applied after any color grading transform (3D LUT). 
	 * They allow basic adjustment of saturation and small exposure adjustments, along with color filter tinting to provide white balance adjustment or more stylistic effects.
	 * These are similar to controls found in many professional imaging or colorist software. The global controls are applied to the entire image. For advanced tuning, extra controls are provided to adjust the shadow, midtone and highlight areas of the image; 
	 * corresponding to low luminance, medium luminance, and high luminance areas respectively.
	 */
	inline private function set_cameraColorCurves(value:ColorCurves):ColorCurves {
		return this.imageProcessingConfiguration.colorCurves = value;
	}

	// Temp values kept as cache in the material.
	private var _renderTargets:SmartArray<RenderTargetTexture> = new SmartArray<RenderTargetTexture>(16);
	private var _reflectionControls:Vector4 = Vector4.Zero();
	

	/**
	 * constructor
	 * @param name The name of the material
	 * @param scene The scene to add the material to
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		// Setup the default processing configuration to the scene.
		this._attachImageProcessingConfiguration(null);
		
		this.getRenderTargetTextures = function():SmartArray<RenderTargetTexture> {
			this._renderTargets.reset();
			
			if (this._diffuseTexture != null && this._diffuseTexture.isRenderTarget) {
				this._renderTargets.push(cast this._diffuseTexture);
			}
			
			if (this._reflectionTexture != null && this._reflectionTexture.isRenderTarget) {
				this._renderTargets.push(cast this._reflectionTexture);
			}
			
			return this._renderTargets;
		};
	}

	/**
	 * The entire material has been created in order to prevent overdraw.
	 * @returns false
	 */
	override public function needAlphaTesting():Bool {
		return true;
	}

	/**
	 * The entire material has been created in order to prevent overdraw.
	 * @returns true if blending is enable
	 */
	override public function needAlphaBlending():Bool {
		return ((this.alpha < 0) || (this._diffuseTexture != null && this._diffuseTexture.hasAlpha));
	}

	/**
	 * Checks wether the material is ready to be rendered for a given mesh.
	 * @param mesh The mesh to render
	 * @param subMesh The submesh to check against
	 * @param useInstances Specify wether or not the material is used with instances
	 */
	override public function isReadyForSubMesh(mesh:AbstractMesh, subMesh:BaseSubMesh, useInstances:Bool = false):Bool { 
		if (subMesh.effect != null && this.isFrozen) {
			if (this._wasPreviouslyReady) {
				return true;
			}
		}
		
		if (subMesh._materialDefines == null) {
			subMesh._materialDefines = new BackgroundMaterialDefines();
		}
		
		var scene = this.getScene();
		var defines:BackgroundMaterialDefines = cast subMesh._materialDefines;
		if (!this.checkReadyOnEveryCall && subMesh.effect != null) {
			if (defines._renderId == scene.getRenderId()) {
				return true;
			}
		}
		
		var engine = scene.getEngine();
		
		// Lights
		MaterialHelper.PrepareDefinesForLights(scene, mesh, defines, false, this._maxSimultaneousLights);
		defines._needNormals = true;
		
		// Textures
		if (defines._areTexturesDirty) {
			defines._needUVs = false;
			if (scene.texturesEnabled) {
				if (scene.getEngine().getCaps().textureLOD) {
					defines.TEXTURELODSUPPORT = true;
				}
				
				if (this._diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					if (!this._diffuseTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					MaterialHelper.PrepareDefinesForMergedUV(this._diffuseTexture, defines, "DIFFUSE");
					defines.DIFFUSEHASALPHA = this._diffuseTexture.hasAlpha;
					defines.GAMMADIFFUSE = this._diffuseTexture.gammaSpace;
					defines.OPACITYFRESNEL = this._opacityFresnel;
				} 
				else {
					defines.DIFFUSE = false;
					defines.DIFFUSEHASALPHA = false;
					defines.GAMMADIFFUSE = false;
					defines.OPACITYFRESNEL = false;
				}
				
				var reflectionTexture = this._reflectionTexture;
				if (reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					if (!reflectionTexture.isReadyOrNotBlocking()) {
						return false;
					}
					
					defines.REFLECTION = true;
					defines.GAMMAREFLECTION = reflectionTexture.gammaSpace;
					defines.REFLECTIONBLUR = this._reflectionBlur > 0;
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
					
					if (this.reflectionFresnel) {
						defines.REFLECTIONFRESNEL = true;
						defines.REFLECTIONFALLOFF = this.reflectionFalloffDistance > 0;
						
						this._reflectionControls.x = this.reflectionAmount;
						this._reflectionControls.y = this.reflectionReflectance0;
						this._reflectionControls.z = this.reflectionReflectance90;
						this._reflectionControls.w = 1 / this.reflectionFalloffDistance;
					}
					else {
						defines.REFLECTIONFRESNEL = false;
						defines.REFLECTIONFALLOFF = false;
					}
				} 
				else {
					defines.REFLECTION = false;
					defines.REFLECTIONFALLOFF = false;
					defines.REFLECTIONBLUR = false;
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
					defines.REFLECTIONMAP_OPPOSITEZ = false;
					defines.LODINREFLECTIONALPHA = false;
					defines.GAMMAREFLECTION = false;
				}
			}
			
			defines.PREMULTIPLYALPHA = (this.alphaMode == Engine.ALPHA_PREMULTIPLIED || this.alphaMode == Engine.ALPHA_PREMULTIPLIED_PORTERDUFF);
			defines.USERGBCOLOR = this._useRGBColor;
			defines.NOISE = this._enableNoise;
		}
		
		if (defines._areImageProcessingDirty) {
			if (!this._imageProcessingConfiguration.isReady()) {
				return false;
			}
			
			this._imageProcessingConfiguration.prepareDefines(defines);
		}
		
		// Misc.
		MaterialHelper.PrepareDefinesForMisc(mesh, scene, false, this.pointsCloud, this.fogEnabled, this._shouldTurnAlphaTestOn(mesh), defines);
		
		// Values that need to be evaluated on every frame
		MaterialHelper.PrepareDefinesForFrameBoundValues(scene, engine, defines, useInstances);
		
		// Attribs
		if (MaterialHelper.PrepareDefinesForAttributes(mesh, defines, false, true, false)) {
			if (mesh != null) {
				if (!scene.getEngine().getCaps().standardDerivatives && !mesh.isVerticesDataPresent(VertexBuffer.NormalKind)) {
					mesh.createNormals(true);
					Tools.Warn("BackgroundMaterial: Normals have been created for the mesh: " + mesh.name);
				}
			}
		}
		
		// Get correct effect
		if (defines.isDirty) {
			defines.markAsProcessed();
			scene.resetCachedMaterial();
			
			// Fallbacks
			var fallbacks = new EffectFallbacks();
			if (defines.FOG) {
				fallbacks.addFallback(0, "FOG");
			}
			
			if (defines.POINTSIZE) {
				fallbacks.addFallback(1, "POINTSIZE");
			}
			
			MaterialHelper.HandleFallbacksForShadows(defines, fallbacks, this._maxSimultaneousLights);
			
			if (defines.NUM_BONE_INFLUENCERS > 0) {
				fallbacks.addCPUSkinningFallback(0, mesh);
			}
			
			//Attributes
			var attribs:Array<String> = [VertexBuffer.PositionKind];
			
			if (defines.NORMAL) {
				attribs.push(VertexBuffer.NormalKind);
			}
			
			if (defines.UV1) {
				attribs.push(VertexBuffer.UVKind);
			}
			
			if (defines.UV2) {
				attribs.push(VertexBuffer.UV2Kind);
			}
			
			MaterialHelper.PrepareAttributesForBones(attribs, mesh, defines.NUM_BONE_INFLUENCERS, fallbacks);
			MaterialHelper.PrepareAttributesForInstances(attribs, defines);
			
			var uniforms = [
				"world", "view", "viewProjection", "vEyePosition", "vLightsType", 
				"vFogInfos", "vFogColor", "pointSize",
				"vClipPlane", "mBones",
				
				"vPrimaryColor", "vSecondaryColor", "vTertiaryColor",
				"vReflectionInfos", "reflectionMatrix", "vReflectionMicrosurfaceInfos",
				
				"shadowLevel", "alpha",
				
				"vBackgroundCenter", "vReflectionControl",
				
				"vDiffuseInfos", "diffuseMatrix",
			];
			
			var samplers = ["diffuseSampler", "reflectionSampler", "reflectionSamplerLow", "reflectionSamplerHigh"];
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
			
			var onCompiled = function(effect:Effect) {
				if (this.onCompiled != null) {
					this.onCompiled(effect);
				}
				
				this.bindSceneUniformBuffer(effect, scene.getSceneUniformBuffer());
			};
			
			var join = defines.toString();
			subMesh.setEffect(scene.getEngine().createEffect("background", {
				attributes: attribs,
				uniformsNames: uniforms,
				uniformBuffersNames: uniformBuffers,
				samplers: samplers,
				defines: join,
				fallbacks: fallbacks,
				onCompiled: onCompiled,
				onError: this.onError,
				indexParameters: { maxSimultaneousLights: this._maxSimultaneousLights }
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

	/**
	 * Build the uniform buffer used in the material.
	 */
	public function buildUniformLayout() {
		// Order is important !
		this._uniformBuffer.addUniform("vPrimaryColor", 4);
		this._uniformBuffer.addUniform("vSecondaryColor", 4);
		this._uniformBuffer.addUniform("vTertiaryColor", 4);
		this._uniformBuffer.addUniform("vDiffuseInfos", 2);
		this._uniformBuffer.addUniform("vReflectionInfos", 2);
		this._uniformBuffer.addUniform("diffuseMatrix", 16);
		this._uniformBuffer.addUniform("reflectionMatrix", 16);
		this._uniformBuffer.addUniform("vReflectionMicrosurfaceInfos", 3);
		this._uniformBuffer.addUniform("pointSize", 1);
		this._uniformBuffer.addUniform("shadowLevel", 1);
		this._uniformBuffer.addUniform("alpha", 1);
		this._uniformBuffer.addUniform("vBackgroundCenter", 3);
		this._uniformBuffer.addUniform("vReflectionControl", 4);
		
		this._uniformBuffer.create();
	}

	/**
	 * Unbind the material.
	 */
	override public function unbind() {
		if (this._diffuseTexture != null && this._diffuseTexture.isRenderTarget) {
			this._uniformBuffer.setTexture("diffuseSampler", null);
		}
		
		if (this._reflectionTexture != null && this._reflectionTexture.isRenderTarget) {
			this._uniformBuffer.setTexture("reflectionSampler", null);
		}
		
		super.unbind();
	}

	/**
	 * Bind only the world matrix to the material.
	 * @param world The world matrix to bind.
	 */
	override public function bindOnlyWorldMatrix(world:Matrix) {
		this._activeEffect.setMatrix("world", world);
	}

	/**
	 * Bind the material for a dedicated submeh (every used meshes will be considered opaque).
	 * @param world The world matrix to bind.
	 * @param subMesh The submesh to bind for.
	 */
	override public function bindForSubMesh(world:Matrix, mesh:Mesh, subMesh:SubMesh) {
		var scene = this.getScene();
		
		var defines:BackgroundMaterialDefines = cast subMesh._materialDefines;
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
		
		// Bones
		MaterialHelper.BindBonesParameters(mesh, this._activeEffect);
		
		var mustRebind = this._mustRebind(scene, effect, mesh.visibility);
		if (mustRebind) {
			this._uniformBuffer.bindToEffect(effect, "Material");
			
			this.bindViewProjection(effect);
			
			var reflectionTexture = this._reflectionTexture;
			if (!this._uniformBuffer.useUbo || !this.isFrozen || !this._uniformBuffer.isSync) {
				// Texture uniforms
				if (scene.texturesEnabled) {
					if (this._diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
						this._uniformBuffer.updateFloat2("vDiffuseInfos", this._diffuseTexture.coordinatesIndex, this._diffuseTexture.level);
						MaterialHelper.BindTextureMatrix(this._diffuseTexture, this._uniformBuffer, "diffuse");
					}
					
					if (reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
						this._uniformBuffer.updateMatrix("reflectionMatrix", reflectionTexture.getReflectionTextureMatrix());
						this._uniformBuffer.updateFloat2("vReflectionInfos", reflectionTexture.level, this._reflectionBlur);
						
						this._uniformBuffer.updateFloat3("vReflectionMicrosurfaceInfos", 
							reflectionTexture.getSize().width, 
							reflectionTexture.lodGenerationScale,
							reflectionTexture.lodGenerationOffset);
					}
				}
				
				if (this.shadowLevel > 0) {
					this._uniformBuffer.updateFloat("shadowLevel", this.shadowLevel);
				}
				this._uniformBuffer.updateFloat("alpha", this.alpha);
				
				// Point size
				if (this.pointsCloud) {
					this._uniformBuffer.updateFloat("pointSize", this.pointSize);
				}
				
				this._uniformBuffer.updateColor4("vPrimaryColor", this._primaryColor, this._primaryLevel);
				this._uniformBuffer.updateColor4("vSecondaryColor", this._secondaryColor, this._secondaryLevel);
				this._uniformBuffer.updateColor4("vTertiaryColor", this._tertiaryColor, this._tertiaryLevel);
			}
			
			// Textures
			if (scene.texturesEnabled) {
				if (this._diffuseTexture != null && StandardMaterial.DiffuseTextureEnabled) {
					this._uniformBuffer.setTexture("diffuseSampler", this._diffuseTexture);
				}
				
				if (reflectionTexture != null && StandardMaterial.ReflectionTextureEnabled) {
					if (defines.REFLECTIONBLUR && defines.TEXTURELODSUPPORT) {
						this._uniformBuffer.setTexture("reflectionSampler", reflectionTexture);
					}
					else if (!defines.REFLECTIONBLUR) {
						this._uniformBuffer.setTexture("reflectionSampler", reflectionTexture);
					}
					else {
						this._uniformBuffer.setTexture("reflectionSampler", reflectionTexture._lodTextureMid != null ? reflectionTexture._lodTextureMid : reflectionTexture);
						this._uniformBuffer.setTexture("reflectionSamplerLow", reflectionTexture._lodTextureLow != null ? reflectionTexture._lodTextureLow : reflectionTexture);
						this._uniformBuffer.setTexture("reflectionSamplerHigh", reflectionTexture._lodTextureHigh != null ? reflectionTexture._lodTextureHigh : reflectionTexture);
					}
					
					if (defines.REFLECTIONFRESNEL) {
						this._uniformBuffer.updateFloat3("vBackgroundCenter", this.sceneCenter.x, this.sceneCenter.y, this.sceneCenter.z);
						this._uniformBuffer.updateFloat4("vReflectionControl", this._reflectionControls.x, this._reflectionControls.y, this._reflectionControls.z, this._reflectionControls.w);
					}
				}
			}
			
			// Clip plane
			MaterialHelper.BindClipPlane(this._activeEffect, scene);
			
			MaterialHelper.BindEyePosition(effect, scene);
		}
		
		if (mustRebind || !this.isFrozen) {
			if (scene.lightsEnabled) {
				MaterialHelper.BindLights(scene, mesh, this._activeEffect, false, this._maxSimultaneousLights, false);
			}
			
			// View
			this.bindView(effect);
			
			// Fog
			MaterialHelper.BindFogParameters(scene, mesh, this._activeEffect);
			
			// image processing
			this._imageProcessingConfiguration.bind(this._activeEffect);
		}
		
		this._uniformBuffer.update();
		
		this._afterBind(mesh);
	}

	/**
	 * Dispose the material.
	 * @forceDisposeEffect Force disposal of the associated effect.
	 * @forceDisposeTextures Force disposal of the associated textures.
	 */
	override public function dispose(forceDisposeEffect:Bool = false, forceDisposeTextures:Bool = false) {
		if (forceDisposeTextures) {
			if (this.diffuseTexture != null) {
				this.diffuseTexture.dispose();
			}
			if (this.reflectionTexture != null) {
				this.reflectionTexture.dispose();
			}
		}
		
		this._renderTargets.dispose();
		
		if (this._imageProcessingConfiguration != null && this._imageProcessingObserver != null) {
			this._imageProcessingConfiguration.onUpdateParameters.remove(this._imageProcessingObserver);
		}
		
		super.dispose(forceDisposeEffect);
	}

	/**
	 * Clones the material.
	 * @name The cloned name.
	 * @returns The cloned material.
	 */
	override public function clone(name:String, cloneChildren:Bool = false):BackgroundMaterial {
		//return SerializationHelper.Clone(() => new BackgroundMaterial(name, this.getScene()), this);
		return null;
	}

	/**
	 * Serializes the current material to its JSON representation.
	 * @returns The JSON representation.
	 */
	override public function serialize():Dynamic {
		/*var serializationObject = SerializationHelper.Serialize(this);
		serializationObject.customType = "BABYLON.BackgroundMaterial";
		return serializationObject;*/
		return null;
	}

	/**
	 * Gets the class name of the material
	 * @returns "BackgroundMaterial"
	 */
	override public function getClassName():String {
		return "BackgroundMaterial";
	}

	/**
	 * Parse a JSON input to create back a background material.
	 * @param source 
	 * @param scene 
	 * @param rootUrl 
	 * @returns the instantiated BackgroundMaterial.
	 */
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):BackgroundMaterial {
		//return SerializationHelper.Parse(() => new BackgroundMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
