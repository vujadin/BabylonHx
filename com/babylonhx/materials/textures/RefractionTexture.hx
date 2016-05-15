package com.babylonhx.materials.textures;

import com.babylonhx.math.Plane;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
* Creates a refraction texture used by refraction channel of the standard material.
* @param name the texture name
* @param size size of the underlying texture
* @param scene root scene
*/ 
class RefractionTexture extends RenderTargetTexture {
	
	public var refractionPlane:Plane = new Plane(0, 1, 0, 1);
	public var depth:Float = 2.0;
	

	public function new(name:String, size:Int, scene:Scene, generateMipMaps:Bool = true) {
		super(name, size, scene, generateMipMaps, true);
		
		this.onBeforeRenderObservable.add(function(val:Int, eventState:EventState = null) {
			scene.clipPlane = this.refractionPlane;
		});
		
		this.onAfterRenderObservable.add(function(val:Int, eventState:EventState = null) {
			scene.clipPlane = null;
		});
	}
	
	override public function clone():RefractionTexture {
		var textureSize = this.getSize();
		var newTexture = new RefractionTexture(this.name, textureSize.width, this.getScene(), this._generateMipMaps);
		
		// Base texture
		newTexture.hasAlpha = this.hasAlpha;
		newTexture.level = this.level;
		
		// Refraction Texture
		newTexture.refractionPlane = this.refractionPlane.clone();
		newTexture.renderList = this.renderList.slice(0);
		newTexture.depth = this.depth;
		
		return newTexture;
	}

	override public function serialize():Dynamic {
		if (this.name == null) {
			return null;
		}
		
		var serializationObject = super.serialize();
		
		serializationObject.mirrorPlane = this.refractionPlane.asArray();
		serializationObject.depth = this.depth;
		
		return serializationObject;
	}
	
}
