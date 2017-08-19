package com.babylonhx.materials.pbr;

import com.babylonhx.materials.textures.BaseTexture;
import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The PBR material of BJS following the specular glossiness convention.
 * 
 * This fits to the define PBR convention in the GLTF definition: 
 * https://github.com/KhronosGroup/glTF/tree/2.0/extensions/Khronos/KHR_materials_pbrSpecularGlossiness
 */
class PBRSpecularGlossinessMaterial extends PBRBaseSimpleMaterial {

	/**
	 * Specifies the diffuse Color of the material.
	 */
	@serializeAsColor3("diffuse")
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_albedoColor")
	public var diffuseColor(get, set):Color3;
	inline private function get_diffuseColor():Color3 {
		return _albedoColor;
	}
	inline private function set_diffuseColor(value:Color3):Color3 {
		_markAllSubMeshesAsTexturesDirty();
		return _albedoColor = value;
	}
	
	/**
	 * Specifies the diffuse texture of the material. This can aslo contains the opcity value in its alpha
	 * channel.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_albedoTexture")
	public var diffuseTexture(get, set):BaseTexture;
	inline private function get_diffuseTexture():BaseTexture {
		return _albedoTexture;
	}
	inline private function set_diffuseTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _albedoTexture = value;
	}

	/**
	 * Specifies the specular color of the material. This indicates how reflective is the material (none to mirror).
	 */
	@serializeAsColor3("specular")
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_reflectivityColor")
	public var specularColor(get, set):Color3;
	inline private function get_specularColor():Color3 {
		return _reflectivityColor;
	}
	inline private function set_specularColor(value:Color3):Color3 {
		_markAllSubMeshesAsTexturesDirty();
		return _reflectivityColor;
	}

	/**
	 * Specifies the glossiness of the material. This indicates "how sharp is the reflection".
	 */
	@serialize()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_microSurface")
	public var glossiness(get, set):Float;
	inline private function get_glossiness():Float {
		return _microSurface;
	}
	inline private function set_glossiness(value:Float):Float {
		_markAllSubMeshesAsTexturesDirty();
		return _microSurface = value;
	}
	
	/**
	 * Spectifies both the specular color RGB and the glossiness A of the material per pixels.
	 */
	@serializeAsTexture()
	//@expandToProperty("_markAllSubMeshesAsTexturesDirty", "_reflectivityTexture")
	public var specularGlossinessTexture(get, set):BaseTexture;
	inline private function get_specularGlossinessTexture():BaseTexture {
		return _reflectivityTexture;
	}
	inline private function set_specularGlossinessTexture(value:BaseTexture):BaseTexture {
		_markAllSubMeshesAsTexturesDirty();
		return _reflectivityTexture = value;
	}
	

	/**
	 * Instantiates a new PBRSpecularGlossinessMaterial instance.
	 * 
	 * @param name The material name
	 * @param scene The scene the material will be use in.
	 */
	public function new(name:String, scene:Scene) {
		super(name, scene);
		this._useMicroSurfaceFromReflectivityMapAlpha = true;
	}
	
	/**
	 * Return the currrent class name of the material.
	 */
	override public function getClassName():String {
		return "PBRSpecularGlossinessMaterial";
	}
	
	/**
	 * Return the active textures of the material.
	 */
	public function getActiveTextures():Array<BaseTexture> {
		var activeTextures = super.getActiveTextures();
		
		if (this.diffuseTexture != null) {
			activeTextures.push(this.diffuseTexture);
		}
		
		if (this.specularGlossinessTexture != null) {
			activeTextures.push(this.specularGlossinessTexture);
		}
		
		return activeTextures;
	}

	public function hasTexture(texture:BaseTexture):Bool {
		if (super.hasTexture(texture)) {
			return true;
		}
		
		if (this.diffuseTexture == texture) {
			return true;
		}
		
		if (this.specularGlossinessTexture == texture) {
			return true;
		}
		
		return false;    
	}

	public function clone(name:String):PBRSpecularGlossinessMaterial {
		// VK TODO:
		//return SerializationHelper.Clone(() => new PBRSpecularGlossinessMaterial(name, this.getScene()), this);
		return null;
	}

	/**
	 * Serialize the material to a parsable JSON object.
	 */
	public function serialize():Dynamic {
		// VK TODO:
		//var serializationObject = SerializationHelper.Serialize(this);
		//serializationObject.customType = "BABYLON.PBRSpecularGlossinessMaterial";
		//return serializationObject;
		return null;
	}

	/**
	 * Parses a JSON object correponding to the serialize function.
	 */
	public static function Parse(source:Dynamic, scene:Scene, rootUrl:String):PBRSpecularGlossinessMaterial {
		//return SerializationHelper.Parse(() => new PBRSpecularGlossinessMaterial(source.name, scene), source, scene, rootUrl);
		return null;
	}
	
}
