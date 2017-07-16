package com.babylonhx.postprocess;

import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.textures.Texture;

/**
 * ...
 * @author Krtolica Vujadin
 */

/*
 *  This post-process allows the modification of rendered colors by using
 *  a 'look-up table' (LUT). This effect is also called Color Grading.
 * 
 *  The object needs to be provided an url to a texture containing the color
 *  look-up table: the texture must be 256 pixels wide and 16 pixels high.
 *  Use an image editing software to tweak the LUT to match your needs.
 * 
 *  For an example of a color LUT, see here:
 *      http://udn.epicgames.com/Three/rsrc/Three/ColorGrading/RGBTable16x1.png
 *  For explanations on color grading, see here:
 *      http://udn.epicgames.com/Three/ColorGrading.html
 */
class ColorCorrectionPostProcess extends PostProcess {
	
	private var _colorTableTexture:Texture;
	

	public function new(name:String, colorTableUrl:String, options:Dynamic, camera:Camera, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, ?engine:Engine, reusable:Bool = false) {
		super(name, 'colorCorrection', null, ['colorTable'], ratio, options, samplingMode, engine, reusable);
		
		this._colorTableTexture = new Texture(colorTableUrl, camera.getScene(), true, false, Texture.TRILINEAR_SAMPLINGMODE);
		this._colorTableTexture.anisotropicFilteringLevel = 1;
		this._colorTableTexture.wrapU = Texture.CLAMP_ADDRESSMODE;
		this._colorTableTexture.wrapV = Texture.CLAMP_ADDRESSMODE;
		
		this.onApply = function(effect:Effect) {
			effect.setTexture("colorTable", this._colorTableTexture);
		};		
	}
	
}
