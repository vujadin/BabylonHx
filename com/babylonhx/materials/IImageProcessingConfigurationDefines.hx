package com.babylonhx.materials;

/**
 * @author Krtolica Vujadin
 */

/**
 * Interface to follow in your material defines to integrate easily the
 * Image proccessing functions.
 */
interface IImageProcessingConfigurationDefines {
	
	var IMAGEPROCESSING:Bool;
	var VIGNETTE:Bool;
	var VIGNETTEBLENDMODEMULTIPLY:Bool;
	var VIGNETTEBLENDMODEOPAQUE:Bool;
	var TONEMAPPING:Bool;
	var CONTRAST:Bool;
	var EXPOSURE:Bool;
	var COLORCURVES:Bool;
	var COLORGRADING:Bool;
	var SAMPLER3DGREENDEPTH:Bool;
	var SAMPLER3DBGRMAP:Bool;
	var IMAGEPROCESSINGPOSTPROCESS:Bool;
	
	var FROMLINEARSPACE:Bool;
  
}
