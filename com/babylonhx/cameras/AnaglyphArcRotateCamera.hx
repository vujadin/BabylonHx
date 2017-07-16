package com.babylonhx.cameras;

import com.babylonhx.materials.Effect;
import com.babylonhx.postprocess.AnaglyphPostProcess;
import com.babylonhx.postprocess.PassPostProcess;
import com.babylonhx.math.Tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.AnaglyphArcRotateCamera') class AnaglyphArcRotateCamera extends ArcRotateCamera {
	
	private var _eyeSpace:Float;
	private var _leftCamera:ArcRotateCamera;
	private var _rightCamera:ArcRotateCamera;
	

	public function new(name:String, alpha:Float, beta:Float, radius:Float, target:Dynamic, eyeSpace:Float, scene:Scene) {
		super(name, alpha, beta, radius, target, scene);
		
		this._eyeSpace = Tools.ToRadians(eyeSpace);
		
		this._leftCamera = new ArcRotateCamera(name + "_left", alpha - this._eyeSpace, beta, radius, target, scene);
		this._rightCamera = new ArcRotateCamera(name + "_right", alpha + this._eyeSpace, beta, radius, target, scene);
		
		AnaglyphArcRotateCamera.buildCamera(this, name);
	}

	override public function _update() {
		this._updateCamera(this._leftCamera);
		this._updateCamera(this._rightCamera);
		
		this._leftCamera.alpha = this.alpha - this._eyeSpace;
		this._rightCamera.alpha = this.alpha + this._eyeSpace;
		
		super._update();
	}

	public function _updateCamera(camera:ArcRotateCamera) {
		camera.beta = this.beta;
		camera.radius = this.radius;
		
		camera.minZ = this.minZ;
		camera.maxZ = this.maxZ;
		
		camera.fov = this.fov;
		
		camera.target = this.target;
	}
	
	public static function buildCamera(that:Dynamic, name:String) {
        that._leftCamera.isIntermediate = true;
		
        that.subCameras.push(that._leftCamera);
        that.subCameras.push(that._rightCamera);
		
        that._leftTexture = new PassPostProcess(name + "_leftTexture", 1.0, that._leftCamera);
        that._anaglyphPostProcess = new AnaglyphPostProcess(name + "_anaglyph", 1.0, that._rightCamera);
		
        that._anaglyphPostProcess.onApply = function(effect:Effect) {
            effect.setTextureFromPostProcess("leftSampler", that._leftTexture);
        };
		
        that._update();
    }
	
}
