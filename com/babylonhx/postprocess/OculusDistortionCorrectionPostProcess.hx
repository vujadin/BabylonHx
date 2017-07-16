package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;
/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.OculusDistortionCorrectionPostProcess') class OculusDistortionCorrectionPostProcess extends PostProcess {
	
	public var aspectRatio:Float;

	private var _isRightEye:Bool;
	private var _distortionFactors:Array<Float>;
	private var _postProcessScaleFactor:Float;
	private var _lensCenterOffset:Float;
	private var _scaleIn:Vector2;
	private var _scaleFactor:Vector2;
	private var _lensCenter:Vector2;


	public function new(name:String, camera:Camera, isRightEye:Bool, cameraSettings:Dynamic) {
		super(name, "oculusDistortionCorrection", [
			'LensCenter',
			'Scale',
			'ScaleIn',
			'HmdWarpParam'
		], null, cameraSettings.PostProcessScaleFactor, camera, Texture.BILINEAR_SAMPLINGMODE, null, null);

		this._isRightEye = isRightEye;
		this._distortionFactors = cameraSettings.DistortionK;
		this._postProcessScaleFactor = cameraSettings.PostProcessScaleFactor;
		this._lensCenterOffset = cameraSettings.LensCenterOffset;


	   this.onSizeChanged = function() {
			this.aspectRatio = this.width * .5 / this.height;
			this._scaleIn = new Vector2(2, 2 / this.aspectRatio);
			this._scaleFactor = new Vector2(.5 * (1 / this._postProcessScaleFactor), .5 * (1 / this._postProcessScaleFactor) * this.aspectRatio);
			this._lensCenter = new Vector2(this._isRightEye ? 0.5 - this._lensCenterOffset * 0.5 :0.5 + this._lensCenterOffset * 0.5, 0.5);
		};
		
		this.onApply = function(effect:Effect) {
			effect.setFloat2("LensCenter", this._lensCenter.x, this._lensCenter.y);
			effect.setFloat2("Scale", this._scaleFactor.x, this._scaleFactor.y);
			effect.setFloat2("ScaleIn", this._scaleIn.x, this._scaleIn.y);
			effect.setFloat4("HmdWarpParam", this._distortionFactors[0], this._distortionFactors[1], this._distortionFactors[2], this._distortionFactors[3]);
		};
	}
	
}
