package com.babylonhx.particles.emittertypes;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.Effect;

/**
 * @author Krtolica Vujadin
 */
/**
 * Particle emitter represents a volume emitting particles.
 * This is the responsibility of the implementation to define the volume shape like cone/sphere/box.
 */
interface IParticleEmitterType {
	
	/**
	 * Called by the particle System when the direction is computed for the created particle.
	 * @param emitPower is the power of the particle (speed)
	 * @param worldMatrix is the world matrix of the particle system
	 * @param directionToUpdate is the direction vector to update with the result
	 * @param particle is the particle we are computed the direction for
	 */
	function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle):Void;
	
	/**
	 * Called by the particle System when the position is computed for the created particle.
	 * @param worldMatrix is the world matrix of the particle system
	 * @param positionToUpdate is the position vector to update with the result
	 * @param particle is the particle we are computed the position for
	 */
    function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle):Void;
	
	/**
     * Clones the current emitter and returns a copy of it
     * @returns the new emitter
     */
    function clone():IParticleEmitterType;
	
	/**
	 * Called by the {BABYLON.GPUParticleSystem} to setup the update shader
	 * @param effect defines the update shader
	 */
	function applyToShader(effect:Effect):Void;

	/**
	 * Returns a string to use to update the GPU particles update shader
	 * @returns the effect defines string
	 */
	function getEffectDefines():String;

	/**
	 * Returns a string representing the class name
	 * @returns a string containing the class name
	 */
	function getClassName():String;

	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */        
	function serialize():Dynamic;

	/**
	 * Parse properties from a JSON object
	 * @param serializationObject defines the JSON object
	 */
	function parse(serializationObject:Dynamic):Void;
  
}
