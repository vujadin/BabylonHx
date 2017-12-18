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
	//@expandToProperty("_markAllSubMeshesAsLightsDirty")
	public var maxSimultaneousLights(get, set):Int;
	inline private function get_maxSimultaneousLights():Int {
		return _maxSimultaneousLights;
	}
	inline private function set_maxSimultaneousLights(value:Int):Int {
		_markAllSubMeshesAsLightsDirty();
		return _maxSimultaneousLights = value;
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
		this._disableLighting = value;
		_markAllSubMeshesAsLightsDirty();
		return value;
	}

	/**
	 * Environment Texture used in the material (this is use for both reflection and environment lighting).
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_reflectionTexture")
	public var environmentTexture(get, set):BaseTexture;
	inline private function get_environmentTexture():BaseTexture {
		return _reflectionTexture;
	}
	inline private function set_environmentTexture(value:BaseTexture):BaseTexture {
		this._reflectionTexture = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
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
		this._invertNormalMapX = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
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
		this._invertNormalMapY = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Normal map used in the model.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_bumpTexture")
	public var normalTexture(get, set):BaseTexture;
	inline private function get_normalTexture():BaseTexture {
		return _bumpTexture;
	}
	inline private function set_normalTexture(value:BaseTexture):BaseTexture {
		this._bumpTexture = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Emissivie color used to self-illuminate the model.
	 */
	@serializeAsColor3("emissive")
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var emissiveColor(get, set):Color3;
	inline private function get_emissiveColor():Color3 {
		return _emissiveColor;
	}
	inline private function set_emissiveColor(value:Color3):Color3 {
		this._emissiveColor = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Emissivie texture used to self-illuminate the model.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var emissiveTexture(get, set):BaseTexture;
	inline private function get_emissiveTexture():BaseTexture {
		return _emissiveTexture;
	}
	inline private function set_emissiveTexture(value:BaseTexture):BaseTexture {
		this._emissiveTexture = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Occlusion Channel Strenght.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_ambientTextureStrength")
	public var occlusionStrength(get, set):Float;
	inline private function get_occlusionStrength():Float {
		return _ambientTextureStrength;
	}
	inline private function set_occlusionStrength(value:Float):Float {
		this._ambientTextureStrength = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Occlusion Texture of the material (adding extra occlusion effects).
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_ambientTexture")
	public var occlusionTexture(get, set):BaseTexture;
	inline private function get_occlusionTexture():BaseTexture {
		return _ambientTexture;
	}
	inline private function set_occlusionTexture(value:BaseTexture):BaseTexture {
		this._ambientTexture = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	/**
	 * Defines the alpha limits in alpha test mode.
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_alphaCutOff")
	public var alphaCutOff(get, set):Float;
	inline private function get_alphaCutOff():Float {
		return _alphaCutOff;
	}
	inline private function set_alphaCutOff(value:Float):Float {
		this._alphaCutOff = value;
		_markAllSubMeshesAsTexturesDirty();
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
		if (this._twoSidedLighting == value) {
			return;
		}
		this._twoSidedLighting = value;
		this.backFaceCulling = !value;
		this._markAllSubMeshesAsTexturesDirty();
		return value;
	}
	
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", null)
	public var lightmapTexture(get, set):BaseTexture;
	inline private function get_lightmapTexture():BaseTexture {
		return _lightmapTexture;
	}
	inline private function set_lightmapTexture(value:BaseTexture):BaseTexture {
		this._lightmapTexture = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}

	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty")
	public var useLightmapAsShadowmap(get, set):Bool;
	inline private function get_useLightmapAsShadowmap():Bool {
		return _useLightmapAsShadowmap;
	}
	inline private function set_useLightmapAsShadowmap(value:Bool):Bool {
		this._useLightmapAsShadowmap = value;
		_markAllSubMeshesAsTexturesDirty();
		return value;
	}
	
	/**
	 * Return the active textures of the material.
	 */
	public function getActiveTextures():Array<BaseTexture> {
		var activeTextures = super.getActiveTextures();
		
		if (this.environmentTexture != null) {
			activeTextures.push(this.environmentTexture);
		}
		
		if (this.normalTexture != null) {
			activeTextures.push(this.normalTexture);
		}
		
		if (this.emissiveTexture != null) {
			activeTextures.push(this.emissiveTexture);
		}
		
		if (this.occlusionTexture != null) {
			activeTextures.push(this.occlusionTexture);
		}
		
		if (this.lightmapTexture != null) {
            activeTextures.push(this.lightmapTexture);
        }
		
		return activeTextures;
	}
	
	public function hasTexture(texture:BaseTexture):Bool {
		if (super.hasTexture(texture)) {
			return true;
		}
		
		if (this.lightmapTexture == texture) {
			return true;
		}
		
		return false;
	}

	/**
	 * Instantiates a new PBRMaterial instance.
	 * 
	 * @param name The material name
	 * @param scene The scene the material will be use in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		
		this._useAlphaFromAlbedoTexture = true;
		this._useAmbientInGrayScale = true;
	}
	
	override public function getClassName():String {
		return "PBRBaseSimpleMaterial";
	}
	
}
