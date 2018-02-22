package com.babylonhx.particles.emittertypes;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Scalar;
import com.babylonhx.materials.Effect;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Particle emitter emitting particles from the inside of a box.
 * It emits the particles randomly between 2 given directions. 
 */
class BoxParticleEmitter implements IParticleEmitterType {
	
	/**
	 * Random direction of each particle after it has been emitted, between direction1 and direction2 vectors.
	 */
	public var direction1:Vector3 = new Vector3(0, 1.0, 0);
	/**
	 * Random direction of each particle after it has been emitted, between direction1 and direction2 vectors.
	 */
	public var direction2:Vector3 = new Vector3(0, 1.0, 0);

	/**
	 * Minimum box point around our emitter. Our emitter is the center of particles source, but if you want your particles to emit from more than one point, then you can tell it to do so.
	 */
	public var minEmitBox:Vector3 = new Vector3(-0.5, -0.5, -0.5);
	/**
	 * Maximum box point around our emitter. Our emitter is the center of particles source, but if you want your particles to emit from more than one point, then you can tell it to do so.
	 */
	public var maxEmitBox:Vector3 = new Vector3(0.5, 0.5, 0.5);
	
	
	/**
	 * Creates a new instance of @see BoxParticleEmitter
	 */
	public function new() {

	}

	/**
	 * Called by the particle System when the direction is computed for the created particle.
	 * @param emitPower is the power of the particle (speed)
	 * @param worldMatrix is the world matrix of the particle system
	 * @param directionToUpdate is the direction vector to update with the result
	 * @param particle is the particle we are computed the direction for
	 */
	public function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle) {
		var randX = Scalar.RandomRange(this.direction1.x, this.direction2.x);
		var randY = Scalar.RandomRange(this.direction1.y, this.direction2.y);
		var randZ = Scalar.RandomRange(this.direction1.z, this.direction2.z);
		
		Vector3.TransformNormalFromFloatsToRef(randX * emitPower, randY * emitPower, randZ * emitPower, worldMatrix, directionToUpdate);
	}

	/**
	 * Called by the particle System when the position is computed for the created particle.
	 * @param worldMatrix is the world matrix of the particle system
	 * @param positionToUpdate is the position vector to update with the result
	 * @param particle is the particle we are computed the position for
	 */
	public function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle) {
		var randX = Scalar.RandomRange(this.minEmitBox.x, this.maxEmitBox.x);
		var randY = Scalar.RandomRange(this.minEmitBox.y, this.maxEmitBox.y);
		var randZ = Scalar.RandomRange(this.minEmitBox.z, this.maxEmitBox.z);
		
		Vector3.TransformCoordinatesFromFloatsToRef(randX, randY, randZ, worldMatrix, positionToUpdate);
	}

	/**
	 * Clones the current emitter and returns a copy of it
	 * @returns the new emitter
	 */
	public function clone():BoxParticleEmitter {
		var newOne = new BoxParticleEmitter();
		
		//Tools.DeepCopy(this, newOne);
		
		return newOne;
	}

	/**
	 * Called by the {BABYLON.GPUParticleSystem} to setup the update shader
	 * @param effect defines the update shader
	 */        
	public function applyToShader(effect:Effect) {            
		effect.setVector3("direction1", this.direction1);
		effect.setVector3("direction2", this.direction2);
		effect.setVector3("minEmitBox", this.minEmitBox);
		effect.setVector3("maxEmitBox", this.maxEmitBox);
	}

	/**
	 * Returns a string to use to update the GPU particles update shader
	 * @returns a string containng the defines string
	 */
	public function getEffectDefines():String {
		return "#define BOXEMITTER";
	}

	/**
	 * Returns the string "BoxEmitter"
	 * @returns a string containing the class name
	 */
	public function getClassName():String {
		return "BoxEmitter";
	}   
	
	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */        
	public function serialize():Dynamic {
		var serializationObject:Dynamic = {};
		
		serializationObject.type = this.getClassName();
		serializationObject.direction1 = this.direction1.asArray();
		serializationObject.direction2 = this.direction2.asArray();
		serializationObject.minEmitBox = this.minEmitBox.asArray();
		serializationObject.maxEmitBox = this.maxEmitBox.asArray();
		
		return serializationObject;
	}

	/**
	 * Parse properties from a JSON object
	 * @param serializationObject defines the JSON object
	 */
	public function parse(serializationObject:Dynamic) {
		this.direction1.copyFrom(serializationObject.direction1);
		this.direction2.copyFrom(serializationObject.direction2);
		this.minEmitBox.copyFrom(serializationObject.minEmitBox);
		this.maxEmitBox.copyFrom(serializationObject.maxEmitBox);
	}
	
}
