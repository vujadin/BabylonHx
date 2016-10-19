package com.babylonhx;

import com.babylonhx.cameras.Camera;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * This class is used by the onRenderingGroupObservable
 */
class RenderingGroupInfo {
	
	/**
	 * Stage corresponding to the very first hook in the renderingGroup phase: before the render buffer may be cleared
	 * This stage will be fired no matter what
	 */
	static public inline var STAGE_PRECLEAR:Int = 1;

	/**
	 * Called before opaque object are rendered.
	 * This stage will be fired only if there's 3D Opaque content to render
	 */
	static public inline var STAGE_PREOPAQUE:Int = 2;

	/**
	 * Called after the opaque objects are rendered and before the transparent ones
	 * This stage will be fired only if there's 3D transparent content to render
	 */
	static public inline var STAGE_PRETRANSPARENT:Int = 3;

	/**
	 * Called after the transparent object are rendered, last hook of the renderingGroup phase
	 * This stage will be fired no matter what
	 */
	static public inline var STAGE_POSTTRANSPARENT:Int = 4;
	
	
	/**
	 * The Scene that being rendered
	 */
	public var scene:Scene;

	/**
	 * The camera currently used for the rendering pass
	 */
	public var camera:Camera;

	/**
	 * The ID of the renderingGroup being processed
	 */
	public var renderingGroupId:Int;

	/**
	 * The rendering stage, can be either STAGE_PRECLEAR, STAGE_PREOPAQUE, STAGE_PRETRANSPARENT, STAGE_POSTTRANSPARENT
	 */
	public var renderStage:Int;

	
	public function new() {
		// ...
	}
	
}
