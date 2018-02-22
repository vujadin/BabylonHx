package com.babylonhx.particles.emittertypes;

import com.babylonhx.math.Scalar;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Matrix;
import com.babylonhx.materials.Effect;

/**
 * ...
 * @author Krtolica Vujadin
 */
/**
 * Particle emitter emitting particles from the inside of a sphere.
 * It emits the particles alongside the sphere radius. The emission direction might be randomized.
 */
class SphereParticleEmitter implements IParticleEmitterType {
	
	/**
	 * The radius of the emission sphere.
	 */
	public var radius:Float;
	/**
	 * How much to randomize the particle direction [0-1].
	 */
	public var directionRandomizer:Float;
	

	/**
	 * Creates a new instance of @see SphereParticleEmitter
	 * @param radius the radius of the emission sphere
	 * @param directionRandomizer defines how much to randomize the particle direction [0-1]
	 */
	public function new(radius:Float = 1, directionRandomizer:Float = 0) {
		this.radius = radius;
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

	/**
	 * Called by the particle System when the position is computed for the created particle.
	 * @param worldMatrix is the world matrix of the particle system
	 * @param positionToUpdate is the position vector to update with the result
	 * @param particle is the particle we are computed the position for
	 */
	public function startPositionFunction(worldMatrix:Matrix, positionToUpdate:Vector3, particle:Particle) {
		var phi = Scalar.RandomRange(0, 2 * Math.PI);
		var theta = Scalar.RandomRange(0, Math.PI);
		var randRadius = Scalar.RandomRange(0, this.radius);
		var randX = randRadius * Math.cos(phi) * Math.sin(theta);
		var randY = randRadius * Math.cos(theta);
		var randZ = randRadius * Math.sin(phi) * Math.sin(theta);
		Vector3.TransformCoordinatesFromFloatsToRef(randX, randY, randZ, worldMatrix, positionToUpdate);
	}
	
	/**
     * Clones the current emitter and returns a copy of it
     * @returns the new emitter
     */
    public function clone():SphereParticleEmitter {
        var newOne = new SphereParticleEmitter(this.radius, this.directionRandomizer);
		
		//Tools.DeepCopy(this, newOne);
		
        return newOne;
    }
	
	/**
	 * Called by the {BABYLON.GPUParticleSystem} to setup the update shader
	 * @param effect defines the update shader
	 */        
	public function applyToShader(effect:Effect) {
		effect.setFloat("radius", this.radius);
		effect.setFloat("directionRandomizer", this.directionRandomizer);
	}    
	
	/**
	 * Returns a string to use to update the GPU particles update shader
	 * @returns a string containng the defines string
	 */
	public function getEffectDefines():String {
		return "#define SPHEREEMITTER";
	}   
	
	/**
	 * Returns the string "SphereParticleEmitter"
	 * @returns a string containing the class name
	 */
	public function getClassName():String {
		return "SphereParticleEmitter";
	}         
	
	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */        
	public function serialize():Dynamic {
		var serializationObject:Dynamic = { };
		serializationObject.type = this.getClassName();
		serializationObject.radius = this.radius;
		serializationObject.directionRandomizer = this.directionRandomizer;
		
		return serializationObject;
	}    
	
	/**
	 * Parse properties from a JSON object
	 * @param serializationObject defines the JSON object
	 */
	public function parse(serializationObject:Dynamic) {
		this.radius = serializationObject.radius;
		this.directionRandomizer = serializationObject.directionRandomizer;
	}
	
}
