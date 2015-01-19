package com.babylonhx.materials.textures;

import com.babylonhx.math.Plane;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.MirrorTexture') class MirrorTexture extends RenderTargetTexture {
	
	public var mirrorPlane = new Plane(0, 1, 0, 1);

	private var _transformMatrix:Matrix = Matrix.Zero();
	private var _mirrorMatrix:Matrix = Matrix.Zero();
	private var _savedViewMatrix:Matrix;
	

	public function new(name:String, size:Int, scene:Scene, ?generateMipMaps:Bool) {
		super(name, size, scene, generateMipMaps, true);
		
		this.onBeforeRender = function() {
			Matrix.ReflectionToRef(this.mirrorPlane, this._mirrorMatrix);
			this._savedViewMatrix = scene.getViewMatrix();
			
			this._mirrorMatrix.multiplyToRef(this._savedViewMatrix, this._transformMatrix);
			
			scene.setTransformMatrix(this._transformMatrix, scene.getProjectionMatrix());
			
			scene.clipPlane = this.mirrorPlane;
			
			scene.getEngine().cullBackFaces = false;
		}
		
		this.onAfterRender = function() {
			scene.setTransformMatrix(this._savedViewMatrix, scene.getProjectionMatrix());
			scene.getEngine().cullBackFaces = true;
			
			scene.clipPlane = null;
		}
	}

	override public function clone():MirrorTexture {
		var textureSize = this.getSize();
		var newTexture = new MirrorTexture(this.name, textureSize.width, this.getScene(), this._generateMipMaps);
		
		// Base texture
		newTexture.hasAlpha = this.hasAlpha;
		newTexture.level = this.level;
		
		// Mirror Texture
		newTexture.mirrorPlane = this.mirrorPlane.clone();
		newTexture.renderList = this.renderList.slice(0);
		
		return newTexture;
	}
	
}
