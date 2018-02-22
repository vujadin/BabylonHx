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
	public function new(radius:Float = 1, ?direction1:Vector3, ?direction2:Vector3) {
		this.direction1 = direction1 != null ? direction1 : new Vector3(0, 1, 0);
		this.direction2 = direction2 != null ? direction2 : new Vector3(0, 1, 0);
		super(radius);
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
		
		//Tools.DeepCopy(this, newOne);
		
        return newOne;
    }
	
	/**
	 * Called by the {BABYLON.GPUParticleSystem} to setup the update shader
	 * @param effect defines the update shader
	 */        
	override public function applyToShader(effect:Effect) {
		effect.setFloat("radius", this.radius);
		effect.setVector3("direction1", this.direction1);
		effect.setVector3("direction2", this.direction2);
	}       
	
	/**
	 * Returns a string to use to update the GPU particles update shader
	 * @returns a string containng the defines string
	 */
	override public function getEffectDefines():String {
		return "#define SPHEREEMITTER\n#define DIRECTEDSPHEREEMITTER";
	}    
	
	/**
	 * Returns the string "SphereDirectedParticleEmitter"
	 * @returns a string containing the class name
	 */
	override public function getClassName():String {
		return "SphereDirectedParticleEmitter";
	}       
	
	/**
	 * Serializes the particle system to a JSON object.
	 * @returns the JSON object
	 */        
	override public function serialize():Dynamic {
		var serializationObject = super.serialize();
		
		serializationObject.direction1 = this.direction1.asArray();
		serializationObject.direction2 = this.direction2.asArray();
		
		return serializationObject;
	}    
	
	/**
	 * Parse properties from a JSON object
	 * @param serializationObject defines the JSON object
	 */
	override public function parse(serializationObject:Dynamic) {
		super.parse(serializationObject);
		this.direction1.copyFrom(serializationObject.direction1);
		this.direction2.copyFrom(serializationObject.direction2);
	}
	
}
