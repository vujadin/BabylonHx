package com.babylonhx.postprocess;

import com.babylonhx.math.Vector2;
import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.VRCameraMetrics;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.materials.Effect;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Krtolica Vujadin
 */
class VRDistortionCorrectionPostProcess extends PostProcess {
	
	public var _aspectRatio:Float;

	private var _isRightEye:Bool;
	private var _distortionFactors:Array<Float>;
	private var _postProcessScaleFactor:Float;
	private var _lensCenterOffset:Float;
	private var _scaleIn:Vector2;
	private var _scaleFactor:Vector2;
	private var _lensCenter:Vector2;
	

	public function new(name:String, camera:Camera, isRightEye:Bool, vrMetrics:VRCameraMetrics) {
		super(name, "vrDistortionCorrection", [
			'LensCenter',
			'Scale',
			'ScaleIn',
			'HmdWarpParam'
		], null, vrMetrics.postProcessScaleFactor, camera, Texture.BILINEAR_SAMPLINGMODE, null, false);
		
		this._isRightEye = isRightEye;
		this._distortionFactors = vrMetrics.distortionK;
		this._postProcessScaleFactor = vrMetrics.postProcessScaleFactor;
		this._lensCenterOffset = vrMetrics.lensCenterOffset;
		
		this.onSizeChangedObservable.add(function(_, _) {
			this._aspectRatio = this.width * 0.5 / this.height;
			this._scaleIn = new Vector2(2, 2 / this.aspectRatio);
			this._scaleFactor = new Vector2(0.5 * (1 / this._postProcessScaleFactor), 0.5 * (1 / this._postProcessScaleFactor) * this.aspectRatio);
			this._lensCenter = new Vector2(this._isRightEye ? 0.5 - this._lensCenterOffset * 0.5 : 0.5 + this._lensCenterOffset * 0.5, 0.5);
		});
		
		this.onApplyObservable.add(function(effect:Effect, es:EventState = null) {
			effect.setFloat2("LensCenter", this._lensCenter.x, this._lensCenter.y);
			effect.setFloat2("Scale", this._scaleFactor.x, this._scaleFactor.y);
			effect.setFloat2("ScaleIn", this._scaleIn.x, this._scaleIn.y);
			effect.setFloat4("HmdWarpParam", this._distortionFactors[0], this._distortionFactors[1], this._distortionFactors[2], this._distortionFactors[3]);
		});
	}
	
}
