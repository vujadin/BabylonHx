package com.babylonhx.lights;

import com.babylonhx.lights.shadows.IShadowGenerator;
import com.babylonhx.materials.UniformBuffer;
import com.babylonhx.cameras.Camera;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.AbstractMesh;


/**
 * @author Krtolica Vujadin
 */
/**
 * Interface describing all the common properties and methods a shadow light needs to implement.
 * This helps both the shadow generator and materials to genrate the corresponding shadow maps
 * as well as binding the different shadow properties to the effects.
 */
@:expose('BABYLON.IShadowLight') interface IShadowLight {
	/**
	 * The light id in the scene (used in scene.findLighById for instance)
	 */
	var id:String;
	/**
	 * The position the shdow will be casted from.
	 */
	var position(get, set):Vector3;
	/**
	 * In 2d mode (needCube being false), the direction used to cast the shadow.
	 */
	var direction(get, set):Vector3;
	/**
	 * The transformed position. Position of the light in world space taking parenting in account.
	 */
	var transformedPosition:Vector3;
	/**
	 * The transformed direction. Direction of the light in world space taking parenting in account.
	 */
	var transformedDirection:Vector3;
	/**
	 * The friendly name of the light in the scene.
	 */
	var name:String;
	/**
	 * Defines the shadow projection clipping minimum z value.
	 */
	var shadowMinZ(get, set):Float;
	/**
	 * Defines the shadow projection clipping maximum z value.
	 */
	var shadowMaxZ(get, set):Float;

	/**
	 * Computes the transformed information (transformedPosition and transformedDirection in World space) of the current light
	 * @returns true if the information has been computed, false if it does not need to (no parenting)
	 */
	function computeTransformedInformation():Bool;
	
	/**
	 * Gets the scene the light belongs to.
	 * @returns The scene
	 */
	function getScene():Scene;

	/**
	 * Callback defining a custom Projection Matrix Builder.
	 * This can be used to override the default projection matrix computation.
	 */
	var customProjectionMatrixBuilder:Matrix->Array<AbstractMesh>->Matrix->Void;
	
	/**
	 * Sets the shadow projection matrix in parameter to the generated projection matrix.
	 * @param matrix The materix to updated with the projection information
	 * @param viewMatrix The transform matrix of the light
	 * @param renderList The list of mesh to render in the map
	 * @returns The current light
	 */
	function setShadowProjectionMatrix(matrix:Matrix, viewMatrix:Matrix, renderList:Array<AbstractMesh>):IShadowLight;
	
	/**
	 * Gets the current depth scale used in ESM.
	 * @returns The scale
	 */
	function getDepthScale():Float;

	/**
	 * Returns whether or not the shadow generation require a cube texture or a 2d texture.
	 * @returns true if a cube texture needs to be use
	 */
	function needCube():Bool;
	
	/**
	 * Detects if the projection matrix requires to be recomputed this frame.
	 * @returns true if it requires to be recomputed otherwise, false.
	 */
	function needProjectionMatrixCompute():Bool;
	
	/**
	 * Forces the shadow generator to recompute the projection matrix even if position and direction did not changed.
	 */
	function forceProjectionMatrixCompute():Void;

	/**
	 * Get the direction to use to render the shadow map. In case of cube texture, the face index can be passed.
	 * @param faceIndex The index of the face we are computed the direction to generate shadow
	 * @returns The set direction in 2d mode otherwise the direction to the cubemap face if needCube() is true
	 */
	function getShadowDirection(?faceIndex:Int):Vector3;
	
	/**
	 * Gets the minZ used for shadow according to both the scene and the light.
	 * @param activeCamera The camera we are returning the min for
	 * @returns the depth min z
	 */
	function getDepthMinZ(activeCamera:Camera):Float;
	
	/**
	 * Gets the maxZ used for shadow according to both the scene and the light.
	 * @param activeCamera The camera we are returning the max for
	 * @returns the depth max z
	 */
	function getDepthMaxZ(activeCamera:Camera):Float;
	
	// BHX
	function _markMeshesAsLightDirty():Void;
	var _shadowGenerator:IShadowGenerator;
	var shadowEnabled:Bool;
	var _uniformBuffer:UniformBuffer;
	
}
