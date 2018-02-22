package com.babylonhx.postprocess;

import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.postprocess.renderpipeline.PostProcessRenderEffect;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Vector2;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * The depth of field effect applies a blur to objects that are closer or further from where the camera is focusing.
 */
class DepthOfFieldEffect extends PostProcessRenderEffect {

	private var _depthOfFieldPass:PassPostProcess;
	private var _circleOfConfusion:CircleOfConfusionPostProcess;
	private var _depthOfFieldBlurX:Array<DepthOfFieldBlurPostProcess>;
	private var _depthOfFieldBlurY:Array<DepthOfFieldBlurPostProcess>;
	private var _depthOfFieldMerge:DepthOfFieldMergePostProcess;

	/**
	 * The focal the length of the camera used in the effect
	 */
	public var focalLength(get, set):Float;
	inline function set_focalLength(value:Float):Float {
		return this._circleOfConfusion.focalLength = value;
	}
	inline function get_focalLength():Float {
		return this._circleOfConfusion.focalLength;
	}
	
	/**
	 * F-Stop of the effect's camera. The diamater of the resulting aperture can be computed by lensSize/fStop. (default: 1.4)
	 */
	public var fStop(get, set):Float;
	inline function set_fStop(value:Float):Float {
		return this._circleOfConfusion.fStop = value;
	}
	inline function get_fStop():Float {
		return this._circleOfConfusion.fStop;
	}
	
	/**
	 * Distance away from the camera to focus on in scene units/1000 (eg. millimeter). (default: 2000)
	 */
	public var focusDistance(get, set):Float;
	inline function set_focusDistance(value:Float):Float {
		return this._circleOfConfusion.focusDistance = value;
	}
	inline function get_focusDistance():Float {
		return this._circleOfConfusion.focusDistance;
	}
	
	/**
	 * Max lens size in scene units/1000 (eg. millimeter). Standard cameras are 50mm. (default: 50) The diamater of the resulting aperture can be computed by lensSize/fStop.
	 */
	public var lensSize(get, set):Float;
	inline function set_lensSize(value:Float):Float {
		return this._circleOfConfusion.lensSize = value;
	}
	inline function get_lensSize():Float {
		return this._circleOfConfusion.lensSize;
	}
	

	/**
	 * Creates a new instance of @see DepthOfFieldEffect
	 * @param scene The scene the effect belongs to.
	 * @param depthTexture The depth texture of the scene to compute the circle of confusion.
	 * @param pipelineTextureType The type of texture to be used when performing the post processing.
	 */
	public function new(scene:Scene, depthTexture:RenderTargetTexture, ?blurLevel:DepthOfFieldEffectBlurLevel, pipelineTextureType:Int = 0) {
		if (blurLevel == null) {
			blurLevel = DepthOfFieldEffectBlurLevel.Low;
		}
		super(scene.getEngine(), "depth of field", function() {
			// Circle of confusion value for each pixel is used to determine how much to blur that pixel
			this._circleOfConfusion = new CircleOfConfusionPostProcess("circleOfConfusion", depthTexture, 1, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, pipelineTextureType);
			// Capture circle of confusion texture
			this._depthOfFieldPass = new PassPostProcess("depthOfFieldPass", 1.0, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, pipelineTextureType);
			this._depthOfFieldPass.autoClear = false;
			
			// Create a pyramid of blurred images (eg. fullSize 1/4 blur, half size 1/2 blur, quarter size 3/4 blur, eith size 4/4 blur)
			// Blur the image but do not blur on sharp far to near distance changes to avoid bleeding artifacts 
			// See section 2.6.2 http://fileadmin.cs.lth.se/cs/education/edan35/lectures/12dof.pdf
			this._depthOfFieldBlurY = [];
			this._depthOfFieldBlurX = [];
			var blurCount = 1;
			var kernelSize = 15;
			switch (blurLevel) {
				case DepthOfFieldEffectBlurLevel.High:
					blurCount = 3;
					kernelSize = 51;
					
				case DepthOfFieldEffectBlurLevel.Medium:
					blurCount = 2;
					kernelSize = 31;
					
				default:
					kernelSize = 15;
					blurCount = 1;
			}
			var adjustedKernelSize = kernelSize / Math.pow(2, blurCount - 1);
			for (i in 0...blurCount) {
				var blurY = new DepthOfFieldBlurPostProcess("verticle blur", scene, new Vector2(0, 1.0), adjustedKernelSize, 1.0 / Math.pow(2, i), null, this._depthOfFieldPass, i == 0 ? this._circleOfConfusion : null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, pipelineTextureType);
				blurY.autoClear = false;
				var blurX = new DepthOfFieldBlurPostProcess("horizontal blur", scene, new Vector2(1.0, 0), adjustedKernelSize, 1.0 / Math.pow(2, i), null,  this._depthOfFieldPass, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, pipelineTextureType);
				blurX.autoClear = false;
				this._depthOfFieldBlurY.push(blurY);
				this._depthOfFieldBlurX.push(blurX);
			}
			
			// Merge blurred images with original image based on circleOfConfusion
			this._depthOfFieldMerge = new DepthOfFieldMergePostProcess("depthOfFieldMerge", this._circleOfConfusion, this._depthOfFieldPass, cast this._depthOfFieldBlurY.slice(1), 1, null, Texture.BILINEAR_SAMPLINGMODE, scene.getEngine(), false, pipelineTextureType);
			this._depthOfFieldMerge.autoClear = false;
			
			// Set all post processes on the effect.
			var effects = [this._circleOfConfusion, this._depthOfFieldPass];
			for (i in 0...this._depthOfFieldBlurX.length) {
				effects.push(this._depthOfFieldBlurY[i]);
				effects.push(this._depthOfFieldBlurX[i]);
			}
			effects.push(this._depthOfFieldMerge);
			return effects;
		}, true);
	}

	/**
	 * Disposes each of the internal effects for a given camera.
	 * @param camera The camera to dispose the effect on.
	 */
	public function disposeEffects(camera:Camera) {
		this._depthOfFieldPass.dispose(camera);
		this._circleOfConfusion.dispose(camera);
		for (element in this._depthOfFieldBlurX) {
			element.dispose(camera);
		}
		for (element in this._depthOfFieldBlurY) {
			element.dispose(camera);
		}
		this._depthOfFieldMerge.dispose(camera);
	}
	
}
