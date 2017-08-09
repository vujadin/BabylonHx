package com.babylonhx.lights.shadows;

import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.MaterialDefines;
import com.babylonhx.cameras.Camera;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.math.Matrix;

/**
 * @author Krtolica Vujadin
 */

/**
 * Interface to implement to create a shadow generator compatible with BJS.
 */
interface IShadowGenerator {
	
	function getShadowMap():RenderTargetTexture;
	function getShadowMapForRendering():RenderTargetTexture;

	function isReady(subMesh:SubMesh, useInstances:Bool):Bool;

	function prepareDefines(defines:MaterialDefines, lightIndex:Int):Void;
	function bindShadowLight(lightIndex:String, effect:Effect):Void;
	function getTransformMatrix():Matrix;

	function recreateShadowMap():Void;
	
	function forceCompilation(onCompiled:ShadowGenerator->Void, useInstances:Bool = false):Void;

	function serialize():Dynamic;
	function dispose():Void;
	
	// BHX	
	function getDarkness():Float;
	function getLight():IShadowLight;
	
	var blurScale(get, set):Float;
	var bias(get, set):Float;
	
}
