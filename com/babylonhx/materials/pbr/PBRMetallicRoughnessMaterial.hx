package com.babylonhx.materials.pbr;

import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The PBR material of BJS following the metal roughness convention.
 * 
 * This fits to the define PBR convention in the GLTF definition: 
 * https://github.com/KhronosGroup/glTF/tree/2.0/specification/2.0
 */
class PBRMetallicRoughnessMaterial extends PBRBaseSimpleMaterial {

	/**
	 * The base color has two different interpretations depending on the value of metalness. 
	 * When the material is a metal, the base color is the specific measured reflectance value 
	 * at normal incidence (F0). For a non-metal the base color represents the reflected diffuse color 
	 * of the material.
	 */
	@serializeAsColor3()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_albedoColor")
	public var baseColor(get, set):Color3;
	inline private function get_baseColor():Color3 {
		return _albedoColor;
	}
	inline private function set_baseColor(value:Color3):Color3 {
		_markAllSubMeshesAsTexturesDirty();
		return _albedoColor = value;
	}
	
	/**
	 * Base texture of the metallic workflow. It contains both the baseColor information in RGB as
	 * well as opacity information in the alpha channel.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_albedoTexture")
	public var baseTexture(get, set):BaseTexture;
	inline private function get_baseTexture():BaseTexture {
		return _albedoTexture;
	}
	inline private function set_baseTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _albedoTexture = value;
	}

	/**
	 * Specifies the metallic scalar value of the material.
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
		return _metallic;
	}

	/**
	 * Specifies the roughness scalar value of the material.
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
	 * Texture containing both the metallic value in the B channel and the 
	 * roughness value in the G channel to keep better precision.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_metallicTexture")
	public var metallicRoughnessTexture(get, set):BaseTexture;
	inline private function get_metallicRoughnessTexture():BaseTexture {
		return _metallicTexture;
	}
	inline private function set_metallicRoughnessTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _metallicTexture = value;
	}

	/**
	 * Instantiates a new PBRMetalRoughnessMaterial instance.
	 * 
	 * @param name The material name
	 * @param scene The scene the material will be use in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		this._useRoughnessFromMetallicTextureAlpha = false;
		this._useRoughnessFromMetallicTextureGreen = true;
		this._useMetallnessFromMetallicTextureBlue = true;
	}

	/**
	 * Return the currrent class name of the material.
	 */
	override public function getClassName():String {
		return "PBRMetallicRoughnessMaterial";
	}
	
	/**
	 * Return the active textures of the material.
	 */
	public function getActiveTextures():Array<BaseTexture> {
		var activeTextures = super.getActiveTextures();
		
		if (this.baseTexture != null) {
			activeTextures.push(this.baseTexture);
		}
		
		if (this.metallicRoughnessTexture != null) {
			activeTextures.push(this.metallicRoughnessTexture);
		}
		
		return activeTextures;
	}

	public function hasTexture(texture:BaseTexture):Bool {
		if (super.hasTexture(texture)) {
			return true;
		}
		
		if (this.baseTexture == texture) {
			return true;
		}
		
		if (this.metallicRoughnessTexture == texture) {
			return true;
		}  
		
		return false;    
	}
	
	public function clone(name:String):PBRMetallicRoughnessMaterial {
		// VK TODO:
		//return SerializationHelper.Clone(() => new PBRMetallicRoughnessMaterial(name, this.getScene()), this);
		return null;
	}

	/**
	 * Serialize the material to a parsable JSON object.
	 */
	public function serialize():Dynamic {
		// VK TODO:
		//var serializationObject = SerializationHelper.Serialize(this);
		//serializationObject.customType = "BABYLON.PBRMetallicRoughnessMaterial";
		//return serializationObject;
		return null;
	}

	/**
	 * Parses a JSON object correponding to the serialize function.
	 */
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):PBRMetallicRoughnessMaterial {
		// VK TODO:
		//return SerializationHelper.Parse(() => new PBRMetallicRoughnessMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
