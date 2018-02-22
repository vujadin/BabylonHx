package com.babylonhx.particles;

import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.particles.emittertypes.IParticleEmitterType;

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
	var emitter:Dynamic;	// AbstractMesh | Vector3
	/**
	 * ID of the rendering group used by the Particle system to chose when to render.
	 */
	var renderingGroupId:Int = 0;
	/**
	 * The layer mask we are rendering the particles through.
	 */
	var layerMask:Int;
	
	/**
	 * The overall motion speed (0.01 is default update speed, faster updates = faster animation)
	 */
	var updateSpeed:Float;        

	/**
	 * The amount of time the particle system is running (depends of the overall update speed).
	 */
	var targetStopDuration:Float;        

	/**
	 * The texture used to render each particle. (this can be a spritesheet)
	 */
	var particleTexture:Texture;   
	
	/**
	 * Blend mode use to render the particle, it can be either ParticleSystem.BLENDMODE_ONEONE or ParticleSystem.BLENDMODE_STANDARD.
	 */
	var blendMode:Int;   
	
	/**
	 * Minimum life time of emitting particles.
	 */
	var minLifeTime:Float;
	/**
	 * Maximum life time of emitting particles.
	 */
	var maxLifeTime:Float;    

	/**
	 * Minimum Size of emitting particles.
	 */
	var minSize:Float;
	/**
	 * Maximum Size of emitting particles.
	 */
	var maxSize:Float;        
	
	/**
	 * Random color of each particle after it has been emitted, between color1 and color2 vectors.
	 */
	var color1:Color4;
	/**
	 * Random color of each particle after it has been emitted, between color1 and color2 vectors.
	 */
	var color2:Color4;  
	
	/**
	 * Color the particle will have at the end of its lifetime.
	 */
	var colorDead:Color4;
	
	/**
	 * The maximum number of particles to emit per frame until we reach the activeParticleCount value
	 */
	var emitRate:Int; 
	
	/**
	 * You can use gravity if you want to give an orientation to your particles.
	 */
	var gravity:Vector3;    

	/**
	 * Minimum power of emitting particles.
	 */
	var minEmitPower:Float;
	/**
	 * Maximum power of emitting particles.
	 */
	var maxEmitPower:Float;        

	/**
	 * The particle emitter type defines the emitter used by the particle system.
	 * It can be for example box, sphere, or cone...
	 */
	var particleEmitterType:IParticleEmitterType;        

	/**
	 * Gets the maximum number of particles active at the same time.
	 * @returns The max number of active particles.
	 */
	function getCapacity():Int;

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
	 * @returns the current number of particles
	 */
	function render():Int;
	
	/**
	 * Dispose the particle system and frees its associated resources.
	 * @param disposeTexture defines if the particule texture must be disposed as well (true by default)
	 */
	function dispose(disposeTexture:Bool = false):Void;
	
	/**
	 * Clones the particle system.
	 * @param name The name of the cloned object
	 * @param newEmitter The new emitter to use
	 * @returns the cloned particle system
	 */
	function clone(name:String, newEmitter:Dynamic):IParticleSystem;
	
	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */
	function serialize():Dynamic;
	
	/**
	 * Rebuild the particle system
	 */
	function rebuild():Void;

	/**
	 * Starts the particle system and begins to emit.
	 */
	function start():Void;

	/**
	 * Stops the particle system.
	 */
	function stop():Void;

	/**
	 * Remove all active particles
	 */
	function reset():Void;
	
	// BHx
	var __smartArrayFlags:Array<Int>;
  
}
