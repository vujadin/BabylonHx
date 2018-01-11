package com.babylonhx.animations;

/**
 * @author Krtolica Vujadin
 */
@:expose('BABYLON.IAnimationKey') typedef IAnimationKey = {
	
	frame:Int,
	value:Dynamic,			// Vector3 or Quaternion or Matrix or Float or Color3 or Vector2
	?outTangent:Dynamic,
	?inTangent:Dynamic,
	?interpolation:AnimationKeyInterpolation
	
}
