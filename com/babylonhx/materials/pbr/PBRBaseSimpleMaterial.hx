package com.babylonhx.materials.pbr;

import com.babylonhx.math.Color3;
import com.babylonhx.materials.textures.BaseTexture;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The Physically based simple base material of BJS.
 * 
 * This enables better naming and convention enforcements on top of the pbrMaterial.
 * It is used as the base class for both the specGloss and metalRough conventions.
 */
class PBRBaseSimpleMaterial extends PBRBaseMaterial {

	/**
	 * Number of Simultaneous lights allowed on the material.
	 */
	@serialize()
	//@expandToProperty(null)
	public var maxSimultaneousLights(get, set):Int;
	inline private function get_maxSimultaneousLights():Int {
		return _maxSimultaneousLights;
	}
	inline private function set_maxSimultaneousLights(value:Int):Int {
		return _maxSimultaneousLights = value;
	}

	/**
	 * If sets to true, disables all the lights affecting the material.
	 */
	@serialize()
	//@expandToProperty(null)
	public var disableLighting(get, set):Bool;
	inline private function get_disableLighting():Bool {
		return _disableLighting;
	}
	inline private function set_disableLighting(value:Bool):Bool {
		return _disableLighting = value;
	}

	/**
	 * Environment Texture used in the material (this is use for both reflection and environment lighting).
	 */
	@serializeAsTexture()
	//@expandToProperty(null, "_reflectionTexture")
	public var environmentTexture(get, set):BaseTexture;
	inline private function get_environmentTexture():BaseTexture {
		return _reflectionTexture;
	}
	inline private function set_environmentTexture(value:BaseTexture):BaseTexture {
		return _reflectionTexture = value;
	}

	/**
	 * If sets to true, x component of normal map value will invert (x = 1.0 - x).
	 */
	@serialize()
	//@expandToProperty(null)
	public var invertNormalMapX(get, set):Bool;
	inline private function get_invertNormalMapX():Bool {
		return _invertNormalMapX;
	}
	inline private function set_invertNormalMapX(value:Bool):Bool {
		return _invertNormalMapX = value;
	}

	/**
	 * If sets to true, y component of normal map value will invert (y = 1.0 - y).
	 */
	@serialize()
	//@expandToProperty(null)
	public var invertNormalMapY(get, set):Bool;
	inline private function get_invertNormalMapY():Bool {
		return _invertNormalMapY;
	}
	inline private function set_invertNormalMapY(value:Bool):Bool {
		return _invertNormalMapY = value;
	}

	/**
	 * Normal map used in the model.
	 */
	@serializeAsTexture()
	//@expandToProperty(null, "_bumpTexture")
	public var normalTexture(get, set):BaseTexture;
	inline private function get_normalTexture():BaseTexture {
		return _bumpTexture;
	}
	inline private function set_normalTexture(value:BaseTexture):BaseTexture {
		return _bumpTexture = value;
	}

	/**
	 * Emissivie color used to self-illuminate the model.
	 */
	@serializeAsColor3("emissive")
	//@expandToProperty(null)
	public var emissiveColor(get, set):Color3;
	inline private function get_emissiveColor():Color3 {
		return _emissiveColor;
	}
	inline private function set_emissiveColor(value:Color3):Color3 {
		return _emissiveColor = value;
	}

	/**
	 * Emissivie texture used to self-illuminate the model.
	 */
	@serializeAsTexture()
	//@expandToProperty(null)
	public var emissiveTexture(get, set):BaseTexture;
	inline private function get_emissiveTexture():BaseTexture {
		return _emissiveTexture;
	}
	inline private function set_emissiveTexture(value:BaseTexture):BaseTexture {
		return _emissiveTexture = value;
	}

	/**
	 * Occlusion Channel Strenght.
	 */
	@serialize()
	//@expandToProperty(null, "_ambientTextureStrength")
	public var occlusionStrength(get, set):Float;
	inline private function get_occlusionStrength():Float {
		return _ambientTextureStrength;
	}
	inline private function set_occlusionStrength(value:Float):Float {
		return _ambientTextureStrength = value;
	}

	/**
	 * Occlusion Texture of the material (adding extra occlusion effects).
	 */
	@serializeAsTexture()
	//@expandToProperty(null, "_ambientTexture")
	public var occlusionTexture(get, set):BaseTexture;
	inline private function get_occlusionTexture():BaseTexture {
		return _ambientTexture;
	}
	inline private function set_occlusionTexture(value:BaseTexture):BaseTexture {
		return _ambientTexture = value;
	}

	/**
	 * Defines the alpha limits in alpha test mode.
	 */
	@serialize()
	//@expandToProperty(null, "_alphaCutOff")
	public var alphaCutOff(get, set):Float;
	inline private function get_alphaCutOff():Float {
		return _alphaCutOff;
	}
	inline private function set_alphaCutOff(value:Float):Float {
		return _alphaCutOff = value;
	}

	public var _transparencyMode:Int = PBRMaterial.PBRMATERIAL_OPAQUE;
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
		this._transparencyMode = value;
		if (value == PBRMaterial.PBRMATERIAL_ALPHATESTANDBLEND) {
			this._forceAlphaTest = true;
		}
		else {
			this._forceAlphaTest = false;
		}
		return value;
	}

	/**
	 * Gets the current double sided mode.
	 */
	@serialize()
	public var doubleSided(get, set):Bool;
	inline private function get_doubleSided():Bool {
		return this._twoSidedLighting;
	}
	/**
	 * If sets to true and backfaceCulling is false, normals will be flipped on the backside.
	 */
	inline private function set_doubleSided(value:Bool):Bool {
		this._twoSidedLighting = value;
		this.backFaceCulling = !value;
		return value;
	}

	/**
	 * Specifies wether or not the alpha value of the albedo texture should be used.
	 */
	public function _shouldUseAlphaFromAlbedoTexture():Bool {
		return this._albedoTexture != null && this._albedoTexture.hasAlpha && this._transparencyMode != PBRMaterial.PBRMATERIAL_OPAQUE;
	}

	/**
	 * Specifies wether or not the meshes using this material should be rendered in alpha blend mode.
	 */
	public function needAlphaBlending():Bool {
		if (this._linkRefractionWithTransparency) {
			return false;
		}
		
		return (this.alpha < 1.0) || 
				(this._shouldUseAlphaFromAlbedoTexture() &&
					(this._transparencyMode == PBRMaterial.PBRMATERIAL_ALPHABLEND ||
						this._transparencyMode == PBRMaterial.PBRMATERIAL_ALPHATESTANDBLEND));
	}

	/**
	 * Specifies wether or not the meshes using this material should be rendered in alpha test mode.
	 */
	public function needAlphaTesting():Bool {
		if (this._linkRefractionWithTransparency) {
			return false;
		}
		
		return this._shouldUseAlphaFromAlbedoTexture() &&
			 this._transparencyMode == PBRMaterial.PBRMATERIAL_ALPHATEST;
	}

	/**
	 * Instantiates a new PBRMaterial instance.
	 * 
	 * @param name The material name
	 * @param scene The scene the material will be use in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this._useEmissiveAsIllumination = true;
		this._useAmbientInGrayScale = true;
		this._useScalarInLinearSpace = true;
	}
	
}
