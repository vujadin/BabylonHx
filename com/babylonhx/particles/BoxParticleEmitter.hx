package com.babylonhx.particles;

import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Scalar;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Particle emitter emitting particles from the inside of a box.
 * It emits the particles randomly between 2 given directions. 
 */
class BoxParticleEmitter implements IParticleEmitterType {
	
	private var _particleSystem:ParticleSystem;

	public var direction1(get, set):Vector3;
	/**
	 * Random direction of each particle after it has been emitted, between direction1 and direction2 vectors.
	 */
	inline function get_direction1():Vector3 {
		return this._particleSystem.direction1;
	}
	/**
	 * Random direction of each particle after it has been emitted, between direction1 and direction2 vectors.
	 */
	inline function set_direction1(value:Vector3):Vector3 {
		return this._particleSystem.direction1 = value;
	}

	public var direction2(get, set):Vector3;
	/**
	 * Random direction of each particle after it has been emitted, between direction1 and direction2 vectors.
	 */
	inline function get_direction2():Vector3 {
		return this._particleSystem.direction2;
	}
	/**
	 * Random direction of each particle after it has been emitted, between direction1 and direction2 vectors.
	 */
	inline function set_direction2(value:Vector3):Vector3 {
		return this._particleSystem.direction2 = value;
	}

	public var minEmitBox(get, set):Vector3;
	/**
	 * Minimum box point around our emitter. Our emitter is the center of particles source, but if you want your particles to emit from more than one point, then you can tell it to do so.
	 */
	inline function get_minEmitBox():Vector3 {
		return this._particleSystem.minEmitBox;
	}
	/**
	 * Minimum box point around our emitter. Our emitter is the center of particles source, but if you want your particles to emit from more than one point, then you can tell it to do so.
	 */
	inline function set_minEmitBox(value:Vector3):Vector3 {
		return this._particleSystem.minEmitBox = value;
	}

	public var maxEmitBox(get, set):Vector3;
	/**
	 * Maximum box point around our emitter. Our emitter is the center of particles source, but if you want your particles to emit from more than one point, then you can tell it to do so.
	 */
	inline function get_maxEmitBox():Vector3 {
		return this._particleSystem.maxEmitBox;
	}
	/**
	 * Maximum box point around our emitter. Our emitter is the center of particles source, but if you want your particles to emit from more than one point, then you can tell it to do so.
	 */
	inline function set_maxEmitBox(value:Vector3):Vector3 {
		return this._particleSystem.maxEmitBox = value;
	}
	
	// to be updated like the rest of emitters when breaking changes.
	// all property should be come public variables and passed through constructor.
	/**
	 * Creates a new instance of @see BoxParticleEmitter
	 * @param _particleSystem the particle system associated with the emitter
	 */
	public function new(particleSystem:ParticleSystem) {
		this._particleSystem = particleSystem;
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
        var newOne = new BoxParticleEmitter(this._particleSystem);
		
		newOne.direction1 = this.direction1;
		newOne.direction2 = this.direction2;
		newOne.maxEmitBox = this.maxEmitBox;
		newOne.minEmitBox = this.minEmitBox;
		
        return newOne;
    }
	
}
