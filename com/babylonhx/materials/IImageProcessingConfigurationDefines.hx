package com.babylonhx.materials;

/**
 * @author Krtolica Vujadin
 */

/**
 * Interface to follow in your material defines to integrate easily the
 * Image proccessing functions.
 */
interface IImageProcessingConfigurationDefines {
	
	var IMAGEPROCESSING:Int;
	var VIGNETTE:Int;
	var VIGNETTEBLENDMODEMULTIPLY:Int;
	var VIGNETTEBLENDMODEOPAQUE:Int;
	var TONEMAPPING:Int;
	var CONTRAST:Int;
	var EXPOSURE:Int;
	var COLORCURVES:Int;
	var COLORGRADING:Int;
	var COLORGRADING3D:Int;
	var SAMPLER3DGREENDEPTH:Int;
	var SAMPLER3DBGRMAP:Int;
	var IMAGEPROCESSINGPOSTPROCESS:Int;
	
	var FROMLINEARSPACE:Int;
  
}
