package com.babylonhx.canvas2d;

/**
 * @author Krtolica Vujadin
 */

/**
 * This interface defines the IBrush2D contract.
 * Classes implementing a new type of Brush2D must implement this interface
 */
interface IBrush2D implements ILockable {
	
	/**
	 * Define if the brush will use transparency/alphablending
	 * @returns true if the brush use transparency
	 */
	function isTransparent():Bool;

	/**
	 * It is critical for each instance of a given Brush2D type to return a unique string that identifies it because the Border instance will certainly be part of the computed ModelKey for a given Primitive
	 * @returns A string identifier that uniquely identify the instance
	 */
	function toString():String;
	
}
	