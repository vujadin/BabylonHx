package com.babylonhx.tools.hdr;

/**
 * @author Krtolica Vujadin
 */

/**
 * Header information of HDR texture files.
 */
typedef HDRInfo = {
	
	/**
	 * The height of the texture in pixels.
	 */
	var height:Int;
	
	/**
	 * The width of the texture in pixels.
	 */
	var width:Int;
	
	/**
	 * The index of the beginning of the data in the binary file.
	 */
	var dataPosition:Int;  
	
}
