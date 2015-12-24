package com.babylonhx.cameras;

import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.VRCameraMetrics') class VRCameraMetrics {
	public var hResolution:Int;
	public var vResolution:Int;
	public var hScreenSize:Float;
	public var vScreenSize:Float;
	public var vScreenCenter:Float;
	public var eyeToScreenDistance:Float;
	public var lensSeparationDistance:Float;
	public var interpupillaryDistance:Float;
	public var distortionK:Array<Float>;
	public var chromaAbCorrection:Array<Float>;
	public var postProcessScaleFactor:Float;
	public var lensCenterOffset:Float;
	public var compensateDistortion:Bool = true;
	
	// VK: these return null ??
	/*public var aspectRatio(get, never):Float;
	public var aspectRatioFov(get, never):Float;*/
	public var leftHMatrix(get, never):Matrix;
	public var rightHMatrix(get, never):Matrix;
	public var leftPreViewMatrix(get, never):Matrix;
	public var rightPreViewMatrix(get, never):Matrix;
	
	
	public function new() {
		//...
	}

	public function aspectRatio():Float {
		return this.hResolution / (2 * this.vResolution);
	}

	public function aspectRatioFov():Float {
		return (2 * Math.atan((this.postProcessScaleFactor * this.vScreenSize) / (2 * this.eyeToScreenDistance)));
	}

	private function get_leftHMatrix():Matrix {
		var meters = (this.hScreenSize / 4) - (this.lensSeparationDistance / 2);
		var h = (4 * meters) / this.hScreenSize;
		
		return Matrix.Translation(h, 0, 0);
	}

	private function get_rightHMatrix():Matrix {
		var meters = (this.hScreenSize / 4) - (this.lensSeparationDistance / 2);
		var h = (4 * meters) / this.hScreenSize;
		
		return Matrix.Translation(-h, 0, 0);
	}

	private function get_leftPreViewMatrix():Matrix {
		return Matrix.Translation(0.5 * this.interpupillaryDistance, 0, 0);
	}

	private function get_rightPreViewMatrix():Matrix {
		return Matrix.Translation(-0.5 * this.interpupillaryDistance, 0, 0);
	}

	public static function GetDefault():VRCameraMetrics {
		var result = new VRCameraMetrics();
		
		result.hResolution = 1280;
		result.vResolution = 800;
		result.hScreenSize = 0.149759993;
		result.vScreenSize = 0.0935999975;
		result.vScreenCenter = 0.0467999987;
		result.eyeToScreenDistance = 0.0410000011;
		result.lensSeparationDistance = 0.0635000020;
		result.interpupillaryDistance = 0.0640000030;
		result.distortionK = [1.0, 0.219999999, 0.239999995, 0.0];
		result.chromaAbCorrection = [0.995999992, -0.00400000019, 1.01400006, 0.0];
		result.postProcessScaleFactor = 1.714605507808412;
		result.lensCenterOffset = 0.151976421;
		
		return result;
	}
	
}
