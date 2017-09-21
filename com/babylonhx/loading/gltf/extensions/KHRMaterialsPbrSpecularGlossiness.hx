package com.babylonhx.loading.gltf.extensions;

import com.babylonhx.materials.Material;
import com.babylonhx.materials.pbr.PBRMaterial;
import com.babylonhx.math.Color3;

/**
 * ...
 * @author Krtolica Vujadin
 */
class KHRMaterialsPbrSpecularGlossiness extends GLTFLoaderExtension {

	public function new() {
		
	}
	
	public var name(get, never):String;
	inline private function get_name():String {
		return "KHR_materials_pbrSpecularGlossiness";
	}

	private function loadMaterial(loader:GLTFLoader, material:IGLTFMaterial, assign:Material->Bool->Void):Bool {
		if (material.extensions == null) {
			return false;
		}
		
		var properties:IKHRMaterialsPbrSpecularGlossiness = cast Reflect.getProperty(material.extensions, this.name);
		if (properties == null) {
			return false;
		}
		
		loader.createPbrMaterial(material);
		loader.loadMaterialBaseProperties(material);
		this._loadSpecularGlossinessProperties(loader, material, properties);
		assign(material.babylonMaterial, true);
		return true;
	}

	private function _loadSpecularGlossinessProperties(loader:GLTFLoader, material:IGLTFMaterial, properties:IKHRMaterialsPbrSpecularGlossiness) {
		var babylonMaterial:PBRMaterial = cast material.babylonMaterial;
		
		babylonMaterial.albedoColor = properties.diffuseFactor != null ? Color3.FromArray(properties.diffuseFactor) : new Color3(1, 1, 1);
		babylonMaterial.reflectivityColor = properties.specularFactor != null ? Color3.FromArray(properties.specularFactor) : new Color3(1, 1, 1);
		babylonMaterial.microSurface = properties.glossinessFactor == null ? 1 : properties.glossinessFactor;
		
		if (properties.diffuseTexture != null) {
			babylonMaterial.albedoTexture = loader.loadTexture(properties.diffuseTexture);
		}
		
		if (properties.specularGlossinessTexture != null) {
			babylonMaterial.reflectivityTexture = loader.loadTexture(properties.specularGlossinessTexture);
			babylonMaterial.reflectivityTexture.hasAlpha = true;
			babylonMaterial.useMicroSurfaceFromReflectivityMapAlpha = true;
		}
		
		loader.loadMaterialAlphaProperties(material, properties.diffuseFactor);
	}
	
}
