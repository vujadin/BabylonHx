package com.babylonhx.particles;

import com.babylonhx.math.Scalar;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Particle emitter emitting particles from the inside of a cone.
 * It emits the particles alongside the cone volume from the base to the particle. 
 * The emission direction might be randomized.
 */
class ConeParticleEmitter implements IParticleEmitterType {
	
	private var _radius:Float;
	private var _height:Float;	
	
	public var angle:Float;
	public var directionRandomizer:Float;

	/**
	 * Gets the radius of the emission cone.
	 */
	public var radius(get, set):Float;
	inline function get_radius():Float {
		return this._radius;
	}
	/**
	 * Sets the radius of the emission cone.
	 */
	inline function set_radius(value:Float):Float {
		this._radius = value;
		if (this.angle != 0) {
			this._height = value / Math.tan(this.angle / 2);
		}
		else {
			this._height = 1;
		}
		return value;
	}
	

	/**
	 * Creates a new instance of @see ConeParticleEmitter
	 * @param radius the radius of the emission cone
	 * @param angles the cone base angle
	 * @param directionRandomizer defines how much to randomize the particle direction [0-1]
	 */
	public function new(radius:Float, angle:Float, directionRandomizer:Float = 0) {
		this._radius = radius;
		this.angle = angle;
		this.directionRandomizer = directionRandomizer;
    }
 
	/**
	 * Called by the particle System when the direction is computed for the created particle.
	 * @param emitPower is the power of the particle (speed)
	 * @param worldMatrix is the world matrix of the particle system
	 * @param directionToUpdate is the direction vector to update with the result
	 * @param particle is the particle we are computed the direction for
	 */
    public function startDirectionFunction(emitPower:Float, worldMatrix:Matrix, directionToUpdate:Vector3, particle:Particle) {
        if (this.angle == 0) {
            Vector3.TransformNormalFromFloatsToRef(0, emitPower, 0, worldMatrix, directionToUpdate);
        }
        else {
            // measure the direction Vector from the emitter to the particle.
			var direction = particle.position.subtract(worldMatrix.getTranslation()).normalize();
			var randX = Scalar.RandomRange(0, this.directionRandomizer);
			var randY = Scalar.RandomRange(0, this.directionRandomizer);
			var randZ = Scalar.RandomRange(0, this.directionRandomizer);
			direction.x += randX;
			direction.y += randY;
			direction.z += randZ;
			direction.normalize();
			
			Vector3.TransformNormalFromFloatsToRef(direction.x * emitPower, direction.y * emitPower, direction.z * emitPower, worldMatrix, directionToUpdate);
        }
    }

	/**
	 * Called by the particle System when the position is computed for the created particle.
	 * @param worldMatrix is the world matrix of the particle system
	 * @param positionToUpdate is the position vector to update with the result
	 * @param particle is the particle we are computed the position for
	 */
    public function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle) {
        var s = Scalar.RandomRange(0, Math.PI * 2);
		var h = Scalar.RandomRange(0, 1);
		// Better distribution in a cone at normal angles.
		h = 1 - h * h;
		var radius = Scalar.RandomRange(0, this._radius);
		radius = radius * h / this._height;
		
		var randX = radius * Math.sin(s);
		var randZ = radius * Math.cos(s);
		var randY = h;
		
		Vector3.TransformCoordinatesFromFloatsToRef(randX, randY, randZ, worldMatrix, positionToUpdate);
    }
	
	/**
     * Clones the current emitter and returns a copy of it
     * @returns the new emitter
     */
    public function clone():ConeParticleEmitter {
        var newOne = new ConeParticleEmitter(this.radius, this.angle, this.directionRandomizer);
		
        return newOne;
    }
	
}
