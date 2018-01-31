package com.babylonhx.particles;

import com.babylonhx.math.Scalar;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Particle emitter emitting particles from the inside of a sphere.
 * It emits the particles randomly between two vectors.
 */
class SphereDirectedParticleEmitter extends SphereParticleEmitter {
	
	/**
	 * The min limit of the emission direction.
	 */
	public var direction1:Vector3;
	/**
	 * The max limit of the emission direction.
	 */
	public var direction2:Vector3;
	

	/**
	 * Creates a new instance of @see SphereDirectedParticleEmitter
	 * @param radius the radius of the emission sphere
	 * @param direction1 the min limit of the emission direction
	 * @param direction2 the max limit of the emission direction
	 */
	public function new(radius:Float, direction1:Vector3, direction2:Vector3) {
		super(radius);
		this.direction1 = direction1;
		this.direction2 = direction2;
	}

	/**
	 * Called by the particle System when the direction is computed for the created particle.
	 * @param emitPower is the power of the particle (speed)
	 * @param worldMatrix is the world matrix of the particle system
	 * @param directionToUpdate is the direction vector to update with the result
	 * @param particle is the particle we are computed the direction for
	 */
	override public function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle) {
		var randX = Scalar.RandomRange(this.direction1.x, this.direction2.x);
		var randY = Scalar.RandomRange(this.direction1.y, this.direction2.y);
		var randZ = Scalar.RandomRange(this.direction1.z, this.direction2.z);
		Vector3.TransformNormalFromFloatsToRef(randX * emitPower, randY * emitPower, randZ * emitPower, worldMatrix, directionToUpdate);
	}
	
	/**
     * Clones the current emitter and returns a copy of it
     * @returns the new emitter
     */
    override public function clone():SphereDirectedParticleEmitter {
        var newOne = new SphereDirectedParticleEmitter(this.radius, this.direction1, this.direction2);
		
        return newOne;
    }
	
}
