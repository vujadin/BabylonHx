package com.babylonhx.materials;

/**
 * @author Krtolica Vujadin
 */
/**
 * Options to be used when creating an effect.
 */
typedef EffectCreationOptions = {
	
	/**
	 * Atrributes that will be used in the shader.
	 */
	@:optional var attributes:Array<String>;
	/**
	 * Uniform varible names that will be set in the shader.
	 */
	@:optional var uniformsNames:Array<String>;
	/**
	 * Uniform buffer varible names that will be set in the shader.
	 */
	@:optional var uniformBuffersNames:Array<String>;
	/**
	 * Sampler texture variable names that will be set in the shader.
	 */
	@:optional var samplers:Array<String>;
	/**
	 * Define statements that will be set in the shader.
	 */
	@:optional var defines:Dynamic;
	/**
	 * Possible fallbacks for this effect to improve performance when needed.
	 */
	@:optional var fallbacks:EffectFallbacks;
	/**
	 * Callback that will be called when the shader is compiled.
	 */
	@:optional var onCompiled:Effect->Void;
	/**
	 * Callback that will be called if an error occurs during shader compilation.
	 */
	@:optional var onError:Effect->String->Void;
	/**
	 * Parameters to be used with Babylons include syntax to iterate over an array (eg. {lights: 10})
	 */
	@:optional var indexParameters:Dynamic;
	/**
	 * Max number of lights that can be used in the shader.
	 */
	@:optional var maxSimultaneousLights:Int;
	/**
	 * See https://developer.mozilla.org/en-US/docs/Web/API/WebGL2RenderingContext/transformFeedbackVaryings
	 */
	@:optional var transformFeedbackVaryings:Array<String>;
	
}
