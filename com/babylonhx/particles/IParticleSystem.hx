package com.babylonhx.particles;

/**
 * @author Krtolica Vujadin
 */
/**
 * Interface representing a particle system in Babylon.
 * This groups the common functionalities that needs to be implemented in order to create a particle system.
 * A particle system represents a way to manage particles (@see Particle) from their emission to their animation and rendering.
 */
interface IParticleSystem extends ISmartArrayCompatible {
	
	/**
	 * The id of the Particle system.
	 */
	var id:String;
	/**
	 * The name of the Particle system.
	 */
	var name:String;
	/**
	 * The emitter represents the Mesh or position we are attaching the particle system to.
	 */
	var emitter:Dynamic;
	/**
	 * ID of the rendering group used by the Particle system to chose when to render.
	 */
	var renderingGroupId:Int = 0;
	/**
	 * The layer mask we are rendering the particles through.
	 */
	var layerMask:Int;
	
	/**
	 * Gets if the particle system has been started.
	 * @return true if the system has been started, otherwise false.
	 */
	function isStarted():Bool;
	/**
	 * Animates the particle system for this frame.
	 */
	function animate():Void;
	/**
	 * Renders the particle system in its current state.
	 * @returns the current number of particles.
	 */
	function render():Int;
	/**
	 * Dispose the particle system and frees its associated resources.
	 */
	function dispose():Void;
	/**
	 * Clones the particle system.
	 * @param name The name of the cloned object
	 * @param newEmitter The new emitter to use
	 * @returns the cloned particle system
	 */
	function clone(name:String, ?newEmitter:Dynamic):IParticleSystem;
	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */
	function serialize():Dynamic;
	/**
	 * Rebuild the particle system
	 */
	function rebuild():Void;
	
	// BHx
	var __smartArrayFlags:Array<Int>;
  
}
